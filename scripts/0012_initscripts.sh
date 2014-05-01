#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=initscripts
VER=1.0
REL=6
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar*
tar xf $SOURCE_DIR/bootscripts-embedded-HEAD.tar.gz
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch

#BUILD
rm -rf $INSTALL_DIR
mkdir $INSTALL_DIR
mv $BUILD_DIR/* $INSTALL_DIR && \
make -C $OPKG_WORK_BUILD/bootscripts-embedded \
	DESTDIR=$OPKG_WORK_BUILD/$INSTALL_DIR install-bootscripts
if [ $? -ne 0 ]; then
	echo "ERROR:	packaging in $NAME-$VER" >&2
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
