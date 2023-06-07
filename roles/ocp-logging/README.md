# ocp-logging role

This role allows enabling the OCP logging subsystem. This allows to aggregate cluster's metrics, application and infrastructure logs. The main components of the stack are:
  - [Loki](https://grafana.com/oss/loki/) - for logs storage in an Object Storage
  - Clusterlogging - for collecting for logs and metrics
  - Object storage bucket - the permanent logs storage
  - Physical volumes - local storage used for data catching

Main role tasks:
  - Validates the logging subsystem requirements
  - Creates the required secrets
  - Validate that the CustomResources are present
  - Deploys Loki stack
  - Create a ClusterLogging instance
  - Configures the cluster to forward metrics and logs to the Loki stack
  - Enables the logging-view-plugin for logs visualization for the OCP console

This role only works on OCP 4.10 and newer and with a S3 compatible storage backend.

## Variables

| Variable                               | Default                       | Required    | Description                                   |
| -------------------------------------- | ----------------------------- | ----------- | ----------------------------------------------|
| ol_access_key_id                       | undefined                     | Yes         | Key ID for the Object storage system          |
| ol_access_key_secret                   | undefined                     | Yes         | Key Secret for the Object Storage system      |
| ol_bucket                              | undefined                     | Yes         | Object Storage bucket name                    |
| ol_endpoint                            | undefined                     | Yes         | Object Storage endpoint                       |
| ol_region                              | undefined                     | Yes         | Object Storage region                         |
| ol_loki_size                           | undefined                     | Yes         | Loki Deployment Size. See [Sizing](https://docs.openshift.com/container-platform/4.13/logging/cluster-logging-loki.html#deployment-sizing_cluster-logging-loki) for more details |
| ol_storage_class                       | undefined                     | Yes         | Cluster Storage class for Loki components     |
| ol_event_router_image                  | registry.redhat.io/openshift-logging/eventrouter-rhel8:v5.2.1-1 | No   | Event Router image |
| ol_action                              | install                       | No          | Controls the action performed by the role: Install or cleanup|
| ol_namespace                           | openshift-logging             | No          | Target namespace. It is the recommended namespace|
| ol_settings                            | undefined                     | No          | An optional yaml file with the variables listed above. The variables defined there take precedence over the ones defined at role level|

## Role requirements
  - Cluster-Logging operator already installed
  - Loki-operator already installed
  - Supported Log Store (AWS S3, Google Cloud Storage, Azure, Swift, Minio, OpenShift Data Foundation) credentials (access_key and access_key_secret)
  - Logs Store endpoint address

## Usage example

See below for some examples of how to use the ocp-logging role to configure the logging subsystem.

Passing the variables at role level:
```yaml
- name: "Setup OCP logging stack"
  include_role:
    name: ocp-logging
  vars:
    ol_access_key_id: <ACCESS_KEY_ID>
    ol_access_key_secret: <ACCESS_KEY_SECRET>
    ol_bucket: loki
    ol_endpoint: http://192.168.16.10:9000
    ol_region: us-east-1
    ol_loki_size: 1x.extra-small
    ol_storage_class: ocs-storagecluster-ceph-rbd
    ol_event_router_image: "registry.redhat.io/openshift-logging/eventrouter-rhel8:v5.2.1-1"
```

Passing the variables using a yaml vars file:
```yaml
- name: "Setup OCP logging stack"
  include_role:
    name: ocp-logging
  vars:
    ol_settings: <path_to_vars_filel.yml>
```

Remove resources created by the role.
```yaml
- name: "Setup OCP logging stack"
  vars:
    ol_action: 'cleanup'
  include_role:
    name: ocp-logging
```

# References

* [Cluster Logging Loki documentation](https://docs.openshift.com/container-platform/4.13/logging/cluster-logging-loki.html)
* [olm-operator](../olm-operator/README.md): A role that installs OLM based operators.
* [dci-openshfit-agent](https://github.com/redhat-cip/dci-openshift-agent/): An agent that allows the deployment of OCP clusters, it is integrated with DCI (Red Hat Distributed CI).
* [dci-openshfit-app-agent](https://github.com/redhat-cip/dci-openshift-app-agent/): An agent that allows the deployment of workloads and certification testing on top OCP clusters, it is integrated with DCI (Red Hat Distributed CI).
