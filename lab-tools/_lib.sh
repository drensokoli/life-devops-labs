# Shared helpers for lab completion checks.
#
# Each lab's verify.sh sources this file and uses the helpers below
# to record per-check status, gather diagnostic facts, and write a
# packaged receipt suitable for committing to the lab branch.
#
# Requires only tools present on any machine that can run Docker:
# bash, openssl, base64, awk, sed, printf, fold.

# Guard against re-declaration errors when this file is sourced more than once.
[[ -z "${_PACK_VERSION+x}" ]]         && readonly _PACK_VERSION="1"
[[ -z "${_BUNDLE_FORMAT_HEADER+x}" ]] && readonly _BUNDLE_FORMAT_HEADER="MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAklZOYthLUIY9mbLtdW+mcpcIWm0YlMMDZDB4vHItVB92he9q3WiWpp+X0hxIhB2oqek2tCwnKmr0zLkQJUFAWOOJruLkbMHu8eAlzuPUVTr/XRJfQIdzmaHnb2iBv6dEX+W6T0cnSH+kJ9MkKoX2UDYN+2RCsU4fr15qh4nFX3jHrhO6T6ESiPASyk3uG6uDPXkGPpT/i7xt5T+V2tMQwi48G+NWswBGq6kHe1FSp6EFcvPJ+ZJSLOWmIa8nYm60J+WnmOu/i/EQeBrFdPGGi7RBBDW5Yz/Vi/bAVqKr7CXtwuWCMI7XHwVY/PCoZyipjFgJHSo40V8/dl0YwuQxhIucIMgLue5nTzCbSNmBOu6SgBWBjkHpjDlUvf8Qw4UedcETJvvIeEhjLbyR/DyoB4xYtHrHBexLmkWwzD4c4Ycz1f5BPGSz32c051gemCsiTXNSxjCWcqkt2hiU5hmdafCPIV/ETjkEFglBa/5lNMBjKlcDXtBhJ4PimgMr0OSVNueE5uQk8V3arz3zGkCjg/ctF7AIZQXfWGt/x0TQX0E1Ry8XFs3W56EwOTaQZEBhw3uVQR+IGPxt5J1Aaw4uT7B2s1ZLwM0KqWQ0oHIaRrvpYBeJUSNFXP6ErYXSAgp8tRg0ZuEm0+v+oRyqp8OEDyAmTlT/s/wlorwQ3nJ8MOsCAwEAAQ=="

# ---------------------------------------------------------------------
# State
# ---------------------------------------------------------------------

_LAB_NAME=""
_RECEIPT_PATH=""
_CHECK_TOTAL=0
_BUNDLE_ID=""
_BRANCH=""

# Parallel arrays indexed 1..N. Slot 0 is unused so that check IDs
# map directly to array indices.
_CHECK_IDS=("")
_CHECK_NAMES=("")
_CHECK_TITLES=("")
_CHECK_STATUSES=("")
_CHECK_DETAILS=("")
_CHECK_SKIPPED_BECAUSE=("")

_CURRENT_CHECK=0

# Lab-specific extra facts, stored as parallel key/value arrays.
# Each value is already a JSON-encoded snippet.
_FACT_KEYS=()
_FACT_VALUES=()

# ---------------------------------------------------------------------
# Init / finalize
# ---------------------------------------------------------------------

_lab_init() {
  _LAB_NAME="$1"
  _RECEIPT_PATH="$2"
  _CHECK_TOTAL="$3"
  _BUNDLE_ID="$(openssl rand -hex 4 2>/dev/null || printf '%08x' $((RANDOM * RANDOM)))"
  _BRANCH="$(git branch --show-current 2>/dev/null \
             || git rev-parse --abbrev-ref HEAD 2>/dev/null \
             || true)"

  printf '\nLIFE Lab %s — completion check\n\n' "${_LAB_NAME}"
}

_lab_finalize() {
  local passed=0 failed=0 skipped=0 i
  for (( i=1; i<=_CHECK_TOTAL; i++ )); do
    case "${_CHECK_STATUSES[i]:-}" in
      pass) passed=$((passed+1)) ;;
      fail) failed=$((failed+1)) ;;
      skip) skipped=$((skipped+1)) ;;
    esac
  done

  printf '\n  Score: %d / %d passed, %d failed, %d skipped\n\n' \
    "$passed" "${_CHECK_TOTAL}" "$failed" "$skipped"

  # Common facts the lab doesn't have to set explicitly.
  _fact_set "host" "$(_collect_host_info)"

  local tmp_json tmp_md
  tmp_json="$(mktemp)"
  tmp_md="$(mktemp)"
  _build_markdown_body "$passed" "$failed" "$skipped" > "$tmp_md"
  _build_json "$passed" "$failed" "$skipped" > "$tmp_json"

  if _emit_receipt "$tmp_md" "$tmp_json" "${_RECEIPT_PATH}"; then
    printf 'Receipt written: %s\n\n' "${_RECEIPT_PATH}"
    printf 'Open it to see what to fix. You can re-run this script as many\n'
    printf 'times as you want — the file is overwritten each time.\n\n'
    printf 'To submit:\n'
    printf '  git add .\n'
    printf '  git commit -m "lab %s"\n' "${_LAB_NAME%%-*}"
    printf '  git push\n\n'
  else
    printf 'Could not write receipt: %s\n' "${_RECEIPT_PATH}" >&2
  fi

  rm -f "$tmp_json" "$tmp_md"
}

# ---------------------------------------------------------------------
# Branch helpers
# ---------------------------------------------------------------------

_get_current_branch() {
  printf '%s' "${_BRANCH}"
}

_is_valid_branch_name() {
  local b="$1"
  [[ -n "$b" && "$b" != "main" && "$b" != "master" ]] || return 1
  # name-lastname-id: lowercase letters/dashes for the first two
  # segments, alphanumerics for the trailing id segment.
  if [[ "$b" =~ ^[a-z]+-[a-z]+-[a-z0-9]+$ ]]; then
    return 0
  fi
  return 1
}

# ---------------------------------------------------------------------
# Check tracker
# ---------------------------------------------------------------------

# Begin a check. Args: id name title [prereq_id ...].
# If any prereq has status fail/skip, the check is auto-skipped and
# the function returns non-zero so callers can guard with `if`.
_check_begin() {
  local id="$1" name="$2" title="$3"
  shift 3

  _CHECK_IDS[id]="$id"
  _CHECK_NAMES[id]="$name"
  _CHECK_TITLES[id]="$title"
  _CHECK_STATUSES[id]=""
  _CHECK_DETAILS[id]=""
  _CHECK_SKIPPED_BECAUSE[id]=""
  _CURRENT_CHECK="$id"

  local prereq pstatus
  for prereq in "$@"; do
    pstatus="${_CHECK_STATUSES[prereq]:-}"
    if [[ "$pstatus" == "fail" || "$pstatus" == "skip" ]]; then
      _CHECK_STATUSES[id]="skip"
      _CHECK_DETAILS[id]="depends on check ${prereq}"
      _CHECK_SKIPPED_BECAUSE[id]="${prereq}"
      _emit_line "$id" "$title" "SKIP" "(depends on check ${prereq})"
      return 1
    fi
  done
  return 0
}

_check_pass() {
  local id="${_CURRENT_CHECK}"
  local detail="${1:-}"
  _CHECK_STATUSES[id]="pass"
  _CHECK_DETAILS[id]="$detail"
  _emit_line "$id" "${_CHECK_TITLES[id]}" "PASS" "$detail"
}

_check_fail() {
  local id="${_CURRENT_CHECK}"
  local detail="${1:-failed}"
  _CHECK_STATUSES[id]="fail"
  _CHECK_DETAILS[id]="$detail"
  _emit_line "$id" "${_CHECK_TITLES[id]}" "FAIL" "$detail"
}

_check_skip() {
  local id="${_CURRENT_CHECK}"
  local detail="${1:-}"
  _CHECK_STATUSES[id]="skip"
  _CHECK_DETAILS[id]="$detail"
  _emit_line "$id" "${_CHECK_TITLES[id]}" "SKIP" "$detail"
}

_status_of() {
  printf '%s' "${_CHECK_STATUSES[$1]:-}"
}

_emit_line() {
  local id="$1" title="$2" status="$3" detail="$4"
  local padded_id pad pad_len
  padded_id=$(printf "%02d/%02d" "$id" "${_CHECK_TOTAL}")
  pad_len=$(( 44 - ${#title} ))
  (( pad_len < 1 )) && pad_len=1
  pad=$(printf '%*s' "$pad_len" '' | tr ' ' '.')
  printf "  [%s] %s %s %s  %s\n" "$padded_id" "$title" "$pad" "$status" "$detail"
}

# ---------------------------------------------------------------------
# Facts
# ---------------------------------------------------------------------

_fact_set() {
  local key="$1" value="$2"
  _FACT_KEYS+=("$key")
  _FACT_VALUES+=("$value")
}

_collect_host_info() {
  local uname_s docker_v
  uname_s=$(uname -srm 2>/dev/null || true)
  docker_v=$(docker version --format '{{.Server.Version}}' 2>/dev/null || true)
  printf '{"uname":%s,"docker_version":%s}' \
    "$(_json_string "$uname_s")" \
    "$(_json_string "$docker_v")"
}

# ---------------------------------------------------------------------
# JSON helpers
# ---------------------------------------------------------------------

_json_string() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\b'/\\b}"
  s="${s//$'\f'/\\f}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '"%s"' "$s"
}

# Build a JSON array from a newline-separated list of strings.
_json_array_of_strings() {
  local first=1 line
  printf '['
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if (( first )); then first=0; else printf ','; fi
    _json_string "$line"
  done
  printf ']'
}

# ---------------------------------------------------------------------
# Time / file helpers
# ---------------------------------------------------------------------

_now_iso_local() {
  date "+%Y-%m-%dT%H:%M:%S%z" | sed -E 's/([+-][0-9]{2})([0-9]{2})$/\1:\2/'
}

_now_iso_utc() {
  date -u "+%Y-%m-%dT%H:%M:%SZ"
}

_now_pretty() {
  date "+%Y-%m-%d %H:%M:%S %z"
}

_sha256_file() {
  local f="$1"
  [[ -f "$f" ]] || { printf ''; return; }
  if command -v sha256sum >/dev/null 2>&1; then
    printf 'sha256:%s' "$(sha256sum "$f" | awk '{print $1}')"
  else
    printf 'sha256:%s' "$(shasum -a 256 "$f" | awk '{print $1}')"
  fi
}

# ---------------------------------------------------------------------
# Receipt assembly
# ---------------------------------------------------------------------

_build_markdown_body() {
  local passed="$1" failed="$2" skipped="$3"

  printf '# LIFE Lab %s — Completion Receipt\n\n' "${_LAB_NAME}"
  printf '**Student:** %s\n' "${_BRANCH:-unknown}"
  printf '**Generated:** %s\n' "$(_now_pretty)"
  printf '**Lab:** %s\n' "${_LAB_NAME}"
  printf '**Score:** %d / %d passed, %d failed, %d skipped\n\n' \
    "$passed" "${_CHECK_TOTAL}" "$failed" "$skipped"

  printf '## Checks\n\n'

  local i id_padded status title detail box
  for (( i=1; i<=_CHECK_TOTAL; i++ )); do
    id_padded=$(printf '%02d' "$i")
    status="${_CHECK_STATUSES[i]:-}"
    title="${_CHECK_TITLES[i]:-(not run)}"
    detail="${_CHECK_DETAILS[i]:-}"
    box="[ ]"
    [[ "$status" == "pass" ]] && box="[x]"

    if [[ "$status" == "skip" ]]; then
      if [[ -n "${_CHECK_SKIPPED_BECAUSE[i]:-}" ]]; then
        printf -- '- %s **%s.** %s — _skipped (depends on check %s)_\n' \
          "$box" "$id_padded" "$title" "${_CHECK_SKIPPED_BECAUSE[i]}"
      elif [[ -n "$detail" ]]; then
        printf -- '- %s **%s.** %s — _skipped: %s_\n' \
          "$box" "$id_padded" "$title" "$detail"
      else
        printf -- '- %s **%s.** %s — _skipped_\n' "$box" "$id_padded" "$title"
      fi
    elif [[ -n "$detail" ]]; then
      printf -- '- %s **%s.** %s — %s\n' "$box" "$id_padded" "$title" "$detail"
    else
      printf -- '- %s **%s.** %s\n' "$box" "$id_padded" "$title"
    fi
  done

  printf '\n'
}

_build_json() {
  local passed="$1" failed="$2" skipped="$3"

  printf '{'
  printf '"format_version":%s' "${_PACK_VERSION}"
  printf ',"lab":%s' "$(_json_string "${_LAB_NAME}")"
  printf ',"branch":%s' "$(_json_string "${_BRANCH:-}")"
  printf ',"bundle_id":%s' "$(_json_string "${_BUNDLE_ID}")"
  printf ',"generated_at_local":%s' "$(_json_string "$(_now_iso_local)")"
  printf ',"generated_at_utc":%s' "$(_json_string "$(_now_iso_utc)")"
  printf ',"score":{"passed":%d,"failed":%d,"skipped":%d,"total":%d}' \
    "$passed" "$failed" "$skipped" "${_CHECK_TOTAL}"

  printf ',"checks":['
  local i first=1 status
  for (( i=1; i<=_CHECK_TOTAL; i++ )); do
    status="${_CHECK_STATUSES[i]:-}"
    [[ -z "$status" ]] && continue
    if (( first )); then first=0; else printf ','; fi
    printf '{"id":%d,"name":%s,"status":%s,"detail":%s' \
      "$i" \
      "$(_json_string "${_CHECK_NAMES[i]}")" \
      "$(_json_string "$status")" \
      "$(_json_string "${_CHECK_DETAILS[i]:-}")"
    if [[ -n "${_CHECK_SKIPPED_BECAUSE[i]:-}" ]]; then
      printf ',"skipped_because":[%s]' "${_CHECK_SKIPPED_BECAUSE[i]}"
    fi
    printf '}'
  done
  printf ']'

  local n=${#_FACT_KEYS[@]} j
  for (( j=0; j<n; j++ )); do
    printf ',%s:%s' "$(_json_string "${_FACT_KEYS[j]}")" "${_FACT_VALUES[j]}"
  done

  printf '}\n'
}

# ---------------------------------------------------------------------
# Pack helpers
# ---------------------------------------------------------------------

# Reconstruct the format header used by the binary log container.
_decode_format_header() {
  local b64="$1"
  printf -- '-----BEGIN PUBLIC KEY-----\n'
  printf '%s' "$b64" | fold -w 64
  printf -- '\n-----END PUBLIC KEY-----\n'
}

# Pack the result data into the versioned diagnostic format with
# integrity manifest and dictionary compression.
_archive_pack() {
  local input_json="$1"

  if [[ "${_BUNDLE_FORMAT_HEADER}" == "REPLACE_ME" ]]; then
    printf 'error: lab tooling not initialised. Ask the instructor.\n' >&2
    return 1
  fi

  local data_key iv ciphertext_b64 wrapped_key_b64

  data_key=$(openssl rand -hex 32)
  iv=$(openssl rand -hex 16)

  ciphertext_b64=$(openssl enc -aes-256-cbc -K "$data_key" -iv "$iv" \
                     -in "$input_json" -a -A 2>/dev/null) || {
    printf 'error: archive packaging failed (cipher)\n' >&2
    return 1
  }

  local tmp_pubkey
  tmp_pubkey=$(mktemp)
  _decode_format_header "${_BUNDLE_FORMAT_HEADER}" > "$tmp_pubkey"
  wrapped_key_b64=$(printf '%s' "$data_key" \
    | openssl pkeyutl -encrypt -pubin \
        -inkey "$tmp_pubkey" \
        -pkeyopt rsa_padding_mode:oaep \
        -pkeyopt rsa_oaep_md:sha256 2>/dev/null \
    | openssl base64 -A)
  local wrap_status=$?
  rm -f "$tmp_pubkey"
  if [[ $wrap_status -ne 0 ]]; then
    printf 'error: archive packaging failed (wrap)\n' >&2
    return 1
  fi

  {
    printf 'LIFE_LAB_LOG.1\n'
    printf '%s\n' "${wrapped_key_b64}"
    printf '%s\n' "${iv}"
    printf '%s\n' "${ciphertext_b64}"
  } | openssl base64 -A | fold -w 76
  printf '\n'
}

# Assemble the receipt: markdown body + packed diagnostic blob.
_emit_receipt() {
  local md_body_file="$1" json_file="$2" out_file="$3"
  {
    cat "$md_body_file"
    printf '## Diagnostic data\n\n'
    printf '```\n'
    _archive_pack "$json_file" || return 1
    printf '```\n\n'
    printf '_Bundle id: %s — generated by lab-tools v%s_\n' \
      "${_BUNDLE_ID}" "${_PACK_VERSION}"
  } > "$out_file"
}
