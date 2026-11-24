#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "$0")/.." && pwd -P)
script="$root/scripts/verify-stage3.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
export GNUPGHOME="$tmp/gnupg"
mkdir -m 700 "$GNUPGHOME"

for command_name in gpg gpgv sha512sum awk; do
    command -v "$command_name" >/dev/null 2>&1 || {
        printf 'Required test command not found: %s\n' "$command_name" >&2
        exit 127
    }
done

# Generate an ephemeral test key. This verifies real gpgv behavior, but does
# not replace independent verification of Gentoo's production key fingerprint.
gpg --batch --passphrase '' --quick-generate-key \
    "AIOS CI Test <aios-ci@example.invalid>" ed25519 sign 1d >/dev/null 2>&1
gpg --batch --export "AIOS CI Test <aios-ci@example.invalid>" > "$tmp/test-keyring.gpg"

printf 'test Gentoo stage archive\n' > "$tmp/stage3.tar.xz"
digest=$(sha512sum "$tmp/stage3.tar.xz" | awk '{print $1}')
printf '# SHA512 HASH\n%s  stage3.tar.xz\n# BLAKE2B512 HASH\n' "$digest" > "$tmp/stage3.DIGESTS"
gpg --batch --yes --clearsign \
    --output "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/stage3.DIGESTS"

bash "$script" "$tmp/stage3.tar.xz" \
    "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/test-keyring.gpg"

# A valid signature with a changed archive must fail the SHA-512 check.
printf 'tampered archive\n' > "$tmp/stage3.tar.xz"
if bash "$script" "$tmp/stage3.tar.xz" \
    "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/test-keyring.gpg"; then
    printf 'Tampered archive unexpectedly passed digest verification\n' >&2
    exit 1
fi

# A modified clear-signed digest file must fail signature verification.
cp "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/tampered.DIGESTS.asc"
printf '\n# tampered\n' >> "$tmp/tampered.DIGESTS.asc"
if bash "$script" "$tmp/stage3.tar.xz" \
    "$tmp/tampered.DIGESTS.asc" "$tmp/test-keyring.gpg"; then
    printf 'Tampered signature unexpectedly passed verification\n' >&2
    exit 1
fi

# A correctly signed digest file for a different filename must fail lookup.
printf '# SHA512 HASH\n%s  other-stage3.tar.xz\n# BLAKE2B512 HASH\n' "$digest" > "$tmp/other.DIGESTS"
gpg --batch --yes --clearsign \
    --output "$tmp/other.DIGESTS.asc" "$tmp/other.DIGESTS"
if bash "$script" "$tmp/stage3.tar.xz" \
    "$tmp/other.DIGESTS.asc" "$tmp/test-keyring.gpg"; then
    printf 'Digest for a different archive unexpectedly passed\n' >&2
    exit 1
fi
