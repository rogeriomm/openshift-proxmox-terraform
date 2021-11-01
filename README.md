
   * https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/
      * "Automated ISO/PXE installs with Ignition embedding" :cool:
 
   * You can edit your '<vmid>.conf' file in /etc/pve/qemu-server to include a line as follows:
```
args: -fw_cfg name=opt/com.coreos/config,file=path/to/example.ign
```

```commandline
sudo qm showcmd 801 --pretty
```

   * VM storage: _/dev/vda_


   * https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable&arch=x86_64: Download Fedora Core OS

# References
   * https://itnext.io/guide-installing-an-okd-4-5-cluster-508a2631cbee: Guide: Installing an OKD 4.5 Cluster
   * https://docs.fedoraproject.org/en-US/fedora-coreos/provisioning-qemu/: Provisioning Fedora CoreOS on QEMU
      * https://github.com/qemu/qemu/blob/master/docs/specs/fw_cfg.txt
           * https://forum.proxmox.com/threads/howto-startup-vm-using-an-ignition-file.63782/: PROXMOX Howto startup VM using an ignition file
   * https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines
   * https://github.com/TribalNightOwl/okd4-esxi-infra/blob/master/terraform/main.tf

