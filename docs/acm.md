# Advanced Cluster Management based installation

Advanced Cluster Management (ACM) is yet another method DCI OCP agent can use to install OpenShift clusters. If you are curious about it please read [Red Hat Advanced Cluster Management for Kubernetes](https://www.redhat.com/en/technologies/management/advanced-cluster-management).

This document will focus on explaining how the ACM can be used to install an OpenShift cluster through the DCI Agent.

## Table of contents

* [Requirements](#requirements)
* [Configuration](#configuration)
* [Explanation of the process](#explanation-of-the-process)
  * [Disconnected Environment](#disconnected-environment)
* [Virtual Lab Quick Start](#virtual-lab-quick-start)

At this time only SNO deployments are supported. Support for multi-node deployments will be added in the future.

## Requirements

* An OCP cluster already installed and configured with the ACM operator and its dependencies. A default storage class is mandatory in order to save information about the clusters managed by ACM. This will act as the Hub Cluster.
* A kubeconfig file to be used to interact with the Hub Cluster.
* An node that will be the target for the SNO deployment with support for Virtual Media at its Baseboard Management Controller (BMC).
  - vCPU: 6
  - RAM: 16 GB
  - At least 20GB of storage

ACM does not require a dedicated jumphost or provisioning node, being able to interact with the Cluster hub using a kubeconfig file is enough.

The ACM integration with DCI uses the [acm-setup](https://github.com/redhat-cip/dci-openshift-agent/blob/master/roles/acm-setup/README.md) and [acm-sno](https://github.com/redhat-cip/dci-openshift-agent/blob/master/roles/acm-sno/README.md) to complete the deployment of SNO instances.

Please read the role's documentation in order to get more information.

# Configuration
1. A Hub cluster is deployed with support for ACM. It can be achieved by setting `enable_acm=true` during an OCP deployment. Please see [acm-hub-pipeline](https://github.com/dci-labs/dallas-pipelines/blob/master/ocp-4.10-acm-hub-pipeline.yml) for an example of a pipeline prepared for ACM.
1. The kubeconfig file of the Cluster Hub is exported as HUB_KUBECONFIG
`export HUB_KUBECONFIG=/<kubeconfig_path>`
1. Define the inventory file with the information of the instance to be used to deploy SNO. See [sno-inventory](https://github.com/dci-labs/inventories/blob/master/dallas/sno/sno1-cluster4.yml) as an example of an inventory for acm-sno deployment.
1. Define the deployment settings for the new SNO instance. See [acm-sno-pipeline](https://github.com/dci-labs/dallas-pipelines/blob/master/ocp-4.10-acm-sno-pipeline.yml) as an example of a pipeline to deploy SNO.

1. Use `dci_pipeline` or the DCI Agent to initiate the deployment using the values defined in the `acm-sno-pipeline`.

* Operators can be deployed on top of the SNO instance by defining the proper `enable_<operator>` flag. DCI will perform the proper operator mirroring and complete its deployment. Please take into consideration that all not operators may be suitable for SNO instances.

## Explanation of the process

1. Process starts, the agent creates a new job in the [DCI dashboard](https://www.distributed-ci.io/login).
1. Some checks are performed to make sure the installation can proceed.
1. If this is a disconnected/restricted network environment:
   1. The OCP release artifacts are downloaded
   1. Container/operator images are mirrored to the local registry
   1. Cluster hub is inspected to get setting that will be inherited to the SNO instance, like pull secrets, registry host, web server, etc
1. The ACM installation is set up and started. The required ACM resources are created>.
   1. BMC secret.
   1. The Agent Service Config is patched with information for the new requested cluster.
   1. InfraEnv.
   1. Cluster deployment.
   1. Bare Metal Controller.
1. The target node's BMC is provisioned by ACM. A base RHCOS image will be used to boot the server, start the ACM agents and completed the initial bootstrap.
1. The node is discovered by ACM and auto-approved.
1. Network settings and NTP are validated.
1. A new cluster installation starts. Deployment should complete in around 50 minutes.
1. If DNS is properly configured, the new instance is registered as a managed cluster in the ACM console.
1. The `KUBECONFIG` and admin credentials are fetched.
1. The `KUBECONFIG` is used to interact with the new cluster and perform the deployment of the desired operators.
1.  Process ends and the job is completed in the DCI dashboard.

### Disconnected environment

* Set `dci_disconnected` to true, this can be done in the inventory file or the
  `settings.yml` file.
