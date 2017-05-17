#!/bin/bash -e

. ../common.sh

log=$logDir/sbatch.log

echo "04-panel sbatch.sh running at `date`" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

if [ "$SP_SIMULATE" = "1" -o "$SP_SKIP" = "1" ]
then
    exclusive=
    echo "  Simulating or skipping. Not requesting exclusive node." >> $log
else
    # Request an exclusive machine so we have enough memory for the panel to finish.
    exclusive=--exclusive
    echo "  Not simulating or skipping. Requesting exclusive node." >> $log
fi

jobid=`sbatch -n 1 $exclusive $SP_DEPENDENCY_ARG submit.sh "$@" | cut -f4 -d' '`
echo "TASK: panel $jobid"

echo "  Job id is $jobid" >> $log
echo >> $log
