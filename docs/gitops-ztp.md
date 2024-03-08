# Gitops ZTP based installation

Gitops ZTP is an OpenShift cluster deployment method based on the principle of managing the installation settings from a source code repository.

## Table of contents

* [Process descritpion](#process-description)
* [Requirements](#requirements)
* [Roles](#roles)
* [Pipelines examples](#pipelines-examples)
* [Inventory examples](#inventory-examples)

## Process description

The DCI process of deploying a cluster using the Gitops ZTP method comprises two stages.

In the first stage, an OpenShift Hub Cluster, running the Advanced Cluster Management (ACM), Gitops and Topology-Aware Lifecycle Manager operators is deployed. This must be a multinode cluster since ACM relies on a redundant PostgreSQL database.

After this, the Gitops operator is connected to a Git repository containing the site configuration (deployment) and policy generator templates (settings and workloads) manifests for the OpenShift Spoke Clusters. On reading and processing these manifests the deployment of any defined spoke clusters is triggered.

This two stages are run through separate DCI jobs that may be pipeline stages.

## Requirements

The requirements for the two clusters are different:

### Requirements for the ACM Hub Cluster

* 

### Requirements for the Spoke Cluster

* An installed OCP cluster configured with the ACM, Gitops and TALM operators and their dependencies. A default storage class is mandatory to save information about the clusters managed by ACM. This will act as the Hub Cluster.

* A kubeconfig file to interact with the Hub Cluster.

* A Git repository accessible from the Hub Cluster, so it can pull the site configuration and policies.

## SNO Spoke Cluster configuration

The following settings must be provided to the SNO Spoke Cluster deployment job.

| Variable | Description |
|==========|=============|
| acm_cluster_name  | Name of the spoke cluster |
| acm_base_domain | Domain for the spoke cluster |
| acm_bmc_address | URL to the Redfish endpoint of the system |
| amc_bmc_user | Username to the BMC console |
| amc_bmc_pass | Password to the BMC console |
| amc_bmc_mac_address | MAC address for the provisioning interface in the node |
| amc_interfaces | List of interfaces in the node with format: {"name": "", "macAddress": ""} |

## Pipeline examples

### Gitops enabled ACM Hub Cluster pipeline

```

```

### ACM SNO pipeline

```

```

## Inventory examples

### SNO inventory file

```

```