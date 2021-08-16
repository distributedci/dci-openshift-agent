== Playbooks to deploy Single Node Openshift on a libvirt VM

=== Pre-requisites

- A RHEL 8.4 server with direct internet access
- access to rhel-8-for-x86_64-baseos-rpms and rhel-8-for-x86_64-appstream-rpms repos required.
- If the vars activation_key and org_id are provided registration is done during the deployment.


=== Prepare SNO node

1. Create your ~/sno-node-settings.yml file to declare your variables.

NOTE: You can provide your RHN password in plaintext but this is ill advised due to the security issues it would pose.

```
dci_client_id: remoteci/XXXXXXXXX
dci_api_secret: API-SECRET-GOES-HERE
rhn_user: your-rhn-user
rhn_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          VAULTED_RHN_PASSWORD
github_user: your-github-user
```

2. Prepare the inventory.

NOTE: The playbook "sno-on-libvirt.yml" invoked in Step 3 explicitly looks for the group name [sno_host] and will fail if it does not find it.
This is also predicated on actually being run on a workstation or server different than the soon-to-be SNO provisioner node.

```bash
your-user@your-workstation ~$ echo "[sno_host]" | sudo tee -a /etc/ansible/hosts
your-user@your-workstation ~$ echo "mysnoserver ansible_user=user-with-sudo-priv ansible_host=some-server" | sudo tee -a /etc/ansible/hosts
```

3. Run playbook from your workstation or other computer.

NOTE: You can run this from the SNO provisioner node directly and skip Step 2, but you absolutely have to run the following cp command if you do so.
```bash
cp samples/sno_on_libvirt/hosts /etc/dci-openshift-agent/hosts
```

```bash
your-user@your-workstation ~$ cd samples/sno_on_libvirt/
your-user@your-workstation ~$ ansible-playbook sno-on-libvirt.yml -e "@~/sno-node-settings.yml" -i /etc/ansible/hosts --vault-password-file ~/.vault_secret
```


=== Deploy with DCI from the SNO provisioner node

```bash
# SNO only works on OCP 4.8 and above. Set the following if using previous OCP version, will ensure DCI is set to use 4.8
sed -i 's/OCP-4.7/OCP-4.8/g' /etc/dci-openshift-agent/settings.yml

# su - dci-openshift-agent
source /etc/dci-openshift-agent/dcirc.sh
cd /usr/share/dci-openshift-agent
ansible-playbook dci-openshift-agent.yml -i /etc/dci-openshift-agent/hosts  -e "@/etc/dci-openshift-agent/settings.yml"
```

or

```bash
# su - dci-openshift-agent
$ source /etc/dci-openshift-agent/dcirc.sh
$ dci-openshift-agent-ctl -s -- -v
```

=== Deploy without DCI from the SNO provisioner node

If you are planning to deploy without DCI agent, then you need to provide the pullsecret variable in your inventory
```bash
# vi /etc/dci-openshift-agent/hosts
...
pullsecret="Add-pull-secret-in-json"
...
```

```bash
# su - dci-openshift-agent
$ cd /usr/share/dci-openshift-agent
$ ansible-playbook ~/samples/sno_on_libvirt/deploy-sno-standalone.yml -i /etc/dci-openshift-agent/hosts
```

=== Destroy the SNO VM and perform some cleanup
NOTE: sno-installer role cleans up before a deployment
```bash
# su - dci-openshift-agent
cd ~/samples/sno_on_libvirt/
ansible-playbook deploy-sno-standalone.yml -t cleanup
```
