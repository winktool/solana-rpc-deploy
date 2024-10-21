#!/bin/bash

# args: $AGAVE_VERSION $YELLOWSTONE-GRPC-GIT-REV
if [ "$#" -ne 2 ]; then
    echo "Not enough params: run this script with the following args: JITO-SOLANA_VERSION YELLOWSTONE-GRPC-GIT-REV"
    exit 1
fi

starting_pwd=$(pwd)

# updates
sudo apt-get update
sudo apt-get upgrade -y

# solana user
sudo useradd -M solana
sudo usermod -L solana

sudo ufw allow 8000:8020/tcp
sudo ufw allow 8000:8020/udp
sudo ufw allow 8899 # http 端口
sudo ufw allow 8900 # websocket 端口

sudo ufw enable
sudo ufw status

# setup service
sudo cp solana-validator.service /etc/systemd/system/solana-validator.service
sudo systemctl enable solana-validator.service
sudo systemctl stop solana-validator.service

# get requirements to build agave validator
curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
rustup update
sudo apt-get install libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler

# clone validator
mkdir /solana
cd /solana
git clone https://github.com/anza-xyz/agave

# clone yellowstone-grpc
# @TODO - this doesn't install all deps for yellowstone
cd /solana
git clone https://github.com/rpcpool/yellowstone-grpc
cd $starting_pwd
cp yellowstone-geyser-config.json /solana/yellowstone-grpc/yellowstone-grpc-geyser/config.json

# build validator and yellowstone plugin
bash build-validator.sh $1 $3

# install solana cli tools
echo 'export PATH="/solana/agave/target/release/:$PATH"' >> /root/.profile && source /root/.profile
source /root/.profile

# generate validator identity
solana-keygen new -o /solana/validator_identity.json

# tune knobs or whatever
sudo cp sysctl.conf /etc/sysctl.d/21-solana-validator.conf
sudo sysctl -p /etc/sysctl.d/21-solana-validator.conf

# Increase systemd and session file limits
sudo sed -i '/^\[Manager\]/a DefaultLimitNOFILE=1000000' /etc/systemd/system.conf && sudo systemctl daemon-reload

sudo systemctl daemon-reload

sudo bash -c "cat >/etc/security/limits.d/90-solana-nofiles.conf <<EOF
# Increase process file descriptor count limit
* - nofile 1000000
EOF"

ulimit -n 1000000

# logrotate
sudo cp logrotate /etc/logrotate.d/sol
systemctl restart logrotate.service

# move validator start script
cp start_validator.sh /solana/start_validator.sh
chmod +x /solana/start_validator.sh

mkdir /solana/snapshots

# transfer ownership of /solana directory to the solana user
chown -R solana /solana
chown -R $(whoami) /solana/agave
chmod -R +r /solana/agave
chown -R $(whoami) /solana/yellowstone-grpc
chmod -R +r /solana/yellowstone-grpc
sudo chown solana:solana /solana/validator_identity.json
sudo chmod 600 /solana/validator_identity.json

sudo apt install linux-tools-common linux-tools-$(uname -r)

sudo cpupower frequency-info

sudo cp cpupower-performance.service /etc/systemd/system/cpupower-performance.service
sudo systemctl enable cpupower-performance.service
sudo systemctl stop cpupower-performance.service
sudo systemctl start cpupower-performance.service

# start rpc
sudo systemctl start solana-validator.service


echo node is deployed!