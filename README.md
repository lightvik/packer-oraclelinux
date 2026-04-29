<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="logo-dark.svg">
    <img src="logo-light.svg" alt="logo" width="660">
  </picture>
</div>

## Описание

Packer-шаблон для автоматической установки Oracle Linux в qcow2-образ через QEMU/KVM.

Загружает DVD ISO в QEMU, поднимает встроенный HTTP-сервер Packer для отдачи `ks.cfg`, передаёт адрес kickstart-файла через параметры ядра GRUB и проводит установку в автоматическом режиме. Результат сохраняется в `output/oraclelinux.qcow2`.

Протестировано с Oracle Linux **10.1**.

## Требования

- Linux-хост с KVM (`/dev/kvm`)
- Docker

## Быстрый старт

1. Положить ISO в корень проекта (`OracleLinux-*-x86_64-dvd.iso`)
2. Положить `ks.cfg` в корень проекта (см. примеры в `examples/`)
3. Запустить, передав тип прошивки первым аргументом: `bios` или `uefi`

```bash
docker run \
  --rm \
  --device /dev/kvm \
  --network=host \
  --volume "$(pwd):/workspace" \
  ghcr.io/lightvik/packer-oraclelinux:latest \
  bios
```

> VNC-консоль установщика доступна на `127.0.0.1:59592` во время сборки.

## Файлы

| Файл | Назначение |
|---|---|
| `oraclelinux-bios.pkr.hcl` | Packer-шаблон для BIOS (SeaBIOS) |
| `oraclelinux-uefi.pkr.hcl` | Packer-шаблон для UEFI (EDK2-OVMF) |
| `plugins.pkr.hcl` | Зависимости плагинов Packer |
| `entrypoint.sh` | Точка входа: запускает Packer с нужным шаблоном |
| `ks.cfg` | Kickstart-конфиг для автоматической установки |
| `examples/` | Примеры kickstart-файлов для разных сценариев |
| `Dockerfile` | Образ с Packer и QEMU на базе Oracle Linux 10 |

## CI

При push в `master` — линтинг Dockerfile и HCL-файлов.  
При теге `vX.Y.Z` — линтинг + сборка и публикация образа в `ghcr.io/lightvik/packer-oraclelinux`.
