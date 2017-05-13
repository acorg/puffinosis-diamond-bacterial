# IMPORTANT: All paths in this file are relative to the scripts in
# 00-start, etc. This file is sourced by those scripts.

logDir=../logs
doneFile=../slurm-pipeline.done
runningFile=../slurm-pipeline.running
errorFile=../slurm-pipeline.error
statsDir=../../../stats
dataDir=../../../fastq
logFile=$logDir/main.log

test -z "$SP_SIMULATE" && export SP_SIMULATE=0
test -z "$SP_SKIP" && export SP_SKIP=0
test -z "$SP_FORCE" && export SP_FORCE=0

function sampleName()
{
    # The sample name is the basename of our parent directory. This will be
    # one of 1, 2, 3, 4, 5, 6.
    echo $(basename $(dirname $(/bin/pwd)))
}

function tasks()
{
    echo $(ls $dataDir/[0-3][0-9]-$1-*.tr.fastq.gz | cut -f5 -d/ | cut -f1 -d.)
}

echo ${SP_SIMULATE:=0} ${SP_SKIP:=0} ${SP_FORCE:=0} >/dev/null
