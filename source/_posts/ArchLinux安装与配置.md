---
title: ArchLinux安装与配置
categories:
  - 搞机
date: 2024-01-23 15:31:09
tags:
cover: images/20240123-153638.png
---

## Before

家里有台联想G400老古董，之前装了ubuntu,太卡，这次决定换成arch试试 (也是第一次装，记录一下安装过程)。

![](images/20240123-153638.png)

arch的逻辑和ubuntu不同，基本什么都要自己动手安装配置，下面从制作启动盘开始介绍：

## 步骤

### 下载&制作启动盘

```bash
wget wget https://geo.mirror.pkgbuild.com/iso/2024.01.01/archlinux-2024.01.01-x86_64.iso
wget https://geo.mirror.pkgbuild.com/iso/2024.01.01/b2sums.txt

# check
b2sum -c b2sums.txt

# write in udisk
cat path/to/archlinux-version-x86_64.iso > /dev/disk/by-id/usb-My_flash_drive
```

然后插上U盘，切换到主板的引导界面

### 启动盘系统的配置

从u盘启动后会进入一个shell，这是启动盘的系统，运行在ram，所作的配置重启后会消失。

```bash
timedatectl set-ntp true
timedatectl status

# 更新软件源
pacman -Sy pacman-mirrorlist
```

### 硬盘分区&挂载

```bash
lsblk -l

# 使用cfdisk进行分区，考虑到设备硬盘本身太过老旧，不设置swap分区
cfdisk /dev/sda

# 格式化分区
# EFI分区
mkfs.fat -F32 /dev/sda1
# root分区
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt
mount --mkdir /dev/sda1 /mnt/boot

# 生成分区表
genfstab -U /mnt >> /mnt/etc/fstab
```

### 系统预设

```bash
# 安装内核与基本软件
pacstrap -K /mnt base linux linux-firmware

# 切换到真正的系统
arch-chroot /mnt

# 时间
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 硬件时间
hwclock --systohc

# 安装软件
pacman -S vim grub efibootmgr intel-ucode networkmanager

vim /etc/locale.gen
locale-gen

# 写入grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH

# 配置&生成grub.cfg
vim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

exit
umount -R /mnt
reboot
```

## 注意

1. 退出u盘系统后发现启动失败不要慌，插上u盘后重新挂载硬盘，进入启动盘系统操作。
2. networkmanager需要提前装好，不然装好的系统没法联网

## 安装桌面（可选）

```bash
pacman -S xorg xorg-xinit gnome

# 写入.xinitrc
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
exec gnome-session

systemctl enable gdm
# 或者直接启动
startx
```

注意最好不要直接root登陆桌面，新建一个用户

## 参考

https://wiki.archlinux.org/title/Installation_guide

https://arch.icekylin.online/guide/rookie/basic-install.html
