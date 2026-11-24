#!/usr/bin/env bash
# Verify a Gentoo Stage 3 archive before any extraction or privileged install.
# The expected fingerprint must be checked independently against Gentoo's
# official release-signature information.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  verify-stage3.sh STAGE3_TARBALL STAGE3_TARBALL.DIGESTS.asc TRUSTED_GENTOO_KEYRING EXPECTED_FINGERPRINT

Verifies the signed Gentoo DIGESTS file with gpgv, pins the signing or primary
key fingerprint, then checks the SHA-512 digest for the exact tarball.
This script does not download, extract, or install anything.
EOF
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
    usage
    exit 0
fi
if [[ $# -ne 4 ]]; then
    usage >&2
    exit 2
fi

tarball=$1
digests=$2
keyring=$3
expected_fingerprint=${4//[[:space:]]/}
expected_fingerprint=${expected_fingerprint^^}

if [[ ! "$expected_fingerprint" =~ ^([0-9A-F]{40}|[0-9A-F]{64})$ ]]; then
    printf 'Expected fingerprint must be 40 or 64 hexadecimal characters.\n' >&2
    exit 2
fi

for command_name in gpgv sha512sum awk grep; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$command_name" >&2
        exit 127
    fi
done

for input_file in "$tarball" "$digests" "$keyring"; do
    if [[ ! -f "$input_file" || ! -s "$input_file" ]]; then
        printf 'Input file is missing, not regular, or empty: %s\n' "$input_file" >&2
        exit 2
    fi
done

tar_dir=$(cd -- "$(dirname -- "$tarball")" && pwd -P)
digest_dir=$(cd -- "$(dirname -- "$digests")" && pwd -P)
keyring_dir=$(cd -- "$(dirname -- "$keyring")" && pwd -P)
digest_path="$digest_dir/$(basename -- "$digests")"
keyring_path="$keyring_dir/$(basename -- "$keyring")"
tar_name=$(basename -- "$tarball")

printf 'Verifying Gentoo release signature and key fingerprint...\n'
signature_status=$(gpgv --status-fd 1 --keyring "$keyring_path" "$digest_path")
valid_fingerprint=$(
    printf '%s\n' "$signature_status" |
        awk '$1 == "[GNUPG:]" && $2 == "VALIDSIG" {
            print toupper($3)
            if (NF >= 12 && $12 ~ /^[[:xdigit:]]+$/) print toupper($12)
        }'
)
if ! printf '%s\n' "$valid_fingerprint" | grep -Fxq "$expected_fingerprint"; then
    printf 'Signature is valid, but its signing/primary fingerprint does not match the expected fingerprint.\n' >&2
    exit 1
fi

printf 'Locating SHA-512 digest for %s...\n' "$tar_name"
digest_line=$(
    awk -v target="$tar_name" '
        /^# SHA512 HASH/ { in_sha512 = 1; next }
        /^#/ { if (in_sha512) in_sha512 = 0 }
        in_sha512 && NF >= 2 && $2 == target {
            print $1 "  " $2
            found = 1
            exit
        }
        END { if (!found) exit 1 }
    ' "$digest_path"
) || {
    printf 'No SHA-512 entry found for exact archive name: %s\n' "$tar_name" >&2
    exit 1
}

printf '%s\n' "$digest_line" | (cd -- "$tar_dir" && sha512sum --check --status)
printf 'Verified signature, signing-key fingerprint, and SHA-512 digest: %s\n' "$tar_name"
