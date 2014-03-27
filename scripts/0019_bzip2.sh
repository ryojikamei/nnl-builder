#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=bzip2
VER=1.0.6
REL=2
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR


#BUILD
grep -v "^CFLAGS=" Makefile > Makefile.1
grep -v "^PREFIX=" Makefile.1 > Makefile
CFLAGS="$OPKG_OPTFLAGS -D_FILE_OFFSET_BITS=64" make
PREFIX=$OPKG_WORK_BUILD/$INSTALL_DIR/usr make install

#CONFIG_ADD=""

#$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
#if [ $? -ne 0 ]; then
#	echo "ERROR:	building in $NAME-$VER" >&2
#	exit 1
#fi

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
