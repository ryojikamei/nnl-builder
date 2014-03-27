#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=zlib
VER=1.2.8
REL=4
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR

#BUILD
CC="gcc" CFLAGS="$OPKG_OPTFLAGS" ./configure --prefix=/ --eprefix=/bin \
	--libdir=/usr/lib --sharedlibdir=/lib --includedir=/usr/include
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi
make && make DESTDIR=$OPKG_WORK_BUILD/$INSTALL_DIR install
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi
rm -rf $OPKG_WORK_BUILD/$INSTALL_DIR/share
rmdir $OPKG_WORK_BUILD/$INSTALL_DIR/bin


#PACK
$OPKG_HELPER/packaging.sh $NAME $VER-$REL $SOURCE_DIR $INSTALL_DIR
if [ $? -ne 0 ]; then
	echo "ERROR:	packaging in $NAME-$VER" >&2
	exit 1
fi


#CLEAN
cd  $OPKG_WORK_BUILD
#rm -rf  $BUILD_DIR $INSTALL_DIR $NAME-build


#FINISH
echo "OK:	$NAME-$VER" >&2
exit 0
