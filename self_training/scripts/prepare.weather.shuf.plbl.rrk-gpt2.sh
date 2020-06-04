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
dest=$pct/shuf.plbl.rrk-gpt2
beam_size=5

mkdir -p $prep/$dest

beam_repeat () {
  awk -v n="$beam_size" '{for(i=0;i<n;i++)print}'
}

rmtreeinfo () {
  sed 's/\[\S\+//g;s/\]//g' | awk '{$1=$1;print}'
}

rplcplhlr () {
  sed '
    s/__ARG_BAD_ARG__/location/g;
    s/__ARG_CITY__/Cleveland/g;
    s/__ARG_COUNTRY__/United States/g;
    s/__ARG_DAY__/6/g;
    s/__ARG_END_DAY__/15/g;
    s/__ARG_END_MONTH__/December/g;
    s/__ARG_END_TIME__/07:00 AM/g;
    s/__ARG_END_WEEKDAY__/Sunday/g;
    s/__ARG_END_YEAR__/2018/g;
    s/__ARG_MONTH__/October/g;
    s/__ARG_PRECIP_AMOUNT_UNIT__/inches/g;
    s/__ARG_PRECIP_AMOUNT__/1.01/g;
    s/__ARG_PRECIP_CHANCE__/58/g;
    s/__ARG_REGION__/Ohio/g;
    s/__ARG_START_DAY__/8/g;
    s/__ARG_START_MONTH__/November/g;
    s/__ARG_START_TIME__/06:00 AM/g;
    s/__ARG_START_WEEKDAY__/Friday/g;
    s/__ARG_TEMP_HIGH__/35/g;
    s/__ARG_TEMP_LOW__/25/g;
    s/__ARG_TEMP_UNIT__/fahrenheit/g;
    s/__ARG_TEMP__/23/g;
    s/__ARG_TIME__/09:00 AM/g;
    s/__ARG_WEEKDAY__/Saturday/g;
    s/__ARG_WIND_SPEED__/moderate winds/g;
    s/__ARG_YEAR__/2018/g;
    s/<number>/70/g;
  '
}

tmp=$prep/$dest/tmp.rrk
hyp=$tmp/hyp

mkdir -p $tmp
fairseq-generate $prep/$pct/shuf.lbl \
  --user-dir . \
  --gen-subset train.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.lbl.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp/gen.txt
grep ^H- $tmp/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo | rplcplhlr > $hyp
python rerank/scorer.gpt2.py $tmp
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
  --path self_training/checkpoints/$data/$pct/shuf.lbl.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp/gen.txt
grep ^H- $tmp/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo | rplcplhlr > $hyp
python rerank/scorer.gpt2.py $tmp
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
