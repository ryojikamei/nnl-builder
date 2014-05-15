#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=zip
VER=3.0
REL=2
BUILD_DIR=${NAME}30
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=${NAME}30.tar.gz
EXTERNAL_URL_0=$URL_SF/infozip/Zip%203.x%20%28latest%29/$VER

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch


#BUILD
CONFIG_ADD=""

OPKG_OPTFLAGS="$OPKG_OPTFLAGS" \
MAKE="make $OPKG_MAKEFLAGS" \
make generic_gcc -f unix/Makefile &&
make prefix=$OPKG_WORK_BUILD/$INSTALL_DIR/usr install -f unix/Makefile


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
