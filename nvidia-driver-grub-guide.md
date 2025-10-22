# NVIDIA Driver & GRUB Configuration Quick Guide

## Changing NVIDIA Driver Versions

### Arch Linux / Manjaro

**Check available drivers:**
```bash
pacman -Ss nvidia
```

**Install specific version:**
```bash
# Latest stable
sudo pacman -S nvidia nvidia-utils nvidia-settings

# LTS kernel
sudo pacman -S nvidia-lts

# DKMS (works with all kernels)
sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings
```

**Downgrade to specific version:**
```bash
# Search AUR archive
yay -S downgrade
sudo downgrade nvidia

# Or manually specify
sudo pacman -U /var/cache/pacman/pkg/nvidia-<version>.pkg.tar.zst
```

**Pin version (prevent updates):**
```bash
# Edit /etc/pacman.conf
sudo nano /etc/pacman.conf

# Add line:
IgnorePkg = nvidia nvidia-utils
```

### Ubuntu / Debian / Linux Mint

**List available drivers:**
```bash
ubuntu-drivers list
```

**Install recommended driver:**
```bash
sudo ubuntu-drivers autoinstall
```

**Install specific version:**
```bash
# Show available
apt search nvidia-driver

# Install specific (e.g., 535)
sudo apt install nvidia-driver-535

# Or use GUI
software-properties-gtk
```

**Remove NVIDIA drivers:**
```bash
sudo apt purge nvidia-* libnvidia-*
sudo apt autoremove
```

### Fedora

**List available:**
```bash
dnf list nvidia-driver
```

**Install from RPM Fusion:**
```bash
# Enable RPM Fusion repos first
sudo dnf install akmod-nvidia
sudo dnf install xorg-x11-drv-nvidia-cuda  # For CUDA
```

### Verify Installation

```bash
# Check driver version
nvidia-smi

# Check loaded module
lsmod | grep nvidia

# Check kernel module version
modinfo nvidia
```

## Setting GRUB Parameters

### Method 1: Edit GRUB Configuration (Persistent)

**1. Edit GRUB defaults:**
```bash
sudo nano /etc/default/grub
```

**2. Find the line starting with:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

**3. Add your parameters inside the quotes:**

**For Intel + NVIDIA (LOQ 15IRH8):**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1"
```

**For AMD + NVIDIA (LOQ 15APH8):**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1 video=2560x1600-32@60"
```

**Common parameter combinations:**
```
# Basic (most systems)
nvidia_drm.modeset=1

# With GSP firmware disabled (driver 555+ issues)
nvidia_drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0

# With suspend/resume support
nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1

# AMD hybrid with specific resolution
nvidia_drm.modeset=1 video=1920x1080-32@60

# Complete LOQ configuration
nvidia_drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0 quiet splash
```

**4. Update GRUB:**

```bash
# Arch / Manjaro
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Ubuntu / Debian / Mint
sudo update-grub

# Fedora
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

**5. Reboot:**
```bash
sudo reboot
```

### Method 2: Temporary Boot Parameter (Testing)

**1. During boot, press:**
- `Shift` (BIOS/MBR systems) or
- `Esc` (UEFI systems)

**2. Highlight your boot entry and press `e`**

**3. Find line starting with `linux`:**
```
linux /boot/vmlinuz-linux root=UUID=... quiet splash
```

**4. Add parameters at the end before `quiet splash`:**
```
linux /boot/vmlinuz-linux root=UUID=... nvidia_drm.modeset=1 quiet splash
```

**5. Press `Ctrl+X` or `F10` to boot**

Note: Changes are temporary and will be lost after reboot.

### Method 3: systemd-boot (Alternative bootloader)

**Edit boot entry:**
```bash
sudo nano /boot/loader/entries/arch.conf
```

**Add to options line:**
```
options root=PARTUUID=... rw nvidia_drm.modeset=1
```

## Module Configuration (Alternative to GRUB)

### Create modprobe configuration:

```bash
sudo nano /etc/modprobe.d/nvidia.conf
```

**Add common options:**
```
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
options nvidia NVreg_EnableGpuFirmware=0
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
```

**Regenerate initramfs:**

```bash
# Arch / Manjaro
sudo mkinitcpio -P

# Ubuntu / Debian
sudo update-initramfs -u

# Fedora
sudo dracut --force
```

## Verify Settings

**Check active kernel parameters:**
```bash
cat /proc/cmdline
```

**Check if modeset is enabled:**
```bash
sudo cat /sys/module/nvidia_drm/parameters/modeset
# Should show: Y
```

**Check NVIDIA DRM status:**
```bash
sudo dmesg | grep -i nvidia
```

## Common GRUB Parameters for NVIDIA Issues

| Parameter | Purpose | When to Use |
|-----------|---------|-------------|
| `nvidia_drm.modeset=1` | Enable kernel modesetting | **Always** (required for Wayland) |
| `nvidia.NVreg_EnableGpuFirmware=0` | Disable GSP firmware | Driver 555+ issues (lag, crashes) |
| `nvidia.NVreg_PreserveVideoMemoryAllocations=1` | Preserve VRAM on suspend | Black screen after resume |
| `video=<res>-32@60` | Force video resolution | AMD+NVIDIA hybrid systems |
| `nomodeset` | Disable all KMS | Emergency boot only |
| `nouveau.modeset=0` | Disable nouveau | Installing proprietary drivers |

## Troubleshooting

**GRUB changes not applying:**
```bash
# Verify syntax in /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
cat /proc/cmdline  # Check after reboot
```

**Driver not loading:**
```bash
# Check for conflicts
lsmod | grep nouveau  # Should be empty if using nvidia
sudo dmesg | grep -i nvidia  # Check for errors
```

**Black screen after driver installation:**
```bash
# Boot with nomodeset
# At GRUB: e → add nomodeset → Ctrl+X
# Then fix driver or remove it
```

**Rollback driver changes:**
```bash
# Arch - reinstall from cache
sudo pacman -U /var/cache/pacman/pkg/nvidia-<old-version>.pkg.tar.zst

# Ubuntu - install older version
sudo apt install nvidia-driver-<version>

# Or boot with old kernel that had working drivers
```

## Quick Reference: LOQ Laptop Configuration

**Recommended GRUB line for Lenovo LOQ with RTX 4060:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0"
```

**Required additional steps:**
1. Set BIOS to **Hybrid Graphics** mode
2. Install kernel 6.5+ (for Intel) or 6.8+ (for AMD)
3. Install proprietary nvidia-driver-535 or newer
4. For AMD variants: blacklist ideapad_laptop driver
5. Use X11 compositor for best stability

## Managing Kernel Updates

### Installing Recommended Kernel (Ubuntu/KDE Neon)

**Install latest recommended kernel:**
```bash
sudo apt update && sudo apt install linux-generic
```

The `linux-generic` meta-package always points to the recommended kernel for your distribution.

**Verify recommended version before installing:**
```bash
apt-cache policy linux-generic
```

**Check current kernel:**
```bash
uname -r
```

### Removing Kernel Package Holds

If you've locked kernel packages for testing, you need to remove the hold before updating:

**List all held packages:**
```bash
sudo apt-mark showhold
```

**Remove hold from specific kernel version:**
```bash
# Example for kernel 6.8
sudo apt-mark unhold linux-image-6.8.0-*-generic linux-headers-6.8.0-*-generic linux-modules-6.8.0-*-generic
```

**Remove hold from all kernel packages:**
```bash
sudo apt-mark unhold $(apt-mark showhold | grep linux-)
```

**After removing hold, update normally:**
```bash
sudo apt update && sudo apt upgrade
```

### Troubleshooting APT Locks

**If apt is locked by packagekitd (KDE's package manager):**
```bash
# Wait for packagekitd to finish, or kill it
sudo killall packagekitd

# Then retry your apt command
```

**Common lock errors:**
- `E: Could not get lock /var/lib/apt/lists/lock` - Another package manager is running
- `It is held by process XXXX (packagekitd)` - KDE Discover or automatic updates are active

---

**Always backup your system before major driver changes!**
