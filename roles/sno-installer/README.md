# SNO-Installer role

This role contains playbooks to deploy OCP SNO in a very opinionated fashion. For SNO on libvirt it uses a livecd to bootstrap a VM, and for baremetal it uses dnsmasq as TFTP/DNS/DHCP server and bootstrap a physical node.

NOTE: Disconnected support only available on Baremetal SNO, virtual SNO still requires connected environment

## Required variables

- pull secret # pull secret content
- domain # FQDN to use
- cluster # name of the cluster
- dir # directory to store deployment files
- extcidrnet # CIDR of the network to use

## SNO Baremetal

### Required variables for SNO Baremetal

sno_install_type == baremetal
sno_extnet_ip # IP address to use on the SNO node from "extcidrnet"
- installation_disk
- ipmi_address
- ipmi_user
- ipmi_password
- ipmi_port
- baremetal_mac
- extcidrrouter
- extcidrdns
- cache_enabled

### DNS Entries Required

- api.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }}
- apps.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }}
- sno.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }} # DNS Name of the SNO node

### Disable cache

Cache can be disabled with variable cache_enabled=false, but the following variables with their values need to be defined; for kernel and initramfs images the path of the file in the tftp server is required, and for the rootfs image and ignition file the URL where the files can be downloaded. Example:

- coreos_pxe_kernel_path=/images/rhcos-48.84.202109241901-0-live-kernel-x86_64
- coreos_pxe_initramfs_path=/images/rhcos-48.84.202109241901-0-live-initramfs.x86_64.img
- coreos_pxe_rootfs_url=http://<web-server>/rhcos-48.84.202109241901-0-live-rootfs.x86_64.img
- coreos_sno_ignition_url=http://<web-server>:8080/4.8.15/sno.ign

### TFTP

To specify a server hosting dnsmasq server include a tftp_host group in the inventory. If not defined, the provisioner node will be chosen
See example in roles/sno-node-prep/tests/inventory-baremetal

### Registry

To specify a server hosting cache service include registry_host group in the inventory. Only required in disconnected mode.
See example in roles/sno-node-prep/tests/inventory-baremetal
