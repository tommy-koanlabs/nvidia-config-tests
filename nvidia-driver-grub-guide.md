# NVIDIA Driver & GRUB Configuration Quick Guide

## NVIDIA Driver Installation & Removal

### Ubuntu / Debian / KDE Neon

**Install recommended driver:**
```bash
sudo ubuntu-drivers autoinstall
```

**Install specific version:**
```bash
apt search nvidia-driver
sudo apt install nvidia-driver-550
```

**Remove NVIDIA drivers:**
```bash
sudo apt purge nvidia-* libnvidia-*
sudo apt autoremove
```

**Verify installation:**
```bash
nvidia-smi
lsmod | grep nvidia
```

## Changing GRUB Boot Parameters

### Edit GRUB Configuration (Persistent)

**1. Edit GRUB file:**
```bash
sudo nano /etc/default/grub
```

**2. Find and modify:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

**3. Add your parameters inside the quotes, then save.**

**4. Update GRUB (Ubuntu/Debian):**
```bash
sudo update-grub
```

**5. Reboot:**
```bash
sudo reboot
```

**Verify changes applied:**
```bash
cat /proc/cmdline
```

### Change Default Kernel at Boot

**Boot the newest kernel by default:**
```bash
sudo nano /etc/default/grub
```
Set:
```
GRUB_DEFAULT=0
```
Then update GRUB:
```bash
sudo update-grub
sudo reboot
```

**Boot a specific kernel by default:**

First, list available kernels during boot by editing GRUB to show the menu (remove `GRUB_TIMEOUT_STYLE=hidden`), or check the menu structure. Then use the submenu index format:
```
GRUB_DEFAULT="1>2"
```
Where `1` is the submenu (e.g., "Advanced options") and `2` is the kernel index within that submenu.

**Save last selected kernel and load it as default:**

Edit `/etc/default/grub` and set:
```
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

Then update and reboot:
```bash
sudo update-grub
sudo reboot
```

Now GRUB will remember whichever kernel you selected at the previous boot and boot that by default. You can change kernels at boot time using the GRUB menu (press Shift during boot), and your selection will be saved automatically.

## Common GRUB Parameters for NVIDIA

| Parameter | Purpose |
|-----------|---------|
| `nvidia_drm.modeset=1` | Enable kernel modesetting (required for Wayland) |
| `nvidia.NVreg_EnableGpuFirmware=0` | Disable GSP firmware (fixes driver 555+ issues) |
| `nvidia.NVreg_PreserveVideoMemoryAllocations=1` | Prevent black screen after resume |
| `nomodeset` | Disable all kernel modesetting (emergency boot only) |
| `nouveau.modeset=0` | Disable nouveau driver before installing proprietary |

### Example Configurations

**Basic NVIDIA setup:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1"
```

**With suspend/resume support:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"
```

**RTX 4060 Laptop (Lenovo LOQ):**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0"
```

## Kernel Management

### Check Current Kernel

```bash
uname -r
```

### List Available Kernels

**Check what's installed:**
```bash
ls /boot/vmlinuz-*
```

**Search for available versions in repos:**
```bash
apt-cache madison linux-image-generic
```

**Show policy and versions:**
```bash
apt-cache policy linux-image-generic
apt-cache policy linux-image-generic-hwe-24.04
```

### Install Kernels

**Install latest recommended kernel:**
```bash
sudo apt update && sudo apt install linux-generic
```

**Install HWE (Hardware Enablement) kernel for newer hardware:**
```bash
sudo apt update && sudo apt install linux-generic-hwe-24.04
```

**Install from mainline GUI:**
```bash
sudo apt install mainline
sudo mainline
```
Then select kernel version in the GUI.

**Install from mainline shell script (alternative):**
```bash
# Download and install script
wget https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
chmod +x ubuntu-mainline-kernel.sh
sudo mv ubuntu-mainline-kernel.sh /usr/local/bin/

# List available kernel series
ubuntu-mainline-kernel.sh -r

# Install latest kernel
sudo ubuntu-mainline-kernel.sh -i

# Install specific version
sudo ubuntu-mainline-kernel.sh -i v6.14.0
```

### Remove Old Kernels

**List held packages (locked kernels):**
```bash
sudo apt-mark showhold
```

**Remove kernel hold:**
```bash
# Remove hold from specific kernel
sudo apt-mark unhold linux-image-6.8.0-*-generic linux-headers-6.8.0-*-generic linux-modules-6.8.0-*-generic

# Remove all kernel holds
sudo apt-mark unhold $(apt-mark showhold | grep linux-)
```

**Remove old kernel packages:**
```bash
sudo apt autoremove
```

**Force remove specific old kernel version:**
```bash
sudo apt purge linux-image-6.8.0-79-generic linux-headers-6.8.0-79-generic
```

**Remove kernel installed via mainline script:**
```bash
# List installed kernels
sudo ubuntu-mainline-kernel.sh -l

# Remove a kernel (choose version interactively)
sudo ubuntu-mainline-kernel.sh -u
```

### Manage Repositories

**Enable proposed repository (testing packages):**
```bash
sudo add-apt-repository proposed
sudo apt update
```

**Disable proposed repository:**
```bash
sudo add-apt-repository --remove proposed
sudo apt update
```

**List all enabled repos:**
```bash
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/
```

**Remove broken PPA:**
```bash
sudo add-apt-repository --remove ppa:username/ppa-name
```

**Remove repository by file:**
```bash
sudo rm /etc/apt/sources.list.d/repository-name.list
sudo apt update
```

### Troubleshoot APT Lock Issues

**If apt is locked by packagekitd (KDE package manager):**
```bash
sudo killall packagekitd
sudo apt update
```

**Common lock errors:**
- `E: Could not get lock /var/lib/apt/lists/lock` - Another package manager is running
- `It is held by process XXXX (packagekitd)` - KDE Discover or automatic updates active

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
| `linux-image-generic-6.11` | 6.11.0-x-generic | HWE kernel 6.11 |

**Note:** `linux-image-generic-hwe-24.04` automatically tracks the newest available HWE kernel. As of now, it points to 6.14. Ubuntu's rolling HWE model means it will update to newer kernels as they're released.

---

**Always backup your system before major driver changes!**
