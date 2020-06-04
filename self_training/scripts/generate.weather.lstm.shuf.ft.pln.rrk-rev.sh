#!/bin/bash

cd $(dirname $0)/../..

export CUDA_VISIBLE_DEVICES=$2
TMPDIR=/tmp
data=weather
model=lstm
pct=pct-$1
SAVEDIR=self_training/checkpoints/$data/$pct/shuf.ft.pln.rrk-rev.$model
testpfx=test

gen=gen.txt
fairseq-generate self_training/data-prep/$data/$pct/shuf.lbl.pln \
  --user-dir . \
  --gen-subset $testpfx \
  --path $SAVEDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $SAVEDIR/$gen
bash scripts/measure_scores.sh $SAVEDIR/$gen self_training/data-prep/$data/$pct/shuf.lbl/$testpfx.mr-ar.ar

tmp=$SAVEDIR/tmp.autotreeacc
REVMDLDIR=self_training/checkpoints/$data/pct-1c/shuf.lbl.rev.$model
mkdir -p $tmp
ln -s $(readlink -f $SAVEDIR/$gen) $tmp/gen.txt
grep ^S- $tmp/gen.txt | awk -F '\t' '{print $2}' > $tmp/test.ar-mr.mr
grep ^H- $tmp/gen.txt | awk -F '\t' '{print $3}' | sed 's/\[\S\+//g;s/\]//g' | awk '{$1=$1;print}' > $tmp/test.ar-mr.ar
ln -s $(readlink -f self_training/data-prep/$data/pct-1c/shuf.lbl.rev/dict.ar.txt) $tmp/dict.ar.txt
ln -s $(readlink -f self_training/data-prep/$data/pct-1c/shuf.lbl.rev/dict.mr.txt) $tmp/dict.mr.txt
fairseq-generate $tmp \
  --user-dir . \
  --gen-subset test \
  --path $REVMDLDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $tmp/gen.rev.txt
bash revmdl/scripts/tree_acc.sh $tmp/gen.rev.txt
rm -rf $tmp
