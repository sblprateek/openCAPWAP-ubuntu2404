# OpenCAPWAP v2.0 for Ubuntu24.04

Original README.md: [README.old.md](./README.old.md)

## Requirements

1. libnl

```bash
sudo apt install -y libnl-3-dev libnl-3-genl-dev
```

2. openssl-0.9.8 or later

```bash
wget https://github.com/openssl/openssl/releases/download/OpenSSL_0_9_8zh/openssl-0.9.8zh.tar.gz
tar -xzf openssl-0.9.8zh.tar.gz
cd openssl-0.9.8zh
./config --prefix=/opt/openssl-0.9.8
make
sudo make install
```

## Installing

Within the openCAPWAP folder, type:
```
make clean
make
```

## Usage and more information

Please read [INSTALL](./INSTALL).
