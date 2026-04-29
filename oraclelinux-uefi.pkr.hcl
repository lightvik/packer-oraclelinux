variable "ovmf_code" {
  type        = string
  default     = "/usr/share/edk2/ovmf/OVMF_CODE.fd"
  description = "OVMF_CODE.fd — прошивка (readonly)"
}

locals {
  iso_url = element(sort(fileset(".", "OracleLinux-*-x86_64-dvd.iso")), 0)
}

source "qemu" "oraclelinux" {
  qemu_binary         = "/usr/libexec/qemu-kvm" # Путь к бинарнику QEMU — задан явно т.к. внутри docker не может найти в $PATH
  iso_url             = local.iso_url           # нужен только Packer для валидации; в QEMU передаётся через qemuargs
  iso_checksum        = "none"                  # Контрольная сумма ISO (none — пропустить проверку)
  output_directory    = "output"                # Директория для сохранения готового образа
  vm_name             = "oraclelinux.qcow2"     # Имя выходного файла образа
  format              = "qcow2"                 # Формат выходного образа диска
  accelerator         = "kvm"                   # Аппаратное ускорение виртуализации
  disk_size           = "31G"                   # Размер виртуального диска
  memory              = 4096                    # Объём оперативной памяти в МБ
  cpus                = 4                       # Количество виртуальных процессоров
  disk_interface      = "virtio"                # используется только для qemu-img create; в QEMU диск передаётся через qemuargs
  net_device          = "virtio-net"            # Модель сетевого адаптера
  communicator        = "none"                  # Без SSH/WinRM — управление только через boot_command
  shutdown_timeout    = "40m"                   # Максимальное время ожидания выключения ВМ
  headless            = true                    # Запуск без графического окна QEMU
  use_default_display = false                   # Не использовать дисплей по умолчанию (нужно для headless)
  vnc_port_min        = 59592                   # Минимальный порт VNC для подключения к консоли
  vnc_port_max        = 59592                   # Максимальный порт VNC (фиксируем один порт)
  vnc_bind_address    = "127.0.0.1"             # Адрес привязки VNC (только локально)
  machine_type        = "q35"                   # Тип чипсета: q35 — современный PCIe-чипсет, обязателен для UEFI/OVMF

  # Packer поднимает HTTP-сервер, отдающий файлы из корня проекта.
  # Адрес и порт подставляются в boot_command через {{ .HTTPIP }} и {{ .HTTPPort }}.
  http_directory = "."

  # При использовании qemuargs Packer заменяет все свои дефолтные аргументы QEMU на наши.
  # Поэтому диск и CD-ROM нужно передавать явно — иначе они не попадут в команду запуска QEMU.
  qemuargs = [
    # OracleLinux 10 требует минимум x86-64-v2; host пробрасывает CPU хоста целиком
    ["-cpu", "host"],
    # UEFI-прошивка
    ["-drive", "if=pflash,format=raw,readonly=on,file=${var.ovmf_code}"],
    # Системный диск
    ["-drive", "file=output/oraclelinux.qcow2,if=virtio,cache=writeback,discard=ignore,format=qcow2"],
    # CD-ROM с установочным ISO через virtio-scsi
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-drive", "if=none,id=isoimg,media=cdrom,readonly=on,file=${local.iso_url}"],
    ["-device", "scsi-cd,drive=isoimg,bus=scsi0.0"],
    ["-boot", "once=d"],
  ]

  boot_wait = "5s"
  boot_command = [
    # В GRUB меню поднимаемся с пункта 'Test this media' до 'Install linux'
    "<up>",
    # Входим в режим редактирования текущей записи загрузки.
    "e",
    # Спускаемся до строки с параметрами ядра - два раза вни
    "<down><down>",
    # Переходим в конец строки.
    "<end>",
    # Дописываем адрес kickstart-файла и режим без интерактивных вопросов.
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg inst.cmdline",
    # Запускаем загрузку с изменёнными параметрами.
    "<leftCtrlOn>x<leftCtrlOff>",
  ]
}

build {
  sources = ["source.qemu.oraclelinux"]
}
