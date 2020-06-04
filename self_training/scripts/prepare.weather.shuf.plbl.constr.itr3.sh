#!/bin/bash

cd $(dirname $0)/../..

export CUDA_VISIBLE_DEVICES=$2
TMPDIR=/tmp
src=mr
tgt=ar
data=weather
model=lstm
orig=data-prep/$data
prep=self_training/data-prep/$data
pct=pct-$1
dest=$pct/shuf.plbl.constr.itr3

mkdir -p $prep/$dest

tmp=$prep/$dest/tmp.repl
gen=$tmp/gen.txt
base=$tmp/base.txt

mkdir -p $tmp
fairseq-generate $prep/$pct/shuf.lbl \
  --user-dir . \
  --constr-dec \
  --gen-subset train.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.ft.constr.itr2.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $gen
repl=$(grep ^H- $gen | awk -F '\t' '$2=="-inf" {print $1}' | cut -d '-' -f 2 | awk '{print $1+1}')
awk -F '\t' 'NR==FNR {l[$0];next;} (FNR in l) {print}' \
  <(echo "$repl") $prep/$pct/shuf.lbl/train.ulbl.$src-$tgt.$src \
  > $tmp/src.fail.$src-$tgt.$src
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.mr.txt) $tmp/dict.mr.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.ar.txt) $tmp/dict.ar.txt
fairseq-generate $tmp \
  --user-dir . \
  --gen-subset src.fail \
  --source-lang $src --target-lang $tgt \
  --path self_training/checkpoints/$data/$pct/shuf.ft.constr.itr2.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $base
awk -F '\t' 'NR==FNR {l[$1]=$4;next;} !(FNR in l) {print $3} (FNR in l) {print l[FNR]}' \
  <(paste <(echo "$repl" | sort -n)  <(grep ^H- $base | sort -n -k 2 -t -)) \
  <(grep ^H- $gen | sort -n -k 2 -t -) \
  > $prep/$dest/train.$src-$tgt.$tgt
rm -rf $tmp

mkdir -p $tmp
fairseq-generate $prep/$pct/shuf.lbl \
  --user-dir . \
  --constr-dec \
  --gen-subset valid.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.ft.constr.itr2.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $gen
repl=$(grep ^H- $gen | awk -F '\t' '$2=="-inf" {print $1}' | cut -d '-' -f 2 | awk '{print $1+1}')
awk -F '\t' 'NR==FNR {l[$0];next;} (FNR in l) {print}' \
  <(echo "$repl") $prep/$pct/shuf.lbl/valid.ulbl.$src-$tgt.$src \
  > $tmp/src.fail.$src-$tgt.$src
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.mr.txt) $tmp/dict.mr.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.ar.txt) $tmp/dict.ar.txt
fairseq-generate $tmp \
  --user-dir . \
  --gen-subset src.fail \
  --source-lang $src --target-lang $tgt \
  --path self_training/checkpoints/$data/$pct/shuf.ft.constr.itr2.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $base
awk -F '\t' 'NR==FNR {l[$1]=$4;next;} !(FNR in l) {print $3} (FNR in l) {print l[FNR]}' \
  <(paste <(echo "$repl" | sort -n)  <(grep ^H- $base | sort -n -k 2 -t -)) \
  <(grep ^H- $gen | sort -n -k 2 -t -) \
  > $prep/$dest/valid.$src-$tgt.$tgt
rm -rf $tmp

ln -s $(readlink -f $prep/ulbl/train.$src-$tgt.$src) $prep/$dest/train.$src-$tgt.$src
ln -s $(readlink -f $prep/ulbl/valid.$src-$tgt.$src) $prep/$dest/valid.$src-$tgt.$src

ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.$src.txt) $prep/$dest/dict.$src.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.$tgt.txt) $prep/$dest/dict.$tgt.txt

ln -s $(readlink -f $orig/test.$src-$tgt.$src) $prep/$dest/test.$src-$tgt.$src
ln -s $(readlink -f $orig/test.$src-$tgt.$tgt) $prep/$dest/test.$src-$tgt.$tgt
