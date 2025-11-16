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
int g0/2/0
ip add 218.107.132.1 255.255.255.240
no cdp en
no shut
ex
ip dh po BEIJING
de 218.107.132.1
ne 218.107.132.0 255.255.255.240
dn 8.8.8.8
ex
ip dh ex 218.107.132.1
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
ip nat inside source list 1 int g0/1 overload
ac 1 permit 192.168.255.0 0.0.0.7
!
! --- Default route to ISP ---
ip route 0.0.0.0 0.0.0.0 218.107.132.1
!
end
write m
copy ru st