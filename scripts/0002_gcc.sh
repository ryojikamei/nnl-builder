#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=gcc
VER=4.6.4
REL=11
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.bz2
EXTERNAL_URL_0=$URL_GNU/$NAME/$NAME-$VER
EXTERNAL_SRC_1=mpfr-3.1.2.tar.xz
EXTERNAL_URL_1=$URL_GNU/mpfr
EXTERNAL_SRC_2=gmp-5.1.3.tar.xz
EXTERNAL_URL_2=$URL_GNU/gmp
EXTERNAL_SRC_3=mpc-1.0.2.tar.gz
EXTERNAL_URL_3=$URL_GNU/mpc

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_1 && mv mpfr-* mpfr
tar xf $SOURCE_DIR/$EXTERNAL_SRC_2 && mv gmp-* gmp
tar xf $SOURCE_DIR/$EXTERNAL_SRC_3 && mv mpc-* mpc
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl-2.patch
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl-3.patch
if [ $OPKG_BUILD_MODE == "target" ]; then
	patch -Np1 -i $SOURCE_DIR/$NAME-$VER-musl-4.patch
fi

#BUILD
rm -rf $OPKG_WORK_BUILD/$NAME-build
mkdir -v $OPKG_WORK_BUILD/$NAME-build
CONFIG_ADD=" --disable-libmudflap --enable-c99 --enable-long-long"
case "$OPKG_BUILD_MODE" in
"native" )
	CONFIG_ADD="$CONFIG_ADD --enable-languages=c,c++ \
	--enable-sjlj-exceptions"
	;;
"target")
	CONFIG_ADD="$CONFIG_ADD --enable-languages=c,c++ \
	--enable-sjlj-exceptions"
	;;
"cross")
	CONFIG_ADD="$CONFIG_ADD --with-sysroot=$OPKG_WORK_CROSS \
	--enable-languages=c,c++ --enable-sjlj-exceptions \
	--with-arch=$OPKG_CTRL_ARCH"
	if [ ! -f $OPKG_WORK_CROSS/lib/libc.a ]; then
		CONFIG_ADD="$CONFIG_ADD --without-headers \
		--with-newlib --disable-decimal-float \
		--disable-threads --disable-shared \
		--disable-libssp --disable-libquadmath \
		--disable-libgomp --disable-libstdc++-v3"
	fi
	;;
esac

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi

#PACK
cd $OPKG_WORK_BUILD
rm -fv $INSTALL_DIR/usr/lib/libiberty.a && \
if [ $OPKG_BUILD_MODE == "native" ]; then rm -fv $INSTALL_DIR/usr/bin/*-linux-musl-*; fi && \
if [ $OPKG_BUILD_MODE == "native" ]; then ln -s gcc $INSTALL_DIR/usr/bin/cc; fi && \
# --strip-unneeded has problem in perl or python
STRIP_BIN="strip --strip-debug" \
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
