# VMware vSphere Hypervisor
### Environment
![Generic badge](https://img.shields.io/badge/vSphere_Hypervisor(EXSi)-7.0-green.svg)
![Generic badge](https://img.shields.io/badge/Chipset-SuperMicro_C621-green.svg)

### EXSi 7.0 Hardware Requirements
   - At least two CPU cores.
   - NX/XD enabled for the CPU in the BIOS.
   - Minimum 4GB of physical RAM.
   - Boot disk at least 8GB for USB or SD devices, and 32GB for other devices types such as HDD, SDD, or etc.

## Drivers
[VMware Compatibility Guide](https://www.vmware.com/resources/compatibility/search.php)

  - Ethernet [Flings](https://flings.vmware.com/community-networking-driver-for-esxi)

[MergeTool](https://github.com/VFrontDe/ESXi-Customizer-PS/blob/master/ESXi-Customizer-PS.ps1)

## Install Command
  - Step.1 Loading EXSi Installer
    - Press `Shift + O`
    - If change EXSi host storage size, Input command
      ```
      runweasel cdromBoot autoPartitionOSDataSize={Size of MB}
      ```
    - If more command need, see the [EXSi Boot Options](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.esxi.upgrade.doc/GUID-9040F0B2-31B5-406C-9000-B02E8DA785D4.html#GUID-9040F0B2-31B5-406C-9000-B02E8DA785D4)

## Port
  - EXSi all port list, see [Port requirements for ESXi](https://kb.vmware.com/s/article/2039095)
  
| TYPE | PORT | Required | Comment |
|---|---|---|---|
| UDP | 9 |  | Wake on LAN |
| TCP | 22 | O | SSH Access |
| TCP | 80 | O | Welcome Page |
| TCP/UDP | 902 | O | vCenter Server agent |
