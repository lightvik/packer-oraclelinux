#!/bin/bash
set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────

log()  { echo "[packer-oraclelinux] $*"; }
step() { echo; echo "==> $*"; }

usage() {
  echo "Usage: $(basename "$0") <bios|uefi>" >&2
  exit 1
}

# ── validate args ─────────────────────────────────────────────────────────────

[[ $# -eq 1 ]] || usage

FIRMWARE="${1,,}"   # lowercase

[[ "$FIRMWARE" == "bios" || "$FIRMWARE" == "uefi" ]] || usage

# ── bios ──────────────────────────────────────────────────────────────────────

run_bios() {
  step "Запуск BIOS-сборки"
  exec packer build oraclelinux-bios.pkr.hcl
}

# ── uefi ──────────────────────────────────────────────────────────────────────

run_uefi() {
  step "Запуск UEFI-сборки"
  exec packer build oraclelinux-uefi.pkr.hcl
}

# ── main ──────────────────────────────────────────────────────────────────────

log "Прошивка: ${FIRMWARE^^}"

case "$FIRMWARE" in
  bios) run_bios ;;
  uefi) run_uefi ;;
esac
