#!/bin/bash

pid=1
mask=0
family=1

if [ -n "$1" ]; then 
	pid=$1
fi

if [ -n "$2" ]; then 
	mask=$2
fi

family=`pstree -p -h $pid|grep -o \([0123456789]*\)|tr -d '()'`
echo $'***   AFFINITY SET START - ' `date` $'   ***'
echo $'Process tree:'
`echo -e `pstree -p -h $pid``
echo $'\n'
echo $'Process affinity before:'
for process in $family
do
   echo `taskset -c -p $process`
done

echo $'\n'
echo $'Setting new affinity ...'
for process in $family
do
   taskset -c -p $mask $process > /dev/null
done


echo $'\n'
echo $'Process affinity after:'
for process in $family
do
   echo `taskset -c -p $process`
done

echo $'***   AFFINITY SET END - ' `date` $'   ***'
