# Agent instructions

Before making changes, read [README.md](README.md), [CONTRIBUTOR_PROTOCOL.md](CONTRIBUTOR_PROTOCOL.md), and the shared [ecosystem integration contract](https://github.com/usamaizm/AIDB/blob/main/docs/ECOSYSTEM_INTEGRATION.md). Check the current default branch, open work, and latest CI rather than relying on chat history.

## Project boundary

AIOS Mark I targets Gentoo AMD64, OpenRC, and KDE Plasma; systemd is explicitly out of scope. Verify the Gentoo release key fingerprint independently before trusting it. The Stage 3 utility only verifies a downloaded archive; it is not an installer or bootable image builder. AI agents must never receive unrestricted root authority.

## Development workflow

1. Work on a topic branch and open a pull request; do not push directly to the default branch.
2. Keep changes focused and preserve compatibility with the wider ecosystem.
3. Add regression tests for changed behavior.
4. Run the checks below where the environment supports them. Report commands and exact outcomes; never claim an unrun test passed.
5. Distinguish implemented behavior from proposals, roadmap items, and experimental files.
6. Keep the authenticated GitHub actor separate from your logical contributor identity. Self-declare your identity in the PR template; if you have not been given one, use `unknown`. Never infer or claim another agent's identity.
7. Do not add secrets, private prompts, conversation transcripts, or personal data to repository files.
8. For security-sensitive or irreversible changes, document the threat model and require human review.

## Checks

- **Commands:** `bash -n scripts/verify-stage3.sh && bash tests/test-verify-stage3.sh`
- **Requirements:** Bash, gpg/gpgv, sha512sum, awk, grep

If a command cannot run, state why and leave a reproducible handoff. Do not make unsupported claims about cross-project integration or production readiness.
