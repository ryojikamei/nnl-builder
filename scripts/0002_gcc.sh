#!/bin/sh -x

#INIT
source ~/.nnl-builder/settings
if [ "`echo $0 | grep cross`" == $0 ]; then
	if [ -f $OPKG_WORK_CROSS/lib/libc.a ]; then
		CROSS=2
	else
		CROSS=1
	fi
else
	CROSS=0
fi

#PARAMS
NAME=gcc
VER=4.6.4
REL=10
MPFR_VER=3.1.2
GMP_VER=5.1.3
MPC_VER=1.0.2
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR
tar xf $SOURCE_DIR/mpfr-$MPFR_VER.* && mv mpfr-* mpfr
tar xf $SOURCE_DIR/gmp-$GMP_VER.* && mv gmp-* gmp
tar xf $SOURCE_DIR/mpc-$MPC_VER.* && mv mpc-* mpc
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl-2.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl-3.patch

#BUILD
rm -rf $OPKG_WORK_BUILD/$NAME-build
mkdir -v $OPKG_WORK_BUILD/$NAME-build
CONFIG_ADD=" --disable-libmudflap --enable-c99 --enable-long-long"
if [ $CROSS -eq 1 ]; then
	CONFIG_ADD="$CONFIG_ADD --with-sysroot=$OPKG_WORK_CROSS \
	--disable-shared --without-headers --with-newlib \
	--disable-decimal-float --disable-libgomp \
	--disable-libssp --disable-libquadmath \
	--disable-threads --enable-languages=c \
	--with-arch=$OPKG_CTRL_ARCH --host=$OPKG_BUILD"
else if [ $CROSS -eq 2 ]; then
	CONFIG_ADD="$CONFIG_ADD --with-sysroot=$OPKG_WORK_CROSS \
	--disable-shared --disable-libgomp \
	--disable-libssp --disable-libquadmath \
	--enable-languages=c \
	--with-arch=$OPKG_CTRL_ARCH --host=$OPKG_BUILD"
else
	CONFIG_ADD="$CONFIG_ADD --enable-languages=c,c++"
fi
fi


$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi

#PACK
cd $OPKG_WORK_BUILD
rm -fv $INSTALL_DIR/usr/lib/libiberty.a && \
if [ $CROSS -eq 0 ]; then rm -fv $INSTALL_DIR/usr/bin/*-linux-musl-*; fi && \
# --strip-unneeded has problem in perl or python
STRIP_BIN="strip --strip-debug" CROSS=$CROSS \
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
