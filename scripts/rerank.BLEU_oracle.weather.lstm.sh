#!/bin/bash

cd $(dirname $0)/..

TMPDIR=/tmp
data=weather
model=lstm
SAVEDIR=checkpoints/$data.$model
testpfx=test
rerank_scorer=BLEU_oracle
gen=gen.rerank-$rerank_scorer.txt

python reranking/generate.py data-prep/$data \
  --user-dir . \
  --rerank-scorer $rerank_scorer \
  --gen-subset $testpfx \
  --path $SAVEDIR/checkpoint_best.pt \
  --dataset-impl raw \
  --max-sentences 128 \
  --beam 5 \
  --max-len-a 2 --max-len-b 50 \
  > $SAVEDIR/$gen

bash scripts/measure_scores.sh $SAVEDIR/$gen data-prep/$data/$testpfx.mr-ar.ar
bash scripts/tree_acc.sh $SAVEDIR/$gen
bash scripts/count_failure_cases.sh $SAVEDIR/$gen

if [[ "$gen" == *".constr."* ]]; then
  base=$(readlink -f $(echo $SAVEDIR/$gen | sed 's/.constr//'))
  echo -e "\nreplacing failures from $base"
  if [ ! -f $base ]; then
    echo "$base does not exist"
    rm $SAVEDIR/$gen
    exit
  fi
  bash scripts/measure_scores.replfail.sh $SAVEDIR/$gen $base data-prep/$data/$testpfx.mr-ar.ar
  bash scripts/tree_acc.replfail.sh $SAVEDIR/$gen $base
fi
