# acm-setup Role

This role performs the Advanced Cluster Management (ACM) post-installation tasks that include:
1. Installation of multicluster-engine and OADP operators
1. Creating of a multicluster engine
1. Creating and configuring the ACM's Central Infrastructure Management

The configuration of the assisted installer instance can be customized by using the following variables:

## Variables

| Variable                           | Default                       | Required    | Description                                   |
| ---------------------------------- | ----------------------------- | ----------- | ----------------------------------------------|
|db_volume_size                      |40Gi                           |No           | This value specifies how much storage is is allocated for storing files like database tables and database views for the clusters. You might need to use a higher value if there are many clusters|
|fs_volume_size                      |50Gi                           |No           | This value specifies how much storage is allocated for storing logs, manifests, and kubeconfig files for the clusters. You might need to use a higher value if there are many clusters|
|img_volume_size                     |40Gi                           |No           | This value specifies how much storage is allocated for the images of the clusters. You need to allow 1 GB of image storage for each instance of Red Hat Enterprise Linux CoreOS that is running. You might need to use a higher value if there are many clusters and instances of Red Hat Enterprise Linux CoreOS|
|mch_availability                    |High                           |No           |Multicluster hub High Availavility configuration                |
|mch_disable_selfmanagement          |False                          |No           |Do not import the hub cluster as managed in ACM                            |
|acm_namespace                       |open-cluster-management        |No           |Namespace where ACM has been installed                          |
|mch_instance                        |multiclusterhub                |No           |Name of the multiclusterhub instance to be created (fail if already exists) |
|acm_disconnected                    |false                          |No           |Defines if the the CA certificate and registries.conf from the Hub workers will be injected to the managed clusters |
|user_bundle                         |Undefined                      |No           |CA certificate to be injected to spoke nodes. Requires `acm_disconnected` set to true |
|user_registry                       |Undefined                      |No           |regitries.conf file to be injected to the spoke nodes. Requires `acm_disconnected` set to true                |


## Requirements
1. An Openshfit Cluster with a subscription for the ACM operator.
1. On airgapped environments, the multicluster-engine operator must be available in the mirrored catalog
1. A storage class set as default with space available to cover the values defined for db_volume_size, fs_volume_size, img_volume_size

## Integration with DCI

The role integration with DCI will pull the CA and registries.conf files from according the type of environment of the Hub Cluster.

- Spoke SNO clusters created by a Hub that is disconnected will inherit the mirroring configs from the Hub cluster.
- Spoke SNO clusters created by a Hub that is connected will no inherit the mirroring configs from the Hub cluster.

Witout DCI, pulling the mirroring configs from a cluster can be managed by the `acm_disconnected` setting. Both, the CA and the registy.conf files will be obtained for the clusters machine configs during the setup.

## Usage example

See below an example of how to use the acm-setup role to configure ACM.

```yaml
- name: "Setup Advanced Cluster Management"
    include_role:
    name: acm-setup
    vars:
    db_volume_size: 10Gi
    fs_volume_size: 10Gi
    img_volume_size: 10Gi
    mch_disableHubSelfManagement: True
    mch_availabilityConfig: High
    acm_disconnected: true
    user_bundle: |
        -----BEGIN CERTIFICATE-----
        REDACTED
        -----END CERTIFICATE-----
    user_registry: |
        unqualified-search-registries = ["registry.access.redhat.com", "docker.io"]
        [[registry]]
        prefix = ""
        location = "jumphost.dfwt5g.lab:4443/ocp4"
        mirror-by-digest-only = true

        [[registry.mirror]]
            location = "registry.dfwt5g.lab:4443/ocp4/openshift4"
        [[registry]]
        prefix = ""
        location = "quay.io/openshift-release-dev/ocp-release"
        mirror-by-digest-only = true
        [[registry.mirror]]
            location = "registry.dfwt5g.lab:4443/ocp4/openshift4"
```
