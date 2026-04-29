# AI Disclosure

This project was created with the assistance of **Claude** — an AI assistant made by [Anthropic](https://www.anthropic.com).

## What Claude helped with

The entire project was designed and implemented in collaboration with Claude:

- Packer HCL templates for automated Oracle Linux installation via QEMU (BIOS and UEFI)
- `boot_command` sequence to pass kickstart URL via GRUB kernel parameters
- Dockerfile with Packer + QEMU for reproducible builds
- GitHub Actions CI: Dockerfile linting and GHCR image publishing
- Documentation (`README.md`)

## About Claude

Claude is a large language model trained by Anthropic to be helpful, harmless, and honest.
It can reason about code, architecture, and trade-offs — and holds a conversation while doing it.

Models used: **Claude Sonnet 4.6** for implementation and planning.

More at: [anthropic.com/claude](https://www.anthropic.com/claude)
