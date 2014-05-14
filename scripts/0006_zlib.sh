#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=zlib
VER=1.2.8
REL=5
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=http://zlib.net

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR


#BUILD
if [ $OPKG_BUILD_MODE == "target" ]; then
	export CC="$OPKG_TARGET-gcc"
else
	export CC="gcc"
fi
CFLAGS="$OPKG_OPTFLAGS" ./configure --prefix=/ --eprefix=/bin \
	--libdir=/usr/lib --sharedlibdir=/lib --includedir=/usr/include && \
make $OPKG_MAKEFLAGS && make DESTDIR=$OPKG_WORK_BUILD/$INSTALL_DIR install
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
rm -rf $INSTALL_DIR/share && rmdir $INSTALL_DIR/bin && \
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
