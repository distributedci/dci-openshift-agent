
## Create a `install-microshift.yaml` pipeline file

```
- name: Microshift
  stage: install
  ansible_playbook: /home/guillaume/workspace/dci-dev-env/dci-openshift-agent/dci-microshift-agent.yml
  dci_credentials: /home/guillaume/dci_credentials.yml
  ansible_extravars:
    http_store: "/opt/http_store"
    dci_cluster_configs_dir: "~/clusterconfigs"
    rhsm_offline_token: "REPLACE_ME"
    rhsm_org_id: "REPLACE_ME"
    rhsm_activation_key: "REPLACE_ME"
    sushy_tools_bmc_address: "localhost:8082"
    suts:
      - name: "sut1"
        memory: 4096
        vcpu: 2
        disk_size: 20
  topic: OCP-4.16
  components:
    - repo?name:Microshift 4.16.0 ec.2

```

## Create dci_credentials.yml

The one linked in the pipeline file

## Clone the collections fork and use the integration branch

git@github.com:redhat-cip/ansible-collection-redhatci-ocp.git

## Install the collection

```
ansible-galaxy install --force -r requirements.yml
```

## Run a job

dci-pipeline @pipeline:name="install microshift" install-microshift.yaml
