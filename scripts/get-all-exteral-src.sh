#!/bin/ash

PROG_DIR=$PWD/`dirname $0`

source ~/.nnl-builder/settings

for s in `ls $PROG_DIR/0*.sh`; do
	src=""
	src=`grep ^EXTERNAL_SRC_ $s`
	if [ "x$src" == "x" ]; then
		continue
	else
		NAME=`grep ^NAME= $s | cut -f2 -d=`
		VER=`grep ^VER= $s | cut -f2 -d=`

		for u in $src; do
			num=`echo $u | cut -f3 -d_ | cut -f1 -d=`
			SRC=`eval echo $u | cut -f2 -d=`
			DIR=$OPKG_WORK_SOURCES/$NAME
			FILE=$DIR/$SRC

			if [ -f $FILE ]; then
				echo "SKIP: $SRC is found."
			else
				eval URL=`grep ^EXTERNAL_URL_$num $s | cut -f2 -d=`
				echo -n "GET: $URL/$SRC... "
				mkdir -p $DIR && wget -q -P $DIR -c $URL/$SRC
				if [ $? -eq 0 ]; then
					echo "done"
				else
					echo "error!"
				fi
			fi
		done
	fi
done
