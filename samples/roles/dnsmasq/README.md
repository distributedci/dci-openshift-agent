# Dnsmasq

This role may be used to deploy and setup the dnsmasq service.

The use case in mind is labs whose infrastructure does not include a DHCP service, so IP settings must be served from the jumpbox.

## Inventory and variables

```
[jumpbox]
jumpbox.cluster.example.lab ansible_become=yes ansible_user=root

[provisioner]
provisioner.cluster.example.lab baremetal_ip=192.168.1.11 baremetal_mac=aa:bb:cc:00:00:11

[masters]
master-0.cluster.example.lab baremetal_ip=192.168.1.20 baremetal_mac=aa:bb:cc:00:00:20
master-1.cluster.example.lab baremetal_ip=192.168.1.21 baremetal_mac=aa:bb:cc:00:00:21
master-2.cluster.example.lab baremetal_ip=192.168.1.22 baremetal_mac=aa:bb:cc:00:00:22

[workers]
worker-0.cluster.example.lab baremetal_ip=192.168.1.30 baremetal_mac=aa:bb:cc:00:00:30
worker-1.cluster.example.lab baremetal_ip=192.168.1.31 baremetal_mac=aa:bb:cc:00:00:31

[all:vars]
pub_nic=ens3f1
domain=cluster.example.lab
public_dns=8.8.8.8
dns_hosts={"apps.cluster.example.lab": "192.168.1.40", "api.cluster.example.lab": "192.168.1.40", "api-int.cluster.example.lab": "192.168.1.40"}
baremetal_range=192.168.1.100,192.168.1.200
baremetal_network=192.168.1.0/24
baremetal_netmask=255.255.255.0
baremetal_router=192.168.1.1
# (optional) If not defined, the role asumes the jumpbox ansible_host
#baremetal_dnsserver=192.168.1.10
# (optional) If not defined, the role asumes the jumpbox ansible_host
#baremetal_ntpserver=192.168.1.10
```

In the sample inventory we observe:

- *jumpbox:* is the group and host that will run the dnsmasq service. This is the only host in the network that must have a static IP address, or at least an IP address not served by the dnsmasq service.

- *other hosts:* the other hosts in the inventory will be managed by the dnsmasq service. For this to happen, they must define the variables:

- *baremetal_ip:* IP address to be assigned to the host.

- *baremetal_mac:* MAC address the dnsmasq service will use to identify the host.

- *pub_nic:* identity of the network interface in the jumpbox connected to the baremetal network.

- *domain:* network domain to be assigned to the hosts.

- *public_dns:* IP address of the external DNS server the jumpbox will forward queries to.

- *dns_hosts:* mapping of hostnames and IP addresses to be resolved. This should include the API host.

- *baremetal_network:* address and CIDR mask of the baremetal network.

- *baremetal_netmask:* netmask of the baremetal network.

- *baremetal_router:* IP address of the gateway in the baremetal network.

- *baremetal_dnsserver:* IP address of the DNS server to be provisioned to the DHCP clients.

- *baremetal_ntpserver:* host address of the NTP server to be provisioned to the DHCP clients.

## Testing

The role includes testing resources in the directory **tests.**

Here you'll find the following files:

- *hosts:* is a sample inventory file you may copy and cusomize to your test environment.

- *test_dnsmasq.yml:* is the playbook with the test cases for the role.

To test the role:

1. Set up a test host acting as the jumpbox. This host must provide SSH access to a user with admin provileges, either root or a sudo user.

2. Copy the hosts file and edit it to meet your needs, for instance, setting the proper login settings for the jumpbox host.

```
# cp hosts /tmp/
# vi /tmp/hosts
```

3. Run the test playbook and point it to your working inventory copy:

```
# ansible-playbook test_dnsmasq.yml -i /tmp/hosts
```

## Work to do

A possible enhancement would be setting up bootstrap for PXE services, like SNO hosts.
