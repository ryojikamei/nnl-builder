#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=pkg-config
VER=0.26
REL=3
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=http://pkgconfig.freedesktop.org/releases

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
sed -i -e 's/linux-newlib/linux-musl/g;' config.sub

#BUILD
CONFIG_ADD=" "

GLIB_CFLAGS="-I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include" \
GLIB_LIBS="-L/usr/lib -lglib-2.0" \
$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
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
