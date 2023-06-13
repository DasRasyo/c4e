#!/bin/bash


echo -e "                                                       ";
echo -e "   ______                                              ";
echo -e "  / ____/___  ____  ____ ___  _____  _________  _____  ";
echo -e " / /   / __ \/ __ \/ __  / / / / _ \/ ___/ __ \/ ___/  ";
echo -e "/ /___/ /_/ / / / / /_/ / /_/ /  __/ /  / /_/ / /      ";
echo -e "\____/\____/_/ /_/\__  /\__ _/\___/_/   \____/_/       ";
echo -e "                    /_/                                ";
echo -e "                                                       ";

echo -e "\033[38;5;245mTwitter : https://twitter.com/Conquerorr_1\033[0m"
echo -e "\033[38;5;245mGithub  : https://github.com/DasRasyo\033[0m"

sleep 5

echo "Which node would you like to install? (1: mainnet, 2: testnet)"
read node_type

case $node_type in
  1)
      echo -e "\033[35mMainnet Node! Lets start!\033[0m"   
sleep 7

prompt() {
  read -p "$1: " val
  echo $val
}

echo -e "\033[38;5;205m⚠️Starting with Packages update and Dependencies Inslall⚠️\033[0m"
sleep 5

sudo apt update && apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential \
git make ncdu -y 

sleep 5

echo -e "\033[38;5;205m⚠️Installing GO⚠️\033[0m"

sleep 10

cd $HOME
curl -Ls https://go.dev/dl/go1.20.1.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
touch $HOME/.bash_profile
source $HOME/.bash_profile
PATH_INCLUDES_GO=$(grep "$HOME/go/bin" $HOME/.bash_profile)
if [ -z "$PATH_INCLUDES_GO" ]; then
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
  echo "export GOPATH=$HOME/go" >> $HOME/.bash_profile
fi
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

sleep 5

source $HOME/.bash_profile

echo -e "\033[38;5;205mPackages updated, Go and Dependencies Inslalled. You can check your go version with = go version\033[0m"

sleep 7

echo -e "\033[35mSetting Up c4e-chain\033[0m"

sleep 5

cd $HOME 
rm -rf c4e-chain
git clone --depth 1 --branch  v1.0.1  https://github.com/chain4energy/c4e-chain.git
cd c4e-chain 
make install


sleep 8
cd $HOME 


echo -e "\033[35mInitializing the c4e-chain\033[0m"

sleep 5

node_name=$(prompt "Enter your node name")
c4ed init $node_name --chain-id perun-1

sleep 8

rm -rf ~/.c4e-chain/config/genesis.json

sleep 3

git clone https://github.com/chain4energy/c4e-chains.git
cd c4e-chains/perun-1
cp genesis.json ~/.c4e-chain/config/

sleep 3


sed -e "s|persistent_peers = \".*\"|persistent_peers = \"$(cat .data | grep -oP 'Persistent peers\s+\K\S+')\"|g" ~/.c4e-chain/config/config.toml > ~/.c4e-chain/config/config.toml.tmp
mv ~/.c4e-chain/config/config.toml.tmp  ~/.c4e-chain/config/config.toml

sleep 3

echo -e "\033[35mSetting State-sync\033[0m"

SNAP_RPC="https://rpc-c4e.theamsolutions.info:443"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height) \
&& BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)) \
&& TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sleep 2

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.c4e-chain/config/config.toml; \
wget -qO $HOME/.c4e-chain/config/addrbook.json  https://snapshots.theamsolutions.info/c4e-addrbook.json

sleep 2

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC1,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.c4e-chain/config/config.toml

sleep 2

c4ed tendermint unsafe-reset-all --home $HOME/.c4e-chain

sleep 5

echo -e "\033[35mStarting c4ed Service\033[0m"

sleep 3

sudo tee <<EOF >/dev/null /etc/systemd/system/c4ed.service
[Unit]
Description=celestia-appd Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/c4ed start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sleep 3

sudo systemctl enable c4ed
sudo systemctl start c4ed

sleep 3

echo -e "\033[35mCongrats!! Your node started!\033[0m"
sleep 3
echo -e "\033[35mSome Useful Command That You May Need For c4ed Service. Copy and Save!\033[0m"
sleep 3
echo -e "\033[35mCheck Your Logs:       sudo journalctl -u c4ed -f --no-hostname -o cat\033[0m"
sleep 3
echo -e "\033[35mStop the Service:      sudo systemctl stop c4ed\033[0m"
sleep 3
echo -e "\033[35mStart the Service:     sudo systemctl start c4ed\033[0m"
sleep 3
echo -e "\033[35mRestart the Service:   sudo systemctl restart c4ed\033[0m"
sleep 10

echo -e "\033[31m⚠️⚠️⚠️Lets create a wallet! Please do not forget to save your mnemonics!!!. If you dont save you can not access your wallet. After creating wallet, you will have 100 second to save your mnemonics. After that script will continued!⚠️⚠️⚠️\033[0m"
sleep 3
echo -e "\033[31m⚠️ Before creating your validator do not forget to top up your wallet with some coin! ⚠️\033[0m"
sleep 3
echo -e "\033[31m⚠️⚠️⚠️ SAVE THE MNEMONICS⚠️⚠️⚠️\033[0m"
sleep 17

wallet_name=$(prompt "Enter your wallet name")
c4ed keys add $wallet_name

sleep 100

echo -e "\033[38;5;205mWith this script we automaticly check if your node fully synced. After synced you can go on with creating your validator. The script will check sync status every 60 seconds and will print the status.\033[0m"

while true
do

    sync_status=$(curl -s localhost:26657/status | jq '.result | .sync_info | .catching_up')
        if [ "$sync_status" = "false" ]; then
        echo "Your node is synced with the c4e-chain."
            sleep 5
            echo "Your node is now synced with the c4e-chain. Proceed with validator creation."
            sleep 5
            echo "Stop the script with ctrl C and edit the following command with your information to create your validator!"
            sleep 10
            echo -e "\033[38;5;205mc4ed tx staking create-validator --amount=1000000uc4e --pubkey=$(c4ed tendermint show-validator) --moniker=$moniker --chain-id=perun-1 --commission-rate=0.10 --commission-max-rate=0.20 --commission-max-change-rate=0.1 --min-self-delegation=1 --identity=KeyBaseID --details=details --website=Yourwebsite --security-contact=contactdetails --from=$wallet_name --evm-address=Evm-address\033[0m"
		sleep 20

        else
       echo "Your node is not synced with the c4e-chain. Waiting for sync to complete..."
           sleep 60
        fi
done

    ;;
esac
