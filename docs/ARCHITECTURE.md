# AIOS Mark I Architecture Decision Brief

**Status:** Working architecture baseline derived from the current Mark I roadmap. This document makes the existing direction easier to implement and test; it does not claim that a bootable image exists.

## 1. Mark I system boundary

Mark I is a practical, human-usable AI-enabled desktop environment built on Gentoo Linux. It is a bootstrap generation for developing and validating later AIOS generations, not a new kernel.

The initial target is x86-64 UEFI hardware and QEMU. ARM remains a future porting goal.

## 2. Selected baseline

| Layer | Mark I direction |
|---|---|
| Base | Official Gentoo Stage 3 archive |
| Profile | Gentoo AMD64 desktop/Plasma profile, OpenRC variant |
| Init | OpenRC; systemd is explicitly out of scope |
| Desktop | KDE Plasma as the primary desktop |
| Package management | Gentoo Portage and emerge |
| AI agent framework | OpenClaw as the initial framework, subject to security review |
| Installer | Calamares as a later milestone after the image is reproducible |
| Filesystem baseline | GPT, FAT32 EFI System Partition, swap partition, ext4 root |
| Build target | x86-64 first; ARM later |

The exact Gentoo profile identifier and Stage 3 artifact must be verified against the official Gentoo release materials at build time. Never hard-code an outdated profile or download URL into a release script.

## 3. System layers

1. **Firmware and boot:** UEFI boot path, bootloader, kernel, initramfs, and verified root filesystem.
2. **Base OS:** Gentoo Stage 3 userspace, OpenRC, Portage, core utilities, and system configuration.
3. **Desktop:** KDE Plasma with a usable login and session lifecycle.
4. **AI service boundary:** a separately managed agent/runtime service with explicit IPC/API boundaries.
5. **Assistant experience:** desktop entry point and optional terminal workflow.
6. **Developer environment:** source build tools and reproducible project workspaces.
7. **Installer and recovery:** deferred until image creation and upgrades are reliable.

## 4. AI authority and safety model

The AI assistant is an application-level service, not a privileged system administrator.

- Run the agent under a dedicated unprivileged account.
- Do not give the agent passwordless root, unrestricted sudo, or direct access to bootloader and system service configuration.
- Put code execution and tool use inside an explicit sandbox with resource limits.
- Require human authorization for package installation, system configuration changes, partitioning, boot changes, service enablement, firewall changes, and access to private files.
- Apply least privilege to filesystem, network, process, and device access.
- Record requested actions, granted permissions, command results, and failures in an audit trail.
- Provide a clear stop/disable control that does not require the agent itself to cooperate.
- Never allow the agent to expand its own permissions or weaken its own isolation.
- Keep model/provider credentials outside project workspaces and logs.

OpenClaw is an initial framework choice, not a reason to inherit permissive defaults. Its exact tools, plugins, network access, and execution model must be reviewed before enabling them.

## 5. Reproducible bootstrap requirements

A bootstrap procedure must:

1. Select a current official Stage 3 artifact for the chosen architecture and OpenRC profile.
2. Verify its checksum and signature using the official Gentoo trust instructions.
3. Record the artifact URL, digest, profile, date, and tool versions.
4. Follow the Gentoo Handbook for partitioning, chroot, kernel, bootloader, and system configuration.
5. Record all selected USE flags and package versions.
6. Build a package manifest and license inventory.
7. Keep secrets and machine-specific values out of source control.
8. Produce a repeatable image and a QEMU boot test.

Do not publish an image if its inputs cannot be traced to an official source and a recorded build configuration.

## 6. Storage and installation baseline

The current proposed UEFI layout is:

- GPT partition table.
- FAT32 EFI System Partition.
- Dedicated Linux swap partition.
- ext4 root partition using the remaining space by default.

The installer must allow custom sizing. Hibernation is experimental: swap size and resume behavior must be tested against actual memory size, hardware, and kernel configuration. The discussed 8 GiB swap size is not a universal requirement.

## 7. Milestones and acceptance criteria

### M1 — verified base system
- Verified Stage 3 archive.
- Gentoo AMD64 OpenRC system boots in QEMU.
- OpenRC starts required services.
- Package inventory and build notes are committed.

### M2 — human-usable desktop
- KDE Plasma starts from the normal login path.
- Keyboard, display, audio, networking, and shutdown behavior are tested in the reference VM.
- A terminal remains available as a supported fallback.

### M3 — isolated assistant service
- Dedicated unprivileged service account.
- Explicit sandbox and resource limits.
- No default host-wide shell or root authority.
- Human approval gate for consequential actions.
- Audit log and emergency stop tested.

### M4 — developer workflow
- Reproducible toolchain installation.
- Project workspace isolation.
- Build/test workflow demonstrated against a selected repository.
- Recovery from failed build or agent termination demonstrated.

### M5 — installer and beta
- Calamares integration only after the base image is reproducible.
- Install, update, rollback/recovery, and clean reinstall tested in QEMU.
- Beta release notes disclose hardware and security limitations.

## 8. Explicit non-goals for Mark I

- Replacing the Linux kernel.
- Supporting every architecture at launch.
- Giving an AI agent unrestricted administrative control.
- Claiming that AIOS is autonomous or self-governing.
- Shipping an installer before a reproducible base image exists.
- Treating hibernation or hardware compatibility as guaranteed.

## 9. Release gate

A Mark I image is not considered ready because it boots once on a developer's machine. The release gate requires a clean, repeatable build, successful QEMU boot, working desktop session, tested update/recovery path, documented package/license inventory, and a security review of the assistant's actual permissions and tools.
