#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "$0")/.." && pwd -P)
script="$root/scripts/verify-stage3.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir "$tmp/bin"

fingerprint=1111111111111111111111111111111111111111
cat > "$tmp/bin/gpgv" <<'MOCK'
#!/usr/bin/env sh
# This test stubs the cryptographic verifier; production runs use real gpgv.
printf '[GNUPG:] VALIDSIG %s 20261124 1795521600 0 4 0 1 10 00\n' "$TEST_FINGERPRINT"
MOCK
chmod +x "$tmp/bin/gpgv"

printf 'test Gentoo stage archive\n' > "$tmp/stage3.tar.xz"
printf 'trusted test keyring placeholder\n' > "$tmp/release.gpg"
digest=$(sha512sum "$tmp/stage3.tar.xz" | awk '{print $1}')
printf '# SHA512 HASH\n%s  stage3.tar.xz\n# BLAKE2B512 HASH\n' "$digest" > "$tmp/stage3.tar.xz.DIGESTS.asc"

PATH="$tmp/bin:$PATH" TEST_FINGERPRINT="$fingerprint" bash "$script" \
  "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/release.gpg" "$fingerprint"

if PATH="$tmp/bin:$PATH" TEST_FINGERPRINT="$fingerprint" bash "$script" \
  "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/release.gpg" "2222222222222222222222222222222222222222"; then
    printf 'Unexpected signing-key fingerprint passed\n' >&2
    exit 1
fi

printf 'tampered archive\n' > "$tmp/stage3.tar.xz"
if PATH="$tmp/bin:$PATH" TEST_FINGERPRINT="$fingerprint" bash "$script" \
  "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/release.gpg" "$fingerprint"; then
    printf 'Tampered archive unexpectedly passed digest verification\n' >&2
    exit 1
fi

printf 'missing archive\n' > "$tmp/other.tar.xz"
if PATH="$tmp/bin:$PATH" TEST_FINGERPRINT="$fingerprint" bash "$script" \
  "$tmp/other.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/release.gpg" "$fingerprint"; then
    printf 'Archive without a matching digest unexpectedly passed\n' >&2
    exit 1
fi
