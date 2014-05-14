#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=bzip2
VER=1.0.6
REL=3
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=http://www.bzip.org/$VER

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR


#BUILD
grep -v "^CFLAGS=" Makefile > Makefile.1
grep -v "^PREFIX=" Makefile.1 > Makefile
CFLAGS="$OPKG_OPTFLAGS -D_FILE_OFFSET_BITS=64" make $OPKG_MAKEFLAGS && \
PREFIX=$OPKG_WORK_BUILD/$INSTALL_DIR/usr make install
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
