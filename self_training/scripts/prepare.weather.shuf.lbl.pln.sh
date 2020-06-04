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
  dest=pct-$p/shuf.lbl.pln
  mkdir -p $prep/$dest

  ln -s $(readlink -f $prep/$orig/train.$src-$tgt.$src) $prep/$dest/train.$src-$tgt.$src
  sed 's/\[\S\+//g;s/\]//g' $prep/$orig/train.$src-$tgt.$tgt | awk '{$1=$1;print}' > $prep/$dest/train.$src-$tgt.$tgt

  ln -s $(readlink -f $prep/$orig/valid.$src-$tgt.$src) $prep/$dest/valid.$src-$tgt.$src
  sed 's/\[\S\+//g;s/\]//g' $prep/$orig/valid.$src-$tgt.$tgt | awk '{$1=$1;print}' > $prep/$dest/valid.$src-$tgt.$tgt

  ln -s $(readlink -f $prep/$orig/test.$src-$tgt.$src) $prep/$dest/test.$src-$tgt.$src
  sed 's/\[\S\+//g;s/\]//g' $prep/$orig/test.$src-$tgt.$tgt | awk '{$1=$1;print}' > $prep/$dest/test.$src-$tgt.$tgt

  ln -s $(readlink -f $prep/$orig/dict.$src.txt) $prep/$dest/dict.$src.txt
  build_vocab $prep/$dest/train.$src-$tgt.$tgt > $prep/$dest/dict.$tgt.txt

  ln -s $(readlink -f $prep/ulbl/train.$src-$tgt.$src) $prep/$dest/train.ulbl.$src-$tgt.$src
  ln -s $(readlink -f $prep/ulbl/valid.$src-$tgt.$src) $prep/$dest/valid.ulbl.$src-$tgt.$src
done
