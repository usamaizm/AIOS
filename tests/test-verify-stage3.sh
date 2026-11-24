#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "$0")/.." && pwd -P)
script="$root/scripts/verify-stage3.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
export GNUPGHOME="$tmp/gnupg"
mkdir -m 700 "$GNUPGHOME"

command -v gpg >/dev/null
command -v gpgv >/dev/null
command -v sha512sum >/dev/null
command -v awk >/dev/null
command -v sed >/dev/null

# Generate a disposable signing key so CI exercises real OpenPGP verification.
gpg --batch --pinentry-mode loopback --passphrase '' \
  --quick-generate-key "AIOS CI Test Key <aios-ci@example.invalid>" ed25519 sign 0 >/dev/null 2>&1
fingerprint=$(gpg --batch --with-colons --list-secret-keys |
  awk -F: '$1 == "fpr" { print $10; exit }')
test -n "$fingerprint"
gpg --batch --export "$fingerprint" > "$tmp/release.gpg"

printf 'test Gentoo stage archive\n' > "$tmp/stage3.tar.xz"
digest=$(sha512sum "$tmp/stage3.tar.xz" | awk '{print $1}')
printf '# SHA512 HASH\n%s  stage3.tar.xz\n# BLAKE2B512 HASH\n' "$digest" > "$tmp/DIGESTS"
gpg --batch --yes --armor --clearsign --output "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/DIGESTS"

bash "$script" "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" \
  "$tmp/release.gpg" "$fingerprint"

if bash "$script" "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" \
  "$tmp/release.gpg" "1111111111111111111111111111111111111111"; then
    printf 'Unexpected signing-key fingerprint passed\n' >&2
    exit 1
fi

# Modify the signed cleartext itself; signature verification must fail.
sed 's/stage3.tar.xz/stage3-altered.tar.xz/' \
  "$tmp/stage3.tar.xz.DIGESTS.asc" > "$tmp/tampered.DIGESTS.asc"
if bash "$script" "$tmp/stage3.tar.xz" "$tmp/tampered.DIGESTS.asc" \
  "$tmp/release.gpg" "$fingerprint"; then
    printf 'Modified signed digest unexpectedly passed signature verification\n' >&2
    exit 1
fi

# A valid signature with a changed archive must fail the SHA-512 check.
printf 'tampered archive\n' > "$tmp/stage3.tar.xz"
if bash "$script" "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" \
  "$tmp/release.gpg" "$fingerprint"; then
    printf 'Tampered archive unexpectedly passed digest verification\n' >&2
    exit 1
fi

# A correctly signed digest file for a different filename must fail lookup.
printf '# SHA512 HASH\n%s  other-stage3.tar.xz\n# BLAKE2B512 HASH\n' "$digest" > "$tmp/other.DIGESTS"
gpg --batch --yes --armor --clearsign --output "$tmp/other.DIGESTS.asc" "$tmp/other.DIGESTS"
if bash "$script" "$tmp/stage3.tar.xz" "$tmp/other.DIGESTS.asc" \
  "$tmp/release.gpg" "$fingerprint"; then
    printf 'Digest for a different archive unexpectedly passed\n' >&2
    exit 1
fi
