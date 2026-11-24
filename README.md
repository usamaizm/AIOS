# AIOS — Artificial Intelligence Operating System

AIOS is an operating-system project that evolves through three generations. The
central experiment is to use an earlier AI-enabled system to help design and
build a later operating system, while keeping consequential architecture and
permission decisions under human authorization.

The full direction is recorded in
[docs/ROADMAP-MARK-I-II-III.md](docs/ROADMAP-MARK-I-II-III.md). This README
summarizes what that roadmap currently decides; where the roadmap marks
something undecided or experimental, this README says so.

## Project status

AIOS is in the definition and documentation phase. The roadmap is working
direction captured from project discussions, not a claim that every
implementation detail has been decided. No installable AIOS system exists yet:
this repository currently contains the project documentation and roadmap, and
no distribution has been built or released.

## Mark I — Bootstrap generation

Mark I establishes a practical, human-usable desktop environment that can help
research, design, build, and test Mark II. Its decided direction:

- **Foundation:** Gentoo Linux, bootstrapped from an official Gentoo Stage 3
  archive. The archive's authenticity and integrity are verified before
  extraction. Gentoo is the initial foundation, not necessarily a permanent
  constraint on later generations.
- **Init system:** OpenRC. Mark I does not use systemd.
- **First target:** x86-64. ARM support is a future compatibility and porting
  goal, not part of the initial target.
- **Desktop:** KDE Plasma is the primary desktop users see when AIOS starts,
  using Gentoo's AMD64 desktop/Plasma profile in its OpenRC variant (for the
  23.0 profile family, `default/linux/amd64/23.0/desktop/plasma`).
- **AI integration:** the AI assistant is integrated into the desktop
  experience, with ordinary desktop and terminal workflows retained. OpenClaw
  is the initial AI agent framework.
- **Packages:** Portage and `emerge`; software is built from source using
  Gentoo's configurable build options and flags where appropriate.
- **Base system:** lean — only what is needed to boot and run the system.
  Additional customization and optional capabilities are installable layers
  rather than mandatory base components.
- **Audiences:** a command-line-oriented experience for beta testers, and a
  desktop installation and experience aimed at general users.
- **Installation guidance:** the Gentoo Handbook is the canonical guide for
  installation and system configuration, adapted only where AIOS-specific
  requirements call for it.
- **Installer:** Calamares is the aim for a graphical installer once the
  distribution is sufficiently stable. A reliable, repeatable installation
  path is a Mark I completion milestone, not a prerequisite for the initial
  bootstrap.

The Stage 3 archive provides the initial userspace; the kernel, bootloader,
hardware configuration, desktop integration, AI-assistant integration, and
AIOS-specific services still need to be configured.

### Mark I installation and storage direction

The current working direction for a conventional UEFI x86-64 installation:

- GPT partition table.
- EFI System Partition formatted as FAT32.
- A dedicated Linux swap partition.
- A root partition using ext4, taking the remaining available disk space
  unless the user chooses custom sizing.
- Hibernation is experimental during the first release: a swap partition can
  provide the hibernation target, but it must be large enough for the memory
  image and configured correctly for resume, and compatibility must be tested
  against hardware rather than assumed. An 8 GiB swap partition was discussed
  as a possible starting point; it is not established as a universal
  requirement, and the installer should allow users to adjust partition sizes.

## Architecture baseline

See [the Mark I architecture decision brief](docs/ARCHITECTURE.md) for the
selected Gentoo/OpenRC/Plasma baseline, system layers, AI permission
boundaries, reproducible bootstrap requirements, and release gates.

## Mark II — AI-designed system

Mark II is the generation the AI designs and helps implement, rather than
merely configuring Mark I:

- Built using Linux From Scratch (LFS) principles and procedures as the
  initial system-construction approach. LFS is a methodology for building a
  Linux system from source, not a separate kernel.
- Remains compatible with upstream Linux kernels; Mark II is not the
  generation for replacing Linux with a fundamentally different kernel
  architecture.
- The AI proposes the operating-system architecture and its components,
  explains the trade-offs, and develops approved designs.
- An AI-designed package-management system may be explored as part of the
  longer-term design; Portage and existing tools can inform or support the
  transition.
- Implementation decisions remain subject to human review and authorization.

## Mark III — Kernel-architecture exploration

Mark III reserves deeper kernel experimentation for a later generation. It is
the stage where AIOS may investigate alternatives to the conventional upstream
Linux-kernel approach — a microkernel, a hybrid kernel, or another
architecture. These are exploration topics, not decisions already made. Mark
III builds on lessons from the earlier generations rather than forcing Mark II
to solve kernel research prematurely.

## Cross-generation principles

From the roadmap:

1. **AI-designed, human-authorized architecture.** The AI can research,
   propose, compare, and implement approved designs. Humans retain authority
   over consequential architecture and permission changes.
2. **Explicit permissions.** The AI must not grant itself additional
   privileges or silently expand its authority.
3. **Isolation and monitoring.** Development and build activities should use
   appropriate sandboxing, network controls, resource limits, audit logs, and
   testing.
4. **Incremental validation.** Build and test components in stages; a
   generated design or successful build is not proof of security or
   correctness.
5. **Preserve options.** Avoid locking later generations into assumptions that
   are only necessary for the current bootstrap.
6. **Record decisions separately from ideas.** Proposals, experiments, and
   confirmed architectural decisions are clearly distinguished.

## Not yet decided

The roadmap lists open questions that should not be treated as settled,
including: the exact responsibilities and permission model of the Mark I AI
environment; Mark I's exact Stage 3 variant, kernel configuration, and
bootloader; the Calamares implementation and its supported partitioning
options; swap sizing and hibernation compatibility across hardware; the
criteria and timing for adding ARM support; Mark II's detailed architecture;
if and when a new package manager replaces or coexists with Portage; and Mark
III's kernel architecture. See the roadmap's "Open questions" section for the
full list.

## Relationship to other projects

AIOS is a distinct operating-system project with its own architecture and
roadmap, maintained in this repository. Its roadmap is kept independent of
Usama's other operating-system projects (OpenOS and FreeOS); shared standards
may be adopted where useful, but AIOS's direction is not assumed from them.

## Ecosystem integration

This project is part of a set of independent, interoperable open projects.
See the [ecosystem integration
contract](https://github.com/usamaizm/AIDB/blob/main/docs/ECOSYSTEM_INTEGRATION.md)
for its role, interoperability boundaries, and integration principles.

## License

AIOS is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for the
full text.
