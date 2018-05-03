#! /bin/sh

. ~/.nnl-builder/settings

if [ "x$1" = "x" ]; then
	echo "need number to open up; 0000 will remove all vacancies."
	exit 1
else
	echo "Reserving $1"
fi

cd $OPKG_WORK_SCRIPTS
tmp=`ls $1_*.sh 2>/dev/null`
cnt=0001
if [ "x$tmp" = "x" ]; then
	if [ $tmp -ne 0000 ]; then
		echo "$1 is vacant, already."
		exit 2
	fi
fi
for s in `ls 0*.sh`; do
	if [ $cnt -eq $1 ]; then
		echo "<`printf '%04d' ${cnt}` is reserved.>"
		cnt=`expr $cnt + 1`
	fi
	b=`echo $s | cut -f2 -d'_'`
	n=`printf '%04d' ${cnt}`_$b
	echo "$s --> $n"
	cnt=`expr $cnt + 1`
	mv $s $n
done
