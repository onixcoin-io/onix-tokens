
# Onix Token Templates

This repository contains the official templates used to make ORC20 (fungible) and ORC721 (non-fungible) tokens
on the Onix Blockchain.

**How to use**

First, you'll need an Ubuntu Linux 20+ VM or VPS with to install requirements and compile the contracts.

The next packages are required:

- Solidity compiler
- [Solar for Onix tool](https://github.com/onixcoin-io/solar)
- Open Zeppelin Smart Contract templates
- An [Onixcoin wallet](https://github.com/onixcoin-io/onix/releases) with a handful of ONIX to pay fees

In the steps below, we'll guide you to get the environment ready.

## Step 1: install prerequisites

Change to the root account with

    sudo -i

Run the next commands to install the Solidity Compiler and NPM:

    apt install software-properties-common
    add-apt-repository ppa:ethereum/ethereum
    add-apt-repository ppa:ethereum/ethereum-dev
    apt-get update
    apt-get install solc
    apt install npm

We'll need version 1.17.8 of Golang, and it is installed with the next commands:

    cd /usr/src
    wget https://go.dev/dl/go1.17.8.linux-amd64.tar.gz
    cd /usr/local
    tar -zxvf /usr/src/go1.17.8.linux-amd64.tar.gz
    cd /bin
    ln -s /usr/local/go/bin/go
    ln -s /usr/local/go/bin/gofmt

Note: only the steps above require root privileges.

## Step 2: install the Onix headless wallet

These steps are done using a standard user account (**not root**).

**Important:** the blockchain weights about 26 GB at the time of writing this tutorial.
Make sure you have enough space for it. 50 GB or more are recommended.

Or...

Download the latest snapshot of the Blockchain from the wallet downloads
at [onixcoin.io](https://onixcoin.io/about/token#wallet) into the `~/.onix` directory
after creating it.

Or...

To decrease the size of the download, you can uncomment the `prune=1024` line below (by removing the # symbol)
to only get the latest 1024 MB (1 GB) of the blockchain.

If you already have a wallet running locally or somewhere else but you can connect to its RPC stack,
skip over to the next step.

    mkdir ~/bin
    cd ~/bin
    wget https://github.com/onixcoin-io/onix/releases/download/0.2.1/onix-0.2.1-linux.tar.gz
    tar -zxvf onix-0.2.1-linux.tar.gz
    mv cli/* ./ && rmdir cli
    cd ~
    mkdir .onix
    
    echo "listen=1"             >  .onix/onix.conf
    echo "server=1"             >> .onix/onix.conf
    echo "bind=127.0.0.1"       >> .onix/onix.conf
    echo "port=5888"            >> .onix/onix.conf
    echo "rpcbind=127.0.0.1"    >> .onix/onix.conf
    echo "rpcport=5889"         >> .onix/onix.conf
    echo "rpcuser=onixrpc"      >> .onix/onix.conf
    echo "rpcpassword=onixpass" >> .onix/onix.conf
    echo "rpcallowip=127.0.0.1" >> .onix/onix.conf
    echo "staking=0"            >> .onix/onix.conf
    echo "logevents=1"          >> .onix/onix.conf
    echo "txindex=0"            >> .onix/onix.conf
    echo "# prune=1024"         >> .onix/onix.conf

**Note:** you might need to restart your SSH connection in order to have `~/bin` in your path.

If you want to download the bootstrap instead of syncing frin scratch, type the next commands:

    cd ~/.onix
    wget https://ipfs.onixcoin.io/ipfs/QmekS4dyu6AeYiHMjrmPt4zzkgfaBLboCzWJwmEJn2wdxr/bootstrap-20221208.zip
    unzip bootstrap-20221208.zip
    rm bootstrap-20221208.zip

Depending on your network speed, it may take a couple of hours (or more) to complete.

Now start the wallet with:

    onixd -daemon

If you've chosen to 'prune' the download and get any error, edit the `.onix/onix.conf` file and comment the
`prune=1024` line by adding a # character at the start.

Once the wallet is in sync with the network, get a deposit address:

    onix-cli getnewaddress

Then copy the given address and paste it in a text file.

Fund that address with a few Onix. About 10 ONIX will suffice for tests. Let them get at least 10 confirmations
before continuing.

To see the transaction details (and confirmations count), you can use the next command:

    onix-cli listtransactions

The output will look like this:

    [
      {
        "address": "Xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "category": "receive",
        "amount": 10.00000000,
        "label": "",
        "vout": 1,
        "confirmations": 3,
        "blockhash": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "blockheight": xxxxxx,
        "blockindex": x,
        "blocktime": xxxxxxxxxx,
        "txid": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "walletconflicts": [
        ],
        "time": xxxxxxxxxx,
        "timereceived": xxxxxxxxxx,
        "bip125-replaceable": "no"
      }
    ]

## Step 3: prepare sources

Run the next commands to instal Solar:

    cd ~
    go get -v -u github.com/onixcoin-io/solar/cli/solar
    cd bin && ln -s ../go/bin/solar && cd ..

Now clone the Open Zeppelin contract templates used for :

    mkdir ~/contracts
    cd ~/contracts
    git clone git@github.com:onixcoin-io/openzeppelin-contracts.git

Now clone **this** repository in place:

    git clone git@github.com:onixcoin-io/onix-tokens.git

## Compiling and deploying

At this moment, you have solc, solar, the smart contracts and a wallet with some Onix in it.
You need to define some environment variables.

Before that, we need to know the hex version of the wallet address you'll use to own the tokens.
That can be achieved with the next command:

    onix-cli gethexaddress <your_onix_address>

E.G.

    onix-cli gethexaddress XNP2kdVeF9nbTWp8fGeasWrDa2gvaeQYTS
    79001e7be0e831e256058c76abfb2ad4f8d5dbe8

The string below the command is the hex string we will need.

Copy the next lines, edit them on a text editor and then paste them on the command line:
    
    cd ~/contracts
    export ONIX_RPC=http://onixrpc:onixpass@127.0.0.1:5889
    SRC_ADDR=<your_onix_address>
    SRC_HEX=<hex_of_your_onix_address>
    DEPLOYMENT_DIR=`pwd`
    TOKEN_NAME="A name for your token"
    TOKEN_SYMBOL="MYTOKEN"
    DECIMALS="8"
    INITIAL_SUPPLY="100000000000000"

From the lines above:

1. Go into the `contracts` directory
2. Set access to the wallet RPC interface on an environment variable
3. Define the Onix wallet address that will hold the tokens
4. The hex version of the address
5. Set where are we going to get the compiled files (the same dir we're on, ~/contracts)
6. Set a name for your token, E.G. "My marvelous token"
7. Set a symbol for your token, E.G. "MARV"
8. The amount of decimals you want to use. Eight decimals are encouraged for compatibility.
9. The initial supply in satoshis. Just add **one zero for each decimal** to the supply you want, E.G.:  
   For 1 billion tokens (1,000,000,000) and eight decimals, set it to 1000000000**00000000**  
   For 21 million tokens and eight decimals, set it to 21000000**00000000** 

**Important:** think of a good symbol that isn't used anywhere else (surely not BTC, ETH, USDT, etc.).
You'll have to do some research over the web, specially in [CoinMarketCap](https://coinmarketcap.com),
[CoinGecko](https://www.coingecko.com/) or the
[BitcoinTalk Altcoin anns forum](https://bitcointalk.org/index.php?board=159.0)
to check for symbols being used already and avoid them.

Once that's set, just invoke solar using the smart contract of choice:

    solar deploy "onix-tokens/ORC20.sol" "[\"$TOKEN_NAME\",\"$TOKEN_SYMBOL\",$INITIAL_SUPPLY,$DECIMALS]" \
          --env="$TOKEN_SYMBOL" --onix_sender="$SRC_ADDR"

You'll get an output like this:

    cli gasPrice 1 1
    🚀  All contracts confirmed
       deployed ORC721.sol => xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Where `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` is the smart contract address of your token.

That's all! You'll have a file named `solar.MYTOKEN.json` that contains all the information
of the smart contract, including the ABI.

## If you plan to deploy NFTs

In the sample above, the `ORC20.sol` contract was used, and that's for fungible tokens.

For NFTs, you use the `ORC721.sol` contract, and you'll have to mint every token at a time.

To deploy the contract, you set the environment variables as shown below:

    cd ~/contracts
    export ONIX_RPC=http://onixrpc:onixpass@127.0.0.1:5889
    SRC_ADDR=<your_onix_address>
    SRC_HEX=<hex_of_your_onix_address>
    DEPLOYMENT_DIR=`pwd`
    TOKEN_NAME="A name for your NFT"
    TOKEN_SYMBOL="MYNFT"

Then invoke solar:

    solar deploy "onix-tokens/ORC721.sol" "[\"$TOKEN_NAME\",\"$TOKEN_SYMBOL\"]" \
          --env="$TOKEN_SYMBOL" --onix_sender="$SRC_ADDR"
    
Then you'll have a file named `solar.MYNFT.json`.

You now need to interact with the smart contract to mint at least 1 NFT.
And for this purpose, you can install and use our
[PHP helper](https://github.com/onixcoin-io/orc721-php-helper).
