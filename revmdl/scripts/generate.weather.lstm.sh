#!/bin/bash

cd $(dirname $0)/../..

TMPDIR=/tmp
data=weather
model=lstm
testpfx=test
PREPDIR=revmdl/data-prep
SAVEDIR=revmdl/checkpoints/$data.$model
gen=gen.txt

fairseq-generate $PREPDIR/$data \
  --user-dir . \
  --gen-subset $testpfx \
  --path $SAVEDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $SAVEDIR/$gen

bash scripts/measure_scores.sh $SAVEDIR/$gen $PREPDIR/$data/$testpfx.ar-mr.mr
bash revmdl/scripts/tree_acc.sh $SAVEDIR/$gen
