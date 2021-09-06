# Setting up the Jumpbox and Provision Host

## Overview

This project includes playbooks to install the jumpbox and provision host in a new lab.

These playbooks were designed to run from a workstation with SSH access to both target hosts, just after the mechanical installation is completed.

The playbooks could be run from the jumpbox itself, but this would entail having previous manual configurations of the host, like installing ansible.

## Requirements

- The Remote CI entity must have been created.

- The target hosts must be SSH accessible, either with password or key pair. The login may be reflected in the inventory.

- Root permissions must be available, either via login as root user or through sudo.

- There must exist a DHCP service serving the network configuration for the baremetal interface in the provision host. (A future version of the playbook may be able to handle static IP address

## Inventory and variables

The following sample inventory depicts the bare minimum settings the playbooks need to operate:

```
[jumpbox]
jumpbox.cluster.example.lab ansible_become=yes ansible_user=root

[provisioner]
provisioner.cluster.example.lab ansible_become=yes ansible_user=root

[provisioner:vars]
pub_nic=eth1
prov_nic=eth0
# (optional) pub_bridge_ip: address to assign to the baremetal interface. Is
# undefined, DHCP method is assumed and a DHCP server must exist in the subnet
# for the provision host to be accessible.
#pub_bridge_ip=192.168.1.10/24
# (optional) pub_bridge_gw: address of the gateway for the baremetal network.
# If undefined, the playbook defaults to the first address in the subnet
# address space.
#pub_bridge_gw: 192.168.1.1
# (optional) prov_bridge_ip defaults to 172.22.0.1/21
#prov_bridge_ip=172.22.0.1/21

[all:vars]
dci_client_id='remoteci/0123456-789a-bcdef'
dci_api_secret='1234567890abcdefABCDEF'
dci_cs_url='https://api.distributed-ci.io/'
```

The inventory must contain the groups "jumpbox" and "provisioner", each containing the respective target host.

In the sample, we can see some mandatory variables, like:

- *pub_nic:* Identifies the interface in the provision host connected to the baremetal network.

- *prov_nic:* Identifies the interface in the provision host connected to the provisioning network.

- *dci_client_id:* Contains the remote CI client ID retrieved from the distributed-ci console.

- *dci_api_secret:* Contains the remote CI API secret retrieved from the distributed-ci console.

- *dci_cs_url:* URL to the distributed-ci console. Although the value should not change across remote-cis, it may be retrieved from the remote-ci login artifacts as well.

Optionally, for each host, the login and privilege escalation variables could be set. This is especially interesting if the login method differs between the two hosts. Otherwise, this settings may be defined from the command line.

This inventory could be merged into the actual DCI inventory, but there could be conflicts with some of the variables that would have to be addressed through the command line call or somehow else.

## Running the playbooks

To run the playbooks:

1. Change directory to a local copy of the dci-openshift-agent repo:

```
# cd /path/to/dci-openshift-agent
```

2. Run the setup_jumpbox playbook:

```
# ansible-playbook samples/control_nodes_setup/setup_jumpbox.yml -i /path/to/inventory [-u username] [-k|--private-key-file=/path/to/ssh/private/key] [--become] [-K] [-v]
```

3. Run the setup_provisioner playbook:

```
# ansible-playbook samples/control_nodes_setup/setup_provisioner.yml -i /path/to/inventory [-u username] [-k|--private-key-file=/path/to/ssh/private/key] [--become] [-K] [-v]
```

In the command examples above, the login parameters are only needed if not defined in the inventory:

- *-u username:* login user if different than the local active user.

- *-k:* ask for the login password.

- *--private-key-file=/path/to/ssh/private/key:* path to the SSH private key if passwordless login was setup.

- *--become:* if login with a non-root user, run all the instructions with sudo.

- *-K:* ask for the sudo password. Not needed if login as root or passwordless sudo was setup for the login user.

- *-v:* run ansible in verbose mode.
