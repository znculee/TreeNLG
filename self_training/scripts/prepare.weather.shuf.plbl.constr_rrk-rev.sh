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
dest=$pct/shuf.plbl.constr_rrk-rev
beam_size=5

mkdir -p $prep/$dest

beam_repeat () {
  awk -v n="$beam_size" '{for(i=0;i<n;i++)print}'
}

rmtreeinfo () {
  sed 's/\[\S\+//g;s/\]//g' | awk '{$1=$1;print}'
}

tmp_repl=$prep/$dest/tmp.repl
gen=$tmp_repl/gen.txt
base=$tmp_repl/base.txt
tmp_rrk=$tmp_repl/tmp.rrk
REVMDLDIR=self_training/checkpoints/$data/$pct/shuf.lbl.rev.$model

mkdir -p $tmp_repl
mkdir -p $tmp_rrk
fairseq-generate $prep/$pct/shuf.lbl \
  --user-dir . \
  --constr-dec \
  --gen-subset train.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.lbl.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp_rrk/gen.txt
grep ^S- $tmp_rrk/gen.txt | awk -F '\t' '{print $2}' | beam_repeat > $tmp_rrk/src
grep ^H- $tmp_rrk/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo > $tmp_rrk/hyp
ln -s $(readlink -f $tmp_rrk/hyp) $tmp_rrk/test.ar-mr.ar
ln -s $(readlink -f $tmp_rrk/src) $tmp_rrk/test.ar-mr.mr
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.ar.txt) $tmp_rrk/dict.ar.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.mr.txt) $tmp_rrk/dict.mr.txt
fairseq-generate $tmp_rrk \
  --user-dir . \
  --gen-subset test \
  --path $REVMDLDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --score-reference | \
  grep ^H- | sort -n -k 2 -t - | \
  awk -F '\t' '{print $2}' \
  > $tmp_rrk/score
paste \
  <(sed 's/^/-/;s/^--//' $tmp_rrk/score) \
  <(grep ^S- $tmp_rrk/gen.txt | beam_repeat) \
  <(grep ^H- $tmp_rrk/gen.txt) \
  <(grep ^P- $tmp_rrk/gen.txt) | \
  awk -v n="$beam_size" 'BEGIN{OFS="\t"}{print int((NR-1)/n),$0}' | \
  sort -g -k 1,1 -k 2,2 | \
  awk -v n="$beam_size" 'NR%n==1 {print}' | \
  awk -F '\t' '{printf"%s\t%s\n%s\t%s\t%s\n%s\t%s\n",$3,$4,$5,$6,$7,$8,$9}' \
  > $gen
rm -rf $tmp_rrk
repl=$(grep ^H- $gen | awk -F '\t' '$2=="-inf" {print $1}' | cut -d '-' -f 2 | awk '{print $1+1}')
awk -F '\t' 'NR==FNR {l[$0];next;} (FNR in l) {print}' \
  <(echo "$repl") $prep/$pct/shuf.lbl/train.ulbl.$src-$tgt.$src \
  > $tmp_repl/src.fail.$src-$tgt.$src
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.mr.txt) $tmp_repl/dict.mr.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.ar.txt) $tmp_repl/dict.ar.txt
mkdir -p $tmp_rrk
fairseq-generate $tmp_repl \
  --user-dir . \
  --gen-subset src.fail \
  --source-lang $src --target-lang $tgt \
  --path self_training/checkpoints/$data/$pct/shuf.lbl.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp_rrk/gen.txt
grep ^S- $tmp_rrk/gen.txt | awk -F '\t' '{print $2}' | beam_repeat > $tmp_rrk/src
grep ^H- $tmp_rrk/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo > $tmp_rrk/hyp
ln -s $(readlink -f $tmp_rrk/hyp) $tmp_rrk/test.ar-mr.ar
ln -s $(readlink -f $tmp_rrk/src) $tmp_rrk/test.ar-mr.mr
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.ar.txt) $tmp_rrk/dict.ar.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.mr.txt) $tmp_rrk/dict.mr.txt
fairseq-generate $tmp_rrk \
  --user-dir . \
  --gen-subset test \
  --path $REVMDLDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --score-reference | \
  grep ^H- | sort -n -k 2 -t - | \
  awk -F '\t' '{print $2}' \
  > $tmp_rrk/score
paste \
  <(sed 's/^/-/;s/^--//' $tmp_rrk/score) \
  <(grep ^S- $tmp_rrk/gen.txt | beam_repeat) \
  <(grep ^H- $tmp_rrk/gen.txt) \
  <(grep ^P- $tmp_rrk/gen.txt) | \
  awk -v n="$beam_size" 'BEGIN{OFS="\t"}{print int((NR-1)/n),$0}' | \
  sort -g -k 1,1 -k 2,2 | \
  awk -v n="$beam_size" 'NR%n==1 {print}' | \
  awk -F '\t' '{printf"%s\t%s\n%s\t%s\t%s\n%s\t%s\n",$3,$4,$5,$6,$7,$8,$9}' \
  > $base
rm -rf $tmp_rrk
awk -F '\t' 'NR==FNR {l[$1]=$4;next;} !(FNR in l) {print $3} (FNR in l) {print l[FNR]}' \
  <(paste <(echo "$repl" | sort -n)  <(grep ^H- $base | sort -n -k 2 -t -)) \
  <(grep ^H- $gen | sort -n -k 2 -t -) \
  > $prep/$dest/train.$src-$tgt.$tgt
rm -rf $tmp_repl

mkdir -p $tmp_repl
mkdir -p $tmp_rrk
fairseq-generate $prep/$pct/shuf.lbl \
  --user-dir . \
  --constr-dec \
  --gen-subset valid.ulbl \
  --path self_training/checkpoints/$data/$pct/shuf.lbl.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp_rrk/gen.txt
grep ^S- $tmp_rrk/gen.txt | awk -F '\t' '{print $2}' | beam_repeat > $tmp_rrk/src
grep ^H- $tmp_rrk/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo > $tmp_rrk/hyp
ln -s $(readlink -f $tmp_rrk/hyp) $tmp_rrk/test.ar-mr.ar
ln -s $(readlink -f $tmp_rrk/src) $tmp_rrk/test.ar-mr.mr
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.ar.txt) $tmp_rrk/dict.ar.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.mr.txt) $tmp_rrk/dict.mr.txt
fairseq-generate $tmp_rrk \
  --user-dir . \
  --gen-subset test \
  --path $REVMDLDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --score-reference | \
  grep ^H- | sort -n -k 2 -t - | \
  awk -F '\t' '{print $2}' \
  > $tmp_rrk/score
paste \
  <(sed 's/^/-/;s/^--//' $tmp_rrk/score) \
  <(grep ^S- $tmp_rrk/gen.txt | beam_repeat) \
  <(grep ^H- $tmp_rrk/gen.txt) \
  <(grep ^P- $tmp_rrk/gen.txt) | \
  awk -v n="$beam_size" 'BEGIN{OFS="\t"}{print int((NR-1)/n),$0}' | \
  sort -g -k 1,1 -k 2,2 | \
  awk -v n="$beam_size" 'NR%n==1 {print}' | \
  awk -F '\t' '{printf"%s\t%s\n%s\t%s\t%s\n%s\t%s\n",$3,$4,$5,$6,$7,$8,$9}' \
  > $gen
rm -rf $tmp_rrk
repl=$(grep ^H- $gen | awk -F '\t' '$2=="-inf" {print $1}' | cut -d '-' -f 2 | awk '{print $1+1}')
awk -F '\t' 'NR==FNR {l[$0];next;} (FNR in l) {print}' \
  <(echo "$repl") $prep/$pct/shuf.lbl/valid.ulbl.$src-$tgt.$src \
  > $tmp_repl/src.fail.$src-$tgt.$src
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.mr.txt) $tmp_repl/dict.mr.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.ar.txt) $tmp_repl/dict.ar.txt
mkdir -p $tmp_rrk
fairseq-generate $tmp_repl \
  --user-dir . \
  --gen-subset src.fail \
  --source-lang $src --target-lang $tgt \
  --path self_training/checkpoints/$data/$pct/shuf.lbl.$model/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp_rrk/gen.txt
grep ^S- $tmp_rrk/gen.txt | awk -F '\t' '{print $2}' | beam_repeat > $tmp_rrk/src
grep ^H- $tmp_rrk/gen.txt | awk -F '\t' '{print $3}' | rmtreeinfo > $tmp_rrk/hyp
ln -s $(readlink -f $tmp_rrk/hyp) $tmp_rrk/test.ar-mr.ar
ln -s $(readlink -f $tmp_rrk/src) $tmp_rrk/test.ar-mr.mr
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.ar.txt) $tmp_rrk/dict.ar.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl.rev/dict.mr.txt) $tmp_rrk/dict.mr.txt
fairseq-generate $tmp_rrk \
  --user-dir . \
  --gen-subset test \
  --path $REVMDLDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --score-reference | \
  grep ^H- | sort -n -k 2 -t - | \
  awk -F '\t' '{print $2}' \
  > $tmp_rrk/score
paste \
  <(sed 's/^/-/;s/^--//' $tmp_rrk/score) \
  <(grep ^S- $tmp_rrk/gen.txt | beam_repeat) \
  <(grep ^H- $tmp_rrk/gen.txt) \
  <(grep ^P- $tmp_rrk/gen.txt) | \
  awk -v n="$beam_size" 'BEGIN{OFS="\t"}{print int((NR-1)/n),$0}' | \
  sort -g -k 1,1 -k 2,2 | \
  awk -v n="$beam_size" 'NR%n==1 {print}' | \
  awk -F '\t' '{printf"%s\t%s\n%s\t%s\t%s\n%s\t%s\n",$3,$4,$5,$6,$7,$8,$9}' \
  > $base
rm -rf $tmp_rrk
awk -F '\t' 'NR==FNR {l[$1]=$4;next;} !(FNR in l) {print $3} (FNR in l) {print l[FNR]}' \
  <(paste <(echo "$repl" | sort -n)  <(grep ^H- $base | sort -n -k 2 -t -)) \
  <(grep ^H- $gen | sort -n -k 2 -t -) \
  > $prep/$dest/valid.$src-$tgt.$tgt
rm -rf $tmp_repl

ln -s $(readlink -f $prep/ulbl/train.$src-$tgt.$src) $prep/$dest/train.$src-$tgt.$src
ln -s $(readlink -f $prep/ulbl/valid.$src-$tgt.$src) $prep/$dest/valid.$src-$tgt.$src

ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.$src.txt) $prep/$dest/dict.$src.txt
ln -s $(readlink -f $prep/$pct/shuf.lbl/dict.$tgt.txt) $prep/$dest/dict.$tgt.txt

ln -s $(readlink -f $orig/test.$src-$tgt.$src) $prep/$dest/test.$src-$tgt.$src
ln -s $(readlink -f $orig/test.$src-$tgt.$tgt) $prep/$dest/test.$src-$tgt.$tgt
