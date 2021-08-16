# Playbooks to deploy Single Node Openshift on a libvirt VM

## Pre-requisites

- A RHEL 8.4 server with direct internet access
  - Access to `rhel-8-for-x86_64-baseos-rpms` and `rhel-8-for-x86_64-appstream-rpms` repos required
  - If the vars activation_key and org_id are provided registration is done during the deployment
- Tested in Fedora 34 using play `deploy-sno-standalone.yml`

## Prepare SNO node

### 1. Configuration

Create your `~/sno-node-settings.yml` file to declare your variables.

NOTE: You can provide your RHN password in plaintext but is not recommended.

```yaml
dci_client_id: remoteci/XXXXXXXXX
dci_api_secret: API-SECRET-GOES-HERE
rhn_user: your-rhn-user
rhn_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          VAULTED_RHN_PASSWORD
github_user: your-github-user
```

### 2. Prepare the inventory

The playbook "sno-on-libvirt.yml" invoked in [Step 3](#3-run-playbook) explicitly looks for the group name `[sno_host]` and will fail if it does not find it.
This is also predicated on actually being run on a workstation or server different than the soon-to-be SNO provisioner node.

```bash
your-user@your-workstation ~$ echo "[sno_host]" | sudo tee -a /etc/ansible/hosts
your-user@your-workstation ~$ echo "mysnoserver ansible_user=user-with-sudo-priv ansible_host=some-server" | sudo tee -a /etc/ansible/hosts
```

### 3. Run playbook

From your workstation or other computer. You can run this from the SNO provisioner node directly and skip [Step 2](#2-prepare-the-inventory), but you absolutely have to run the following cp command if you do so.

```bash
cp samples/sno_on_libvirt/hosts /etc/dci-openshift-agent/hosts
```

```bash
your-user@your-workstation ~$ cd samples/sno_on_libvirt/
your-user@your-workstation ~$ ansible-playbook sno-on-libvirt.yml -e "@~/sno-node-settings.yml" -i /etc/ansible/hosts --vault-password-file ~/.vault_secret
```

## Deploy with DCI from the SNO provisioner node

NOTE: SNO only works on OCP 4.8 and above. Please ensure your `/etc/dci-openshift-agent/settings.yml` has only 4.8 references.

```bash
sudo su - dci-openshift-agent
source /etc/dci-openshift-agent/dcirc.sh
cd /usr/share/dci-openshift-agent
ansible-playbook dci-openshift-agent.yml -i /etc/dci-openshift-agent/hosts  -e "@/etc/dci-openshift-agent/settings.yml"
```

or

```bash
sudo su - dci-openshift-agent
source /etc/dci-openshift-agent/dcirc.sh
dci-openshift-agent-ctl -s -- -v
```

## Deploy without DCI from the SNO provisioner node

If you are planning to deploy without DCI agent, then you need to provide the pullsecret variable in your inventory

```bash
$ sudo vi /etc/dci-openshift-agent/hosts
...
pullsecret="Add-pull-secret-in-json"
...
```

If you want to deploy a specific version of SNO >= 4.8 then update the version variable or build variable with (ga or dev)

```bash
$ sudo su - dci-openshift-agent
cd /usr/share/dci-openshift-agent
vi ~/samples/sno_on_libvirt/deploy-sno-standalone.yml
...
version="4.8.X"
...
```

Deploy

```bash
sudo su - dci-openshift-agent
cd /usr/share/dci-openshift-agent
ansible-playbook ~/samples/sno_on_libvirt/deploy-sno-standalone.yml -i /etc/dci-openshift-agent/hosts
```

## Destroy the SNO VM and perform some cleanup

NOTE: sno-installer role cleans up before a deployment

```bash
sudo su - dci-openshift-agent
cd ~/samples/sno_on_libvirt/
ansible-playbook deploy-sno-standalone.yml -t cleanup
```
