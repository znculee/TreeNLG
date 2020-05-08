#!/bin/bash

cd $(dirname $0)/../..

dataset=weather
src=mr
tgt=ar
orig=data-prep/$dataset
prep=revmdl/data-prep/$dataset

if [ -d $prep ]; then
  echo "$dataset has been prepared for reverse model"
  echo "start over by removing manually"
  exit
fi
mkdir -p $prep

for pou in train valid test; do
  echo "preparing $pou..."
  python revmdl/scripts/_prepare.mr.helper.py $dataset $pou
  sed 's/\[\S\+//g;s/\]//g' $orig/$pou.$src-$tgt.ar | awk '{$1=$1;print}' > $prep/tmp.$pou.ar
done

echo -e "\nproprecessing..."
fairseq-preprocess \
  --source-lang $tgt --target-lang $src \
  --trainpref $prep/tmp.train --validpref $prep/tmp.valid --testpref $prep/tmp.test \
  --destdir $prep \
  --dataset-impl raw \

rm $prep/tmp.*
