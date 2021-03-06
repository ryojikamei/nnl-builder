#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings


#PARAMS
NAME=musl
VER=1.0.3
REL=1
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=http://www.musl-libc.org/releases

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
# This reverse patching may be required in a certain environment
##patch -Np1 -R -i $SOURCE_DIR/$NAME-$VER-gcc4.6.patch


#BUILD
CONFIG_ADD=" --libdir=/lib"
if [ "$OPKG_BUILD_MODE" != "native" ]; then export CROSS_COMPILE="${OPKG_TARGET}-"; fi && \
$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
mkdir -p $INSTALL_DIR/bin && \
ln -s ../lib/ld-musl-i386.so.1 $INSTALL_DIR/bin/ldd && \
mkdir -p $INSTALL_DIR/usr/lib && \
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
