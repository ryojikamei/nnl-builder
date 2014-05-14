#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=linux
VER=3.2.58
REL=2
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.xz
EXTERNAL_URL_0=ftp://ftp.kernel.org/pub/linux/kernel/v3.x


#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch
if [ $OPKG_BUILD_MODE == "native" ]; then
	patch -Np1 -i $SOURCE_DIR/$NAME-$VER-2.patch
fi


#BUILD
if [ $OPKG_BUILD_MODE == "cross" ]; then
	make mrproper
	if [ $? -ne 0 ]; then
		echo "ERROR:	building in $NAME-$VER" >&2
		exit 1
	fi
	MAKE_TARGET="headers_install"
else
	#make mrproper && \
	#make ARCH=$OPKG_ARCH allyesconfig && \
	make mrproper && \
	cp -a $SOURCE_DIR/$NAME-$VER.config .config && \
	make ARCH=$OPKG_ARCH oldconfig && \
	make $OPKG_MAKEFLAGS ARCH=$OPKG_ARCH all  && \
	mkdir -p $OPKG_WORK_BUILD/$INSTALL_DIR/boot
	if [ $? -ne 0 ]; then
		echo "ERROR:	building in $NAME-$VER" >&2
		exit 1
	fi
	MAKE_TARGET="install modules_install firmware_install headers_install"
fi
make ARCH=$OPKG_ARCH \
	INSTALL_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR/boot \
	INSTALL_MOD_STRIP=1 \
	INSTALL_MOD_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR \
	INSTALL_HDR_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR/usr \
	$MAKE_TARGET
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
