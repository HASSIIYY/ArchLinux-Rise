# ArchLinux-Rise
# ArchLinux + i3-gaps + Ranger + NeoVim + Alacritty + Firefox


Подготовка:
	1. Загружаемся с загрузочной флешки
	2. Подключаемся к интернету по кабелю
		2.1 Можно проверить соеденение с интернетом с помощью утилиты ping google.com
		2.2 Если не пингует google.com то редактируем подключение к DNS серверу в файле /etc/resulv.conf через редактор nano:		nano /etc/resulv.conf
		2.3 Дописываем в файл:
			nameserver 8.8.8.8
			nameserver 8.8.4.4


Разметка диска:
	1. Проверяем разметку диска утилитой fdisk с ключем -l
		fdisk -l

	2. Устанавливаем таблицу разделов GPT на нужнуй нам диск
		fdisk /dev/"Диск"
		Ключи:
			d - удаление раздела диска
			g - установка разделов GPT
			w - выход из утилиты

	3. cfdisk /dev/"ДИСК":	Разбиваем диск на разделы
	 3.1 Первый раздел:	31M BIOS boot
	 3.2 Второй раздел: 300M-500M EFI system	#Раздел используется для установки ядер linux, если планируется устанавливать нескольно, то используем не 300MiB, а 500MiB.
	 3.3 Третий раздел: Linux filesystem
	 3.4 Жмём Write, подтверждаем и выходим
	
	4. Проверяем разметку диска
	
	5. Форматируюем разделы
		5.1 mkfs.vfat /dev/"Второй раздел диска"
		5.2	mkfs.btrfs -f /dev/"Третий раздел диска"
	
	6. Монтируем главный раздел
		mount /dev/"Третий раздел диска" /mnt

	7. Монтируем закрузочный раздел
		mkdir /mnt/boot
		mkdir /mnt/boot/EFI
		mount /dev/"Второй раздел диска" /mnt/boot/EFI


Настройка базавой системы:
	1. Устанавливаем базавую систему
		pacstap -i /mnt base base-devel linux-zen linux-zen-headers linux-firmware dosfstools btrfs-progs intel-ucode iucode-tool nano
	
	2. Создаем файл конфигураций файловых систем диска 
		genfstab -U /mnt >> /mnt/etc/fstab

	3. Проверяем файл конфигурации файловых систем
		cat /mnt/etc/fstab


Первичная настройка системы:
	1. Входим в систему
		arch-chroot /mnt
	
	2. Конфигурируем время и дату
		ln -sf /usr/share/zoneinfo/Europe/Kaliningrad /etc/localtime
		hwclock --systohc

	3. Русифицируем систему
		nano /etc/locale.gen	#Выбираем языки системы, en_US.UTF-8 должен быть открыт ОБЯЗАТЕЛЬНО!
		locale-gen

	4. Прописываем язык системы
		nano /etc/locale.conf:
			LANG=ru_RU.UTF-8	#Локализация для Русского языка
	
	5. Локализируем консоль
		nano /etc/vconsole.conf:
			KEYMAP=ru
			FONT=cyr-sun16
	
	6. Задаём имя компьютера
		nano /etc/hostname:
			ARCH	#Моё имя компьютера

	7. Редактируем файл доменных имён
		nano /etc/hosts:
			127.0.0.1 localhost
			::1				localhost
			127.0.0.1 ARCH.localdomain ARCH		#Вместо ARCH вводим своё имя компьютера
	
	8. Создаём образ ядра для оперативной памяти
		mkinitcpio -P		#Используем ключ -P если в системе установлено одно ядро, иначе -p "Желаемое ядро"(например linux-zen)

	9. Устанавливаем парол root
		passwd	#Пароль вводиться, но не отображается

	10. Скачиваем загрузчик и сетевые утилиты
		pacman -S grub efibootmgr dhcpcd dhclient networkmanager
	
	11. Устанавливаем загрузчик
		grub-install /dev/"Диск"

	12. Конфигурируем загрузчик
		grub-mkconfig -o /boot/grub/grub.cfg
	
	13. Выходим из root и отмантируем /mnt каталог
		umount -R /mnt
	
	14. Перезагружаемся в нашу систему
		reboot
		

Основная настройка системы:
	1. Входим в систему под пользователя root

	2. Настройка доступа к правам root 
		nano /etc/sudoers:
			Раскоментируем строку: %wheel ALL=(ALL) ALL (Она находиться почти в самом низу)

	3. Создаем обычную учётную запись пользователя
		usseradd -m -G wheel -S /bin/bash "Имя пользователя"

	4. Задаём пароль этой учётной записи
		passwd "Имя пользователя"		#В обязательном порядке вводим ОТЛИЧНЫЙ пароль от пользователя root

	5. Выходим из root и заходим под нашим пользователем
		exit

	6. Проверяем работу root доступа
		sudo su
	
	7. Запускаем сетевую службу networkmanager
		systemctl enable NetworkManager
	
	8. Перезагружаемся
		reboot
	
	9. Подключаемся к интернету
		#У меня подключение по кабелю

	10. Открываем репозиторий multilib
		sudo nano /etc/pacman.conf:
			Раскоментируюем строки:
				[multilib]
				Include = /etc/pacman.d/mirrorlist

	11. Обновляем репозитории и устанавливаем набор пакетов для видеоускорения
		Nvidia:
			sudo pacman -Syu nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader lib32-opencl-nvidia opencl-nvidia libxnvctrl
		Intel:
			sudo pacman -Syu lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader libva-intel-driver xf86-video-intel

	12. Устанавливаем дополнение к networkmanager
		sudo pacman -S network-manager-applet

	13. Перезагружаемся
		reboot


Добавляем swap файл
	1. Добавляем файл подкачки(swapfile)
		touch swapfile
		chattr +C swappfile
		fallocate --length "Размер файла"MiB swapfile		#Выбираем размер файла подкачки исходя из размера оперативной памяти
		sudo chown root swapfile
		sudo chmod 600 swapfile
		sudo mkswap swapfile
		sudo swapon swapfile

	2. Добавляем автомантирование swap файла
		sudo nvim /etc/fstab:
			/home/"Имя пользователя"/swapfile			none		swap		defaults		0 0

	3. Перезагружаемся
		reboot
		

Добавляем автомантирование дисков
	1. Ищем название и UUID подключаемых разделов
		sudo blkid
	
	2. sudo nvim /etc/fstab:
		# /dev/"Идентификатор вашего раздела"
		UUID="UUID вашего раздела"	/run/media/hassiiyy/"Название вашего раздела"	"Файловая система вашего раздела"	defaults	0 0
	
	3. Перезагружаемся
		reboot
	

Добавляем дополнительные модули ядра для Nvidia и BTRFS:
	1. Открываем файл конфигурации ядра
		sudo nvim /etc/mkinitcpio.conf:
			В раздел MODULES=():
				crc32c libcrc32c zlib_deflate btrfs nvidia nvidia_modeset vnidia_uvm  nvidia_drm

	2. Пересобираем initramfs
		sudo mkinitcpio -P	#Используем ключи как это было описанно рание

	3. Перезагружаемся
		reboot


Добавление символьные ссылки на папки пользователя находящиеся в другой директории:
	1. ln -s /run/media/hassiiyy/"Имя раздела"/"Имя папки" /home/"Имя пользователя"/"Имя папки"
		

Установка графической оболочки i3:
	1. sudo pacman -S xorg xorg-xinit i3-gaps alacritty ranger rofi nitrogen picom gdm neovim

	2. Добавляем в автозагрузку службу дисплейменеджера 
		sudo systenctl enable "Дисплейменеджер"		#Например решение от Gnome под названием gdm

	3. Перезагружаемся в графическую оболочку
		reboot

	
Оптимизация ArchLinux
	1. Устанавливаем пакет git
		sudo pacman -S git

	2. Прописываем папку для временных сборочных файлов и переходим в неё
		mkdir tools
		cd tools

	3. Закачиваем пакет yay
		git clone https://aur.archlinux.org/yay.git
	
	4. Собираем пакет yay
		cd yay
		makepkg -sric
		cd ..

	5. Включаем OpenGL
		sudo pacman -S xf86-video-nouveau
		sudo -i		#Переход к пользователю root с каталогом обычного пользователя
		echo "MESA_GL_VERSION_OVERRIDE=4.5" >> /etc/environment
		echo "MESA_GLSL_VERSION_OVERRIDE=450" >> /etc/environment

	6. Устанавливаем Nvidia Optinus manager
		yay optimus-manager
		sudo systemctl enable optimus-manager.service
		sudo systemctl start optimus-manager.service

	7. Устанавливаем демон управляющий приоритетом распределения ресусов между задачами Ananicy
		git clone https://aur.archlinux.org/ananicy-git.git
		cd ananicy-git
		makepkg -sric
		sudo systemctl enable ananicy
		cd ..

	8. Включаем службу Trim файловой системы, преднозначена для SSD дисков
		sudo systemctl enable fstrim.timer
		sudo fstrim -v	#Если несработала использовать ключ -va

	9. Улитита профилей частоты процессора Cpupower-gui
		git clone https://aur.archlinux.org/cpupower-gui.git
		cd cpupower-gui
		makepkg -sric
		cd ..

	10. Оптимизация загрузки системы
		sudo nvim /etc/default/grub:
			GRUB_TIMEOUT=0
			GRUB_CMDLINE_LINUX_DEFAULT="":
				quiet loglevel=0 rd.systemd.show_status=auto rd.udev.log_level=0 splash rootfstype=btrfs selinux=0 lpj=3499912 raid=noautodetect noibrs noibpb no_stf_barrier tsx=on tsx_async_abort=off elevator=noop mitigations=off
			GRUB_TIMEOUT_STYLE=false
		sudo grub-mkconfig -o /boot/grub/grub.cfg

	11. Параметры оптимизации SSD
		sudo nvim /etc/fstab:
			Прописываем в опции диска до параметра subvol=/
				rw,lazytime,ssd,ssd_spread,space_cache=v2,max_inline=256,commit=600,nodatacow

	12. Перезагружаемся 
		reboot


Настройка NeoVim
	1. Создаём папку и файл конфигурации NeoVim
		cd .config && mkdir nvim && cd nvim
		cp Documents/init.vim .config/nvim

	2. Интегрируем Vim-Plug
		sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

	3. Догрузжаем зависимости плагина YouCompleteMy
		python .local/share/nvim/plugged/YouCompleteMe/install.py
		sudo pacman -S pyhton-pip
		pip pynvim

	4. Догружаем зависимости плагина Vim-DevIcons
		yay nerd-fonts-complete

	5. Устанавливаем плагины vim
		:PlugInstall
		
		
Настройка файлового менеджера i3-gaps:
	1. Добавляем файл конфигурации клавиатуры:
		/etc/X11/xorg.conf.d/00-keyboard.conf:
			Section "inputClass"
				Identifier "system-keyboard"
				MatchIsKeyboard "on"
				Option "XkbLayout" "us, ru"
				Option "XkbModel" "pc105"
				Option "XkbOptions" "grp:caps_toggle"
			EndSection

	2. Подключаем звук
		sudo pacman -S alsa-lib alsa-utils pulseaudio

	3. Подключаем притер
		sudo pacman -S cups cups-pdf
		sudo systemctl enable cups.service
		yay pantum
		http://localhost:631/

	. Перезагружаемся
		reboot


Настраиваем эмулятор терминала Alacritty:
	1. Создаём папку конфигурации Alacritty
		mkdir alacritty && cd alacritty

	2. Копируем файл конфигурации
		cp .myconfig/alacritty.yml .config/alacritty


Настраиваем файловый менеджер ranger:
	1. Устанавливаем зависимости плагинов
		sudo pacman -S ueberzug
		git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

	2. Копируем файл конфигурации Ranger
		cp .myconfig/rc.conf .config/ranger
