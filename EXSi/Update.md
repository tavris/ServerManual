# Update System
### Environment
![Generic badge](https://img.shields.io/badge/vSphere_Hypervisor(EXSi)-7.0-green.svg)
![Generic badge](https://img.shields.io/badge/Chipset-SuperMicro_C621-green.svg)

## Pre-work
* Must be able to connect to the ESXi host with SSH.
* Since ESXi patches are cumulative patches, you only need to install the most recent version.
* Unless there is a special reason, only care about profiles whose Image Profile Name ends with `-standard`. In the case of `-no-tools`, VMTools is the removed version.
* You can update to ESXi 6.0 -> 6.7 with the patch file.

## How to
### Update patch
1. Connect to the ESXi server and check the currently installed version.  
    `Host` -> `Configuration` -> `Image Profile` (ex. ESXi-6.7.0-201905001-standard)
2. Visit the VMware ESXi Patch Tracker homepage, go to your ESXi installation version, and check the image profile version for the latest patch.
3. Go to the VMware homepage and log in as my vmware. After logging in, go to Product > All Products & Programs > Product Patches in the upper right corner.
4. After confirming that the latest version of the patch identified above is the same, click the Download button to download the patch file.
5. After enabling SSH, upload the downloaded file to SFTP or upload it to the ESXi server using the datastore browser.
6. Shut down all host virtual machines.
7. Enter the host `Maintenance mode` from the management console.
8. Check the update data in the update zip file.
9. Run `standard` of the update zip file you put in your datastore.
10. Reboot the host.

## Reference
1) [ESXi Patches](https://esxi-patches.v-front.de)
2) [WMWare Homepage](https://www.vmware.com)
