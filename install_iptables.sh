#! /bin/bash
sudo yum update -y
sudo sysctl net.ipv4.ip_forward=1
sudo yum install iptables tcpdump -y
sudo yum install iptables-services -y
sudo service iptables restart
sudo iptables --flush
sudo iptables --table nat --flush
sudo iptables --delete-chain
sudo iptables --table nat --delete-chain
sudo iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
sudo iptables --append FORWARD --in-interface eth0 -j ACCEPT
sudo iptables-save
