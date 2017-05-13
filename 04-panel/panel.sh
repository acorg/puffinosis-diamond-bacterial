#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

# The log file is the top-level log file, seeing as this step is a
# 'collect' step that is only run once.
log=$logFile
out=summary-virus

echo "04-panel started at `date`" >> $log

sample=$(sampleName)

# Find the sequence files that correspond to this sample.
tasks=$(tasks $sample)

if [ -z "$tasks" ]
then
    echo "  No FASTQ file matches in $dataDir for sample '$sample'!" >> $log
    exit 1
fi

json=
fastq=
for task in $tasks
do
    echo "  Task (i.e., sequencing run) $task" >> $log
    json="$json ../03-diamond/$task.json.bz2"
    fastq="$fastq ../../../diamond-viral/$sample/02-map/$task-unmapped.fastq.gz"
done

dbDir=$HOME/scratch/root/share/ncbi/bacterial-refseq/20170421
sqliteDb=$dbDir/bacteria.nonredundant_protein.db

if [ ! -d $dbDir ]
then
    echo "  Database FASTA directory '$dbDir' does not exist!" >> $log
    exit 1
fi

if [ ! -f $sqliteDb ]
then
    echo "  DIAMOND FASTA sqlite database file '$sqliteDb' does not exist!" >> $log
    exit 1
fi

function skip()
{
    # We're being skipped. Make an empty output file, if one doesn't
    # already exist. There's nothing much else we can do and there's no
    # later steps to worry about.
    [ -f $out ] || touch $out
}

function panel()
{
    echo "  noninteractive-alignment-panel.py started at `date`" >> $log
    noninteractive-alignment-panel.py \
      --json $json \
      --fastq $fastq \
      --matcher diamond \
      --outputDir out \
      --withScoreBetterThan 60 \
      --maxTitles 100 \
      --minMatchingReads 10 \
      --scoreCutoff 50 \
      --minCoverage 0.1 \
      --negativeTitleRegex phage \
      --diamondSqliteDatabaseFilename $sqliteDb \
      --diamondDatabaseFastaDirectory $dbDir > summary-proteins
    echo "  noninteractive-alignment-panel.py stopped at `date`" >> $log

    echo "  proteins-to-pathogens.py started at `date`" >> $log
    echo summary-proteins | proteins-to-pathogens.py --pathogenType bacterial > summary-bacteria
    echo "  proteins-to-pathogens.py stopped at `date`" >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Panel is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            panel
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Making panel." >> $log
        panel
    fi
fi

echo "04-panel stopped at `date`" >> $log
echo >> $log
