# Microshift installation

In this section of the documentation we will see how to run the DCI OpenShift Agent to install Microshift on a system. At the end of this documentation you should have at least one system under test (SUT) running Microshift.

Before starting, check that you have followed the [get started](get_started). Normally you should have a ~/.config/dci-pipeline/dci_credentials.yml file available and dcictl installed. The `dcictl --version` command should return the client version.

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

## Create a repository to save your settings

```
mkdir <your company>-<lab>-config
cd <your company>-<lab>-config
touch install-microshift.yaml
touch ansible.cfg
```

## Edit install-microshift.yaml

Modify your pipeline file `install-microshift.yaml`:

```yaml
- name: Microshift
  stage: install
  ansible_playbook: /usr/share/dci-openshift-agent/plays/microshift/main.yml
  ansible_cfg: ./ansible.cfg
  dci_credentials: ~/.config/dci-pipeline/dci_credentials.yml
  ansible_extravars:
    http_store: "/opt/http_store"
    dci_cluster_configs_dir: "~/clusterconfigs"
    rhsm_offline_token: "REPLACE_ME"
    rhsm_org_id: "REPLACE_ME"
    rhsm_activation_key: "REPLACE_ME"
    suts:
      - name: "sut1"
        memory: 4096
        vcpu: 2
        disk_size: 20
  topic: OCP-4.16
  components:
    - repo?name:Microshift 4.16.0 ec.2
```

* `rhsm_offline_token`: RHSM offline token. Get it [here](https://access.redhat.com/management/api)
* `rhsm_org_id` and `rhsm_activation_key`: RHSM organization ID and activation key. Information available on [console.redhat.com](https://console.redhat.com/insights/connector/activation-keys)
* `suts`: Describe the system under tests the agent will create. We are using Redfish to install Microshift OStree ISO on the SUTs. Sushy tools is used to control virtual systems with Redfish protocol. 
* `topic` and `components`: Choose the right version of Microshift you want to test.
* `http_store`: Location of the data folder served by a HTTP server on port 80. During the process, a `http://localhost:80/microshift.iso` will be created and used by the agent to provision the SUTs.
* `dci_cluster_configs_dir`: Where the kubeconfig files are saved. You will have for example a `~/clusterconfigs/kubeconfig-sut1` file for `sut1`.

## Edit ansible.cfg

Modify your pipeline file `ansible.cfg`:

```ini
[defaults]
library             = /usr/share/dci/modules/
module_utils        = /usr/share/dci/module_utils/
action_plugins      = /usr/share/dci/action_plugins/
filter_plugins      = /usr/share/dci/filter_plugins/
callback_plugins    = /usr/share/dci/callback/
callback_whitelist  = dci,junit
retry_files_enabled = False
host_key_checking   = False
roles_path          = /usr/share/dci/roles/
log_path            = ansible.log

[privilege_escalation]
become_method       = sudo
```

## Run the installation manually


```console
dci-pipeline @pipeline:name="install microshift" install-microshift.yaml
```
