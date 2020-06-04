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
dest=$pct/shuf.plbl.rrk-rev.itr3
beam_size=5

mkdir -p $prep/$dest

beam_repeat () {
  awk -v n="$beam_size" '{for(i=0;i<n;i++)print}'
}

rmtreeinfo () {
  sed 's/\[\S\+//g;s/\]//g' | awk '{$1=$1;print}'
}

tmp=$prep/$dest/tmp.rrk
REVMDLDIR=self_training/checkpoints/$data/$pct/shuf.ft.rrk-rev.rev.itr2.$model

mkdir -p $tmp
fairseq-generate $prep/$pct/shuf.lbl \
  --user-dir . \
  --gen-subset train.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.ft.rrk-rev.itr2.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp/gen.txt
grep ^S- $tmp/gen.txt | awk -F '\t' '{print $2}' | beam_repeat > $tmp/src
grep ^H- $tmp/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo > $tmp/hyp
ln -s $(readlink -f $tmp/hyp) $tmp/test.ar-mr.ar
ln -s $(readlink -f $tmp/src) $tmp/test.ar-mr.mr
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.ar.txt) $tmp/dict.ar.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.mr.txt) $tmp/dict.mr.txt
fairseq-generate $tmp \
  --user-dir . \
  --gen-subset test \
  --path $REVMDLDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --score-reference | \
  grep ^H- | sort -n -k 2 -t - | \
  awk -F '\t' '{print $2}' \
  > $tmp/score
paste \
  <(sed 's/^/-/;s/^--//' $tmp/score) \
  <(grep ^S- $tmp/gen.txt | beam_repeat) \
  <(grep ^H- $tmp/gen.txt) \
  <(grep ^P- $tmp/gen.txt) | \
  awk -v n="$beam_size" 'BEGIN{OFS="\t"}{print int((NR-1)/n),$0}' | \
  sort -g -k 1,1 -k 2,2 | \
  awk -v n="$beam_size" 'NR%n==1 {print}' | \
  awk -F '\t' '{printf"%s\t%s\n%s\t%s\t%s\n%s\t%s\n",$3,$4,$5,$6,$7,$8,$9}' | \
  grep ^H- | sort -n -k 2 -t - | awk -F '\t' '{print $3}' \
  > $prep/$dest/train.$src-$tgt.$tgt
rm -rf $tmp

mkdir -p $tmp
fairseq-generate $prep/$pct/shuf.lbl \
  --user-dir . \
  --gen-subset valid.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.ft.rrk-rev.itr2.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp/gen.txt
grep ^S- $tmp/gen.txt | awk -F '\t' '{print $2}' | beam_repeat > $tmp/src
grep ^H- $tmp/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo > $tmp/hyp
ln -s $(readlink -f $tmp/hyp) $tmp/test.ar-mr.ar
ln -s $(readlink -f $tmp/src) $tmp/test.ar-mr.mr
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.ar.txt) $tmp/dict.ar.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.mr.txt) $tmp/dict.mr.txt
fairseq-generate $tmp \
  --user-dir . \
  --gen-subset test \
  --path $REVMDLDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --score-reference | \
  grep ^H- | sort -n -k 2 -t - | \
  awk -F '\t' '{print $2}' \
  > $tmp/score
paste \
  <(sed 's/^/-/;s/^--//' $tmp/score) \
  <(grep ^S- $tmp/gen.txt | beam_repeat) \
  <(grep ^H- $tmp/gen.txt) \
  <(grep ^P- $tmp/gen.txt) | \
  awk -v n="$beam_size" 'BEGIN{OFS="\t"}{print int((NR-1)/n),$0}' | \
  sort -g -k 1,1 -k 2,2 | \
  awk -v n="$beam_size" 'NR%n==1 {print}' | \
  awk -F '\t' '{printf"%s\t%s\n%s\t%s\t%s\n%s\t%s\n",$3,$4,$5,$6,$7,$8,$9}' | \
  grep ^H- | sort -n -k 2 -t - | awk -F '\t' '{print $3}' \
  > $prep/$dest/valid.$src-$tgt.$tgt
rm -rf $tmp

ln -s $(readlink -f $prep/ulbl/train.$src-$tgt.$src) $prep/$dest/train.$src-$tgt.$src
ln -s $(readlink -f $prep/ulbl/valid.$src-$tgt.$src) $prep/$dest/valid.$src-$tgt.$src

ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.$src.txt) $prep/$dest/dict.$src.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.$tgt.txt) $prep/$dest/dict.$tgt.txt

ln -s $(readlink -f $orig/test.$src-$tgt.$src) $prep/$dest/test.$src-$tgt.$src
ln -s $(readlink -f $orig/test.$src-$tgt.$tgt) $prep/$dest/test.$src-$tgt.$tgt
