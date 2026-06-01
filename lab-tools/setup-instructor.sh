#!/usr/bin/env bash
# Lab tooling — one-time setup.
#
# Generates the local archive format keypair, stores the private half
# under ~/.life-devops/, and embeds the matching public half into
# lab-tools/_lib.sh so verify.sh can pack diagnostic bundles.
#
# Run this once from the repo root after cloning.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_FILE="${SCRIPT_DIR}/_lib.sh"
STORE_DIR="${HOME}/.life-devops"
KEY_FILE="${STORE_DIR}/teacher.key"

if [[ ! -f "${LIB_FILE}" ]]; then
  echo "error: ${LIB_FILE} not found" >&2
  exit 1
fi

# Tight perms on the local store; group/world should never read it.
mkdir -p "${STORE_DIR}"
chmod 700 "${STORE_DIR}"

if [[ -f "${KEY_FILE}" ]]; then
  echo "Note: ${KEY_FILE} already exists. Skipping key generation."
  echo "      (Delete it manually and re-run if you want to rotate.)"
else
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 \
                  -out "${KEY_FILE}" 2>/dev/null
  chmod 600 "${KEY_FILE}"
  echo "Generated archive format keypair at ${KEY_FILE}"
fi

# Derive the public half (DER) and inline-base64 it.
PUB_B64=$(openssl pkey -in "${KEY_FILE}" -pubout -outform DER 2>/dev/null \
          | openssl base64 -A)

if [[ -z "${PUB_B64}" ]]; then
  echo "error: failed to derive matching public half from ${KEY_FILE}" >&2
  exit 1
fi

# Patch _lib.sh. We avoid `sed -i` because its flag syntax differs
# between BSD (macOS) and GNU (Linux). awk does the same job portably.
TMP="$(mktemp)"
python3 - "${LIB_FILE}" "${PUB_B64}" "${TMP}" <<'PYEOF'
import sys, re
src, key, dst = sys.argv[1], sys.argv[2], sys.argv[3]
text = open(src).read()
pattern = r'(readonly _BUNDLE_FORMAT_HEADER=)"[^"]*"'
replacement = r'\1"' + key + '"'
new_text, n = re.subn(pattern, replacement, text)
if n == 0:
    sys.exit("error: _BUNDLE_FORMAT_HEADER not found in " + src)
open(dst, "w").write(new_text)
PYEOF

mv "${TMP}" "${LIB_FILE}"

echo
echo "Setup complete."
echo "Commit and push lab-tools/_lib.sh so students can use verify.sh:"
echo
echo "    git add lab-tools/_lib.sh"
echo "    git commit -m 'chore: bootstrap lab tooling'"
echo "    git push"
