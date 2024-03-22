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

## ZTP ACM Hub Cluster

### Requirements for the ZTP ACM Hub Cluster

* A multi-node or compact cluster (minimum 3 control plane nodes).

### Configuration for the ZTP ACM Hub Cluster

| Variable | Description |
|----------|-------------|
| dci_operators | List of the operators, along with their specific settings, to be installed in the Hub Cluste. This list must included, at minimum, the advanced-cluster-management, the openshift-gitops-operator and the topology-aware-lifecycle manager.
| enabled_acm | The variable must be set to True for the dci-openshift-agent to run the ACM hub cluster configuration tasks.

### Pipeline example for the ZTP ACM Hub Cluster

```
- name: acm-hub
  stage: acm-hub
  ansible_cfg: /usr/share/dci-openshift-agent/ansible.cfg
  ansible_extravars:
    install_type: assisted
    installer: assisted         # for the inventory playbook
    config_dir: ~/ocp-config
    samples_dir: /var/lib/dci-openshift-agent/samples
    cluster: "@RESOURCE"        # for the inventory playbook
    dci_tags:
      - debug
      - acm
      - hub
      - ztp
      - virt
    # Enable NFS storage for workloads that may require it (e.g. tnf-test pipeline)
    enable_nfs_storage: true
    nfs_server: 192.168.16.10
    nfs_path: /exports/external-provisioner
    # Set up performance profile definition
    performance_definition: ~/performance/files/performance-profile/performance-profile-assisted.yml
    # Operators to mirror and install
    dci_operators:
      - name: advanced-cluster-management
        catalog_source: "redhat-operators"
        namespace: "open-cluster-management"
        operator_group_spec:
          targetNamespaces:
            - "open-cluster-management"
      - name: metallb-operator
        catalog_source: "redhat-operators"
        namespace: metallb-system
      - name: kubevirt-hyperconverged
        catalog_source: "redhat-operators"
        namespace: openshift-cnv
        starting_csv: kubevirt-hyperconverged-operator.v4.14.3
      - name: openshift-gitops-operator
        catalog_source: redhat-operators
        namespace: openshift-gitops-operator
      - name: topology-aware-lifecycle-manager
        catalog_source: redhat-operators
        namespace: openshift-operators
        operator_group_name: "global-operators"
    # Operators to configure
    enable_acm: true
    enable_mlb: true
    enable_cnv: true
  ansible_inventory: ~/inventories/@QUEUE-@RESOURCE-hosts
  ansible_playbook: /usr/share/dci-openshift-agent/dci-openshift-agent.yml
  configuration: "@QUEUE"
  components:
    - ocp?tags:build:dev
  dci_credentials: ~/.config/dci-pipeline/credentials.yml
  topic: OCP-4.15
  outputs:
    kubeconfig: "kubeconfig"
```

### Inventory example for the ZTP ACM Hub Cluster

```
all:
  vars:
    #######################
    # Nodes configuration #
    #######################

    # Default credentials for the BMCs
    VAULT_NODES_BMC_USER: USER
    VAULT_NODES_BMC_PASSWORD: PASSWORD

    cluster_name: "server05"

    base_dns_domain: "partnerci.hub.lab"

    api_vip: "192.168.16.58" # the IP address to be used for api.clustername.example.lab and api-int.clustername.example.lab, if installing SNO set to the same IP as the single master node
    ingress_vip: "192.168.16.59" # the IP address to be used for *.apps.clustername.example.lab, if installing SNO set to the same IP as the single master node

    vip_dhcp_allocation: false

    machine_network_cidr: "192.168.16.0/25"

    service_network_cidr: 172.30.0.0/16

    cluster_network_cidr: 10.128.0.0/14 # The subnet, internal to the cluster, on which pods will be assigned IPs
    cluster_network_host_prefix: 23 # The subnet prefix length to assign to each individual node.

    ######################################
    # Prerequisite Service Configuration #
    ######################################

    ntp_server: "192.168.16.14"
    ntp_server_allow: "192.168.16.0/25"

    discovery_iso_name: "discovery/{{ cluster_name }}/discovery-image.iso"
    discovery_iso_server: "http://{{ hostvars['http_store']['ansible_host'] }}"

    repo_root_path: "{{ dci_cluster_configs_dir }}"
    fetched_dest: "{{ repo_root_path }}/fetched"

    pull_secret_lookup_paths:
      - "{{ fetched_dest }}/pull-secret.txt"
      - "{{ repo_root_path }}/pull-secret.txt"

    ssh_public_key_lookup_paths:
      - "{{ fetched_dest }}/ssh_keys/{{ cluster_name }}.pub"
      - "{{ repo_root_path }}/ssh_public_key.pub"
      - ~/.ssh/id_rsa.pub
    ssh_key_dest_base_dir: "{{ dci_cluster_configs_dir }}"

    kubeconfig_dest_dir: "{{ dci_cluster_configs_dir }}"
    kubeconfig_dest_filename: "{{ dci_cluster_configs_dir }}/kubeconfig"
    kubeadmin_dest_filename: "{{ cluster_name }}-kubeadmin.vault.yml"
    
    cluster: "{{ cluster_name }}"

    local_ssh_public_key_path: "{{ lookup('first_found', ssh_public_key_lookup_paths) }}"
    ssh_public_key: "{{ lookup('file', local_ssh_public_key_path) }}"


  children:
    bastions:
      hosts:
        bastion:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"

    provisioner:
      hosts:
        provisioner:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"

    services:
      hosts:
        assisted_installer:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"
          host: "server05.partnerci.hub.lab"
          port: 8090 # Do not change
          dns: "192.168.16.10"

        registry_host:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"
          registry_port: 5000
          registry_fqdn: "server05.partnerci.hub.lab"
          cert_common_name: "{{ registry_fqdn }}"
          cert_country: US
          cert_locality: Westford
          cert_organization: DCI
          cert_organizational_unit: Lab
          cert_state: MA

          # Configure the following secret values in the inventory.vault.yml file
          REGISTRY_HTTP_SECRET: "{{ VAULT_REGISTRY_HOST_REGISTRY_HTTP_SECRET | mandatory }}"
          disconnected_registry_user: "{{ VAULT_REGISTRY_HOST_DISCONNECTED_REGISTRY_USER | mandatory }}"
          disconnected_registry_password: "{{ VAULT_REGISTRY_HOST_DISCONNECTED_REGISTRY_PASSWORD | mandatory }}"

        dns_host:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"

        http_store:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"

        tftp_host:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"
          tftp_directory: /var/lib/tftpboot/

        ntp_host:
          ansible_host: "server05.partnerci.hub.lab"
          ansible_user: "dci"
          ansible_connection: "ssh"

    # Describe the desired cluster members
    nodes:
      vars:
        bmc_user: "{{ VAULT_NODES_BMC_USER | mandatory }}"
        bmc_password: "{{ VAULT_NODES_BMC_PASSWORD | mandatory }}"
        bmc_address: "server05.partnerci.hub.lab:8082"
        vendor: KVM
        vm_spec:
          cpu_cores: 8
          ram_mib: 16384
          disk_size_gb: 250  # Use a bigger disk size to avoid installation issues
        network_config:
          interfaces:
            - name: enp1s0
              mac: "{{ mac }}"
              addresses:
                ipv4:
                  - ip: "{{ ansible_host}}"
                    prefix: "25"
          dns_server_ips:
           - "192.168.16.10"
          routes: # optional
            - destination: 0.0.0.0/0
              address: "192.168.16.1"
              interface: enp1s0
      children:
        masters:
          vars:
            role: master
            vm_spec:
              cpu_cores: "8"
              ram_mib: "32768"
              disk_size_gb: "250"
          hosts:
            dciokd-master-0:
              ansible_host: "192.168.16.51"
              mac: "52:54:00:00:05:01"
            dciokd-master-1:
              ansible_host: "192.168.16.52"
              mac: "52:54:00:00:05:02"
            dciokd-master-2:
              ansible_host: "192.168.16.53"
              mac: "52:54:00:00:05:03"
        workers:
          vars:
            role: worker
            vm_spec:
              cpu_cores: "24"
              ram_mib: "98304"
              disk_size_gb: "250"
          hosts:
            dciokd-worker-0:
              ansible_host: "192.168.16.54"
              mac: "52:54:00:00:05:04"
            dciokd-worker-1:
              ansible_host: "192.168.16.55"
              mac: "52:54:00:00:05:05"
            dciokd-worker-2:
              ansible_host: "192.168.16.56"
              mac: "52:54:00:00:05:06"
```

## ZTP spoke cluster

### Requirements for the ZTP Spoke Cluster

* An installed OCP cluster configured with the ACM, Gitops and TALM operators and their dependencies. A default storage class is mandatory to save information about the clusters managed by ACM. This will act as the Hub Cluster.

* A kubeconfig file to interact with the Hub Cluster.

* A Git repository accessible from the Hub Cluster, so it can pull the site configuration and policies.

* The Git repository must have a SSH public key enabled.

* The private key to the SSH private key enabled in the Git repository.

* Credentials to log into the spoke cluster node BMC consoles.

* A pull secret file.

### Configuration for the ZTP Spoke Cluster

The following settings must be provided to the SNO Spoke Cluster deployment job.

| Variable | Required | Value | Description |
|----------|----------|-------|-------------|
| install_type | yes | acm | Enables the dci-openshift-agent flow that installs a spoke cluster. |
| acm_cluster_type | yes | ztp-spoke | Enables the gitops-ztp installation method from all the available ACM based methods. |
| bmc_user | yes | | User name for the Spoke Cluster nodes BMC consoles. |
| bmc_password | yes | | Password for the Spoke Cluster nodes BMC consoles. |
| dci_gitops_sites_repo | yes | | Parameters to the site-config manifest repository.
| dci_gitops_policies_repo | yes | | Parameters to the policy generator template manifest repository. |
| dci_gitops_*_repo.url | yes | | URL to the repository. |
| dci_gitops_*_repo.path | yes | | Path to the directory containing the manifests. |
| dci_gitops_*_repo.branch | yes | | Branch containing your target version of the manifests. |
| dci_gitops_*_repo.key_path | yes | | Local path to the SSH private key file authorized to access the repository. |
| dci_gitops_*_repo.known_hosts | yes | | List of the repository SSH fingerprints. |

### Pipeline example for the ZTP Spoke Cluster

```
- name: openshift-ztp-spoke
  stage: ztp-spoke
  prev_stages: [acm-hub]
  ansible_playbook: /usr/share/dci-openshift-agent/dci-openshift-agent.yml
  ansible_cfg: /usr/share/dci-openshift-agent/ansible.cfg
  dci_credentials: /etc/dci-openshift-agent/dci_credentials.yml
  configuration: "@QUEUE"
  ansible_inventory: ~/inventories/sno_baremetal-sno1-ztp-spoke-hosts
  ansible_extravars:
    install_type: acm
    acm_cluster_type: ztp-spoke
    dci_tags: [debug, sno, ztp, spoke, baremetal]
    dci_must_gather_images:
      - registry.redhat.io/openshift4/ose-must-gather
    dci_teardown_on_success: false
    acm_vm_external_network: False # False when running on ACM Hubs deployed by Assisted
  topic: OCP-4.15
  components:
    - ocp
  inputs:
    kubeconfig: hub_kubeconfig_path
  outputs:
    kubeconfig: "kubeconfig"
```

### Inventory example for the ZTP Spoke Cluster inventory - SNO

```
all:
  hosts:
    localhost:
      ansible_connection: local
  children:
    spoke_nodes:
      hosts:
        sno1:
          bmc_user: {{ VAULT_NODES_BMC_USER }}
          bmc_password: {{ VAULT_NODES_BMC_PASSWORD }}
  vars:
    cluster: sno1
    domain: partnerci.spoke.lab
    dci_gitops_sites_repo:
      url: git@github.com:dci-labs/spoke-ci-config.git
      path: files/ztp-spoke/sites
      branch: ztp_spoke
      key_path: "/var/lib/dci-openshift-agent/.ssh/id_dcibot"
      known_hosts: "{{ gitops_repo_known_hosts }}"
    dci_gitops_policies_repo:
      url: git@github.com:dci-labs/spoke-ci-config.git
      path: files/ztp-spoke/policies
      branch: ztp_spoke
      key_path: "/var/lib/dci-openshift-agent/.ssh/id_dcibot"
      known_hosts: "{{ gitops_repo_known_hosts }}"
    gitops_repo_known_hosts: |
      github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
      github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
```