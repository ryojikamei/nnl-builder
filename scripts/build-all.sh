#!/bin/ash

source ~/.nnl-builder/settings
mkdir -p ~/DONE

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

		mv $s ~/DONE
		opkg-cl install $OPKG_WORK_PKGS/*.opk
		mv $OPKG_WORK_PKGS/*.opk ~/DONE/
	else
		echo "NG"
		mv /tmp/$l.log /tmp/NG-$l.log
	fi
done

