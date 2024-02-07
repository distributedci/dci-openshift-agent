
## Create a `install-microshift.yaml` pipeline file

```
---
- name: Microshift
  stage: install
  ansible_playbook: /<replace_me>/dci-openshift-agent/dci-microshift-agent.yml
  ansible_inventory: /<replace_me>/dci-pipeline/inventory
  dci_credentials: /<replace_me>/dci_credentials.yml
  topic: OCP-4.14
  components:
    - repo?name:Microshift 4.14.0 rc.7
```

## Create dci_credentials.yml

The one linked in the pipeline file

## Clone the collections fork and use the microshift branch

https://github.com/fdaencarrh/ansible-collection-redhatci-ocp/tree/microshift_generate_iso

## Create a `requirements.yml`

```
---
collections:
  - name: redhatci.ocp
    source: /<replace_me>/ansible-collection-redhatci-ocp
    type: dir
```

## Install the collection

```
ansible-galaxy install --force -r requirements.yml
```

## Run a job

dci-pipeline @pipeline:name="install microshift" install-microshift.yaml