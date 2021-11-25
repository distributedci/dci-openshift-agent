# SNO-Installer role

## DNS Entries Required

api.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }}
.apps.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }} 
master-0.{{ cluster }}.{{ domain }}  =>  {{ sno_extnet_ip }}

## Required variables for SNO Baremetal

sno_install_type == baremetal
- installation_disk
- ipmi_address
- ipmi_user
- ipmi_password
