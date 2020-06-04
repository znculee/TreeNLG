#!/bin/bash

cd $(dirname $0)/../..

data=weather
src=mr
tgt=ar
prep=self_training/data-prep/$data

build_vocab() {
  sed 's/ /\n/g' $1 | \
  awk '
    {if ($0!="") wc[$0]+=1}
    END {for (w in wc) print w, wc[w]}
  ' | \
  LC_ALL=C sort -k2,2nr -k1,1
}

for p in 01 02 05 10 20 50 1c; do
  orig=pct-$p/shuf.lbl
  dest=pct-$p/shuf.lbl.rev
  mkdir -p $prep/$dest

  ln -s $(readlink -f $prep/$orig/train.$src-$tgt.$src) $prep/$dest/train.$tgt-$src.$src
  sed 's/\[\S\+//g;s/\]//g' $prep/$orig/train.$src-$tgt.$tgt | awk '{$1=$1;print}' > $prep/$dest/train.$tgt-$src.$tgt

  ln -s $(readlink -f $prep/$orig/valid.$src-$tgt.$src) $prep/$dest/valid.$tgt-$src.$src
  sed 's/\[\S\+//g;s/\]//g' $prep/$orig/valid.$src-$tgt.$tgt | awk '{$1=$1;print}' > $prep/$dest/valid.$tgt-$src.$tgt

  ln -s $(readlink -f $prep/$orig/dict.$src.txt) $prep/$dest/dict.$src.txt
  build_vocab $prep/$dest/train.$tgt-$src.$tgt > $prep/$dest/dict.$tgt.txt
done
