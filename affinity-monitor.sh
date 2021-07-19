#!/bin/bash

pid=1
family=1

if [ -n "$1" ]; then 
	pid=$1
fi

family=`pstree -p -h $pid|grep -o \([0123456789]*\)|tr -d '()'`
echo $'***   AFFINITY MONITOR START - ' `date` $'   ***'
echo $'Process tree:'
`echo -e `pstree -p -h $pid``
echo $'\n'
echo $'Process affinity:'
for process in $family
do
   echo `taskset -c -p $process`
done
echo $'***   AFFINITY MONITOR END - ' `date` $'   ***'
