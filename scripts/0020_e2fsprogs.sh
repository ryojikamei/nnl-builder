#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=e2fsprogs
VER=1.42.9
REL=3
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.xz
EXTERNAL_URL_0=$URL_KERNEL/kernel/people/tytso/$NAME/v$VER

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch


#BUILD
CONFIG_ADD=" --disable-nls"

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
