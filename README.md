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


## Beijiing Root Router setting
hostname ROOT_ROUTER
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

## ASA Firewall setting
hostname L4_FIREWALL
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