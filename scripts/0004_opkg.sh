#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=opkg
VER=0.2.2
REL=1
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=http://downloads.yoctoproject.org/releases/opkg

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
sed -i -e 's/linux-newlib/linux-musl/g;' conf/config.sub

#BUILD
CONFIG_ADD=" --disable-curl --disable-gpg --enable-shared"

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi

#PACK
cd $OPKG_WORK_BUILD
mkdir -p $OPKG_WORK_BUILD/$INSTALL_DIR/usr/lib/opkg/info && \
mkdir -p $OPKG_WORK_BUILD/$INSTALL_DIR/usr/lib/opkg/lists && \
rm -f $OPKG_WORK_BUILD/$INSTALL_DIR/usr/bin/update-alternatives && \
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
