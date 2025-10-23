# NVIDIA Driver Configuration & Testing
This project is dedicated to debugging the installation of Nvidia drivers on a KDE Neon system with a 4060 Mobile GPU. Use the check-graphics-config.sh script to access up to data information about the system. Always begin sessions by fetching the linked Ubuntu documentation

## Current System Information
- OS: KDE Neon
- Kernel: Linux 6.8.0-86-generic (target default boot kernel)
- Current Kernel: Linux 6.14.0-33-generic (testing)
- NVIDIA Driver: 570.195.03
- GPU: NVIDIA GeForce RTX 4060 Mobile
- Display Protocol: Wayland
- Platform: linux
- Status: ✅ **FULLY OPERATIONAL** (as of 2025-10-23)

## System Configuration (Completed - 2025-10-23)

### NVIDIA Driver Installation ✅
- **Driver Version**: 570.195.03
- **CUDA Version**: 12.8
- **Kernel Modules**: Properly loaded for kernel 6.8.0-86-generic
- **Display Manager**: Working with Wayland
- **GPU Utilization**: Confirmed working with KDE Plasma and applications

### Hibernation Setup ✅
All hibernation configuration completed and operational:

1. ✅ **Swap Partition Created**
   - Device: `/dev/nvme1n1p3`
   - UUID: `8ee02c29-527d-4277-a315-3c580a1a294e`
   - Size: 24GB (1.5x RAM)

2. ✅ **System Configuration**
   - `/etc/fstab`: Swap partition configured
   - GRUB: Resume parameter added to `GRUB_CMDLINE_LINUX`
   - Boot parameters verified in `/proc/cmdline`

3. ✅ **NVIDIA Hibernation Services**
   - `nvidia-suspend.service`: enabled
   - `nvidia-hibernate.service`: enabled
   - `nvidia-resume.service`: enabled
   - `nvidia-persistenced.service`: static

### NVIDIA Module Configuration
Located in `/etc/modprobe.d/nvidia.conf`:
```
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
options nvidia NVreg_EnableGpuFirmware=0
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
```

### GRUB Boot Parameters
Current configuration (`/etc/default/grub`):
```
GRUB_SAVEDEFAULT=true
GRUB_DEFAULT=saved
GRUB_CMDLINE_LINUX="nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=0 quiet nvme_load=YES loglevel=3 resume=UUID=8ee02c29-527d-4277-a315-3c580a1a294e"
GRUB_CMDLINE_LINUX_DEFAULT='quiet splash'
```

**Note**: Using `GRUB_SAVEDEFAULT=true` and `GRUB_DEFAULT=saved` to persist the last selected kernel boot option. This allows manual selection of 6.8.0-86-generic as the default.

**Critical Note**: The `acpi.ec_no_wakeup=1` parameter that previously caused display issues has been removed.

## Directory Contents
- `check-graphics-config.sh` - Graphics configuration check script
- `nvidia-driver-grub-guide.md` - GRUB configuration guide for NVIDIA drivers
- `commands.md` - Command reference for NVIDIA configuration
- `graphics-config-*.txt` - Timestamped graphics configuration snapshots
