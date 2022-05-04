#!/bin/sh
#
# USAGE: verify.sh <cwp_state_file> <bpmn_file> <cwp_ltl_file> property1 property2 ...
#   or   cat properties.txt | xargs verify.sh <cwp_state_file> <bpmn_file> <cwp_ltl_file>

cwp_class_file=${1}
bpmn_file=${2}
cwp_state_file=${3}
combined="combined_${bpmn_file}"
shift 3
rm ${combined}
cat ${cwp_class_file} >& ${combined}
cat ${cwp_state_file} >> ${combined}
cat ${bpmn_file} >> ${combined}
# echo "$file"
# echo "$@"

# Sanity check for assertion violations
spin -run -noclaim ${i} -m50000 ${combined} | grep -E "(never claim[[:space:]+])|(errors:)|(of [[:digit:]+])"

# Check each specified property
for i in "$@"
do
  spin -run -ltl ${i} -m50000 ${combined} | grep -E "(never claim[[:space:]+])|(errors:)|(of [[:digit:]+])" &
  wait $!
done
