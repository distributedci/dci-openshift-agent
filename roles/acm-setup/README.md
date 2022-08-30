# acm-setup Role

This role performs the Advanced Cluster Management (ACM) post-installation tasks that include:
1. Installation of multicluster-engine and oadp-operators
1. Check for a storage class
1. Creating of a multicluster engine
1. Creating and configuring and Assisted installer instance

The configuration of the assisted installer instance can be customized by using the following variables:

## Variables

| Variable                           | Default                       | Required    | Description                                   |
| ---------------------------------- | ----------------------------- | ----------- | ----------------------------------------------|
|db_volume_size                      |40Gi                           |No           | This value specifies how much storage is is allocated for storing files like database tables and database views for the clusters. You might need to use a higher value if there are many clusters|
|fs_volume_size                      |50Gi                           |No           | This value specifies how much storage is allocated for storing logs, manifests, and kubeconfig files for the clusters. You might need to use a higher value if there are many clusters|
|img_volume_size                     |40Gi                           |No           | This value specifies how much storage is allocated for the images of the clusters. You need to allow 1 GB of image storage for each instance of Red Hat Enterprise Linux CoreOS that is running. You might need to use a higher value if there are many clusters and instances of Red Hat Enterprise Linux CoreOS|
|user_bundle                         |CA from the hub cluster        |No           | Certificate authority for third party images registries access this one will be added to additionalTrustBundle |
|user_registry                       |registry.conf from the hub cluster |No           |registries.conf file that will be injected to new cluster nodes |
|mch_availabilityConfig              |High                           |No           |Multicluster hub High Availavility configuration                |
|mch_disableHubSelfManagement        |False                          |No           |Import hub cluster as managed in ACM                            |
|acm_namespace                       |open-cluster-management        |No           |Namespace where ACM has been installed                          |
|mch_instance                        |multiclusterhub                |No           |Name of the multiclusterhub instance to be created (fail if already exists) |

Some of the values required to configure ACM will be installed from the running cluster and can be overrided by using the variables defined above.

## Requirements
1. An Openshfit Cluster with a subscription for the ACM operator.
1. Access to the cluster's kubeconfig (i.e. through the KUBECONFIG environment variable)

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
    user_bundle: |
        -----BEGIN CERTIFICATE-----
        REDACTED
        -----END CERTIFICATE-----
    user_registry: |
        unqualified-search-registries = ["registry.access.redhat.com", "docker.io"]
        short-name-mode = ""
        [[registry]]
            prefix = ""
            location = "docker.io/library/busybox"
            mirror-by-digest-only = true
```

