#!/bin/bash
echo "modprobe mac80211_hwsim..."
sudo modprobe mac80211_hwsim
sudo iw dev wlan0 del
sudo iw dev wlan1 del
sudo iw dev WTPWLan00 del

echo "Running WTP and AC in separate terminals..."
proj_path=/home/eqqie/work/openCAPWAP-master
sudo killall -9 WTP
gnome-terminal -- sudo ./WTP $proj_path
read -n1 -r -p "Press any key to continue..." key

proj_path=/home/eqqie/work/openCAPWAP-master
sudo killall -9 AC
gnome-terminal -- sudo ./AC $proj_path
read -n1 -r -p "Press any key to continue..." key

sleep 2

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

sleep 2

echo "Check running wtps..."
sudo ./wum/wum -c wtps

