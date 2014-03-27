#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=wireless_tools
VER=29
REL=2
BUILD_DIR=$NAME.$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$NAME.$VER.*tar* && cd $BUILD_DIR
sed -i -e "s/-Os/$OPKG_OPTFLAGS/g;" Makefile

#BUILD
make $OPKG_MAKEFLAGS && make PREFIX=$OPKG_WORK_BUILD/$INSTALL_DIR/usr install
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi

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
