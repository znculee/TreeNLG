#!/bin/bash

cd $(dirname $0)/..

export CUDA_VISIBLE_DEVICES=$1
TMPDIR=/tmp
data=weather
model=lstm
SAVEDIR=checkpoints/$data.$model
testpfx=test
beam_size=5
gen=gen.rrk-bleu_oracle.txt

tmp=$SAVEDIR/tmp.rrk
mkdir -p $tmp

# generating
fairseq-generate data-prep/$data \
  --user-dir . \
  --gen-subset $testpfx \
  --path $SAVEDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam $beam_size --nbest $beam_size \
  --max-len-a 2 --max-len-b 50 \
  > $tmp/gen.txt

beam_repeat () {
  awk -v n="$beam_size" '{for(i=0;i<n;i++)print}'
}

# preparing for rescoring
grep ^T- $tmp/gen.txt | awk -F '\t' '{print $2}' | beam_repeat > $tmp/tgt
grep ^H- $tmp/gen.txt | awk -F '\t' '{print $3}' > $tmp/hyp

# rescoring
python rerank/scorer.bleu_oracle.py $tmp

# reranking
paste \
  <(sed 's/^/-/;s/^--//' $tmp/score) \
  <(grep ^S- $tmp/gen.txt | beam_repeat) \
  <(grep ^T- $tmp/gen.txt | beam_repeat) \
  <(grep ^H- $tmp/gen.txt) \
  <(grep ^P- $tmp/gen.txt) | \
  awk -v n="$beam_size" 'BEGIN{OFS="\t"}{print int((NR-1)/n),$0}' | \
  sort -n -k 1,1 -k 2,2 | \
  awk -v n="$beam_size" 'NR%n==1 {print}' | \
  awk -F '\t' '{printf"%s\t%s\n%s\t%s\n%s\t%s\t%s\n%s\t%s\n",$3,$4,$5,$6,$7,$8,$9,$10,$11}' \
  > $SAVEDIR/$gen

rm -rf $tmp

# evaluating
if [[ "$gen" == *".constr."* ]]; then
  base=$(readlink -f $SAVEDIR/$(echo $gen | sed 's/.constr//'))
  echo -e "\nreplacing failures from $base"
  if [ ! -f $base ]; then
    echo "$base does not exist"
    exit
  fi
  bash scripts/measure_scores.replfail.sh $SAVEDIR/$gen $base data-prep/$data/$testpfx.mr-ar.ar
  bash scripts/tree_acc.replfail.sh $SAVEDIR/$gen $base
else
  bash scripts/measure_scores.sh $SAVEDIR/$gen data-prep/$data/$testpfx.mr-ar.ar
  bash scripts/tree_acc.sh $SAVEDIR/$gen
fi
