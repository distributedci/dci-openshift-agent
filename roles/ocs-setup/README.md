Role Name
=========

Role to install and setup Openshift Container Storage (OCS) 
and integrate with Internal Local Storage operators in OCP 4.X 
or integrate with External RHCS cluster (ODF External Mode)


Requirements
------------

- oc client
- python3-kubernetes (community.kubernetes.k8s)
- Bash session and OCP account with cluster-admin privileges
- In ODF External Mode requires access to RHCS cluster


Role Variables
--------------

# defaults variables for ocs-setup

### Local Storage Operator variables
# (Optional) registry catalog URL with index from where to pull the image 
# local_storage_operator_catalog_source: "registry.redhat.io/redhat/redhat-operator-index:v4.7"
#
# (Required) Channel versions to use, namespace and operators names
local_storage_operator: local-storage-operator
local_storage_namespace: openshift-local-storage
local_storage_channel: "4.7"

### OCS Storage Operator variables
# (Optional) registry catalog URL with index from where to pull the image 
# ocs_operator_image_catalog_source: "registry.redhat.io/redhat/redhat-operator-index:v4.7"
#
# (Required) Channel versions to use, namespace and operators names
ocs_storage_operator: ocs-operator
ocs_storage_namespace: openshift-storage
ocs_storage_channel: "stable-4.7"

# (Required) enable or disable a phase
ocs_deploy_install: true
ocs_deploy_test: false
ocs_deploy_teardown: false


Inventory Groups and Variables
--------------

[all:vars]
# (Required) whether to enable or not OCS
enable_ocs=true

# (Required) true for default integration with OCS and false for external ODF/OCS
internal_ocs=false

# (Required) if internal_ocs=false, then pass JSON output generated from RHCS
# with ceph-external-cluster-details-exporter.py script 
external_ceph_data='JSON_PAYLOAD'

# (Required) List of disk devices per node to use for OCS, comma separated
# All servers must have the same
local_storage_devices=["/dev/sdb"]

# (Required) For each set of disks increment the count by 1.
# for example on a 3 node replica each OSD will use 3 disks, 1 on each node
# then if you have 30 disks (10 disks per node) storage_ds_count is = 10
ocs_storage_ds_count=1  # <-- Modify count

# (Required) Group of nodes where to install OCS
[ocs_nodes:children]
masters

# (Required) Label to identify the OCS Nodes
[ocs_nodes:vars]
labels={"cluster.ocs.openshift.io/openshift-storage": ""}


Dependencies
------------

This role depends on the following dci-openshift-agent roles:

- olm-catalog-source: To setup the catalog source for OCS
- olm-operator: To install OCS and Local Storage operators (namespace, group operators, subscriptions)
- label-nodes: To setup node labels to identify OCS nodes
- deploy-cr: To deploy the custom resource for OCS and Local Storage


Example Inventory
----------------

./etc/dci-openshift-agent/hosts
[source,yaml]
----
[all:vars]
...
enable_ocs=true
local_storage_devices=["/dev/sdb"]
ocs_storage_ds_count=1  # <-- Modify count

[ocs_nodes:children]
masters

[ocs_nodes:vars]
labels={"cluster.ocs.openshift.io/openshift-storage": ""}
----

Example Playbook
----------------

.deploy-ocs.yml
[source,yaml]
----
---
- name: "Deploy OCS and LocalStorage"
  hosts: provisioner
  roles:
    - ocs-setup
----


Run Playbook
----------------

[source,bash]
----
# Authenticate
$ export KUBECONFIG=/path/of/your/kubeconfig

# Perform installation
$ ansible-playbook -i /etc/dci-openshift-agent/hosts deploy-ocs.yml

# Perform tests
$ ansible-playbook -i /etc/dci-openshift-agent/hosts deploy-ocs.yml -e "ocs_deploy_install=false" -e "ocs_deploy_test=true"

# Uninstall OCS and Local Storage
$ ansible-playbook -i /etc/dci-openshift-agent/hosts deploy-ocs.yml -e "ocs_deploy_install=false" -e "ocs_deploy_teardown=true"
----

License
-------

Apache 2.0


Author Information
------------------
author: Manuel Rodriguez
description: Senior Software Engineer
company: Red Hat
