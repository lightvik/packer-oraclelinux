locals {
  iso_url = element(sort(fileset(".", "OracleLinux-*-x86_64-dvd.iso")), 0)
}

source "qemu" "oraclelinux" {
  qemu_binary         = "/usr/libexec/qemu-kvm" # Путь к бинарнику QEMU — задан явно т.к. внутри docker не может найти в $PATH
  iso_url             = local.iso_url           # Путь к ISO-образу установщика
  iso_checksum        = "none"                  # Контрольная сумма ISO (none — пропустить проверку)
  output_directory    = "output"                # Директория для сохранения готового образа
  vm_name             = "oraclelinux.qcow2"     # Имя выходного файла образа
  format              = "qcow2"                 # Формат выходного образа диска
  accelerator         = "kvm"                   # Аппаратное ускорение виртуализации
  disk_size           = "31G"                   # Размер виртуального диска
  memory              = 4096                    # Объём оперативной памяти в МБ
  cpus                = 4                       # Количество виртуальных процессоров
  disk_interface      = "virtio"                # Интерфейс диска
  net_device          = "virtio-net"            # Модель сетевого адаптера
  communicator        = "none"                  # Без SSH/WinRM — управление только через boot_command
  shutdown_timeout    = "40m"                   # Максимальное время ожидания выключения ВМ
  headless            = true                    # Запуск без графического окна QEMU
  use_default_display = false                   # Не использовать дисплей по умолчанию (нужно для headless)
  vnc_port_min        = 59592                   # Минимальный порт VNC для подключения к консоли
  vnc_port_max        = 59592                   # Максимальный порт VNC (фиксируем один порт)
  vnc_bind_address    = "127.0.0.1"             # Адрес привязки VNC (только локально)
  machine_type        = "pc"                    # Тип чипсета: pc — классический i440FX, достаточен для Legacy BIOS
  cpu_model           = "host"                  # OracleLinux 10 требует минимум x86-64-v2; host пробрасывает CPU хоста целиком

  # Packer поднимает HTTP-сервер, отдающий файлы из корня проекта.
  # Адрес и порт подставляются в boot_command через {{ .HTTPIP }} и {{ .HTTPPort }}.
  http_directory = "."

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
