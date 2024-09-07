# GPU passthrough to a Windows Virtual Machine

In an attempt to create the ultimate workstation PC, I have decides to built a MiniITX that is capable of running both Linux for work, as well as Windows for games. The main OS will be a Linux OS and the Window OS will auto start on the background. The user will have the ability to switch between the Linux and the Windows VM using shortcut keys.

I'm using Arch Linux (btw) but the same idea can be applied to other Linux OS as well. My second iteration of the ultimate workstation, I passthrough the GPU on my Proxmox server. I was also able to get dual booting to work on the drive used by the VM for when I want to solely boot Windows. 

NOTE: I did not stick with this set up because I notice some latency while context switching between the VM and the host environment. This setup uses Looking Glass which is great but I think the software is still at it's infancy and I had issues switching between VM and Host OS.

### Hardware

- Gigabyte B650I AORUS ULTRA AM5
- Ryzen 7 7900: 12 cores with 24 threads
    - Ryzen chip has APU for the host OS
    - We can pin the CPU along with its thread directly to the VM.
- Nvidia 4070 Super
- 64GB RAM
- 2x 2TB NVME SSD

### Enable requirements on BIOS (settings for AMD CPU)

- SVM Module
- NX Mode
- IOMMU

### Verify that IOMMU is enabled

```jsx
sudo dmesg | grep -i -e DMAR -e IOMMU
```

- Example output:
    
    ```jsx
    [    0.000000] Command line: BOOT_IMAGE=/vmlinuz-linux root=UUID=463be187-f052-4e5e-8646-752e202ba0b7 rw rootflags=subvol=@ zswap.enabled=0 rootfstype=btrfs iommu=pt amd_iommu=on rd.driver.pre=vfio-pci loglevel=3
    [    0.047471] Kernel command line: BOOT_IMAGE=/vmlinuz-linux root=UUID=463be187-f052-4e5e-8646-752e202ba0b7 rw rootflags=subvol=@ zswap.enabled=0 rootfstype=btrfs iommu=pt amd_iommu=on rd.driver.pre=vfio-pci loglevel=3
    [    0.420687] iommu: Default domain type: Passthrough (set via kernel command line)
    [    0.463667] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
    [    0.463698] pci 0000:00:01.0: Adding to iommu group 0
    [    0.463709] pci 0000:00:01.1: Adding to iommu group 1
    [    0.463728] pci 0000:00:02.0: Adding to iommu group 2
    [    0.463740] pci 0000:00:02.1: Adding to iommu group 3
    [    0.463752] pci 0000:00:02.2: Adding to iommu group 4
    [    0.463767] pci 0000:00:03.0: Adding to iommu group 5
    [    0.463785] pci 0000:00:04.0: Adding to iommu group 6
    [    0.463803] pci 0000:00:08.0: Adding to iommu group 7
    [    0.463813] pci 0000:00:08.1: Adding to iommu group 8
    [    0.463824] pci 0000:00:08.3: Adding to iommu group 9
    [    0.463846] pci 0000:00:14.0: Adding to iommu group 10
    [    0.463857] pci 0000:00:14.3: Adding to iommu group 10
    [    0.463915] pci 0000:00:18.0: Adding to iommu group 11
    [    0.463927] pci 0000:00:18.1: Adding to iommu group 11
    [    0.463937] pci 0000:00:18.2: Adding to iommu group 11
    [    0.463948] pci 0000:00:18.3: Adding to iommu group 11
    [    0.463959] pci 0000:00:18.4: Adding to iommu group 11
    [    0.463970] pci 0000:00:18.5: Adding to iommu group 11
    [    0.463981] pci 0000:00:18.6: Adding to iommu group 11
    [    0.463991] pci 0000:00:18.7: Adding to iommu group 11
    [    0.464014] pci 0000:01:00.0: Adding to iommu group 12
    [    0.464026] pci 0000:01:00.1: Adding to iommu group 12
    [    0.464037] pci 0000:02:00.0: Adding to iommu group 13
    [    0.464049] pci 0000:03:00.0: Adding to iommu group 14
    [    0.464060] pci 0000:03:04.0: Adding to iommu group 15
    [    0.464071] pci 0000:03:05.0: Adding to iommu group 16
    [    0.464083] pci 0000:03:06.0: Adding to iommu group 17
    [    0.464094] pci 0000:03:07.0: Adding to iommu group 18
    [    0.464106] pci 0000:03:08.0: Adding to iommu group 19
    [    0.464118] pci 0000:03:09.0: Adding to iommu group 20
    [    0.464130] pci 0000:03:0a.0: Adding to iommu group 21
    [    0.464141] pci 0000:03:0b.0: Adding to iommu group 22
    [    0.464153] pci 0000:03:0c.0: Adding to iommu group 23
    [    0.464164] pci 0000:03:0d.0: Adding to iommu group 24
    [    0.464167] pci 0000:04:00.0: Adding to iommu group 14
    [    0.464170] pci 0000:0b:00.0: Adding to iommu group 21
    [    0.464174] pci 0000:0c:00.0: Adding to iommu group 22
    [    0.464177] pci 0000:0d:00.0: Adding to iommu group 23
    [    0.464181] pci 0000:0e:00.0: Adding to iommu group 24
    [    0.464193] pci 0000:0f:00.0: Adding to iommu group 25
    [    0.464213] pci 0000:10:00.0: Adding to iommu group 26
    [    0.464225] pci 0000:10:00.1: Adding to iommu group 27
    [    0.464237] pci 0000:10:00.2: Adding to iommu group 28
    [    0.464250] pci 0000:10:00.3: Adding to iommu group 29
    [    0.464261] pci 0000:10:00.4: Adding to iommu group 30
    [    0.464273] pci 0000:10:00.6: Adding to iommu group 31
    [    0.464284] pci 0000:11:00.0: Adding to iommu group 32
    [    0.468594] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
    ```
    

### Install required packages

```jsx
sudo pacman -S virt-manager virt-viewer qemu vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf swtpm
```

### Additional configuration from Stephan Raabe install script

== Start ==

**Remove # at the following lines: unix_sock_group = "libvirt" and unix_sock_rw_perms = "0770”**

```jsx
sudo vim /etc/libvirt/libvirtd.conf
```

**Modify /etc/libvirt/libvirtd.conf**

```jsx
sudo echo 'log_filters="3:qemu 1:libvirt"' >> /etc/libvirt/libvirtd.conf
sudo echo 'log_outputs="2:file:/var/log/libvirt/libvirtd.log"' >> /etc/libvirt/libvirtd.conf
```

**Add your user to the group**

```jsx
sudo usermod -a -G kvm,libvirt $(whoami)
```

**Enable services**

```jsx
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

**Modify Qemmu config**

```jsx
sudo vim /etc/libvirt/qemu.conf
```

Update:

```jsx
user = "your username"'
group = "your username"'
```

**Restart services to apply changes**

```
# ------------------------------------------------------
# Restart Services
# ------------------------------------------------------
sudo systemctl restart libvirtd

# ------------------------------------------------------
# Autostart Network
# ------------------------------------------------------
sudo virsh net-autostart default
```

**Reboot system**

== End ==

### Check IOMMU groups

```
#!/bin/bash
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;

```

Script this is also in Stephan’s archinstall repo: [https://gitlab.com/stephan-raabe/archinstall/-/tree/main/gpu-pt?ref_type=heads](https://gitlab.com/stephan-raabe/archinstall/-/tree/main/gpu-pt?ref_type=heads)

### Isolating the GPU

Find IOMMU group for the GPU

```xml
IOMMU Group 12:
	01:00.0 VGA compatible controller [0300]: NVIDIA Corporation AD104 [GeForce RTX 4070 SUPER] [**10de:2783**] (rev a1)
	01:00.1 Audio device [0403]: NVIDIA Corporation Device [**10de:22bc**] (rev a1)
IOMMU Group 13:
```

We will need the device IDs of the GPU for VFIO: 

Nvidia VGA ID = **10de:2783**

Nvidia Audio ID = **10de:22bc**

Add the device IDs to /etc/modprobe.d/vfio.conf

```xml
sudo vi /etc/modprob.d/vfio.conf
```

Add the following line: options vfio-pci ids=10de:2783,10de:22bc

### **Loading vfio-pci early**

**Stop the OS from loading the GPU before VFIO**

We have to stop the system from loading out GPU so we can pass it through from VFIO

There are 3 drivers that may be loading the GPU early on. Add the following lines to /etc/modprobe.d/vfio.conf

```xml
softdep nvidia pre: vfio-pci
softdep drm pre: vfio-pci
softdep nouveau pre: vfio-pci
```

**Loading from VFIO**

Modify /etc/mkinitcpio.conf

```
MODULES=(... vfio_pci vfio vfio_iommu_type1 ...)
HOOKS=(... modconf ...)
```

After modifying /etc/mkinitcpio.conf update initramfs:

```xml
sudo mkinitcpio -p linux
```

**Modify Grub:(/etc/default/grub)**

Add the following to **GRUB_CMDLINE_LINUX_DEFAULT**

```xml
iommu=pt amd_iommu=on rd.driver.pre=vfio-pci vfio-pci.ids=**10de:2783,10de:22bc** 
```

Update grub

```xml
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Verify GPU isolation**

After updating mkinitcpio.conf and grub do a system reboot.

Verify the GPU was properly isolate by running :

```xml
lspci -nnv
```

- Sample output
    
    ```jsx
    01:00.0 VGA compatible controller [0300]: NVIDIA Corporation AD104 [GeForce RTX 4070 SUPER] [10de:2783] (rev a1) (prog-if 00 [VGA controller])
    Subsystem: ASUSTeK Computer Inc. Device [1043:896e]
    Flags: fast devsel, IRQ 255, IOMMU group 12
    Memory at f5000000 (32-bit, non-prefetchable) [size=16M]
    Memory at f800000000 (64-bit, prefetchable) [size=16G]
    Memory at fc00000000 (64-bit, prefetchable) [size=32M]
    I/O ports at f000 [size=128]
    Expansion ROM at f6000000 [disabled] [size=512K]
    Capabilities: <access denied>
    Kernel driver in use: **vfio-pci**
    Kernel modules: nouveau, nvidia_drm, nvidia
    ```
    
    ```jsx
    01:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:22bc] (rev a1)
    Subsystem: ASUSTeK Computer Inc. Device [1043:896e]
    Flags: fast devsel, IRQ 255, IOMMU group 12
    Memory at f6080000 (32-bit, non-prefetchable) [disabled] [size=16K]
    Capabilities: <access denied>
    Kernel driver in use: **vfio-pci**
    Kernel modules: snd_hda_intel
    ```
    

## Creating the Virtual Machine

### Passing a drive to the Virtual Machine

Instead of passing out external drive directly using PCI, we’ll pass the drive using it’s windows file route. This can be found by going to ` /dev/disk/by-id/nvme-Samsung_SSD_990_EVO_2TB_S7M4NS0X110596E` 

- Example XML
    
    ```jsx
        <disk type="block" device="disk">
          <driver name="qemu" type="raw" cache="none" io="native" discard="unmap"/>
          <source dev="/dev/disk/by-id/nvme-Samsung_SSD_990_EVO_2TB_S7M4NS0X110596E"/>
          <target dev="vda" bus="virtio"/>
          <boot order="1"/>
          <address type="pci" domain="0x0000" bus="0x04" slot="0x00" function="0x0"/>
        </disk>
    ```
    

### Installing Looking Glass
[Installation guide](https://looking-glass.io/docs/B6/install/)

### CPU Pinning

If we have a system with a lot of CPU and we are willing to spare some for our VM, we can pin the CPU cores to be used exclusively by the VM. Ideally, the CPU should we passed to the VM should be closely grouped to each other. This is so that the pinned CPU can take advantage to it’s L3 cache.

The example CPU layout below show that core 6-11, 18-23 uses the same L3 cache. This is also a 12c/12t AMD CPU so we can assume that core 6-11, 18-23 are the cores and thread that uses the L3 cache. Thus, we we map these cores to the VM, there will be no performance issues as the L3 cache for these cores and threads will be used strictly by the VM. We we had a setup where the host CPU and the VM CPU shares the same L3 cache there will be a high rate of cache misses, which will lead to bad performance. 

- lscpu -e
    
    ```jsx
    CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE    MAXMHZ   MINMHZ       MHZ
      0    0      0    0 0:0:0:0          yes 5482.0000 400.0000 3590.9490
      1    0      0    1 1:1:1:0          yes 5482.0000 400.0000 5195.3662
      2    0      0    2 2:2:2:0          yes 5482.0000 400.0000 3716.1499
      3    0      0    3 3:3:3:0          yes 5482.0000 400.0000 3684.5820
      4    0      0    4 4:4:4:0          yes 5482.0000 400.0000 4195.5791
      5    0      0    5 5:5:5:0          yes 5482.0000 400.0000  400.0000
      6    0      0    6 8:8:8:1          yes 5482.0000 400.0000  400.0000
      7    0      0    7 9:9:9:1          yes 5482.0000 400.0000  400.0000
      8    0      0    8 10:10:10:1       yes 5482.0000 400.0000 3615.0381
      9    0      0    9 11:11:11:1       yes 5482.0000 400.0000 3570.3750
     10    0      0   10 12:12:12:1       yes 5482.0000 400.0000  400.0000
     11    0      0   11 13:13:13:1       yes 5482.0000 400.0000 4373.1318
     12    0      0    0 0:0:0:0          yes 5482.0000 400.0000 3568.5669
     13    0      0    1 1:1:1:0          yes 5482.0000 400.0000 3757.2561
     14    0      0    2 2:2:2:0          yes 5482.0000 400.0000 4890.8379
     15    0      0    3 3:3:3:0          yes 5482.0000 400.0000  400.0000
     16    0      0    4 4:4:4:0          yes 5482.0000 400.0000 5209.2222
     17    0      0    5 5:5:5:0          yes 5482.0000 400.0000 5359.4209
     18    0      0    6 8:8:8:1          yes 5482.0000 400.0000 5195.0601
     19    0      0    7 9:9:9:1          yes 5482.0000 400.0000 4592.5942
     20    0      0    8 10:10:10:1       yes 5482.0000 400.0000  400.0000
     21    0      0    9 11:11:11:1       yes 5482.0000 400.0000  400.0000
     22    0      0   10 12:12:12:1       yes 5482.0000 400.0000 4587.9229
     23    0      0   11 13:13:13:1       yes 5482.0000 400.0000  400.0000
    ```
    

Knowing this, when we create the VM, we can optimally pass the cores using the same L3 cache to the VM.

To dynamically isolate the CPU cores we’ll utilize the libvirt hooks. The following script will isolate the host system to use only some half of the CPUs; leaving the rest for us to attach to the VM.

```jsx
/etc/libvirt/hooks/qemu
#!/bin/sh

command=$2

if [ "$command" = "started" ]; then
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-5,12-17
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-5,12-17
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-5,12-17
elif [ "$command" = "release" ]; then
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-23
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-23
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-23
fi
```

- Example XML
    
    ```jsx
      ...
      <vcpu placement="static">12</vcpu>
      <iothreads>1</iothreads>
      <cputune>
        <vcpupin vcpu="0" cpuset="6"/>
        <vcpupin vcpu="1" cpuset="18"/>
        <vcpupin vcpu="2" cpuset="7"/>
        <vcpupin vcpu="3" cpuset="19"/>
        <vcpupin vcpu="4" cpuset="8"/>
        <vcpupin vcpu="5" cpuset="20"/>
        <vcpupin vcpu="6" cpuset="9"/>
        <vcpupin vcpu="7" cpuset="21"/>
        <vcpupin vcpu="8" cpuset="10"/>
        <vcpupin vcpu="9" cpuset="22"/>
        <vcpupin vcpu="10" cpuset="11"/>
        <vcpupin vcpu="11" cpuset="23"/>
        <emulatorpin cpuset="0-5,12-17"/>
        <iothreadpin iothread="1" cpuset="0-5,12-17"/>
      </cputune>
      ...
        <cpu mode="host-passthrough" check="none" migratable="on">
        <topology sockets="1" dies="1" clusters="1" cores="6" threads="2"/>
        <feature policy="require" name="topoext"/>
      </cpu>
      ...
    ```
    

## Troubleshoot

### Xorg failing after successful passthrough

We need to tell xorg explicitly which screen, card, driver to use so that it doesn’t fall back on the Primary GPU, which it thinks is our dGPU.

To do this we must use Xorg to help us create a Xorg config file.

```jsx
Xorg :0 -configure # generates an xorg.conf.new file
```

Using this file we can find out which monitor screen Xorg is detecting and which GPU is the default GPU for that screen and monitor.

Using `lscpi -nnk` we can see the BusID of the dGPU. Update the [xorg.conf.new](http://xorg.conf.new) file to use the iGPU BusID.

After this, reboot the system and the the iGPU will be used to capture the monitor.

- Example:
    
    ```jsx
    Section "Monitor"
    Identifier   "Monitor0"
    VendorName   "Monitor Vendor"
    ModelName    "Monitor Model"
    EndSection
    ```
    
    ```jsx
    Section "Monitor"
    Identifier   "Monitor1"
    VendorName   "Monitor Vendor"
    ModelName    "Monitor Model"
    EndSection
    ```
    
    ```jsx
    Section "Device"
    Identifier  "Card1"
    Driver      "modesetting"
    BusID       "PCI:16:0:0"
    EndSection
    ```
    
    ```jsx
    Section "Screen"
    Identifier "Screen0"
    Device     "Card1"
    Monitor    "Monitor0"
    SubSection "Display"
    Viewport   0 0
    Depth     1
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     4
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     8
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     15
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     16
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     24
    EndSubSection
    EndSection
    ```
    
    ```jsx
    Section "Screen"
    Identifier "Screen1"
    Device     "Card1"
    Monitor    "Monitor1"
    SubSection "Display"
    Viewport   0 0
    Depth     1
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     4
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     8
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     15
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     16
    EndSubSection
    SubSection "Display"
    Viewport   0 0
    Depth     24
    EndSubSection
    EndSection
    ```
### Helpful resources:
- [https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Prerequisites)
- [https://mathiashueber.com/windows-virtual-machine-gpu-passthrough-ubuntu/](https://mathiashueber.com/windows-virtual-machine-gpu-passthrough-ubuntu/)
- [https://sysguides.com/install-a-windows-11-virtual-machine-on-kvm#7-17-configure-virtual-network-interface](https://sysguides.com/install-a-windows-11-virtual-machine-on-kvm#7-17-configure-virtual-network-interface)
- [https://www.youtube.com/watch?v=uOuzFd8Gd2o](https://www.youtube.com/watch?v=uOuzFd8Gd2o)
- [https://www.youtube.com/watch?v=KVDUs019IB8](https://www.youtube.com/watch?v=KVDUs019IB8)
- [https://www.youtube.com/watch?v=29S7KReCdu8](https://www.youtube.com/watch?v=29S7KReCdu8)
- [https://gitlab.com/stephan-raabe/archinstall/-/blob/main/7-kvm.sh?ref_type=heads](https://gitlab.com/stephan-raabe/archinstall/-/blob/main/7-kvm.sh?ref_type=heads)
- [https://gitlab.com/stephan-raabe/archinstall/-/tree/main/gpu-pt?ref_type=heads](https://gitlab.com/stephan-raabe/archinstall/-/tree/main/gpu-pt?ref_type=heads)
- [https://wiki.archlinux.org/title/chroot#Running_on_Btrf](https://wiki.archlinux.org/title/chroot#Running_on_Btrfs)
- [https://looking-glass.io/](https://looking-glass.io/)
- [https://looking-glass.io/docs/B6/install/](https://looking-glass.io/docs/B6/install/)
