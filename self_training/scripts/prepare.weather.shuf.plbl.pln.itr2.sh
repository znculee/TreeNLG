#!/bin/bash

cd $(dirname $0)/../..

export CUDA_VISIBLE_DEVICES=$2
TMPDIR=/tmp
src=mr
tgt=ar
data=weather
model=lstm
prep=self_training/data-prep/$data
pct=pct-$1
dest=$pct/shuf.plbl.pln.itr2

mkdir -p $prep/$dest

fairseq-generate $prep/$pct/shuf.lbl.pln \
  --user-dir . \
  --gen-subset train.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.ft.pln.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 | \
  grep ^H- | sort -n -k 2 -t - | awk -F '\t' '{print $3}' \
  > $prep/$dest/train.$src-$tgt.$tgt

fairseq-generate $prep/$pct/shuf.lbl.pln \
  --user-dir . \
  --gen-subset valid.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.ft.pln.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 | \
  grep ^H- | sort -n -k 2 -t - | awk -F '\t' '{print $3}' \
  > $prep/$dest/valid.$src-$tgt.$tgt

ln -s $(readlink -f $prep/ulbl/train.$src-$tgt.$src) $prep/$dest/train.$src-$tgt.$src
ln -s $(readlink -f $prep/ulbl/valid.$src-$tgt.$src) $prep/$dest/valid.$src-$tgt.$src

ln -s $(readlink -f $prep/$pct/shuf.lbl.pln/dict.$src.txt) $prep/$dest/dict.$src.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl.pln/dict.$tgt.txt) $prep/$dest/dict.$tgt.txt

ln -s $(readlink -f $prep/$pct/shuf.lbl.pln/test.$src-$tgt.$src) $prep/$dest/test.$src-$tgt.$src
ln -s $(readlink -f $prep/$pct/shuf.lbl.pln/test.$src-$tgt.$tgt) $prep/$dest/test.$src-$tgt.$tgt
