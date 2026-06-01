#!/usr/bin/env bash
# Lab grading & decryption (instructor only).
#
# Iterates every student branch in the local + remote refs, extracts
# the receipt file for the chosen lab, decrypts the diagnostic blob
# with ~/.life-devops/teacher.key, and produces:
#
#   grading-<lab>.md             — scoreboard + collusion flags + notes
#   grading-<lab>/<branch>.json  — decrypted JSON per student (for digging in)
#   grading-<lab>/<branch>.md    — copy of the original receipt markdown
#
# Usage:
#   cd <repo-root>
#   lab-tools/decrypt-submissions.sh 09
#
# Requirements: bash, git, openssl, python3.

set -u

LAB="${1:-}"
if [[ -z "$LAB" ]]; then
  echo "usage: $0 <lab-number>  (e.g. 09)" >&2
  exit 1
fi

# Accept either a plain lab number ("09", "9") or a full branch name
# ("john-doe-1234567") — in the latter case, extract the receipt based
# on the lab directory rather than a student branch argument.
#
# Supported call modes:
#   decrypt-submissions.sh 09               → grade all student branches for lab 09
#   decrypt-submissions.sh john-doe-1234567 → not the intended usage; see below
#
# If the argument looks like a branch name (contains letters + dashes, not
# purely numeric), treat it as a lab number of "09" for backward compat and
# warn the user.
if [[ "$LAB" =~ ^[0-9]+$ ]]; then
  LAB_TWO_DIGIT=$(printf '%02d' "$((10#${LAB}))")
else
  echo "error: '${LAB}' looks like a branch name, not a lab number." >&2
  echo "       Usage: $0 09" >&2
  echo "       This grades ALL student branches for lab 09." >&2
  exit 1
fi

PRIV="${HOME}/.life-devops/teacher.key"
if [[ ! -f "$PRIV" ]]; then
  echo "error: ${PRIV} not found." >&2
  echo "       Run lab-tools/setup-instructor.sh first." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 not found. Install python3 to run the grader." >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [[ -z "$REPO_ROOT" ]]; then
  echo "error: not inside a git repository" >&2
  exit 1
fi
cd "$REPO_ROOT"

# Where the receipt lives inside a student branch, for each lab.
RECEIPT_PATH=""
case "$LAB_TWO_DIGIT" in
  06) RECEIPT_PATH="02-kubernetes/06-k8s-homework/lab-06-receipt.md" ;;
  07) RECEIPT_PATH="03-iac-cloud/07-iac-homework/lab-07-receipt.md" ;;
  09) RECEIPT_PATH="01-containers/09-compose-homework/lab-09-receipt.md" ;;
  *)
    echo "error: unknown lab '${LAB_TWO_DIGIT}'. Add it to the case in this script." >&2
    exit 1
    ;;
esac

OUT_DIR="grading-${LAB_TWO_DIGIT}"
OUT_MD="grading-${LAB_TWO_DIGIT}.md"
mkdir -p "${OUT_DIR}"

echo "Fetching latest branches..."
git fetch --all --quiet 2>/dev/null || true

# Branches that match name-lastname-id, from local and remote refs.
# Use a while-read loop instead of mapfile for bash 3.2 (macOS) compat.
BRANCHES=()
while IFS= read -r _branch; do
  BRANCHES+=("$_branch")
done < <(
  {
    git branch --format='%(refname:short)' 2>/dev/null || true
    git branch -r --format='%(refname:short)' 2>/dev/null \
      | sed 's|^[^/]*/||' || true
  } \
    | grep -E '^[a-z]+-[a-z]+-[a-z0-9]+$' \
    | sort -u
)

if (( ${#BRANCHES[@]} == 0 )); then
  echo "no student branches found matching name-lastname-id" >&2
  exit 0
fi

echo "Found ${#BRANCHES[@]} student branch(es) — processing..."

# Resolve a branch name to a usable git ref (local or remote).
resolve_ref() {
  local b="$1"
  if git rev-parse --verify --quiet "refs/heads/$b" >/dev/null 2>&1; then
    printf 'refs/heads/%s' "$b"
    return
  fi
  local remote_ref
  remote_ref=$(git for-each-ref --format='%(refname:short)' "refs/remotes/*/$b" 2>/dev/null | head -1)
  [[ -n "$remote_ref" ]] && printf '%s' "$remote_ref"
}

# Decrypt a single receipt.md file. Writes the JSON to stdout.
# Exit codes:
#   0 = success
#   1 = could not extract a base64 blob
#   2 = bad magic header
#   3 = malformed envelope
#   4 = RSA unwrap failed (wrong key?)
#   5 = AES decrypt failed
decrypt_receipt() {
  local receipt="$1"

  local outer
  outer=$(awk '
    BEGIN { in_sec=0; in_block=0 }
    /^## Diagnostic data[[:space:]]*$/ { in_sec=1; next }
    in_sec && /^```[[:space:]]*$/ {
      if (in_block) exit
      in_block=1; next
    }
    in_sec && in_block { print }
  ' "$receipt" | tr -d '\r' | tr -d '\n')
  [[ -z "$outer" ]] && return 1

  local inner
  inner=$(printf '%s' "$outer" | openssl base64 -d -A 2>/dev/null) || return 1

  local header wrapped_key_b64 iv ciphertext_b64
  header=$(printf '%s\n' "$inner" | sed -n '1p')
  wrapped_key_b64=$(printf '%s\n' "$inner" | sed -n '2p')
  iv=$(printf '%s\n' "$inner" | sed -n '3p')
  ciphertext_b64=$(printf '%s\n' "$inner" | sed -n '4p')

  [[ "$header" =~ ^LIFE_LAB_LOG ]] || return 2
  [[ -z "$wrapped_key_b64" || -z "$iv" || -z "$ciphertext_b64" ]] && return 3

  local data_key
  data_key=$(printf '%s' "$wrapped_key_b64" \
    | openssl base64 -d -A 2>/dev/null \
    | openssl pkeyutl -decrypt -inkey "$PRIV" \
        -pkeyopt rsa_padding_mode:oaep \
        -pkeyopt rsa_oaep_md:sha256 2>/dev/null) || return 4

  printf '%s' "$ciphertext_b64" \
    | openssl enc -aes-256-cbc -d -K "$data_key" -iv "$iv" -a -A 2>/dev/null \
    || return 5
}

# Per-branch status table (for the markdown report).
SUMMARY_FILE="${OUT_DIR}/_summary.tsv"
META_FILE="${OUT_DIR}/_meta.json"
: > "$SUMMARY_FILE"

# Record main tip so Python can detect branches not forked from main.
MAIN_TIP=$(git rev-parse --short=12 refs/heads/main 2>/dev/null \
           || git rev-parse --short=12 refs/remotes/origin/main 2>/dev/null \
           || true)
printf '{"main_tip":"%s"}\n' "${MAIN_TIP}" > "${META_FILE}"

# For each student branch collect two things:
#   1. Its merge-base with main (fork point SHA, short 12)
#   2. Whether any OTHER student branch is an ancestor of it
# Written as a JSON object: { "branch": { "fork_sha": "...", "forked_from": "..." } }
# "forked_from" is either "main" or the name of the student branch it was forked from.
FORK_POINTS_FILE="${OUT_DIR}/_fork_points.json"
MAIN_REF=""
git rev-parse --verify --quiet refs/heads/main >/dev/null 2>&1 && MAIN_REF="refs/heads/main"
[[ -z "$MAIN_REF" ]] && MAIN_REF="refs/remotes/origin/main"

# Collect every branch's tip SHA into a temp file: one "branch<TAB>sha" per line.
# (Bash 3.2-safe alternative to declare -A)
_SHA_FILE="${OUT_DIR}/_branch_shas.tsv"
: > "${_SHA_FILE}"
for branch in "${BRANCHES[@]}"; do
  ref="$(resolve_ref "$branch")"
  [[ -z "$ref" ]] && continue
  sha=$(git rev-parse "$ref" 2>/dev/null || true)
  [[ -n "$sha" ]] && printf '%s\t%s\n' "$branch" "$sha" >> "${_SHA_FILE}"
done

_sha_of() {
  grep -m1 "^${1}	" "${_SHA_FILE}" | cut -f2 || true
}

printf '{' > "${FORK_POINTS_FILE}"
_fp_first=1
for branch in "${BRANCHES[@]}"; do
  ref="$(resolve_ref "$branch")"
  [[ -z "$ref" ]] && continue

  fp=$(git merge-base "$ref" "${MAIN_REF}" 2>/dev/null | cut -c1-12 || true)

  # Check if any other student branch's tip is an ancestor of this branch.
  forked_from="main"
  for other in "${BRANCHES[@]}"; do
    [[ "$other" == "$branch" ]] && continue
    other_sha="$(_sha_of "$other")"
    [[ -z "$other_sha" ]] && continue
    if git merge-base --is-ancestor "$other_sha" "$(resolve_ref "$branch")" 2>/dev/null; then
      forked_from="$other"
      break
    fi
  done

  if (( _fp_first )); then _fp_first=0; else printf ',' >> "${FORK_POINTS_FILE}"; fi
  printf '"%s":{"fork_sha":"%s","forked_from":"%s"}' \
    "$branch" "$fp" "$forked_from" >> "${FORK_POINTS_FILE}"
done
printf '}\n' >> "${FORK_POINTS_FILE}"
rm -f "${_SHA_FILE}"

for branch in "${BRANCHES[@]}"; do
  ref="$(resolve_ref "$branch")"
  if [[ -z "$ref" ]]; then
    printf '%s\tno_ref\tcould not resolve branch\n' "$branch" >> "$SUMMARY_FILE"
    echo "  [${branch}] no ref found"
    continue
  fi

  receipt_tmp="${OUT_DIR}/${branch}.md"
  if ! git show "${ref}:${RECEIPT_PATH}" > "$receipt_tmp" 2>/dev/null; then
    printf '%s\tno_receipt\treceipt not committed\n' "$branch" >> "$SUMMARY_FILE"
    echo "  [${branch}] no receipt at ${RECEIPT_PATH}"
    rm -f "$receipt_tmp"
    continue
  fi

  json_tmp="${OUT_DIR}/${branch}.json"
  if decrypt_receipt "$receipt_tmp" > "$json_tmp" 2>/dev/null; then
    if ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$json_tmp" 2>/dev/null; then
      printf '%s\tbad_json\tdecrypted but JSON malformed\n' "$branch" >> "$SUMMARY_FILE"
      echo "  [${branch}] decrypted but not valid JSON"
    else
      printf '%s\tok\t\n' "$branch" >> "$SUMMARY_FILE"
      echo "  [${branch}] OK"
    fi
  else
    rc=$?
    printf '%s\tdecrypt_failed_rc%d\tcould not decrypt (forged or corrupted blob?)\n' \
      "$branch" "$rc" >> "$SUMMARY_FILE"
    echo "  [${branch}] decrypt failed (rc=${rc})"
    rm -f "$json_tmp"
  fi
done

# ---------------------------------------------------------------------
# Build the markdown report
# ---------------------------------------------------------------------

REPORT_TS="$(date '+%Y-%m-%d %H:%M:%S %z')"

python3 - "$LAB_TWO_DIGIT" "$OUT_DIR" "$SUMMARY_FILE" "$OUT_MD" "$REPORT_TS" \
          "${FORK_POINTS_FILE}" "${META_FILE}" <<'PY'
import json, os, sys
from collections import defaultdict
from datetime import datetime

lab, out_dir, summary_tsv, out_md, report_ts, fork_points_file, meta_file = sys.argv[1:8]

# Load TSV: branch \t status \t note
rows = []
with open(summary_tsv) as f:
    for line in f:
        parts = line.rstrip('\n').split('\t')
        while len(parts) < 3:
            parts.append('')
        rows.append({"branch": parts[0], "status": parts[1], "note": parts[2]})

# Load per-branch JSONs where decryption succeeded.
data_by_branch = {}
for r in rows:
    if r["status"] == "ok":
        path = os.path.join(out_dir, r["branch"] + ".json")
        try:
            with open(path) as f:
                data_by_branch[r["branch"]] = json.load(f)
        except Exception as e:
            r["status"] = "load_failed"
            r["note"] = str(e)

# --- Collusion buckets ---
def bucket_by(field_path):
    """field_path is a dotted path like 'backend_image_id' or 'host.docker_version'."""
    out = defaultdict(list)
    for br, d in data_by_branch.items():
        cur = d
        for p in field_path.split('.'):
            if isinstance(cur, dict) and p in cur:
                cur = cur[p]
            else:
                cur = None
                break
        if cur is None or cur == "" or cur == "unknown":
            continue
        out[cur].append(br)
    return {k: v for k, v in out.items() if len(v) > 1}

groups = {
    "Identical backend Dockerfile (sha256)": bucket_by("backend_dockerfile_sha256"),
    "Identical frontend Dockerfile (sha256)": bucket_by("frontend_dockerfile_sha256"),
    "Identical docker-compose.yml (sha256)": bucket_by("compose_sha256"),
    "Identical nginx.conf (sha256)": bucket_by("nginx_conf_sha256"),
    "Identical backend image id (impossible without sharing)": bucket_by("backend_image_id"),
    "Identical frontend image id (impossible without sharing)": bucket_by("frontend_image_id"),
}

# --- Check 1: branch name in encrypted JSON matches the git branch it was committed on ---
branch_mismatch = {}
for br, d in data_by_branch.items():
    encrypted_branch = d.get("branch", "")
    if encrypted_branch != br:
        branch_mismatch[br] = encrypted_branch

# --- Check 2: branch forked from another student branch instead of main ---
# fork_points: { branch: { fork_sha, forked_from } }
# "forked_from" is "main" or the name of the student branch it descended from.
try:
    fork_points = json.load(open(fork_points_file))
except Exception:
    fork_points = {}

bad_fork = {}   # branch -> forked_from string
for br, info in fork_points.items():
    forked_from = info.get("forked_from", "main")
    if forked_from != "main":
        bad_fork[br] = forked_from

# --- Suspicious URL list ---
def looks_fake(urls):
    if not urls:
        return False
    junk_count = 0
    for u in urls:
        if not isinstance(u, str): continue
        u_clean = u.strip().lower()
        if not u_clean: continue
        if len(u_clean) <= 5:
            junk_count += 1
        elif any(token in u_clean for token in ["test1", "test2", "test3", "asdf", "qwer", "aaa", "bbb", "abc", "foo", "bar"]):
            junk_count += 1
    return junk_count >= 2

suspicious_urls = {}
for br, d in data_by_branch.items():
    sample = d.get("user_urls_sample") or []
    if looks_fake(sample):
        suspicious_urls[br] = sample

# --- Build markdown ---
def line(s=""):
    out.append(s)

out = []
line(f"# LIFE Lab {lab} — grading report")
line()
line(f"_Generated: {report_ts}_")
line()
line(f"- Total submissions found: **{len(rows)}**")
line(f"- Successfully decrypted: **{len(data_by_branch)}**")
line(f"- Missing / failed: **{len(rows) - len(data_by_branch)}**")
line()

# --- Scoreboard ---
line("## Scoreboard")
line()
line("| Branch | Score | Failed checks | Notes |")
line("|--------|-------|---------------|-------|")

# Sort: ok first by score desc, then problems
def sort_key(r):
    br = r["branch"]
    if r["status"] != "ok" or br not in data_by_branch:
        return (1, br)
    sc = data_by_branch[br].get("score", {})
    return (0, -(sc.get("passed", 0)), br)

rows.sort(key=sort_key)

for r in rows:
    br = r["branch"]
    if r["status"] == "ok" and br in data_by_branch:
        d = data_by_branch[br]
        sc = d.get("score", {})
        passed = sc.get("passed", 0)
        total = sc.get("total", 24)
        failed_names = [c.get("name", "?") for c in d.get("checks", []) if c.get("status") == "fail"]
        failed_str = ", ".join(failed_names) if failed_names else "—"
        if len(failed_str) > 60:
            failed_str = failed_str[:57] + "..."
        notes = []
        if br in suspicious_urls:
            notes.append("⚠ fake-looking URLs")
        if br in branch_mismatch:
            notes.append("⚠ receipt mismatch")
        if br in bad_fork:
            notes.append(f"⚠ forked from {bad_fork[br]}")
        notes_str = "; ".join(notes) if notes else ""
        line(f"| `{br}` | **{passed}/{total}** | {failed_str} | {notes_str} |")
    else:
        line(f"| `{br}` | — | (no data) | {r['status']}: {r['note']} |")

line()

# --- Branch name mismatch (submitted someone else's receipt) ---
if branch_mismatch:
    line("## ⚠ Branch name mismatch (possible receipt swap)")
    line()
    line("The branch name on the git commit **does not match** the branch name")
    line("recorded inside the encrypted blob. This means the student either:")
    line("- submitted a receipt generated on a different branch, or")
    line("- copied another student's `lab-09-receipt.md` file.")
    line()
    line("| Git branch | Branch in encrypted data |")
    line("|------------|--------------------------|")
    for br, enc_br in sorted(branch_mismatch.items()):
        line(f"| `{br}` | `{enc_br}` |")
    line()

# --- Branch forked from another student branch ---
if bad_fork:
    line("## ⚠ Branch not forked from main")
    line()
    line("These students created their branch from another student's branch")
    line("instead of from `main`. This is a strong indicator of copied work.")
    line()
    for br, forked_from in sorted(bad_fork.items()):
        line(f"- `{br}` — forked from `{forked_from}`")
    line()

# --- Collusion flags ---
flagged = any(g for g in groups.values())
if flagged:
    line("## ⚠ Collusion flags")
    line()
    line("Submissions sharing the same artifact fingerprint are listed below. ")
    line("Two students producing identical Dockerfile bytes or identical built")
    line("image digests almost always means they shared work (a digest can only")
    line("match if the build context is byte-identical AND was built in the")
    line("same Docker daemon, which is rare without explicit `docker save`).")
    line()
    for label, buckets in groups.items():
        if not buckets:
            continue
        line(f"### {label}")
        line()
        for fingerprint, branches_in_group in buckets.items():
            short_fp = (fingerprint[:24] + "…") if len(fingerprint) > 24 else fingerprint
            line(f"- `{short_fp}` → " + ", ".join(f"`{b}`" for b in sorted(branches_in_group)))
        line()

# --- Suspicious URL submissions ---
if suspicious_urls:
    line("## ⚠ Submissions with fake-looking shortened URLs")
    line()
    for br, urls in sorted(suspicious_urls.items()):
        line(f"### `{br}`")
        line()
        line("```")
        for u in urls[:10]:
            line(str(u))
        line("```")
        line()

# --- Per-student detail (one section each, ok branches only) ---
line("## Per-submission detail")
line()
for r in rows:
    br = r["branch"]
    if r["status"] != "ok" or br not in data_by_branch:
        line(f"### `{br}` — {r['status']}")
        line()
        line(f"> {r['note']}")
        line()
        continue
    d = data_by_branch[br]
    sc = d.get("score", {})
    line(f"### `{br}` — {sc.get('passed', 0)}/{sc.get('total', 24)}")
    line()
    line(f"- generated_at_utc: `{d.get('generated_at_utc', '?')}`")
    line(f"- bundle_id: `{d.get('bundle_id', '?')}`")
    line(f"- branch in receipt: `{d.get('branch', '?')}`" + (" ⚠ **MISMATCH**" if br in branch_mismatch else ""))
    host = d.get("host", {}) or {}
    line(f"- host: `{host.get('uname', '?')}`")
    line(f"- docker_version: `{host.get('docker_version', '?')}`")
    fp_info = fork_points.get(br, {})
    if fp_info:
        forked_from = fp_info.get("forked_from", "main")
        fork_flag = f" ⚠ **forked from `{forked_from}`**" if forked_from != "main" else ""
        line(f"- branched from: `{forked_from}`" + fork_flag)
    if d.get("backend_image_id"):
        line(f"- backend image: `{d['backend_image_id'][:24]}…` ({(d.get('backend_image_size') or 0)//1024//1024} MB)")
    if d.get("frontend_image_id"):
        line(f"- frontend image: `{d['frontend_image_id'][:24]}…` ({(d.get('frontend_image_size') or 0)//1024//1024} MB)")
    line()
    line("**Checks:**")
    line()
    for c in d.get("checks", []):
        s = c.get("status", "?")
        emoji = {"pass": "✅", "fail": "❌", "skip": "⏭"}.get(s, "•")
        detail = c.get("detail") or ""
        if detail:
            line(f"- {emoji} {c.get('name')} — {detail}")
        else:
            line(f"- {emoji} {c.get('name')}")
    line()

with open(out_md, "w") as f:
    f.write("\n".join(out) + "\n")

print(f"Wrote {out_md}")
PY

# Clean up internal scratch files.
rm -f "${SUMMARY_FILE}" "${META_FILE}" "${FORK_POINTS_FILE}"

echo
echo "Done. Open ${OUT_MD} for the report; raw decrypted JSON is in ${OUT_DIR}/."
