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


sudo apt install linux-modules-nvidia-535-6.11.0-29-generic

sudo apt install nvidia-driver-535


Check modules for kernel:
sudo apt-cache policy linux-modules-nvidia-550-$(uname -r)
sudo apt-cache policy linux-modules-nvidia-535-$(uname -r)


Install driver
sudo apt install nvidia-driver-550


s
Keep old working kernels and drivers:
sudo apt-mark hold $(dpkg -l | grep '^ii' | grep -E 'nvidia.*570|6\.8\.0-86' | awk '{print $2}')


# Additional script blocks installing 580 packages
Enable pin (block 580):
sudo ./nvidia-pin-toggle.sh enable

Disable pin (allow 580):
sudo ./nvidia-pin-toggle.sh disable

Check status:
./nvidia-pin-toggle.sh status

Toggle on/off:
sudo ./nvidia-pin-toggle.sh toggle
