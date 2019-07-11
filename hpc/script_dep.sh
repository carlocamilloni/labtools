#!/bin/bash

Nj=3 		# total number of jobs, inculding the first one
lastID=$1	# if the first job depends on a job already running, the ID of this job;
		# otherwise nothing

if [ ! $lastID ]; then 
	jtmp=`sbatch job_restart.sh`
	jid=`echo $jtmp | awk '{print $NF}'`
	echo -e "Running Job-ID $jid\n"
else 
	jtmp=`sbatch --dependency=afterok:$lastID job_restart.sh`
	jid=`echo $jtmp | awk '{print $NF}'`
	echo -e "Running Job-ID $jid after Job-ID $lastID\n"
fi

for ((i=1;i<Nj;i++));  do
	jtmp=$(sbatch --dependency=afterok:$jid job_restart.sh)
	jidOLD=$jid
	jid=`echo $jtmp | awk '{print $NF}'`
        echo -e "Running Job-ID $jid after Job-ID $jidOLD\n"
done
