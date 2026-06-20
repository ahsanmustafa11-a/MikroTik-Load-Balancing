/interface
set [find default-name=ether1] name=WAN1
set [find default-name=ether2] name=WAN2
set [find default-name=ether3] name=LAN

/ip address
add address=192.168.1.2/24 interface=WAN1
add address=192.168.2.2/24 interface=WAN2
add address=10.10.10.1/24 interface=LAN

/ip firewall mangle

add chain=prerouting dst-address-type=!local \
in-interface=LAN \
per-connection-classifier=both-addresses:2/0 \
action=mark-connection \
new-connection-mark=WAN1_conn

add chain=prerouting dst-address-type=!local \
in-interface=LAN \
per-connection-classifier=both-addresses:2/1 \
action=mark-connection \
new-connection-mark=WAN2_conn

add chain=prerouting connection-mark=WAN1_conn \
action=mark-routing \
new-routing-mark=to_WAN1

add chain=prerouting connection-mark=WAN2_conn \
action=mark-routing \
new-routing-mark=to_WAN2

/ip route

add dst-address=0.0.0.0/0 gateway=192.168.1.1 routing-mark=to_WAN1

add dst-address=0.0.0.0/0 gateway=192.168.2.1 routing-mark=to_WAN2

/ip firewall nat

add chain=srcnat out-interface=WAN1 action=masquerade
add chain=srcnat out-interface=WAN2 action=masquerade
