# Microshift installation

In this section of the documentation we will see how to run the DCI OpenShift Agent to install Microshift on a system. At the end of this documentation you should have at least one system under test (SUT) running Microshift.

Before starting, check that you have followed the [get started](get_started). Normally you should have a ~/dcirc.sh file available and dcictl installed. The `dcictl --version` command should return the client version.

The Microshift installation require a dedicated RHEL 9.2+ system. It could be a virtual machine or a baremetal server.

The rest of the documentation is performed as root user.

## Installing the DCI OpenShift Agent

The `dci-openshift-agent` is packaged and available as a RPM file. However `epel-release` along with additional support
repos must be installed first:

For RHEL-8

```console
subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms
subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
```

For CentOS Stream 8

```console
dnf install centos-release-ansible-29.noarch
```

For Both

```console
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --add-repo=https://releases.ansible.com/ansible-runner/ansible-runner.el8.repo
dnf -y install dci-openshift-agent
```

## Image builder system

To build the image, you need a dedicated RHEL 9.2+ system. It could be a virtual machine or a baremetal server.

Verify you can ssh on the system without any password.

```console
ssh root@image-builder
```

## Edit your inventory file

Modify your inventory file (`/etc/dci-openshift-agent/hosts`) to add the `image_builder` system

```
[builder]
image_builder ansible_user=root ansible_host=xxx.xxx.xxx.xxx ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
```

## Edit your settings file

Modify your settings file (`/etc/dci-openshift-agent/settings.yml`)

`dci_topic` and `dci_components_by_query` helps you to choose the version of Microshift you want to test:

```yaml
---
dci_topic: OCP-4.16
dci_components_by_query: ['type:repo,display_name:Microshift*']
```

## Run the installation manually


```console
ansible-playbook dci-microshift-agent.yml -e @/etc/dci-openshift-agent/settings.yml -i /etc/dci-openshift-agent/hosts
```
