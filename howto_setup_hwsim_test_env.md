## Prepare

```bash
sudo apt install -y iw isc-dhcp-client bridge-utils net-tools
```

## Install hwsim module

```bash
sudo modprobe mac80211_hwsim
```

show the available hwsim interfaces:

```bash
➜  ~ sudo iw dev            
phy#1
	Interface wlan1
		ifindex 11
		wdev 0x100000001
		addr 02:00:00:00:01:00
		type managed
		txpower 20.00 dBm
		multicast TXQ:
			qsz-byt	qsz-pkt	flows	drops	marks	overlmt	hashcol	tx-bytes	tx-packets
			0	0	0	0	0	0	0	0		0
phy#0
	Unnamed/non-netdev interface
		wdev 0x3
		addr 42:00:00:00:00:00
		type P2P-device
		txpower 20.00 dBm
	Interface wlan0
		ifindex 10
		wdev 0x1
		addr 02:00:00:00:00:00
		type managed
		txpower 20.00 dBm
		multicast TXQ:
			qsz-byt	qsz-pkt	flows	drops	marks	overlmt	hashcol	tx-bytes	tx-packets
			0	0	0	0	0	0	0	0		0
``` 

## Delete all wlan interfaces:

Example commands:

```bash
sudo iw dev wlan0 del
sudo iw dev wlan1 del
sudo iw dev WTPWLan00 del
...
```

## Choose two interfaces for Control Plane and Data Plane

For me:
- Control Plane: `ens33`
- Data Plane: `ens37`

## Rewrite the WTP config file

Rewrite `setting.wtp.txt` like below:

```text
# Settings File for WTP. Lines beginning with # and blank lines will be ignored

<LOG_FILE_WTP>/var/log/wtp1.txt

#Elena Agostini 07-2014: nl80211 support
<RADIO_PHY_TOT>1
<RADIO_PHY_NAME_0>phy0

#Elena Agostini 11/2014: Local Bridgind Support with mac80211
<WTP_ETH_IF_NAME> ens37
<BRIDGE_IF_NAME> bridge0

<IF_NAME>    mon.wlan0
<RADIO_0_IF_NAME>    wlan0
<BASE_MAC_IF_NAME>   lo
<BOARD_REVISION_NO>   ens37
<WTP_MODEL_NUM>    12345678
<WTP_SERIAL_NUM>   12345678

<WTP_HOSTAPD_PORT> 6333
<WTP_HOSTAPD_UNIX_PATH> /tmp/wtp_ipc_hostapd

# Elena Agostini - 02/2014
# QoS Static Values variables
<WTP_QOS_FREQ> 1
<WTP_QOS_BITRATE> 1
<WTP_QOS_FRAG> 1
<WTP_QOS_TXPOWER> 1
<WTP_QOS_CWMIN> 1
<WTP_QOS_CWMAX> 1
<WTP_QOS_AIFS> 1
<WTP_QOS_WME_CWMIN> 1
<WTP_QOS_WME_CWMAX> 1
<WTP_QOS_WME_AIFSN> 1
```

Explanation of the config items:

| 配置项 | 含义 | 示例 | 是否必须 |
|--------|------|------|----------|
| `<LOG_FILE_WTP>` | WTP 日志输出路径 | `/var/log/wtp1.txt` | ✅ |
| `<RADIO_PHY_TOT>` | 使用的 PHY 数量 | `1` | ✅ |
| `<RADIO_PHY_NAME_0>` | 第 0 个 PHY 名称（来自 `iw phy`） | `phy0` | ✅ |
| `<WTP_ETH_IF_NAME>` | WTP 的有线接口名称（用于 CAPWAP 控制通道） | `eth0` | ✅ |
| `<BRIDGE_IF_NAME>` | 本地桥接接口名（用于数据转发） | `bridge0` | ❌（若不开启 local bridging 可忽略） |
| `<IF_NAME>` | Monitor 模式接口名（用于监听 802.11 帧） | `mon.wlan0` | ✅（用于 hostapd 通信） |
| `<RADIO_0_IF_NAME>` | 第 0 个无线接口名（managed 模式） | `wlan0` | ✅ |
| `<BASE_MAC_IF_NAME>` | 用于生成 base MAC 地址的接口名 | `eth0` | ✅ |
| `<BOARD_REVISION_NO>` | 板级版本号（可用接口名代替） | `eth0` | ❌ |
| `<WTP_MODEL_NUM>` | 模拟的设备型号编号 | `12345678` | ✅ |
| `<WTP_SERIAL_NUM>` | 模拟的设备序列号 | `12345678` | ✅ |
| `<WTP_HOSTAPD_PORT>` | 与 hostapd 通信的本地端口 | `6333` | ✅ |
| `<WTP_HOSTAPD_UNIX_PATH>` | 与 hostapd 通信的 UNIX socket 路径 | `/tmp/wtp_ipc_hostapd` | ✅ |
| `<WTP_QOS_*>` | QoS 相关配置，1 表示启用 | `1` | ❌（可选） |

## Rewrite `config.wtp`

Set the AP ip address:

```text
...
<AC_ADDRESSES>
192.168.10.128
</AC_ADDRESSES>
...
```

## Start the WTP

```bash
sudo iw dev WTPWLan00 del
proj_path=/home/eqqie/work/openCAPWAP-master
sudo killall -9 WTP
sudo ./WTP $proj_path
```

## Start the AC and create the bridge

### Run AC

```bash
proj_path=/home/eqqie/work/openCAPWAP-master
sudo killall -9 AC
sudo ./AC $proj_path
```

### Create a bridge

1. Using DHCP

```bash
targetif=ens37
sudo dhclient -r bridgeAC
sudo ip link add name bridgeAC type bridge
sudo ip link set dev AC_tap master bridgeAC
sudo ip link set dev $targetif master bridgeAC
sudo ip link set dev bridgeAC up
sudo ip link set dev AC_tap up
sudo ip addr flush dev $targetif
sudo ip addr flush dev AC_tap
sudo dhclient bridgeAC
```

2. Using static IP (Recommend!!!)

```bash
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
sudo ip route add default via 192.168.10.1
```

3. Remove the bridge

```bash
targetif=ens37
sudo ip link set dev $targetif nomaster
sudo ip link set dev AC_tap nomaster
sudo ip addr flush dev bridgeAC
sudo ip link del bridgeAC
sudo ip link set dev $targetif up
```

## Using wum to create an Access Point

Enter into the "wum" folder and run "make"

```bash
cd wum
make
```

Get all WTPs associated with your AC

```bash
➜  wum git:(master) ✗ ./wum -c wtps         
*-------*--------------------------------*
| WTPId | WTPName                        |
*-------*--------------------------------*
|    -1 | all                            |
|     0 | openCAPWAP WTP 1               |
*-------*--------------------------------*
```

Add a new WLAN interface to a specific WTP

```bash
./wum -c addwlan -w <WTP_ID> -r 1 -l 1 -s <SSID> -t 1
# e.g.
./wum -c addwlan -w 0 -r 1 -l 1 -s opencapwap_wlan_test -t 1
```
