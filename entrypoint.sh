#!/bin/bash
set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────

log()  { echo "[packer-oraclelinux] $*"; }
step() { echo; echo "==> $*"; }

usage() {
  echo "Usage: $(basename "$0") <bios|uefi>" >&2
  exit 1
}

clean_output() {
  local hcl="$1"
  local output_dir
  output_dir=$(grep -oP 'output_directory\s*=\s*"\K[^"]+' "$hcl" | head -1)
  output_dir="${output_dir:-output}"

  if [[ -d "$output_dir" ]]; then
    step "Удаление предыдущей директории сборки: $output_dir"
    rm -rf "$output_dir"
  fi
}

# ── validate args ─────────────────────────────────────────────────────────────

[[ $# -eq 1 ]] || usage

FIRMWARE="${1,,}"   # lowercase

[[ "$FIRMWARE" == "bios" || "$FIRMWARE" == "uefi" ]] || usage

# ── bios ──────────────────────────────────────────────────────────────────────

run_bios() {
  clean_output oraclelinux-bios.pkr.hcl
  step "Запуск BIOS-сборки"
  exec packer build oraclelinux-bios.pkr.hcl
}

# ── uefi ──────────────────────────────────────────────────────────────────────

run_uefi() {
  clean_output oraclelinux-uefi.pkr.hcl
  step "Запуск UEFI-сборки"
  exec packer build oraclelinux-uefi.pkr.hcl
}

# ── main ──────────────────────────────────────────────────────────────────────

log "Прошивка: ${FIRMWARE^^}"

case "$FIRMWARE" in
  bios) run_bios ;;
  uefi) run_uefi ;;
esac
