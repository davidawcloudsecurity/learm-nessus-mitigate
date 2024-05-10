#!/bin/bash

# Apply the active kernel parameters
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.route.flush=1

echo "IPv4 parameters set."
