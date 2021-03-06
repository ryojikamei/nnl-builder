#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=zlib
VER=1.2.11
REL=1
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
case "$OPKG_BUILD_MODE" in
"native" )
	export CC="gcc"
	SHARED="--sharedlibdir=/lib"
	;;
"target" )
	export CC="$OPKG_TARGET-gcc"
	SHARED="--sharedlibdir=/lib"
	;;
"cross" )
	export CC="$OPKG_TARGET-gcc"
	SHARED="--static"
	;;
esac
CFLAGS="$OPKG_OPTFLAGS" ./configure --prefix=/ --eprefix=/bin \
	--libdir=/usr/lib $SHARED --includedir=/usr/include && \
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
