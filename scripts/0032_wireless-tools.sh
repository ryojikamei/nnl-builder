#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=wireless_tools
VER=29
REL=3
BUILD_DIR=$NAME.$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME.$VER.tar.gz
EXTERNAL_URL_0=http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
sed -i -e "s/-Os/$OPKG_OPTFLAGS/g;" Makefile
sed -i -e "s/CC = gcc//g;" Makefile
sed -i -e "s/AR = ar//g;" Makefile
sed -i -e "s/RANLIB = ranlib//g;" Makefile


#BUILD
make $OPKG_MAKEFLAGS && make PREFIX=$OPKG_WORK_BUILD/$INSTALL_DIR/usr install
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
$OPKG_HELPER/packaging.sh $NAME $VER-$REL $SOURCE_DIR $INSTALL_DIR
if [ $? -ne 0 ]; then
	echo "ERROR:	packaging in $NAME-$VER" >&2
	exit 1
fi


#CLEAN
cd  $OPKG_WORK_BUILD
rm -rf  $BUILD_DIR $INSTALL_DIR $NAME-build


#FINISH
echo "OK:	$NAME-$VER" >&2
exit 0
