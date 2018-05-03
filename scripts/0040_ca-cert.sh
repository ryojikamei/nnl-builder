#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings


#PARAMS
NAME=ca-cert
VER=20140422
REL=2
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=cacert.pem.bz2
EXTERNAL_URL_0=http://curl.haxx.se/ca

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR && mkdir -p $BUILD_DIR && cd $BUILD_DIR

#http://curl.haxx.se/ca/cacert.pem.bz2
mkdir -p usr/share/curl && \
bzip2 -dc $SOURCE_DIR/$EXTERNAL_SRC_0 > usr/share/curl/curl-ca-bundle.crt
if [ $? -ne 0 ]; then
        echo "ERROR:    building in $NAME-$VER" >&2
        exit 1
fi


#BUILD
cd $OPKG_WORK_BUILD
rm -rf $INSTALL_DIR                                                           
mkdir $INSTALL_DIR                                                            
mv $BUILD_DIR/* $INSTALL_DIR


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
