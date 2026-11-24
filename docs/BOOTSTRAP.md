# AIOS Mark I bootstrap verification

This is the first safe bootstrap utility for Mark I. It verifies a locally downloaded Gentoo Stage 3 archive before extraction. It deliberately does not download files, unpack archives, partition disks, chroot, install packages, or invoke privileged commands.

## Target

- Gentoo AMD64 Stage 3 with the OpenRC init variant.
- UEFI x86-64 as the first intended machine target.
- KDE Plasma desktop profile as described in the [architecture brief](ARCHITECTURE.md).

Always select the current artifact from Gentoo's official distribution directory. Stage 3 names, profile paths, and release metadata change; do not pin a dated tarball or assume that a profile identifier remains current.

## Trust chain

1. Obtain the Stage 3 tarball and its matching `.DIGESTS.asc` from the same official Gentoo release directory.
2. Obtain Gentoo's release-signing public key using an official Gentoo key-distribution method.
3. Verify the full key fingerprint independently against Gentoo's official release-signature information before trusting it.
4. Create a dedicated keyring containing the verified release key. Do not blindly trust a key merely because it was downloaded from a keyserver.
5. Run the verification script:

```sh
scripts/verify-stage3.sh \
  /path/to/stage3-amd64-RELEASE-openrc.tar.xz \
  /path/to/stage3-amd64-RELEASE-openrc.tar.xz.DIGESTS.asc \
  /path/to/trusted-gentoo-release.gpg
```

The script uses `gpgv` against the supplied keyring, then checks the SHA-512 entry for the exact archive filename. Both checks must pass. A successful checksum alone does not establish authenticity; a valid signature from an unverified key is not a trustworthy release chain.

## After verification

Only after verification should a separate, reviewed build process unpack the archive and follow the current Gentoo Handbook. Preserve archive metadata and numeric ownership as required by Gentoo's instructions. Record the selected Stage 3 URL, filename, SHA-512 digest, signing-key fingerprint, profile, build date, and tool versions in the build manifest.

Do not run this verification utility as a substitute for reviewing the Gentoo Handbook, profile settings, package licenses, kernel/bootloader configuration, or the security model for the AI assistant.

## Limitations

- The script verifies only the supplied archive and its signed digest entry.
- It does not fetch keys, establish key trust, download artifacts, inspect archive contents, or prove reproducibility.
- The trusted keyring must be prepared and fingerprint-checked by the operator.
- The script is a local verification step, not an installer or bootable image builder.
