#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings


#PARAMS
NAME=binutils
VER=2.22
REL=9
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.bz2
EXTERNAL_URL_0=$FTP_GNU/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch
if [ $OPKG_BUILD_MODE == "target" ]; then
	patch -Np1 -i $SOURCE_DIR/$NAME-$VER-2.patch
fi


#BUILD
if [ `which makeinfo` -ne 0 ]; then
	echo "Install texinfo package beforehand!"
	exit 1
fi

rm -rfv $OPKG_WORK_BUILD/$NAME-build
mkdir -v $OPKG_WORK_BUILD/$NAME-build
if [ $OPKG_BUILD_MODE == "cross" ]; then
	CONFIG_ADD=" --with-sysroot=$OPKG_WORK_CROSS --with-lib-path=$OPKG_WORK_CROSS/usr/lib:$OPKG_WORK_CROSS/lib:$OPKG_WORK_TARGET/usr/lib:$OPKG_WORK_TARGET/lib --disable-werror"
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
