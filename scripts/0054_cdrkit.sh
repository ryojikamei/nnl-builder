#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings


#PARAMS
NAME=cdrkit
VER=1.1.11
REL=1
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME-$VER.*tar* && cd $BUILD_DIR
patch -Np1 -i $SOURCE_DIR/$NAME-$VER-1.patch

#BUILD
export PREFIX=/usr && \
$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
ln -s wodim $INSTALL_DIR/usr/bin/cdrecord
ln -s readom $INSTALL_DIR/usr/bin/readcd
ln -s genisoimage $INSTALL_DIR/usr/bin/mkisofs
ln -s genisoimage $INSTALL_DIR/usr/bin/mkhybrid
ln -s icedax $INSTALL_DIR/usr/bin/cdca2wav
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