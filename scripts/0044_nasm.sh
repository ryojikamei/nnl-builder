#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=nasm
VER=2.09.10
REL=2
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.bz2
EXTERNAL_URL_0=http://www.nasm.us/pub/nasm/releasebuilds/$VER

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR


#BUILD
CONFIG_ADD=""

INSTALLROOT=$OPKG_WORK_BUILD/$INSTALL_DIR \
$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
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
