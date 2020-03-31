#!/bin/bash

if [ $# -eq 1 ]; then
  gen=$(readlink -f $1)
else
  echo "Usage: tree_acc hypothesis"
fi

cd $(dirname $0)/..

tmp=scripts/tmp
tsv=$tmp/tsv
id=$tmp/id
src=$tmp/src
hyp=$tmp/hyp

mkdir -p $tmp

grep S- $gen | awk -F '\t' '{print $1}' | sed 's/^S-//' > $id
grep S- $gen | awk -F '\t' '{print $2}' > $src
grep H- $gen | awk -F '\t' '{print $3}' > $hyp
paste $id $src $hyp > $tsv

python scripts/compute_tree_acc.py -tsv $tsv


rm -rf $tmp
