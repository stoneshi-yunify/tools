#!/bin/bash
set -e

echo "This script will recreate /etc/netplan/50-cloud-init.yaml"
echo "It only applies to a KSV vm in the 172.31.53.255 subnet on the enp1s0 interface. Use it with caution."
echo "Do you want to continue?(y/n)"
read -r ans
[[ $ans != "y" ]] && echo "Required answer 'y' to continue" && exit 1

cd /etc/netplan
mv 50-cloud-init.yaml "50-cloud-init.yaml.$(date +"%Y-%m-%d_%H-%M-%S").bak"
mac=$(ip a show enp1s0 | grep "link/ether" | awk '{print $2}')
cat <<EOT > 50-cloud-init.yaml
network:
    ethernets:
        eth0:
            dhcp4: true
            gateway4: 172.31.53.1
            match:
              macaddress: $mac
            nameservers:
                addresses:
                - 114.114.114.114
            routes:
            -   metric: 3
                to: 192.168.3.0/24
                via: 172.31.53.254
            -   metric: 3
                to: 192.168.200.0/24
                via: 172.31.53.138
            -   metric: 3
                to: 100.92.0.0/16
                via: 172.31.53.138
            -   metric: 3
                to: 100.80.0.0/13
                via: 172.31.53.138
    version: 2
EOT

netplan apply
sleep 5
ip a show enp1s0


