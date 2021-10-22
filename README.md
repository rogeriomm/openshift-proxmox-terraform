   * You can edit your '<vmid>.conf' file in /etc/pve/qemu-server to include a line as follows:
```
args: -fw_cfg name=opt/com.coreos/config,file=path/to/example.ign
```

 
   * https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable&arch=x86_64: Download Fedora Core OS

# References
   * https://docs.fedoraproject.org/en-US/fedora-coreos/provisioning-qemu/: Provisioning Fedora CoreOS on QEMU
      * https://github.com/qemu/qemu/blob/master/docs/specs/fw_cfg.txt
   * https://itnext.io/guide-installing-an-okd-4-5-cluster-508a2631cbee: Guide: Installing an OKD 4.5 Cluster
   * https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines
   * https://github.com/TribalNightOwl/okd4-esxi-infra/blob/master/terraform/main.tf
   * https://forum.proxmox.com/threads/howto-startup-vm-using-an-ignition-file.63782/: Howto startup VM using an ignition file

