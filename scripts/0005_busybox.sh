#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=busybox
VER=1.22.1
REL=5
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-ash.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-date.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-iplink.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-nc.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch
sed -i -e 's/NAME_MAX/255/g;' coreutils/split.c


#BUILD
if [ $OPKG_BUILD_MODE != "native" ]; then
	export CROSS_COMPILE=${OPKG_TARGET}-
fi
make defconfig
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi
sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
sed -i 's/# CONFIG_INSTALL_NO_USR is not set/CONFIG_INSTALL_NO_USR=y/' .config
make $OPKG_MAKEFLAGS && \
make CONFIG_PREFIX=$OPKG_WORK_BUILD/$INSTALL_DIR install && \
cp -a examples/depmod.pl $OPKG_WORK_BUILD/$INSTALL_DIR/sbin/
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
