#!/bin/ash -x

# This is the kernel to build your own kernel

#INIT
. ~/.nnl-builder/settings

#PARAMS
P_NAME=linux-build
NAME=linux
VER=3.2.60
REL=1
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$P_NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.xz
EXTERNAL_URL_0=$URL_KERNEL/kernel/v3.x


#PREP
mkdir -p $OPKG_WORK_BUILD && cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch
if [ "$OPKG_BUILD_MODE" = "native" ]; then
	patch -Np1 -i $SOURCE_DIR/$NAME-$VER-2.patch
fi


#BUILD
if [ "$OPKG_BUILD_MODE" = "cross" ]; then
	make mrproper
	if [ $? -ne 0 ]; then
		echo "ERROR:	building in $P_NAME-$VER" >&2
		exit 1
	fi
	MAKE_TARGET="headers_install"
else
	make mrproper && \
	make ARCH=$OPKG_ARCH allmodconfig && \
	sed -i -e "s/CONFIG_LOCALVERSION=\"\"/CONFIG_LOCALVERSION=\"-${REL}allmod\"/g;" .config && \
	make $OPKG_MAKEFLAGS ARCH=$OPKG_ARCH all  && \
	mkdir -p $OPKG_WORK_BUILD/$INSTALL_DIR/boot
	if [ $? -ne 0 ]; then
		echo "ERROR:	building in $P_NAME-$VER" >&2
		exit 1
	fi
	MAKE_TARGET="install modules_install"
fi
#prevent from running /sbin/installkernel in host
for i in arch/*/boot/install.sh; do
	grep -v INSTALLKERNEL $i > $i.tmp
	mv $i.tmp $i
done
make ARCH=$OPKG_ARCH \
	INSTALL_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR/boot \
	INSTALL_MOD_STRIP=1 \
	INSTALL_MOD_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR \
	INSTALL_HDR_PATH=$OPKG_WORK_BUILD/$INSTALL_DIR/usr \
	$MAKE_TARGET
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $P_NAME-$VER" >&2
	exit 1
fi

#PACK
cd $OPKG_WORK_BUILD
##depmod -b $OPKG_WORK_BUILD/$INSTALL_DIR $VER-${REL}allmod
mv $OPKG_WORK_BUILD/$INSTALL_DIR/boot/vmlinuz \
	$OPKG_WORK_BUILD/$INSTALL_DIR/boot/vmlinuz-$VER-${REL}allmod
mv $OPKG_WORK_BUILD/$INSTALL_DIR/boot/System.map \
	$OPKG_WORK_BUILD/$INSTALL_DIR/boot/System.map-$VER-${REL}allmod
rm -rf $OPKG_WORK_BUILD/$INSTALL_DIR/lib/firmware
$OPKG_HELPER/packaging.sh $P_NAME $VER-$REL $SOURCE_DIR $INSTALL_DIR
if [ $? -ne 0 ]; then
	echo "ERROR:	packaging in $P_NAME-$VER" >&2
	exit 1
fi


#CLEAN
cd  $OPKG_WORK_BUILD
rm -rf  $BUILD_DIR $INSTALL_DIR $NAME-build


#FINISH
echo "OK:	$P_NAME-$VER" >&2
exit 0
