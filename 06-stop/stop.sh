#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

log=$logFile

echo "SLURM pipeline finished at `date`" >> $log

touch $doneFile
rm -f $runningFile
