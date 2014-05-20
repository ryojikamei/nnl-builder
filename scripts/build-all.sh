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
		if [ $OPKG_BUILD_MODE == "native" ]; then
			opkg-cl install $OPKG_WORK_PKGS/*.opk
			mv $OPKG_WORK_PKGS/*.opk ~/DONE/
		fi
	else
		echo "NG"
		mv /tmp/$l.log /tmp/NG-$l.log
		if [ "x$1" != "x--continue" ]; then
			exit 1
		fi
	fi
done

if [ $OPKG_BUILD_MODE == "native" ]; then
	echo "Check output in ~/DONE and /tmp. After that move them in ~/DONE to $OPKG_WORK_SCRIPTS or $OPKG_WORK_PKGS."
else
	echo "Check output in ~/DONE and /tmp. After that move them in ~/DONE to $OPKG_WORK_SCRIPTS."
fi
