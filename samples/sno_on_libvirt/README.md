== Playbooks to deploy Single Node Openshift on a libvirt VM

=== Pre-requisites

- A RHEL 8.4 server with direct internet access
- access to base and appstream repos required. 
- If the vars activation_key and org_id are provided registration is done during the deployment.



=== Prepare SNO node

Create your ~/sno-node-settings.yml file to declare your variables

```
dci_client_id: remoteci/XXXXXXXXX
dci_api_secret: API-SECRET-GOES-HERE
rhn_user: your-rhn-user
rhn_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          VAULTED_RHN_PASSWORD
github_user: your-github-user
```

Then prepare the inventory
```bash
your-user@your-workstation ~$ echo "[sno_host]" | sudo tee -a /etc/ansible/hosts
your-user@your-workstation ~$ echo "mysnoserver ansible_user=user-with-sudo-priv ansible_host=some-server" | sudo tee -a /etc/ansible/hosts
```

Run playbook from workstation
```bash
your-user@your-workstation ~$ cd samples/sno_on_libvirt/
your-user@your-workstation ~$ ansible-playbook sno-on-libvirt.yml -e "@~/sno-node-settings.yml" -i /etc/ansible/hosts --vault-password-file ~/.vault_secret
```

=== Deploy with DCI from the SNO provisioner node
```bash
source /etc/dci-openshift-agent/dcirc.sh
cd /usr/share/dci-openshift-agent
ansible-playbook dci-openshift-agent.yml -i /etc/dci-openshift-agent/hosts  -e "@/etc/dci-openshift-agent/settings.yml"
```

=== Deploy without DCI from the SNO provisioner node
```bash
cd /usr/share/dci-openshift-agent
ansible-playbook ~/samples/sno_on_libvirt/deploy-sno.yml -i /etc/dci-openshift-agent/hosts
```

