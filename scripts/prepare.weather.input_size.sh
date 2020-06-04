#!/bin/bash

cd $(dirname $0)/..

src=mr
tgt=ar
orig=data-prep/weather
prep=data-prep/weather.dialogacts

mkdir -p $prep

awk '{str=$0;print gsub(/\[__DG_INFORM__/,"")"\t"str}' \
  $orig/test.mr-ar.mr | \
  sort -n -k1,1 \
  > $prep/test.dginform.mr

awk -F '\t' 'BEGIN{printf "stastistics:\n"}{n[$1]+=1}END{for(i in n)print i"\t"n[i]}' \
  $prep/test.dginform.mr |
  sort -n -k1,1

awk -F '\t' '{if($1==1)print $2}' $prep/test.dginform.mr > $prep/test.dginform.1.mr
awk -F '\t' '{if($1==2)print $2}' $prep/test.dginform.mr > $prep/test.dginform.2.mr
awk -F '\t' '{if($1==3)print $2}' $prep/test.dginform.mr > $prep/test.dginform.3.mr
awk -F '\t' '{if($1==4)print $2}' $prep/test.dginform.mr > $prep/test.dginform.4.mr
awk -F '\t' '{if($1==5)print $2}' $prep/test.dginform.mr > $prep/test.dginform.5.mr

awk -F '\t' '{if($1<=1)print $2}' $prep/test.dginform.mr > $prep/test.dginform.upto1.mr
awk -F '\t' '{if($1<=2)print $2}' $prep/test.dginform.mr > $prep/test.dginform.upto2.mr
awk -F '\t' '{if($1<=3)print $2}' $prep/test.dginform.mr > $prep/test.dginform.upto3.mr
awk -F '\t' '{if($1<=4)print $2}' $prep/test.dginform.mr > $prep/test.dginform.upto4.mr
awk -F '\t' '{if($1<=5)print $2}' $prep/test.dginform.mr > $prep/test.dginform.upto5.mr
