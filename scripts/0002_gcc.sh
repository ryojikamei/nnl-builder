#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=gcc
VER=4.6.4
REL=9
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
CONFIG_ADD=" --disable-libmudflap --enable-languages=c,c++ \
	--enable-c99 --enable-long-long"

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi

#PACK
cd $OPKG_WORK_BUILD
rm -fv $INSTALL_DIR/usr/lib/libiberty.a && \
rm -fv $INSTALL_DIR/usr/bin/*-linux-musl-* && \
# --strip-unneeded has problem in perl or python
STRIP_BIN="strip --strip-debug" $OPKG_HELPER/packaging.sh $NAME $VER-$REL $SOURCE_DIR $INSTALL_DIR
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
