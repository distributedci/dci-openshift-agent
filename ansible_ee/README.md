## Running DCI OpenShift Agent with Ansible

This guide explains how to set up an Ansible execution environment specifically designed to run the DCI OpenShift Agent collection.

**Requirements:**

* `ansible-builder`
* `ansible-navigator`

**Setting Up the Environment**

1. **Navigate to the directory:**

```
cd ansible_ee
```

2. **Build the environment:**

```
ansible-build build -t dci_openshift_agent_ee
```

This command utilizes `ansible-builder` to construct the execution environment with the `dci_openshift_agent_ee` target.

## Running a Playbook with the Execution Environment

```
cd ../ocp_on_libvirt
```

**Note:** Replace `libvirt_destroy.yml` with the actual playbook you want to run.

```
ansible-navigator run libvirt_destroy.yml -mstdout --pp never --eei dci_openshift_agent_ee -u $(whoami) -e vbmc_host_provided="{{ ansible_host }}"
```

**Explanation of the command:**

* `ansible-navigator run`: This tells `ansible-navigator` to run a playbook.
* `libvirt_destroy.yml`: This is the name of the playbook to run. Replace this with your actual playbook file.
* `-mstdout`: This tells `ansible-navigator` to print the output to the console.
* `--pp never`: This disables pretty printing of the output.
* `--eei dci_openshift_agent_ee`: This specifies the execution environment to use, which is `dci_openshift_agent_ee` in this case.
* `-u $(whoami)`: This runs the playbook with your current user privileges.
* `-e vbmc_host_provided="{{ ansible_host }}"`: This defines an extra variable `vbmc_host_provided` with the value of the current host being managed (`ansible_host`).
