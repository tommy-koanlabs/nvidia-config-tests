# NVIDIA Driver Configuration & Testing
This project is dedicated to debugging the installation of Nvidia drivers on a KDE Neon system with a 4060 Mobile GPU. Use the check-graphics-config.sh script to access up to data information about the system. Always begin sessions by fetching the linked Ubuntu documentation

## Current System Information
- OS: KDE Neon
- Kernel: Linux 6.11.0-29-generic
- NVIDIA Driver: 550
- Platform: linux

## NVIDIA Driver Installation Progress

### Completed Steps
1. ✅ **Module Installation Verification** (2025-10-22)
   - Verified NVIDIA kernel modules are installed for kernel 6.11.0-29-generic
   - Package: `linux-modules-nvidia-550-6.11.0-29-generic`
   - Version: `6.11.0-29.29~24.04.1+3`
   - Status: Installed and up-to-date

   **Verification command:**
   ```bash
   sudo apt-cache policy linux-modules-nvidia-550-$(uname -r)
   ```

   **Common Issue Encountered:** When using environment variables like `${DRIVER_BRANCH}`, ensure they're expanded before passing to `sudo`. Use direct values or wrap in shell command: `sudo sh -c 'DRIVER_BRANCH=550 apt-cache policy ...'`

### Next Steps
- Continue with remaining steps from Ubuntu NVIDIA driver installation documentation
- Reference: https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/

## Hibernation Setup (In Progress - 2025-10-23)

### Completed Steps
- ✅ Decided on 24GB swap partition size (1.5x RAM)
- ✅ Created swap partition at `/dev/nvme1n1p3` with GParted
- ✅ Initialized swap partition with `mkswap`
- ✅ Activated swap partition with `swapon`
- ✅ Updated `/etc/fstab` with swap partition entry:
  ```
  UUID=8ee02c29-527d-4277-a315-3c580a1a294e none swap sw 0 0
  ```
- ✅ Verified swap is active and working (23GB available)
- ✅ Old swapfile was already removed (not present in /etc/fstab)

### Current Task
Update GRUB with resume parameter and test hibernation.

### Next Steps
1. ⏸️ **IN PROGRESS**: Edit `/etc/default/grub` and add resume parameter:
   ```
   GRUB_CMDLINE_LINUX_DEFAULT='quiet splash resume=UUID=8ee02c29-527d-4277-a315-3c580a1a294e'
   ```
2. ⏸️ Run `sudo update-grub` to update boot configuration
3. ⏸️ Reboot system
4. ⏸️ Test hibernation with `systemctl hibernate`

### Swap Partition Details
- **Device**: `/dev/nvme1n1p3`
- **UUID**: `8ee02c29-527d-4277-a315-3c580a1a294e`
- **Size**: 24GB
- **PARTUUID**: `a9c0e13d-bb02-40b9-8c10-6074b96bbf1a`

## Directory Contents
- `check-graphics-config.sh` - Graphics configuration check script
- `nvidia-driver-grub-guide.md` - GRUB configuration guide for NVIDIA drivers
- `commands.md` - Command reference for NVIDIA configuration
- `graphics-config-*.txt` - Timestamped graphics configuration snapshots
