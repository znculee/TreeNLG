#!/bin/bash

cd $(dirname $0)/..

export CUDA_VISIBLE_DEVICES=0
TMPDIR=/tmp
data=weather
model=lstm
SAVEDIR=checkpoints/$data.$model

mkdir -p $SAVEDIR

fairseq-train data-prep/$data \
  --user-dir . \
  --task translation --arch $model \
  --max-epoch 100 --patience 5 \
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
  | tee $SAVEDIR/log.txt
