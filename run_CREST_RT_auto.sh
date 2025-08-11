#!/bin/bash

########################################
# Routing 自动脚本（可扩展到多核）
# 用法：
#   bash run_CREST_RT_auto.sh <MCR> <PROJECT> <BIN> <NCORES>
# 示例：
#   srun -n1 bash run_CREST_RT_auto.sh ... 1
########################################

# 获取参数
MCR="$1"
PROJECT="$2"
BIN="$3"
NCORES="$4"

# 当前核编号
# 加入一个偏移
RANK=$((SLURM_PROCID + 1))

echo "[Routing Rank $RANK] Starting routing task..."
echo "  - MCR     = $MCR"
echo "  - PROJECT = $PROJECT"
echo "  - BIN     = $BIN"
echo "  - RANK    = $RANK"
echo "  - NCORESRT  = $NCORES"

# 执行 routing（模式设为 mean）
$BIN/run_CREST_RT.sh "$MCR" "$PROJECT" mean "$RANK" "$NCORES"

