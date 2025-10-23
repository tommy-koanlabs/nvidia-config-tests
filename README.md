# This is a shell script and process I used to debug my Nvidia driver issues on a Lenovo LOQ 15ARP9 running KDE Neon
# The system refused to wakeup from a sleep state requiring a hard reset with the power button
# The only thing that seems to make a real difference is downgrading the kernel version to 6.8; 6.14 and 6.11 dont work. I had to do a bunch of research and only found this tip in one place on an Arch forum, so I want to document this to help others


# First run the shell script to document your system
chmod +x ./check-graphics-config.sh
sudo ./check-graphics-config.sh


# Install new kernels:
## I am installing 6.8 but you can test other kernels to see what works, replace the 6.8.0-86 in the apt search (or just the -86) to broaden the search

```bash
apt search 'linux-headers.*6.8.0-86'
sudo apt install linux-headers-6.8.0-86-generic linux-image-6.8.0-86-generic
```


# Install modules:

**Remove NVIDIA drivers:**
```bash
sudo apt purge nvidia-* libnvidia-*
sudo apt autoremove


apt search 'linux-modules-nvidia.*6.8.0-86'
sudo apt install linux-modules-nvidia-570-6.11.0-29-generic

Check modules for kernel:
sudo apt-cache policy linux-modules-nvidia-570-$(uname -r)

Install driver
sudo apt install nvidia-driver-570


# Keep old working kernels and drivers:
sudo apt-mark hold $(dpkg -l | grep '^ii' | grep -E 'nvidia.*570|6\.8\.0-86' | awk '{print $2}')
```
# These are the parameters Im using, see what works on your system. This is just an example
# Modify modprobe and grub settings
sudo nano /etc/modprobe.d/nvidia.conf
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
options nvidia NVreg_EnableGpuFirmware=0

sudo nano /etc/default/grub
GRUB_CMDLINE_LINUX="nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=0"

# These settings will allow you to choose the default kernel in grub, you can change GRUB_TIMEOUT_STYLE to hidden once your system is working
GRUB_SAVEDEFAULT=true
GRUB_DEFAULT=saved
GRUB_TIMEOUT_STYLE=menu

sudo update-grub

# systemd services
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

# Finally run the shell script again to record the new system configuration
sudo ./check-graphics-config.sh

## Common GRUB Parameters for NVIDIA

| Parameter | Purpose |
|-----------|---------|
| `nvidia_drm.modeset=1` | Enable kernel modesetting (required for Wayland) |
| `nvidia.NVreg_EnableGpuFirmware=0` | Disable GSP firmware (fixes driver 555+ issues) |
| `nvidia.NVreg_PreserveVideoMemoryAllocations=1` | Prevent black screen after resume |
| `nomodeset` | Disable all kernel modesetting (emergency boot only) |
| `nouveau.modeset=0` | Disable nouveau driver before installing proprietary |

## Ubuntu 24.04 Official Kernel Versions

### GA (General Availability) Kernel

| Package | Actual Version | Release Type |
|---------|----------------|--------------|
| `linux-image-generic` | 6.8.0-x-generic | Original GA kernel (receives security updates) |

### HWE (Hardware Enablement) Kernels

| Package | Actual Version | Release Type |
|---------|----------------|--------------|
| `linux-image-generic-hwe-24.04` | 6.14.0-x-generic | Latest HWE (current default via rolling updates) |
| `linux-image-generic-6.14` | 6.14.0-x-generic | HWE kernel 6.14 |
| `linux-image-generic-6.11` | 6.11.0-x-generic | HWE kernel 6.11 

# Additional script blocks installing 580 packages, I had claude write this and didnt need it so use caution. Originally was intended to allow me to install the 550 driver without it being overwritten by 580
```bash
Enable pin (block 580):
sudo ./nvidia-pin-toggle.sh enable

Disable pin (allow 580):
sudo ./nvidia-pin-toggle.sh disable

Check status:
./nvidia-pin-toggle.sh status

Toggle on/off:
sudo ./nvidia-pin-toggle.sh toggle
```
