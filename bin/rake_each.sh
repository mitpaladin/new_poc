#!/bin/bash
all_specs=`find spec -name *_spec.rb`
Q=$CODECLIMATE_REPO_TOKEN
unset CODECLIMATE_REPO_TOKEN
START_TIME=`date`
for i in $all_specs; do
  bundle exec rspec -f p --order defined $i 2>&1 > last.out
  if [[ $? -ne 0 ]]; then
    echo FAILED SPEC: $i
    cat last.out >> all.out
  fi
done
export CODECLIMATE_REPO_TOKEN=$q
unset Q
echo Started at      $START_TIME
echo Current time is `date`
unset START_TIME
if [[ -e all.out ]]; then
  echo "** ALL FAILED SPECS:"
  grep ^rspec all.out | cut -f 1 -d ':' | awk '{printf("%s\n", $2);}' | sed 's,^./,,' | sort -u
  return 99
fi
true
