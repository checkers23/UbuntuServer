# Netplan configuration for LAB07 Domain Controller (ls07)
# File: /etc/netplan/50-cloud-init.yaml
# Ubuntu Server 24.04 LTS

network:
  version: 2
  ethernets:
    # External/Bridge interface
    enp0s3:
      dhcp4: no
      addresses:
        - 172.30.20.54/25
      routes:
        - to: default
          via: 172.30.20.1
      nameservers:
        addresses: [127.0.0.1, 10.239.3.7]
        search: [lab07.lan]
    
    # Internal network interface
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.100.1/25
      nameservers:
        addresses: [127.0.0.1]
        search: [lab07.lan]

# ============================================================================
# IMPORTANT NOTES:
# ============================================================================
# 1. Replace interface names (enp0s3, enp0s8) with your actual interface names
#    Use 'ip a' command to identify your network interfaces
#
# 2. Network breakdown:
#    - enp0s3: External network (172.30.20.54/25)
#      * Subnet: 172.30.20.0/25
#      * Usable IPs: 172.30.20.1 - 172.30.20.126
#      * Gateway: 172.30.20.1
#
#    - enp0s8: Internal network (192.168.100.1/25)
#      * Subnet: 192.168.100.0/25
#      * Usable IPs: 192.168.100.1 - 192.168.100.126
#      * This is the AD domain network
#
# 3. DNS configuration:
#    - Primary DNS: 127.0.0.1 (DC itself)
#    - Secondary DNS: 10.239.3.7 (external forwarder)
#    - Search domain: lab07.lan
#
# 4. For LAB08 (second DC), change IPs to:
#    - External: 172.30.20.XX/25
#    - Internal: 192.168.100.3/25
#
# 5. To apply changes:
#    sudo netplan apply
#
# 6. To verify:
#    ip a
#    ip route
#    ping -c 2 172.30.20.1
#    ping -c 2 10.239.3.7
# ============================================================================

# Example for Ubuntu Desktop Client (lc07):
#
# network:
#   version: 2
#   ethernets:
#     enp0s3:
#       dhcp4: no
#       addresses:
#         - 192.168.100.2/25
#       nameservers:
#         addresses: [192.168.100.1]
#         search: [lab07.lan]
