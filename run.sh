#!/bin/bash

echo "Delete old WLAN interfaces"
sudo iw dev WTPWLan00 del

echo "Running WTP and AC in separate terminals..."
proj_path=/home/eqqie/work/openCAPWAP-master
sudo killall -9 WTP
gnome-terminal -- sudo bash -c "./WTP $proj_path; bash"
read -n1 -r -p "Press any key to continue..." key

proj_path=/home/eqqie/work/openCAPWAP-master
sudo killall -9 AC
gnome-terminal -- sudo bash -c "./AC $proj_path; bash"
read -n1 -r -p "Press any key to continue..." key

sleep 1

echo "Creating bridgeAC and add it into AC_tap..."
targetif=ens37
sudo ip link add name bridgeAC type bridge
sudo ip link set dev AC_tap master bridgeAC
sudo ip link set dev $targetif master bridgeAC
sudo ip link set dev bridgeAC up
sudo ip link set dev AC_tap up
sudo ip addr flush dev $targetif
sudo ip addr flush dev AC_tap
sudo ip addr add 192.168.10.128/24 dev bridgeAC
sudo ip addr flush dev $targetif

sleep 1

echo "Check running wtps..."
sudo ./wum/wum -c wtps

