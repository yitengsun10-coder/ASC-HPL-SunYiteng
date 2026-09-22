# ASC HPL 性能优化与可复现实验记录

- 学生：孙逸腾（240810010427）
- 题目：基础题 HPL
- 官方入口：https://www.netlib.org/benchmark/hpl/
- 状态：7 组参数全部完成，7/7 通过残差正确性检查
- 最佳结果：235.50 GFLOP/s（`N=18000`、`NB=256`、`P×Q=2×2`）

本仓库是轻量可复核仓库，保存参数文件、构建配置、批量脚本和原始文本日志，不保存可重新编译得到的二进制文件。

## 一分钟验收

在仓库根目录执行：

```bash
python tools/verify_evidence.py
```

该命令仅使用 Python 标准库，会逐个解析 `results/*.log`，检查 HPL 结果行、`PASSED` 残差标记和最佳 GFLOP/s。它不会重新运行 HPL。

## 环境与构建

实验环境为 Linux/WSL，使用 MPI 和 OpenBLAS。仓库中的 [`复现脚本/Make.WSL_OpenBLAS`](复现脚本/Make.WSL_OpenBLAS) 保存了本次构建配置。下载 HPL 2.3 后，将该文件放入 HPL 的 `setup/` 或按本机路径调整 `TOPdir`、MPI、BLAS 路径，然后执行：

```bash
make arch=WSL_OpenBLAS
```

生成的 `xhpl` 不纳入仓库，因为它依赖本机 MPI/BLAS 动态库。

## 运行方法

将 `HPL_BIN` 指向编译后的 `xhpl`：

```bash
export HPL_BIN=/absolute/path/to/xhpl
bash run_hpl_matrix.sh
```

脚本依次复制 [`configs/`](configs/) 中的 7 份 `HPL.dat`，按 `P×Q` 启动相应 MPI 进程，并把新输出保存到被 Git 忽略的 `reproduced/`，不会覆盖原始 `results/`。单组复现示例：

```bash
mkdir -p reproduced/manual && cd reproduced/manual
cp ../../configs/HPL_2x2_N18000_NB256.dat HPL.dat
mpirun -np 4 "$HPL_BIN" | tee run.log
```

## 参数与实测结果

| N | NB | P×Q | 时间 s | GFLOP/s | 正确性 | 原始日志 |
|---:|---:|:---:|---:|---:|:---:|---|
| 18000 | 128 | 1×1 | 22.79 | 170.66 | PASSED | [`HPL_1x1_N18000_NB128.log`](results/HPL_1x1_N18000_NB128.log) |
| 18000 | 256 | 1×1 | 22.47 | 173.03 | PASSED | [`HPL_1x1_N18000_NB256.log`](results/HPL_1x1_N18000_NB256.log) |
| 18000 | 256 | 1×2 | 17.49 | 222.31 | PASSED | [`HPL_1x2_N18000_NB256.log`](results/HPL_1x2_N18000_NB256.log) |
| 18000 | 256 | 1×4 | 23.51 | 165.41 | PASSED | [`HPL_1x4_N18000_NB256.log`](results/HPL_1x4_N18000_NB256.log) |
| 18000 | 192 | 2×2 | 19.73 | 197.07 | PASSED | [`HPL_2x2_N18000_NB192.log`](results/HPL_2x2_N18000_NB192.log) |
| 18000 | 256 | 2×2 | 16.51 | **235.50** | PASSED | [`HPL_2x2_N18000_NB256.log`](results/HPL_2x2_N18000_NB256.log) |
| 18000 | 384 | 2×2 | 22.62 | 171.92 | PASSED | [`HPL_2x2_N18000_NB384.log`](results/HPL_2x2_N18000_NB384.log) |

## 优化分析

本实验逐项改变进程网格和分块大小，保持矩阵规模一致。`2×2, NB=256` 在该机器上取得最高吞吐；`NB=192/384` 均较慢，说明分块过小会增加面板与调度开销，过大则降低并行和缓存利用。`1×4` 也明显弱于均衡的 `2×2` 网格，表明进程网格形状会影响通信量。

## 证据目录

- [`configs/`](configs/)：每组测试实际使用的 `HPL.dat`。
- [`results/`](results/)：7 份未经改写的 HPL 标准输出。
- [`run_hpl_matrix.sh`](run_hpl_matrix.sh)：完整矩阵运行脚本。
- [`run_hpl_sweep2.sh`](run_hpl_sweep2.sh)：第二轮参数扫描脚本。
- [`tools/verify_evidence.py`](tools/verify_evidence.py)：跨平台证据解析器。

判断正确性时以每份日志末尾的归一化残差和 `PASSED` 为准；性能数值不能替代正确性检查。
