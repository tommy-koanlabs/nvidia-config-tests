# NVIDIA Driver Setup for KDE Neon (RTX 4060 Mobile)

## Overview

This documents the process I used to fix NVIDIA driver issues on a Lenovo LOQ 15ARP9 running KDE Neon. The system failed to wake from sleep (requiring hard reset) with newer kernels. After testing multiple kernel versions, only 6.8 worked reliably. Kernels 6.14 and 6.11 both had the same sleep/wake issues. I only found the kernel fix in an Arch forum after quite a bit of searching, and havent seen this tip elsewhere so I wanted to document it.

The main piece of code is a shell script that logs several key system parameters to better track changes to settings.

**System:** Lenovo LOQ 15ARP9
**GPU:** NVIDIA GeForce RTX 4060 Mobile
**OS:** KDE Neon (Ubuntu 24.04 base)
**Working Kernel:** 6.8.0-86-generic
**Working Driver:** 570.195.03


Originally I had a working configuration with 6.8 and 550, and it appeared that changing to X11 from Wayland fixed a lot of issues. However, I had to reinstall and ended up doing more testing. Right now it appears that Wayland does work along with the 570 driver so I am using that for now.

## Disclaimer

These instructions worked on my specific hardware configuration. Always review commands before running them with sudo, especially when modifying system configurations or installing/removing packages. Your system may require different parameters or kernel versions.

## Initial System Snapshot

Run the configuration check script to document your current system state before making changes.

```bash
# Make script executable
chmod +x ./check-graphics-config.sh

# Run configuration snapshot
sudo ./check-graphics-config.sh
```

### Report Contents

The script generates a timestamped report containing:

- Operating System version and distribution info
- Hardware information (system manufacturer, model)
- Linux kernel version
- Graphics information (nvidia-smi output, driver version, CUDA version)
- Display protocol (X11/Wayland)
- Package holds (pinned packages)
- GRUB configuration
- Current boot parameters
- Modprobe configuration for NVIDIA
- NVIDIA systemd service status


## Install Target Kernel

Install kernel 6.8.0-86. You can test other versions by modifying the version number in the search command.

```bash
# Search for available kernel packages
apt search 'linux-headers.*6.8.0-86'

# Install kernel headers and image
sudo apt install linux-headers-6.8.0-86-generic linux-image-6.8.0-86-generic
```

## Install NVIDIA Driver and Modules

### Remove Existing NVIDIA Drivers

```bash
# Purge all NVIDIA packages
sudo apt purge nvidia-* libnvidia-*

# Remove leftover dependencies
sudo apt autoremove
```

### Install NVIDIA Modules for Target Kernel

```bash
# Search for NVIDIA modules matching your kernel version
apt search 'linux-modules-nvidia.*6.8.0-86'

# Install NVIDIA modules for kernel 6.8.0-86
sudo apt install linux-modules-nvidia-570-6.8.0-86-generic

# Verify modules are available for current kernel
sudo apt-cache policy linux-modules-nvidia-570-$(uname -r)

# Install NVIDIA driver 570
sudo apt install nvidia-driver-570
```

### Pin Packages to Prevent Upgrades

```bash
# Hold all kernel 6.8.0-86 and NVIDIA 570 packages to prevent automatic updates
sudo apt-mark hold $(dpkg -l | grep '^ii' | grep -E 'nvidia.*570|6\.8\.0-86' | awk '{print $2}')
```

## Configure NVIDIA Kernel Modules

Edit `/etc/modprobe.d/nvidia.conf` and add the following parameters. These settings enable kernel modesetting, framebuffer support, disable GPU firmware (fixes driver 555+ issues), and enable video memory preservation for suspend/resume.

```bash
sudo nano /etc/modprobe.d/nvidia.conf
```

Add these lines:

```
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
options nvidia NVreg_EnableGpuFirmware=0
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
```

## Configure GRUB Boot Parameters

Edit `/etc/default/grub` to add NVIDIA parameters to the kernel command line. Only NVIDIA-relevant parameters are shown below.

```bash
sudo nano /etc/default/grub
```

Add to `GRUB_CMDLINE_LINUX`:

```
GRUB_CMDLINE_LINUX="nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=0"
```

Configure GRUB to remember kernel selection (allows choosing 6.8 as default):

```
GRUB_SAVEDEFAULT=true
GRUB_DEFAULT=saved
GRUB_TIMEOUT_STYLE=menu
```

Update GRUB configuration:

```bash
sudo update-grub
```

## Enable NVIDIA Power Management Services

Enable systemd services required for proper suspend, hibernate, and resume functionality.

```bash
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service
```

## Apply Changes and Verify

```bash
# Reboot to load new kernel and driver configuration
sudo reboot

# After reboot, verify configuration matches expected settings
sudo ./check-graphics-config.sh
```

## Common GRUB Parameters for NVIDIA

| Parameter | Purpose |
|-----------|---------|
| `nvidia_drm.modeset=1` | Enable kernel modesetting (required for Wayland) |
| `nvidia.NVreg_EnableGpuFirmware=0` | Disable GSP firmware (fixes driver 555+ issues) |
| `nvidia.NVreg_PreserveVideoMemoryAllocations=1` | Prevent black screen after resume |
| `nomodeset` | Disable all kernel modesetting (emergency boot only) |
| `nouveau.modeset=0` | Disable nouveau driver before installing proprietary |

## Driver Version Pinning Tool

The `nvidia-pin-toggle.sh` script manages apt pinning to control NVIDIA driver version upgrades. Use with caution, I had Claude write this and ended up not needing it so it hasnt been extensively tested. The 550 driver was originally the version that worked for me but Nvidia no longer supports it. Apt install will try to install the newest (580) driver instead. Eventually I found that 570 works so I abandoned this.

```bash
# Block driver 580 upgrades
sudo ./nvidia-pin-toggle.sh enable

# Allow driver 580 upgrades
sudo ./nvidia-pin-toggle.sh disable

# Check current pin status
./nvidia-pin-toggle.sh status

# Toggle pin on/off
sudo ./nvidia-pin-toggle.sh toggle
```

# Notes
11/21/2025 - Black screen on resuming from suspend, mouse still visible. Attempting to remove nvidia_drm.modeset=1 from grub
11/22/2025 - Issue persists. Adding nomodeset back, re-enabling gpu firmware, and switching to wayland. Also updating modprobe
