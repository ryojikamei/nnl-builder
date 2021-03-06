#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=glib
VER=2.32.4
REL=4
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.xz
EXTERNAL_URL_0=http://ftp.gnome.org/pub/gnome/sources/glib/2.32

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch
sed -i -e 's/linux-newlib/linux-musl/g;' config.sub


#BUILD
CONFIG_ADD=" "

LIBFFI_CFLAGS="-I`find /usr/lib -name "libffi-*" -type d`/include " LIBFFI_LIBS="-lffi" \
$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
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
