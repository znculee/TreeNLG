#!/bin/bash

cd $(dirname $0)/../..

data=weather
src=mr
tgt=ar
prep=self_training/data-prep/$data

for p in 01 02 05 10 20 50 1c; do
  orig=pct-$p/shuf.plbl.rrk-rev
  dest=pct-$p/shuf.plbl.rrk-rev.rev
  mkdir -p $prep/$dest

  ln -s $(readlink -f $prep/$orig/train.$src-$tgt.$src) $prep/$dest/train.$tgt-$src.$src
  sed 's/\[\S\+//g;s/\]//g' $prep/$orig/train.$src-$tgt.$tgt | awk '{$1=$1;print}' > $prep/$dest/train.$tgt-$src.$tgt

  ln -s $(readlink -f $prep/$orig/valid.$src-$tgt.$src) $prep/$dest/valid.$tgt-$src.$src
  sed 's/\[\S\+//g;s/\]//g' $prep/$orig/valid.$src-$tgt.$tgt | awk '{$1=$1;print}' > $prep/$dest/valid.$tgt-$src.$tgt

  ln -s $(readlink -f $prep/pct-$p/shuf.lbl.rev/dict.$src.txt) $prep/$dest/dict.$src.txt
  ln -s $(readlink -f $prep/pct-$p/shuf.lbl.rev/dict.$tgt.txt) $prep/$dest/dict.$tgt.txt
done
