#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings
if [ "`echo $0 | grep cross`" == $0 ]; then
	CROSS=1
else
	CROSS=0
fi


#PARAMS
NAME=binutils
VER=2.22
REL=8
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch


#BUILD
rm -rfv $OPKG_WORK_BUILD/$NAME-build
mkdir -v $OPKG_WORK_BUILD/$NAME-build
if [ $CROSS ]; then
	CONFIG_ADD="--host=$OPKG_BUILD --with-sysroot=$OPKG_WORK_CROSS"
else
	CONFIG_ADD=""
fi

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
rm -rf $INSTALL_DIR/usr/*-linux-musl
CROSS=$CROSS $OPKG_HELPER/packaging.sh $NAME $VER-$REL \
$SOURCE_DIR $INSTALL_DIR
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
