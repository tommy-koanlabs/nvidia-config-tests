sudo apt update && sudo apt install linux-generic

**Install specific version:**
```bash
apt search nvidia-driver
sudo apt install nvidia-driver-550
```

**Remove NVIDIA drivers:**
```bash
  sudo apt purge nvidia-driver-580 'libnvidia-*-580' 'nvidia-*-580'
  sudo apt purge nvidia-driver-580
  sudo apt autoremove
  sudo apt install --reinstall nvidia-driver-550
  sudo reboot

```

To see what's actually installed and for which kernels:
And to see what's currently loaded:
```bash
dpkg -l | grep linux-modules-nvidia | grep -E '(6\.8|6\.11|6\.14)'
lsmod | grep nvidia
modinfo nvidia | grep -E 'version|vermagic'
```

Install new kernels:
apt search linux-headers-6.8.0-86
sudo apt install linux-headers-${LINUX_FLAVOUR}
sudo apt install linux-headers-6.11.0-29-generic (already installed, good)
sudo apt install linux-headers-6.8.0-86-generic


linux-modules-nvidia-535-6.14.0-33-generic 

Install modules:
apt search 'linux-modules-nvidia.*6.8.0-86'

sudo apt install linux-modules-nvidia-535-6.8.0-85-generic
sudo apt install linux-modules-nvidia-535-6.11.0-29-generic

apt search 'linux-modules-nvidia*6.8.0-86'


Check modules for kernel:
sudo apt-cache policy linux-modules-nvidia-550-$(uname -r)
sudo apt-cache policy linux-modules-nvidia-535-$(uname -r)


Install driver
sudo apt install nvidia-driver-550


Enable pin (block 580):
sudo ./nvidia-pin-toggle.sh enable

Disable pin (allow 580):
sudo ./nvidia-pin-toggle.sh disable

Check status:
./nvidia-pin-toggle.sh status

Toggle on/off:
sudo ./nvidia-pin-toggle.sh toggle



```bash

info: Selecting GID from range 100 to 999 ...
info: Adding system user `nvidia-persistenced' (UID 120) ...
info: Adding new group `nvidia-persistenced' (GID 125) ...
info: Adding new user `nvidia-persistenced' (UID 120) with group `nvidia-persistenced' ...
info: Not creating `/nonexistent'.
Setting up nvidia-prime (0.8.17.2) ...
Setting up nvidia-kernel-source-580 (580.95.05-0ubuntu0.24.04.2) ...
Setting up dkms (3.0.11-1ubuntu13) ...
Setting up libnvidia-egl-wayland1:amd64 (1:1.1.13-1build1) ...
Setting up libnvidia-extra-580:amd64 (580.95.05-0ubuntu0.24.04.2) ...
Setting up libpkgconf3:amd64 (1.8.1-2build1) ...
Setting up libnvidia-common-580 (580.95.05-0ubuntu0.24.04.2) ...
Setting up pkgconf-bin (1.8.1-2build1) ...
Setting up libnvidia-gl-580:amd64 (580.95.05-0ubuntu0.24.04.2) ...
Setting up screen-resolution-extra (0.18.3ubuntu0.24.04.1) ...
Setting up libnvidia-decode-580:amd64 (580.95.05-0ubuntu0.24.04.2) ...
Setting up libnvidia-cfg1-580:amd64 (580.95.05-0ubuntu0.24.04.2) ...
Setting up nvidia-firmware-580-580.95.05 (580.95.05-0ubuntu0.24.04.2) ...
Setting up xserver-xorg-video-nvidia-580 (580.95.05-0ubuntu0.24.04.2) ...
Setting up nvidia-utils-580 (580.95.05-\0ubuntu0.24.04.2) ...
Setting up libnvidia-encode-580:amd64 (580.95.05-0ubuntu0.24.04.2) ...
Setting up pkgconf:amd64 (1.8.1-2build1) ...
Setting up nvidia-kernel-common-580 (580.95.05-0ubuntu0.24.04.2) ...
update-initramfs: deferring update (trigger activated)
update-initramfs: Generating /boot/initrd.img-6.11.0-29-generic
Created symlink /etc/systemd/system/systemd-hibernate.service.wants/nvidia-hibernate.service → /usr/lib/systemd/system/nvidia-hibernate.service.
Created symlink /etc/systemd/system/systemd-suspend.service.wants/nvidia-resume.service → /usr/lib/systemd/system/nvidia-resume.service.
Created symlink /etc/systemd/system/systemd-hibernate.service.wants/nvidia-resume.service → /usr/lib/systemd/system/nvidia-resume.service.
Created symlink /etc/systemd/system/systemd-suspend-then-hibernate.service.wants/nvidia-resume.service → /usr/lib/systemd/system/nvidia-resume.service.
Created symlink /etc/systemd/system/systemd-suspend.service.wants/nvidia-suspend.service → /usr/lib/systemd/system/nvidia-suspend.service.
Setting up pkg-config:amd64 (1.8.1-2build1) ...
Setting up nvidia-dkms-580 (580.95.05-0ubuntu0.24.04.2) ...
update-initramfs: deferring update (trigger activated)
update-initramfs: Generating /boot/initrd.img-6.11.0-29-generic
INFO:Enable nvidia
DEBUG:Parsing /usr/share/ubuntu-drivers-common/quirks/lenovo_thinkpad
DEBUG:Parsing /usr/share/ubuntu-drivers-common/quirks/put_your_quirks_here
DEBUG:Parsing /usr/share/ubuntu-drivers-common/quirks/dell_latitude
Loading new nvidia-580.95.05 DKMS files...
Building for 6.11.0-29-generic 6.14.0-33-generic
Building for architecture x86_64
Building initial module for 6.11.0-29-generic

```

