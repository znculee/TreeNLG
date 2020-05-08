#!/bin/bash

if [ $# -eq 2 ]; then
  gen=$(readlink -f $1)
  ref_tree=$(readlink -f $(dirname $2)/$(basename $2 | sed 's/.disc//'))
else
  echo "Usage: measure_scores hypothesis reference"
  exit 0
fi

cd $(dirname $0)/..

if [ ! -d e2e-metrics ]; then
  echo 'Cloning e2e-metrics github repository...'
  git clone https://github.com/tuetschek/e2e-metrics
  echo '-----------------------------------------------------'
  echo '| See README of e2e-metrics to install dependencies |'
  echo '-----------------------------------------------------'
  exit
fi

SCORER=e2e-metrics/measure_scores.py
org=data/E2E_compositional/testset_w_refs.csv
tmp=scripts/tmp
src=$tmp/src
ref=$tmp/ref
hyp=$tmp/hyp

mkdir -p $tmp

rmtreeinfo () {
  sed 's/\[\S\+//g;s/\]//g' | awk '{$1=$1;print}'
}

cat $ref_tree | rmtreeinfo > $ref
grep ^H- $gen | sort -n -k 2 -t - | awk -F '\t' '{print $3}' | rmtreeinfo > $hyp
if [[ $(basename $2) == *".disc."* ]]; then
  didx=data/E2E_compositional/disc.idx
  dhyp=$tmp/hyp.disc
  awk -F '\t' '
    NR==FNR {l[$1]=$2;next}
    (FNR in l) {print l[FNR]}
    !(FNR in l) {print "n/a"}
  ' <(paste $didx $hyp) $ref > $dhyp
  mv $dhyp $hyp
fi
tail -n +2 $org | cut -d '"' -f 2 > $src

python scripts/_eval_e2e_helper.py
python $SCORER -p $ref $hyp 2> /dev/null

rm -rf $tmp
