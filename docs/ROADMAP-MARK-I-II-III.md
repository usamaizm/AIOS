# AIOS Generation Roadmap

**Status:** Working direction captured from project discussions. This document records the current intent; it is not a claim that every implementation detail has been decided.

## Vision

AIOS is intended to evolve through three generations. The central experiment is to use an earlier AI-enabled system to help design and build a later operating system, while keeping consequential architecture and permission decisions under human authorization.

## Mark I — Bootstrap generation

**Purpose:** Establish a practical environment that can help research, design, build, and test Mark II.

- Bootstrap from **Gentoo Linux**, starting from an official Gentoo Stage 3 archive.
- Use **OpenRC** as Mark I's init system. **Do not use systemd.**
- Target **x86-64 first** for the initial Mark I implementation.
- Keep **ARM support** as a future compatibility and porting goal; it is not part of the initial target.
- Make **KDE Plasma the primary desktop users see when AIOS starts**, so Mark I is a human-usable desktop OS rather than a terminal-first environment.
- Integrate the AI assistant into the desktop experience, while retaining ordinary desktop and terminal workflows.
- Use Gentoo's **AMD64 desktop/Plasma profile**, selecting the OpenRC variant (the profile path does not include `systemd`; for the current 23.0 profile family this is `default/linux/amd64/23.0/desktop/plasma`).
- Use **OpenClaw** as the initial AI agent framework.
- Use Gentoo's **Portage** package-management system and the `emerge` tool.
- Build software from source and use Gentoo's configurable build options and flags where appropriate.
- Verify the authenticity and integrity of the Stage 3 archive before extracting it.
- Use this generation as the development and experimentation environment for proposing and constructing Mark II.

Gentoo is the initial foundation, not necessarily a permanent constraint on every future generation. The Stage 3 archive provides the initial userspace; kernel, bootloader, hardware configuration, desktop integration, AI-assistant integration, and AIOS-specific services still need to be configured. The selected profile provides Gentoo defaults for a Plasma desktop; it does not by itself complete the desktop installation or configuration.

## Mark II — AI-designed system on an upstream-compatible Linux kernel

**Purpose:** Have the AI design and help implement the next-generation AIOS, rather than merely configure Mark I.

- Use **Linux From Scratch (LFS) principles and procedures** as an initial system-construction approach.
- Remain compatible with **upstream Linux kernels**. Mark II is not the generation for replacing Linux with a fundamentally different kernel architecture.
- Let the AI propose the operating-system architecture and its components, explain the trade-offs, and develop approved designs.
- Explore an AI-designed package-management system as part of the longer-term design; Portage and existing tools can inform or support the transition.
- Keep implementation decisions subject to human review and authorization.

**Important distinction:** Linux From Scratch is a methodology for building a Linux system from source; it is not a separate kernel. Mark II remains in the Linux-kernel generation.

## Mark III — Kernel-architecture exploration

**Purpose:** Reserve deeper kernel experimentation for a later generation.

Mark III is the stage where AIOS may investigate alternatives to the conventional upstream Linux-kernel approach. Possibilities to research could include a microkernel, a hybrid kernel, or another architecture. These are exploration topics, not decisions already made.

Mark III should build on lessons from the earlier generations rather than forcing Mark II to solve kernel research prematurely.

## Cross-generation principles

1. **AI-designed, human-authorized architecture.** The AI can research, propose, compare, and implement approved designs. Humans retain authority over consequential architecture and permission changes.
2. **Explicit permissions.** The AI must not grant itself additional privileges or silently expand its authority.
3. **Isolation and monitoring.** Development and build activities should use appropriate sandboxing, network controls, resource limits, audit logs, and testing.
4. **Incremental validation.** Build and test components in stages; do not treat a generated design or successful build as proof of security or correctness.
5. **Preserve options.** Avoid locking later generations into assumptions that are only necessary for the current bootstrap.
6. **Record decisions separately from ideas.** Proposals, experiments, and confirmed architectural decisions should be clearly distinguished.

## Current generation boundaries

| Generation | Foundation / kernel direction | Primary role |
|---|---|---|
| Mark I | Gentoo Linux Stage 3; OpenRC; x86-64 first; KDE Plasma as primary desktop; integrated AI assistant; OpenClaw | Human-usable, AI-integrated desktop and development environment |
| Mark II | LFS-based construction; upstream-compatible Linux kernel | AI-designed operating system and components |
| Mark III | Kernel architecture open for exploration | Deeper kernel research and possible alternatives |

## Open questions

The following remain to be designed and should not be treated as settled:

- The exact responsibilities and permission model of the Mark I AI environment, including how desktop actions are authorized.
- Mark I's exact Stage 3 variant, kernel configuration, and bootloader.
- The criteria and timing for adding ARM support.
- Mark II's detailed architecture, system interfaces, and component boundaries.
- How and when a new package manager should replace or coexist with Portage.
- Mark III's kernel architecture and the criteria for choosing one.
- Hardware support and maturity targets for each generation.

---
