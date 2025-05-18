# 🟢 Ethereum Sepolia Node Setup (Geth + Prysm)

Geth = Execution (Sepolia)  
Prysm = Consensus (Beacon)

Deploy a full Ethereum Sepolia Execution + Consensus node in **one click** using Docker and `docker-compose`.

---

## ⚙️ Recommended System Requirements

| Component | Recommended       |
|-----------|-------------------|
| OS        | Ubuntu 20.04+     |
| RAM       | 8–16 GB           |
| CPU       | 4–6 cores         |
| Disk      | SSD with 550 GB+  |

---

## VPS Purchase Recommendation

Buy from 👉 [Contabo VPS](https://contabo.com/en/vps/)

#### ✅ Recommended Plan:

![Screenshot 2025-05-19 015838](https://github.com/user-attachments/assets/4bca754f-555f-4246-a20b-3d40674b0274)

#### 📦 Buy more storage (800GB SSD):

![Screenshot 2025-05-19 015815](https://github.com/user-attachments/assets/efb93500-3528-490f-9d71-f9721b173350)

---

## 🙂 Update VPS 

```bash

sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt install git -y

```
## 🚀 One-Line Deployment

Run this command on a fresh VPS:

```bash
bash <(curl -s https://raw.githubusercontent.com/MeG0302/Sepolia-node-deployment-script/main/setup.sh)
```

Below are normal logs you’ll see during sync:

![Screenshot 2025-05-19 020345](https://github.com/user-attachments/assets/4763da84-e823-4dec-a142-17866b99b1b5)

> 💡 Press `CTRL + C` to stop checking logs.

## 🕒 Sync Time

Once deployed, wait for your node to fully sync.  
⏳ **Estimated Time:** 2–5 hours depending on network and disk speed.

---

## ✅ Checking If Nodes Are Synced

### ➡️ Execution Node (Geth)

Run the following command:

```bash
curl -X POST -H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
http://localhost:8545
```

- ✅ **If fully synced:**

```json
{"jsonrpc":"2.0","id":1,"result":false}
```

- 🚫 **If still syncing:**

```json
{
  "jsonrpc":"2.0",
  "id":1,
  "result":{
    "startingBlock":"0x0",
    "currentBlock":"0x1a2b3c",
    "highestBlock":"0x1a2b4d"
  }
}
```

---

### ➡️ Beacon Node (Prysm)

Check the sync status with:

```bash
curl http://localhost:3500/eth/v1/node/syncing
```

- ✅ **If fully synced:**

```json
{
  "data": {
    "head_slot": "12345",
    "sync_distance": "0",
    "is_syncing": false
  }
}
```

- 🚫 **If still syncing:**

```json
{
  "data": {
    "head_slot": "12345",
    "sync_distance": "100",
    "is_syncing": true
  }
}
```

If `is_syncing` is `true`, your beacon node is still catching up.  
`sync_distance` shows how many slots behind it is.



## 🌐 Getting the RPC Endpoints

### ⚙️ Execution Node (Geth)

Geth exposes its HTTP RPC interface on **port 8545**. You can use this to interact with the Ethereum execution layer.

- **Inside the VPS**  
  `http://localhost:8545`

- **Outside the VPS**  
  `http://<your-vps-ip>:8545`  
  *(Replace `<your-vps-ip>` with your VPS’s public IP. Example: `http://203.0.113.5:8545`)*

- **Aztec Sequencer Execution RPC**  
  - If using **CLI**: `http://<your-vps-ip>:8545`  
  - If using **docker-compose**: `http://127.0.0.1:8545` or `http://localhost:8545`

---

### 🔗 Beacon Node (Prysm)

Prysm exposes its HTTP interface on **port 3500**. This is used for consensus (beacon chain) interactions.

- **Inside the VPS**  
  `http://localhost:3500`

- **Outside the VPS**  
  `http://<your-vps-ip>:3500`  
  *(Example: `http://203.0.113.5:3500`)*

- **Aztec Sequencer Consensus RPC**  
  - If using **CLI**: `http://<your-vps-ip>:3500`  
  - If using **docker-compose**: `http://127.0.0.1:3500` or `http://localhost:3500`

---

✅ Use these endpoints to connect to your node — whether you're working directly on the VPS or accessing it remotely.
