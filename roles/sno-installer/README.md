# SNO-Installer role

## DNS Entries Required

- api.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }}
- apps.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }} 
- master-0.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }}

## Required variables for SNO Baremetal

sno_install_type == baremetal
- installation_disk
- ipmi_address
- ipmi_user
- ipmi_password
- ipmi_port
- baremetal_mac
- extcidrrouter
- extcidrdns
- cache_enabled

## Disable cache

Cache can be disabled with variable cache_enabled=false, but the following variables with example values need to be defined:

- coreos_pxe_kernel_path=/images/rhcos-48.84.202109241901-0-live-kernel-x86_64
- coreos_pxe_initramfs_path=/images/rhcos-48.84.202109241901-0-live-initramfs.x86_64.img
- coreos_pxe_rootfs_url=http://<web-server>/rhcos-48.84.202109241901-0-live-rootfs.x86_64.img
- coreos_sno_ignition_url=http://<web-server>:8080/4.8.15/sno.ign

