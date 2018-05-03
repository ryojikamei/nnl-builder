#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=util-linux
VER=2.20.1
REL=3
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.xz
EXTERNAL_URL_0=$URL_KERNEL/utils/util-linux/v2.20/

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl.patch
sed -i -e 's/linux-newlib/linux-musl/g;' config/config.sub


#BUILD
CONFIG_ADD=""

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
mkdir -p $OPKG_WORK_BUILD/$INSTALL_DIR/usr/sbin \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/bin && \
mv $OPKG_WORK_BUILD/$INSTALL_DIR/sbin/* \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/sbin && \
mv $OPKG_WORK_BUILD/$INSTALL_DIR/bin/* \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/bin && \
rmdir $OPKG_WORK_BUILD/$INSTALL_DIR/sbin $OPKG_WORK_BUILD/$INSTALL_DIR/bin && \
rm -f $OPKG_WORK_BUILD/$INSTALL_DIR/usr/bin/uuidgen  \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/sbin/uuidd  \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/sbin/findfs  \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/sbin/fsck  \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/sbin/blkid && \
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
