# Mirror OpenShift

You can use DCI OpenShift Agent to mirror OpenShift on a local registry.
It will use the dci-openshift-agent to mirror the containers, download the Red Hat CoreOS QCOW2 image and the OC binaries.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Configurations](#configurations)
- [Deploying the Registry (optional)](<#deploying-the-registry-(optional)>)
- [Running dci-openshift-agent](#running-dci-openshift-agent)

## Requirements:

- One RHEL server where we are going to install dci-openshift-agent. We call this server the jumpbox.
- A registry host. It will usually be the jumpbox but it can be another server.
  The registry host needs to have access to the Internet and at least 110 GB of disk space.
  dci-openshift-agent will download the required software repositories and container images to this server.
- A provisionner host. In a normal setup the provisionner host is another server.
  In a normal dci-openshift-installation, it's where the HTTP, DHCP, PXE servers (all services required by an OCP installation) are installed.
  For mirroring only, provisionner host can also be the jumpbox. dci-openshift-agent will download the appropriate Core OS QCOW2 image.
- An HTTP server running on the provisionner host
- A local registry running on the registry host

## Installation:

### Install dci-openshift-agent

You need to install dci-openshift-agent:

```
# dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# dnf -y install https://packages.distributed-ci.io/dci-release.el8.noarch.rpm
# subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms
# subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms
# dnf -y install dci-openshift-agent
```

### Configure the ssh key to your hosts

```
# su - dci-openshift-agent
% ssh-keygen
% ssh-copy-id dci-openshift-agent@jumpbox
```

### Get your jumbox dcirc.sh

dci-openshift-agent will use a `dcirc.sh` script file to access DCI servers.

- See how to setup an account on https://www.distributed-ci.io/: https://doc.distributed-ci.io/dci-openshift-agent/#installation-of-dci-jumpbox
- See how to create a `dcirc.sh` for your jumpbox: https://doc.distributed-ci.io/dci-openshift-agent/#etcdci-openshift-agentdcircsh

Check everything is working as expected

```
% source /etc/dci-openshift-agent/dcirc.sh
% dcictl topic-list
```

## Configuration

### /etc/dci-openshift-agent/hosts

You need to edit this file used by the `dci-openshift-agent` to specify where services, jumpbox, registry host and provision host are.

```
[all:vars]
# name of your cluster
cluster=dciokd

# Information about the registry running on the registry host
local_registry_host=jumpbox
local_registry_port=5000
#local_registry_user=MY_REGISTRY_USER
#local_registry_password=MY_REGISTRY_PASSWORD

# Where the oc binaries and RHCOS image will be downloaded
provision_cache_store="/opt/cache"

webserver_url=http://jumpbox

# Registry host where the local registry service is running
[registry_host]
jumpbox ansible_user=dci-openshift-agent ansible_connection=local

[registry_host:vars]
# The following cert_* variables are needed to create the certificates
#   when creating a disconnected registry. They are not needed to use
#   an existing disconnected registry.
disconnected_registry_auths_file=/opt/cache/jumpbox-auths.json
disconnected_registry_mirrors_file=/opt/cache/jumpbox-trust-bundle.yml
local_repo=ocp4/openshift4

[provisioner]
jumpbox ansible_user=dci-openshift-agent ansible_connection=local
```

### /etc/dci-openshift-agent/settings.yml

This file is used by dci-openshift-agent. You have to set the `dci_disconnected` option to `True` (to force the download of the containers on the local registry).
You need to set the `dci_topic` you want to mirror.

```
---
dci_disconnected: True
dci_topic: OCP-4.10
```

## Deploying the registry (Optional)

A playbook exist to deploy the registry and the webserver storing the QCOW images

On the jumpbox:

```
su - dci-openshift-agent
cd samples
ansible-playbook infrastructure.yml
```

It will install podman and create a local registry

## Running dci-openshift-agent

After the configuration and the registry are setup, we can mirror openshift using the dci-openshift-agent:

```
dci-openshift-agent-ctl -s -- -v --tags dci,job,pre-run
```
