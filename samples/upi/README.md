
# OpenShift 4 Bare Metal - User Provisioned Infrastructure (UPI)

- [OpenShift 4 Bare Metal Install - User Provisioned Infrastructure (UPI)](#openshift-4-bare-metal-install---user-provisioned-infrastructure-upi)
  - [Required Services](#required-services)
  - [Example Configs](#example-configs)
  - [Example Hook](#example-hook)
  - [Example Inventory](#example-inventory)

## Required Services

The Following services must be configured:

- HTTPD
- DHCP
- DNS
- HAProxy
- TFTPBoot

## Example Configs

The following examples assume eno1 is your internal network for the cluster and eno2 is your external network which can route to the internet.

1. Set a Static IP for OCP network interface `nmtui-edit eno1` or edit `/etc/sysconfig/network-scripts/ifcfg-eno1`

   - **Address**: 192.168.7.1
   - **DNS Server**: 127.0.0.1
   - **Search domain**: ocp4.example.com
   - Never use this network for default route
   - Automatically connect

   > If changes arent applied automatically you can bounce the NIC with `nmcli connection down eno1` and `nmcli connection up eno1`


1. Setup firewalld

   Create **internal** and **external** zones

   ```bash
   nmcli connection modify eno1 connection.zone internal
   nmcli connection modify eno2 connection.zone external
   ```

   View zones:

   ```bash
   firewall-cmd --get-active-zones
   ```

   Set masquerading (source-nat) on the both zones.

   So to give a quick example of source-nat - for packets leaving the external interface, which in this case is eno2 - after they have been routed they will have their source address altered to the interface address of eno2 so that return packets can find their way back to this interface where the reverse will happen.

   ```bash
   firewall-cmd --zone=external --add-masquerade --permanent
   firewall-cmd --zone=internal --add-masquerade --permanent
   ```

   Reload firewall config

   ```bash
   firewall-cmd --reload
   ```

   Check the current settings of each zone

   ```bash
   firewall-cmd --list-all --zone=internal
   firewall-cmd --list-all --zone=external
   ```

   When masquerading is enabled so is ip forwarding which basically makes this host a router. Check:

   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   ```

1. Install and configure BIND DNS

   Install

   ```bash
   dnf install bind bind-utils -y
   ```

   Apply configuration

   ```bash
   cp ~/samples/upi/dns/named.conf /etc/named.conf
   cp -R ~/samples/upi/dns/zones /var/named/
   ```

   Configure the firewall for DNS

   ```bash
   firewall-cmd --add-port=53/udp --zone=internal --permanent
   firewall-cmd --reload
   ```

   Enable and start the service

   ```bash
   systemctl enable named
   systemctl start named
   systemctl status named
   ```

   > At the moment DNS will still be pointing to the LAN DNS server. You can see this by testing with `dig ocp4.example.com`.

   Change the LAN nic (eno1) to use 127.0.0.1 for DNS AND ensure `Ignore automatically Obtained DNS parameters` is ticked

   ```bash
   nmtui-edit eno1
   ```

   Restart Network Manager

   ```bash
   systemctl restart NetworkManager
   ```

   Confirm dig now sees the correct DNS results by using the DNS Server running locally

   ```bash
   dig ocp4.example.com
   # The following should return the answer bootstrap.ocp4.example.com from the local server
   dig -x 192.168.7.20
   ```

1. Install & configure DHCP

   Install the DHCP Server

   ```bash
   dnf install dhcp-server -y
   ```

   Edit dhcpd.conf to have the correct mac address for each host and copy the conf file to the correct location for the DHCP service to use.  If your internal network is not eno1 then you will need to edit the interface entry in the file as well.

   ```bash
   cp ~/samples/upi/dhcpd.conf /etc/dhcp/dhcpd.conf
   ```

   Configure the Firewall

   ```bash
   firewall-cmd --add-service=dhcp --zone=internal --permanent
   firewall-cmd --reload
   ```

   Enable and start the service

   ```bash
   systemctl enable dhcpd
   systemctl start dhcpd
   systemctl status dhcpd

1. Install & configure Apache Web Server

   Install Apache

   ```bash
   dnf install httpd -y
   ```

   Change default listen port to 8080 in httpd.conf

   ```bash
   sed -i 's/Listen 80/Listen 0.0.0.0:8080/' /etc/httpd/conf/httpd.conf
   ```

   Configure the firewall for Web Server traffic

   ```bash
   firewall-cmd --add-port=8080/tcp --zone=internal --permanent
   firewall-cmd --reload
   ```

   Enable and start the service

   ```bash
   systemctl enable httpd
   systemctl start httpd
   systemctl status httpd
   ```

   Making a GET request to localhost on port 8080 should now return the default Apache webpage

   ```bash
   curl localhost:8080
   ```

1. Install & configure HAProxy

   Install HAProxy

   ```bash
   dnf install haproxy -y
   ```

   Copy HAProxy config

   ```bash
   cp ~/samples/upi/haproxy.cfg /etc/haproxy/haproxy.cfg
   ```

   Configure the Firewall

   > Note: Opening port 9000 in the external zone allows access to HAProxy stats that are useful for monitoring and troubleshooting. The UI can be accessed at: `http://{ocp-svc_IP_address}:9000/stats`

   ```bash
   firewall-cmd --add-port=6443/tcp --zone=internal --permanent # kube-api-server on control plane nodes
   firewall-cmd --add-port=6443/tcp --zone=external --permanent # kube-api-server on control plane nodes
   firewall-cmd --add-port=22623/tcp --zone=internal --permanent # machine-config server
   firewall-cmd --add-service=http --zone=internal --permanent # web services hosted on worker nodes
   firewall-cmd --add-service=http --zone=external --permanent # web services hosted on worker nodes
   firewall-cmd --add-service=https --zone=internal --permanent # web services hosted on worker nodes
   firewall-cmd --add-service=https --zone=external --permanent # web services hosted on worker nodes
   firewall-cmd --add-port=9000/tcp --zone=external --permanent # HAProxy Stats
   firewall-cmd --reload
   ```

   Enable and start the service

   ```bash
   setsebool -P haproxy_connect_any 1 # SELinux name_bind access
   systemctl enable haproxy
   systemctl start haproxy
   systemctl status haproxy

1. Install & configure TFTPBOOT

   Install TFTPBoot

   ```bash
   dnf install tftp-server -y
   ```

   Configure the Firewall

   ```bash
   firewall-cmd --add-service=tftp --zone=internal --permanent
   firewall-cmd --reload
   ```

## Example Hook

1. Copy hooks directory contents to /etc/dci-openshift-agent/hooks

   ```bash
   cp -rp ~/samples/upi/hooks/* /etc/dci-openshift-agent/hooks
   ```

  The example hooks copy the kernel and ramdisk to the tftpboot/rhcos location and the ramdisk to the html/install location.  The generated ignition files get copied to html/ignition location.

1. Create a hosting directories to serve the configuration files for the OpenShift booting process

   ```bash
   mkdir /var/www/html/install
   mkdir /var/www/html/ignition
   ```

1. Create the TFTPBoot rhcos directory

   ```bash
   mkdir /var/lib/tftpboot/rhcos
   ```

## Example Inventory
