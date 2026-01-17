# ElectrumX with BitcoinPurple (BTCP) Support

This repository provides a **Dockerized** setup of **ElectrumX** with support for the **BitcoinPurple (BTCP)** coin.
It also includes a test script (`test-server.py`) to verify the connection and main functionalities of the ElectrumX server.

Tested on:

* ✅ Debian 12
* ✅ Ubuntu 24.04

🔗 BitcoinPurple Full Node: [BitcoinPurpleBlockchain/bitcoinpurplecore](https://github.com/BitcoinPurpleBlockchain/bitcoinpurplecore)

---

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Electrum      │    │   ElectrumX     │    │  BitcoinPurple  │
│   Clients       │◄──►│   Server        │◄──►│   Full Node     │
│                 │    │   (Docker)      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## Requirements

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* Python 3.10+ (to use `test-server.py`)
* A running **BitcoinPurple** full node

**System Architecture**: This server requires a **64-bit system** (both AMD64 and ARM64 architectures are supported, but 32-bit systems are not compatible).

**Recommendation**: to ensure maximum stability and reduce communication latency, it is strongly recommended to run the BitcoinPurple node **on the same machine** that hosts the ElectrumX container.

---

## Docker Installation

If you don't have Docker installed yet, follow the official guide:
- [Install Docker](https://docs.docker.com/get-docker/)

For Docker Compose:
- [Install Docker Compose](https://docs.docker.com/compose/install/)

---

## Configuration

In the `docker-compose.yml` file, you can set the RPC credentials of the BitcoinPurple full node that ElectrumX will use:

```yaml
environment:
  DAEMON_URL: "http://<rpcuser>:<rpcpassword>@host.docker.internal:<port>/"
```

Replace with your actual values:

* `<rpcuser>` → RPC username of the node
* `<rpcpassword>` → RPC password of the node
* `<port>` → RPC port of the node (e.g., `13495` for BitcoinPurple)

**Note:** The compose uses `host.docker.internal` to connect to the BitcoinPurple node running on your host machine (outside the container). This works on both Windows/Mac and Linux thanks to the `extra_hosts` configuration.

**Important RPC Configuration:** To allow RPC connections from the Docker container, you need to configure your `bitcoinpurple.conf` file properly.

Here's a recommended complete configuration:

```conf
# Basic settings
txindex=1
server=1
discover=1
listen=1
daemon=1

# RPC Configuration
rpcport=13495
rpcuser=<rpcuser>
rpcpassword=<rpcpassword>

# Network binding - listen on localhost and Docker bridge
rpcbind=127.0.0.1
rpcbind=172.17.0.1

# Allow RPC access from localhost and Docker networks
rpcallowip=127.0.0.1
rpcallowip=172.16.0.0/12

# P2P port
port=13496

# Optional: Add bootstrap nodes
```

**Important Notes:**
- Replace `<your_rpc_username>` and `<your_rpc_password>` with secure credentials
- `rpcallowip=172.16.0.0/12` covers all Docker private networks (172.16.0.0 - 172.31.255.255)
- After modifying the config, you **must restart** the BitcoinPurple node for changes to take effect

**Ports:** ElectrumX exposes:
- `60001` → TCP (unencrypted)
- `60002` → SSL (encrypted, recommended)

**Important:** never include real credentials in files you upload to GitHub.

---

## Start the Project

1. Navigate to the directory containing `docker-compose.yml` and `Dockerfile`.

2. Start the ElectrumX server:

   ```bash
   docker compose up -d
   ```

   **Note:** The Docker image will be built automatically on the first run. You don't need to run `docker build` manually.

3. Check the logs to verify that ElectrumX started correctly:

   ```bash
   docker compose logs -f
   ```

   You should see messages indicating successful connection to the BitcoinPurple node and synchronization progress.

### Rebuilding the Image

If you need to rebuild the image after making changes to the Dockerfile or ElectrumX configuration:

```bash
docker compose up -d --build
```

Or manually:

```bash
docker compose build
docker compose up -d
```
---

## Testing with `test-server.py`

The `test-server.py` script allows you to connect to the ElectrumX server and test its APIs.

Usage example:

```bash
python test-server.py 127.0.0.1:60002
```

The script will perform:

* Handshake (`server.version`)
* Feature request (`server.features`)
* Block header subscription (`blockchain.headers.subscribe`)

---

## Notes

* `coins_btcp.py` defines the **BitcoinPurple (BTCP)** coin, based on Bitcoin.
* Production recommendations:

  * Protect RPC credentials
  * Use valid SSL certificates
  * Monitor containers (logs, metrics, alerts)

---

## License

Distributed under the **MIT** license. See the `LICENSE` file for details.
