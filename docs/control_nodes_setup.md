# Automated setup of the Jump Host and the Provision Host

## Introduction

In order to standardize the setup of the control nodes (jumpbox and provision host) of the different lab environments, and remove difficulty for partners running restricted labs, the DCI OpenShift Agent project includes the playbooks described in this section.

## Requirements

Prior to running the playbooks:

- The Remote CI must exist already on the distributed-ci.io portal.
- An Ansible inventory for the lab must exist. Below you'll find an example of the inventory file needed to set up the control nodes. Although the same inventory that will be deployed with the DCI OpenShift Agent may be used, bear in mind that SSH access settings (username and SSH private key) for the Provision host in the agent's inventory are intended for the agent to operate the provisioner and may not be valid for management purposes, like running the setup_provisioner.yml playbook.
- Both hosts must have a working Red Hat 8.4 (at the time or writing this document) installation.
- Although the playbooks will try to set up a Red Hat set up through the Subscription Manager. It is strongly recommended that the subscription is set up in advance manually.
- SSH access on a privileged account must be available, either root or a SUDO enabled account.

## Example inventory

```
[jumpbox]
jumpbox-host ansible_host=192.168.122.111 ansible_user=redhat ansible_become=yes

[provisioner]
provision-host ansible_host=192.168.122.111 ansible_user=redhat ansible_become=yes

[provisioner:vars]
pub_nic=enp1s0
prov_nic=enp7s0

[jumpbox:vars]
dci_client_id='remoteci/21456e98'
dci_api_secret='0123456789abcdef'
dci_cs_url='https://api.distributed-ci.io/'
```

To bear in mind:
- Since the jumpbox group and host are not part of the DCI OpenShift Agent's inventory, you could include this group into the agent's inventory with privileged user SSH access settings.
- The provisioner group is part of the agent's inventory, and must include the SSH settings for the agent to operate the provisioner. This means, if you want to use the agent's inventory as the inventory for the setup_provisioner.yml playbook, you must overwrite the access settings from the command line.
- The provisioner variables pub_nic and prov_nic are also part of the agent's inventory and are used to set up the bridge interfaces for the bootstrap VM.
- The variables dci_client_id, dci_api_secret and dci_cs_url encode the authentication artifacts needed for the agent to register into the distributed-ci.io portal and can be retrieved from this portal after creating the Remote CI. Depending on the security concerns for the partner's lab, these could be protected with ansible-vault.


## Running the playbooks

During the setup of the jumpbox, the user dci-openshift-agent is created with a random SSH key pair.

The public key is retrieved locally and copied on the provisioner's dci user account authorized_keys file so the agent can log into and operate the provisioner.

This means the setup_jumpbox.yml playbook must be run before setup_provisioner.yml.

```ShellSession
$ cd samples/control_nodes_setup
$ ansible-playbook setup_jumpbox.yml -i /path/to/hosts
$ ansible-playbook setup_provisioner.yml -i /path/to/hosts
```

This example assumes both, passwordless SSH and SUDO are enabled for the login user. Depending on your setup the following arguments could be needed:

- *-k:* ask for the login password.
- *-K:* ask for the SUDO password.
- *--become:* force all the actions to be run with SUDO privileges
- *--private-key-file /path/to/key:* use the indicated non-default private key for passwordless login.

The playbooks will prompt for the RHN username and password. This values are only needed if the systems are not previously subscribed to the Red Hat Network. If the hosts are not subscribed, Ansible will try to do so for you. If they are, you may leave the prompts empty or provide fake values.
