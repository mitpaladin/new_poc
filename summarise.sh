#!/bin/bash

outfile="$TMPDIR/summarise.out"

function _summarise_grep_outfile()
{
    grep $1 $outfile | cut -d ' ' -f $2
}

function _summarise_get_rspec_examples()
{
    _summarise_grep_outfile ' examples, ' 1
}

function _summarise_get_rspec_failures()
{
    _summarise_grep_outfile ' examples, ' 3
}

function _summarise_get_rubocop_inspected()
{
    _summarise_grep_outfile ' inspected' 1
}

function _summarise_get_rubocop_offenses()
{
    local ret=`_summarise_grep_outfile " inspected" 3`
    echo $ret | sed 's/no/0/g'
}

function _summarise_total_of()
{
    local total=0
    for i in $*; do
        total=`expr $total + $i`
    done
    echo -n $total
}

function summarise()
{
    echo "Running RSpec and RuboCop now; please wait."
    rasummary > $outfile
    echo; echo; echo 'SUMMARY:'
    echo -n 'RSpec: '
    _summarise_total_of `_summarise_get_rspec_examples`
    echo -n ' examples, '
    _summarise_total_of `_summarise_get_rspec_failures`
    echo " errors"
    echo -n 'RuboCop: '
    _summarise_total_of `_summarise_get_rubocop_inspected`
    echo ' files inspected, '
    _summarise_total_of `_summarise_get_rubocop_offenses`
    echo "offenses found"
    rm $outfile
}
