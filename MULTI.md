# Multi-sequence profile

This repository adds [`start-multi.sh`](start-multi.sh) on top of [MiaAI-Lab/DeepSeek-v4-Flash-One-DGX-Spark](https://github.com/MiaAI-Lab/DeepSeek-v4-Flash-One-DGX-Spark).

| Launcher | Profile |
|----------|---------|
| `./start-multi.sh` | 8 concurrent seqs, 256k context, port **8001**, DSpark K5 |
| `./start.sh` | Upstream defaults: 1 seq, 384k context, port **8888** |

```bash
git clone https://github.com/rimusz/DeepSeek-v4-Flash-One-DGX-Spark.git
cd DeepSeek-v4-Flash-One-DGX-Spark
./download.sh
./start-multi.sh
curl -sf http://127.0.0.1:8001/v1/models
```

Override with env vars, e.g. `MAX_NUM_SEQS=4 ./start-multi.sh`.
