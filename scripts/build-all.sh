#!/bin/ash

source ~/.nnl-builder/settings

case "$OPKG_BUILD_MODE" in
"native" )
	TYPE=""
	;;
"target" )
	TYPE="-target"
	;;
"cross" )
	TYPE="-cross"
	;;
*)
	echo "Error: Invalid settings!"
	exit 1
esac


for s in `ls -1 $OPKG_WORK_SCRIPTS/0*${TYPE}.sh`;do
	l=`basename $s .sh`
	echo -n "${l}: "
	$s > /tmp/$l.log 2>&1
	if [ $? -eq 0 ]; then
		echo "OK"
		mv /tmp/$l.log /tmp/OK-$l.log
	else
		echo "NG"
		mv /tmp/$l.log /tmp/NG-$l.log
	fi
done
