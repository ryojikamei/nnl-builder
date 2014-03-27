#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=linux
VER=3.2.55
REL=4
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch


#BUILD
make mrproper
cp -a $SOURCE_DIR/$NAME-$VER.config .config
make oldconfig
make $OPKG_MAKEFLAGS ARCH=$OPKG_ARCH all  && \
mkdir -p $OPKG_WORK_BUILD/$INSTALL_DIR/boot && \
make ARCH=$OPKG_ARCH \
	INSTALL_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR/boot \
	INSTALL_MOD_STRIP=1 \
	INSTALL_MOD_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR \
	INSTALL_HDR_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR/usr \
	install modules_install firmware_install headers_install
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi

#PACK
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
