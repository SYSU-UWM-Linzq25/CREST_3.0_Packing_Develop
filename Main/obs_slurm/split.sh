#!/bin/bash

if [ "z$1" == "z" ]; then
  echo missing the slurm output.
  echo "usage: ./split.sh slurm_output [largest_number_of_tasks]"
  exit 1
fi

mkdir ${1%.*}

nfile=$(cut -d ":" -f 1 slurm-31772.out |sort|tail -n1)
if [ "z$2" == "z" ] || [ $2 -gt $nfile  ]; then
  echo Assuming there are $nfile tasks.
else
  nfile=$2
fi

for i in `seq -f %02g 0 $nfile`; do
  echo greping $i:
  grep "$i: " $1 > ${1%.*}/$1_$i.out
done
