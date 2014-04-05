#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings
if [ "`echo $0 | grep cross`" == $0 ]; then
	CROSS=1
else
	CROSS=0
fi

#PARAMS
NAME=musl
VER=1.0.0
REL=3
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR
patch -Np1 -R -i $SOURCE_DIR/$NAME-$VER-gcc4.6.patch


#BUILD
CONFIG_ADD=" --libdir=/lib"
if [ $CROSS ]; then
	CONFIG_ADD="$CONFIG_ADD --host=$OPKG_BUILD"
fi

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi

#PACK
cd $OPKG_WORK_BUILD
mkdir -p $INSTALL_DIR/bin && \
ln -s ../lib/ld-musl-i386.so.1 $INSTALL_DIR/bin/ldd && \
mkdir -p $INSTALL_DIR/usr/lib && \
CROSS=$CROSS $OPKG_HELPER/packaging.sh $NAME $VER-$REL $SOURCE_DIR $INSTALL_DIR
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
