#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=openssl
VER=1.0.1h
REL=1
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=http://www.openssl.org/source


#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch


#BUILD
CONFIG_ADD=""

./config --prefix=/usr --openssldir=/usr/lib/openssl zlib shared no-sse2 \
&& make && \
sed -i -e 's|./demoCA|/usr/lib/openssl|g;' apps/openssl.cnf && \
make INSTALL_PREFIX=$OPKG_WORK_BUILD/$INSTALL_DIR install
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
