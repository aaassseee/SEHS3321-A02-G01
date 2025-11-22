ROUTER x.x.x.1, .2
DHCP x.x.x.5
DNS x.x.x.10
ROOT-DNS x.x.x.10, 11

## IOS Logging setting
en
conf t
line con 0
logg sy
end

## ISP Route setting
en
conf t
ho ISP-ROUTER
!
int g0/2/0
ip add 218.107.132.1 255.255.255.240
no cdp en
no shut
ex
!
ip dh po BEIJING
de 218.107.132.1
ne 218.107.132.0 255.255.255.240
dn 8.8.8.8
ex
ip dh ex 218.107.132.1
!
ip dh po HONG_KONG
de 112.119.63.90
ne 112.119.63.90 255.255.255.240
dn 8.8.8.8
ex
ip dh ex 112.119.63.90
!
end


## Beijing Root Router setting
en
conf t
ho ROOT-ROUTER
!
int g0/0
ip address 218.107.132.2 255.255.255.252
ip nat outside
no shutdown
!
int g0/1
ip add 192.168.1.1 255.255.255.248
ip nat inside
no sh
!
! --- Static NAT: Map ASA to public IP ---
ip nat inside source static 192.168.255.2 218.107.132.1
!
! --- Dynamic PAT fallback (if you add more devices later) ---
ac 1 permit 192.168.255.0 0.0.0.7
ip nat inside source list 1 int f0/0 overload
!
! --- Default route to ISP ---
ip route 0.0.0.0 0.0.0.0 218.107.132.1
!
end
write m
copy ru st

## Firewall setting
en
conf t
ho FIREWALL
!
int g1/1
nameif outside
sec 0
ip add 192.168.255.2 255.255.255.248
!
int g1/2
nameif inside
sec 100
ip add 192.168.254.1 255.255.255.0
!
object network INSIDE
sub 192.168.254.0 255.255.255.0
nat (inside,outside) dy int
!
route outside 0.0.0.0 0.0.0.0 192.168.255.1 1
!
access-list INSIDE_PING_RESPONSE extended permit icmp any host 192.168.255.2 echo-reply
access-group INSIDE_PING_RESPONSE in interface outside
!
class-map inspection_default
match default-inspection-traffic
!
policy-map global_policy
class inspection_default
inspect http
inspect icmp
!
service-policy global_policy global
!

object network FACTORY
subnet 192.168.26.0 255.255.254.0
nat (factory,outside) dynamic interface

## ASA dhcpd
dhcpd address 192.168.10.100-192.168.10.200 dmz2
dhcpd dns 8.8.8.8
dhcpd enable dmz2


## VLAN Trunk
conf t

vlan 66
name DAD
ex

int vlan 66
ip add 192.168.68.1 255.255.254.0
no shut

int f0/8
sw t e d
sw m t
sw t a v 73
no shut

conf t
ip dh po VLAN73
net 192.168.73.0 255.255.255.0
default-r 192.168.73.1
dns 8.8.8.8
ex

ip dh ex 192.168.26.1 192.168.26.99
ip dh ex 192.168.26.201 192.168.26.245
ip dh ex 192.168.27.1 192.168.27.99
ip dh ex 192.168.27.201 192.168.27.245
ex

## Sub Switch
en
conf t
line con 0
logg sy
exi

conf t
vlan 24
name DB
ex

conf t
vlan 25
name VDB
ex

conf t
host TIER-3-SWITCH

conf t
int f0/1
sw m a
sw a v 24
no shut
ex

conf t
int f0/2
sw t e d
sw m t
sw t a v 24
no shut
ex

conf t
int f0/3
sw t e d
sw m t
sw t a v 25
no shut
ex

ex
wr m
cop ru st

conf t
object network API-SERVER
host 192.168.0.2
nat (factory,outside) static 218.107.132.2

conf t
object network MAIL-SERVER
host 192.168.0.3
nat (factory,outside) static 218.107.132.3

conf t
object network MAIL2-SERVER
host 192.168.0.4
nat (factory,outside) static 218.107.132.4


router eigrp 1
network 192.168.24.0
network 192.168.25.0