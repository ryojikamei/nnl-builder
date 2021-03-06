#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=gettext
VER=0.18.1.1
REL=4
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=$URL_GNU/$NAME


#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
sed -i -e 's/linux-newlib/linux-musl/g;' build-aux/config.sub

#BUILD
# We don't use libintl.so from it
CONFIG_ADD=" --disable-shared"

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
mv $OPKG_WORK_BUILD/$INSTALL_DIR/usr/include/libintl.h \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/include/libintl-libintl.h

# XXX We don't use libintl.so from it
rm -rf $OPKG_WORK_BUILD/$INSTALL_DIR/usr/include
rm -rf $OPKG_WORK_BUILD/$INSTALL_DIR/usr/lib
#

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
