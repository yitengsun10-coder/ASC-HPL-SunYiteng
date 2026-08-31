# ASC HPL 实验记录

姓名：孙逸腾  
学号：240810010427

本仓库保存 ASC 训练中 HPL 的可复现实验材料，包括构建配置、7 组参数、运行脚本和完整结果日志。

## 结果摘要

- 7 组配置均通过残差正确性检查（PASSED）。
- 最佳结果：235.50 GFLOP/s。
- 主要搜索维度：MPI 进程网格、矩阵规模 `N`、分块大小 `NB`。

## 目录

- `configs/`：各组 HPL.dat 配置。
- `results/`：逐组原始运行日志。
- `复现脚本/`：构建配置与批量运行脚本。
- `run_hpl_matrix.sh`、`run_hpl_sweep2.sh`：参数搜索脚本。

大型编译产物未纳入仓库；请先安装 MPI 与 OpenBLAS，并按 `复现脚本/Make.WSL_OpenBLAS` 构建 HPL。

