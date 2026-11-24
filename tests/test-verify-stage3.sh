#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "$0")/.." && pwd -P)
script="$root/scripts/verify-stage3.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir "$tmp/bin"

cat > "$tmp/bin/gpgv" <<'MOCK'
#!/usr/bin/env sh
# This test stubs signature verification; production runs use real gpgv.
exit 0
MOCK
chmod +x "$tmp/bin/gpgv"

printf 'test Gentoo stage archive\n' > "$tmp/stage3.tar.xz"
printf 'trusted test keyring placeholder\n' > "$tmp/release.gpg"
digest=$(sha512sum "$tmp/stage3.tar.xz" | awk '{print $1}')
printf '# SHA512 HASH\n%s  stage3.tar.xz\n# BLAKE2B512 HASH\n' "$digest" > "$tmp/stage3.tar.xz.DIGESTS.asc"

PATH="$tmp/bin:$PATH" "$script" \
  "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/release.gpg"

printf 'tampered archive\n' > "$tmp/stage3.tar.xz"
if PATH="$tmp/bin:$PATH" "$script" \
  "$tmp/stage3.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/release.gpg"; then
    printf 'Tampered archive unexpectedly passed digest verification\n' >&2
    exit 1
fi

printf 'missing archive\n' > "$tmp/other.tar.xz"
if PATH="$tmp/bin:$PATH" "$script" \
  "$tmp/other.tar.xz" "$tmp/stage3.tar.xz.DIGESTS.asc" "$tmp/release.gpg"; then
    printf 'Archive without a matching digest unexpectedly passed\n' >&2
    exit 1
fi
