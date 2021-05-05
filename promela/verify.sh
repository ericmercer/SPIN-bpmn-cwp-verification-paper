#!/bin/sh
#
# USAGE: verify.sh <model_file> <property_file> property1 property2 ...
#   or   cat properties.txt | xargs verify.sh <model_file> <property_file>
model_file=${1}
property_file=${2}
combined="combined_${model_file}"
shift 2
rm ${combined}
cat ${model_file} >& ${combined}
cat ${property_file} >> ${combined}
# echo "$file"
# echo "$@"
for i in "$@"
do
  spin -run -ltl ${i} -m50000 ${combined} | grep -E "(never claim[[:space:]+])|(errors:)|(of [[:digit:]+])" &
  wait $!
done
