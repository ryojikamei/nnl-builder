#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings


#PARAMS
NAME=ca-cert
VER=20140422
REL=1
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR && mkdir -p $BUILD_DIR && cd $BUILD_DIR

#http://curl.haxx.se/ca/cacert.pem.bz2
mkdir -p usr/share/curl && \
bzip2 -dc $SOURCE_DIR/cacert.pem.bz2 > usr/share/curl/curl-ca-bundle.crt
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
