#!/bin/bash

cd $(dirname $0)/../..

export CUDA_VISIBLE_DEVICES=$2
TMPDIR=/tmp
data=weather
model=lstm
pct=pct-$1
SAVEDIR=self_training/checkpoints/$data/$pct/shuf.ft.itr3.$model
RESTORECKP=self_training/checkpoints/$data/$pct/shuf.plbl.itr3.$model/checkpoint_best.pt

mkdir -p $SAVEDIR

fairseq-train self_training/data-prep/$data/$pct/shuf.lbl \
  --user-dir . \
  --task translation --arch $model \
  --max-epoch 500 --patience 20 \
  --optimizer adam --lr 1e-3 --clip-norm 0.1 \
  --lr-scheduler reduce_lr_on_plateau --lr-shrink 0.1 --lr-patience 3 \
  --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
  --max-sentences 128 \
  --dropout 0.2 \
  --encoder-embed-dim 300 --decoder-embed-dim 300 \
  --encoder-hidden-size 128 --decoder-hidden-size 128 \
  --encoder-layers 1 --decoder-layers 1 \
  --dataset-impl raw \
  --save-dir $SAVEDIR \
  --no-epoch-checkpoints \
  --restore-file $RESTORECKP \
  --reset-dataloader --reset-lr-scheduler --reset-meters --reset-optimizer \
  | tee $SAVEDIR/log.txt
