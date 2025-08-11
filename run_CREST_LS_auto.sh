#!/bin/bash

########################################
# 通用并行运行脚本（用于替代 multi-prog）
# 用法：
#   bash run_CREST_LS_auto.sh <MCR> <PROJECT> <BIN> <NCORES>
# 示例：
#   srun -n500 -o log/%j_rank%t_run_LS.out bash run_CREST_LS_auto.sh /path/to/mcr /path/to/project /path/to/bin 500
########################################

# 获取传入参数
MCR="$1"
PROJECT="$2"
BIN="$3"
NCORES="$4"

# 获取当前核编号
RANK=${SLURM_PROCID}

# 打印当前信息
echo "[Rank $RANK] Running task with:"
echo "  - MCR     = $MCR"
echo "  - PROJECT = $PROJECT"
echo "  - BIN     = $BIN"
echo "  - NCORES  = $NCORES"

# 核心 0 运行 Monitor
if [ "$RANK" -eq 0 ]; then
  echo "[Rank $RANK] ➤ Starting CRESTIOMonitor_LS..."
  $BIN/run_CRESTIOMonitor_LS.sh "$MCR" "$PROJECT" "$((NCORES - 1))" "$((NCORES - 1))"

# 其它核心运行 CREST_LS
else
  echo "[Rank $RANK] ➤ Starting CREST_LS..."
  $BIN/run_CREST_LS.sh "$MCR" "$PROJECT" mean "$RANK" "$((NCORES - 1))"
fi

