#!/bin/bash

cd $(dirname $0)/../..

data=e2e
orig=data-prep/$data
prep=self_training/data-prep/$data/ulbl

mkdir -p $prep

build_vocab() {
  sed 's/ /\n/g' $1 | \
  awk '
    {if ($0!="") wc[$0]+=1}
    END {for (w in wc) print w, wc[w]}
  ' | \
  LC_ALL=C sort -k2,2nr -k1,1
}

shuf $orig/train.augment-del.mr| \
  awk -v path="$prep//" '{print > ((NR<=3000) ? (path "valid.mr-ar.mr") : (path "train.mr-ar.mr"))}'

build_vocab $prep/train.mr-ar.mr > $prep/dict.mr.txt
