# acm-sno role

This role allows the deployment of SNO (Single Node Openshift) instances using ACM (Advanced Cluster Management). In order to execute the acm-sno role a running OpenShift cluster and its credentials are required. i.e. through the KUBECONFIG environment variable.

Please see [acm-setup](../acm-setup/README.md) role in case configuring the ACM hub is required.

```shell
export KUBECONFIG=<path_kubeconfig>
```

Main tasks:
- Provisioning the target host using a defined BMC
- Configure the ACM's CIM (Cluster Infrastructure Management) database
- Setup the instance parameters
- Request the cluster deployment
- The role will disable the ClusterImageSet subscription

The role will pull some data from the Hub cluster (the one running ACM) and apply them to the spoke cluster. Some of the inherited details are:
- The cluster pull_secret
- The SSH public key assigned to the OS user called "core"
- The CA certificate and registries.conf entries if the Hub has them available (Usually in air-gapped environments or with a local registry service)

## Variables

| Variable                           | Default                       | Required    | Description                                   |
| ---------------------------------- | ----------------------------- | ----------- | ----------------------------------------------|
| acm_cluster_name                   | sno                           | No          | Name of the spoke cluster                     |
| acm_base_domain                        | example.com                   | No          | DNS domain for the SNO instance|
| acm_cluster_location                   | Unknown                       | No          | SNO server location|
| acm_bmc_user                           | None                          | Yes         | Username for the BMC|
| acm_bmc_pass                           | None                          | Yes         | Password for the BMC|
| acm_bmc_address                        | None                          | Yes         | IP address of the target BMC                  |
| boot_mac_address                     | None                          | Yes         | MAC Address of the interface to be used to bootstrap the node |
| acm_machine_cidr                       | None                          | Yes         |  	A block of IPv4 or IPv6 addresses in CIDR notation used for the target bare-metal host external communication. Also used to determine the API and Ingress VIP addresses when provisioning DU single-node clusters.|
| acm_release_image                       | quay.io/openshift-release-dev/ocp-release:4.9.47-x86_64| No        |The specific release image to deploy. The release image can be provided using a SHA but it must match with the version specified for the RHCOS images|
| acm_cluster_network_host_prefix         | /23                           | No          | Network prefix for cluster nodes|
| acm_cluster_network_cidr                | 10.128.0.0/14                 | No          | A block of IPv4 or IPv6 addresses in CIDR notation used for communication among cluster nodes|
| acm_service_network_cidr                | 172.30.0.0/16                 | NO          | A block of IPv4 or IPv6 addresses in CIDR notation used for cluster services internal communication|
| acm_iso_url                            | https://rhcos.mirror.openshift.com/art/storage/releases/rhcos-4.9/49.84.202207192205-0/x86_64/rhcos-49.84.202207192205-0-live.x86_64.iso"                                 | No         | ISO boot Image. See: https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/ |
| acm_root_fs_url                        | https://rhcos.mirror.openshift.com/art/storage/releases/rhcos-4.9/49.84.202207192205-0/x86_64/rhcos-49.84.202207192205-0-live-rootfs.x86_64.img                         | No                            | Root FS image. See https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/|
| acm_ocp_version                        | 4.9.47             | No             | Full OCP version to install on the spoke cluster. <major>.<minor>.<patch> |

*Important:* The values defined for the `acm_ocp_version` must match with the images provided for `acm_iso_url` and `acm_root_fs_url` variables.

## Role requirements

### Networking

The proper network connectivity between ACM and the target servers and BMCs should be in place.

### DHCP configuration

A DHCP serving for the range defined in the `acm_machine_cidr` must exists.

### DNS configuration

It is recommended that the following DNS entries should be already configured in order to allow ACM to import the cluster as a managed instance automatically.

<cluster_name>.<base_domain>
api.<cluster_name>.<base_domain>
apps.<cluster_name>.<base_domain>
multicloud-console.apps.<cluster_name>.<base_domain>

## Integration with DCI

The role integration with DCI will pull the CA and registries.conf files according the type of environment (connected/disconnected) of the Hub Cluster.

- Spoke SNO clusters created by a Hub that is disconnected will inherit the mirroring configs from the Hub cluster.
- Spoke SNO clusters created by a Hub that is connected will not inherit the mirroring configs from the Hub cluster.

Without DCI, pulling the mirroring configs from a cluster can be managed by the `acm_disconnected` setting. Both, the CA and the registry.conf files will be obtained from the Hub cluster's machine configs during the setup.

## Usage example

See below for an example of how to use the acm-setup role to configure ACM.

```yaml
- name: "Deploy an SNO node via ACM"
  vars:
    acm_force_deploy: true
    acm_cluster_name: server9
    acm_base_domain: example.com
    acm_bmc_address: 192.168.16.158
    acm_boot_mac_address: b4:96:91:ba:16:5b
    acm_machine_cidr: 192.168.16.0/25
    acm_bmc_user: REDACTED
    acm_bmc_pass: REDACTED
    acm_iso_url: https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.10/latest/rhcos-4.10.16-x86_64-live.x86_64.iso
    acm_root_fs_url: https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.10/latest/rhcos-installer-rootfs.x86_64.img
    acm_ocp_version: 4.10.32
  include_role:
    name: acm-sno
```

## Known issues and limitations

* At this time the role only deploys SNO instances
* The SNO instance will inherit the pull-secrets, SSH keys, CA certificates, and registry.conf settings from the Hub cluster
* This role does not perform the mirroring of RHCOS, release images, and operators
* Deployments have only been testing ein x86_64 architectures

# Role Outputs

The following facts can be consumed by other playbooks or roles as those are generated as outputs.

```
acm_kubeconfig_text: Kubeconfig file for the new spoke cluster.

acm_kubeconfig_user: Username for the new spoke cluster.

acm_kubeconfig_user: Password for the new spoke cluster.
```

Kubeconfig file and initial user's credentials are saved in a temporal directory generated at runtime. Please see the playbook's output to get the path.

# Troubleshooting

In case of issues during the deployment, please review the logs corresponding to the assisted service deployment.

```
$ oc logs -n multicluster-engine -l app=assisted-service
$ oc logs -n multicluster-engine -l app=assisted-image-service
```

# References

* [acm-setup](../acm-setup/README.md): A role that configures and ACM instance on a running cluster.
* [mirror-ocp-release](../mirror-ocp-release/): A role that mirror and OCP release to a third-party registry.
* [operators-mirror](../operators-mirror/): A role that mirrors operators from a Catalog index into a third-party registry.
* [dci-openshfit-agent](https://github.com/redhat-cip/dci-openshift-agent/): An agent that allows the deployment of OCP clusters, it is integrated with DCI (Red Hat Distributed CI).
* [dci-openshfit-app-agent](https://github.com/redhat-cip/dci-openshift-app-agent/): An agent that allows the deployment of workloads and certification testing in top OCP clusters, it is integrated with DCI (Red Hat Distributed CI).
