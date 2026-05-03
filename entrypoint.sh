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

run_packer() {
  local hcl="$1"
  packer build "$hcl" &
  local pid=$!
  # При Ctrl+C packer ждёт graceful shutdown QEMU (до shutdown_timeout).
  # Убиваем packer и все его дочерние процессы (QEMU) принудительно.
  trap 'pkill -KILL -P $pid 2>/dev/null; kill -KILL $pid 2>/dev/null; exit 130' INT TERM
  wait "$pid"
  local rc=$?
  trap - INT TERM
  return $rc
}

# ── validate args ─────────────────────────────────────────────────────────────

[[ $# -eq 1 ]] || usage

FIRMWARE="${1,,}"   # lowercase

[[ "$FIRMWARE" == "bios" || "$FIRMWARE" == "uefi" ]] || usage

# ── bios ──────────────────────────────────────────────────────────────────────

run_bios() {
  clean_output oraclelinux-bios.pkr.hcl
  step "Запуск BIOS-сборки"
  run_packer oraclelinux-bios.pkr.hcl
}

# ── uefi ──────────────────────────────────────────────────────────────────────

run_uefi() {
  clean_output oraclelinux-uefi.pkr.hcl
  step "Запуск UEFI-сборки"
  run_packer oraclelinux-uefi.pkr.hcl
}

# ── main ──────────────────────────────────────────────────────────────────────

log "Прошивка: ${FIRMWARE^^}"

case "$FIRMWARE" in
  bios) run_bios ;;
  uefi) run_uefi ;;
esac
