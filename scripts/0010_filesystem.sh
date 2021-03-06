#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=filesystem
VER=1.0
REL=4
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $INSTALL_DIR && mkdir -p $INSTALL_DIR


#BUILD
cd $OPKG_WORK_BUILD/$INSTALL_DIR
mkdir bin boot dev etc home
mkdir -p lib/firmware lib/modules
mkdir -p mnt media opt proc sbin srv sys
mkdir var && cd var && mkdir cache lib local lock log opt run spool && cd ..
install -d -m 0750 ./root
install -d -m 1777 ./tmp
mkdir -p usr/local && cd usr && mkdir bin include lib sbin share src \
&& cd local && mkdir bin include lib sbin share src && cd ../..

#PACK
cd $OPKG_WORK_BUILD
if [ "$OPKG_BUILD_MODE" = "native" ]; then
	cp -av $SOURCE_DIR/CONTROL $INSTALL_DIR/
	DEPENDS=`grep ^Depends: $SOURCE_DIR/CONTROL/control`
	cat > $SOURCE_DIR/CONTROL/control <<EOF
Package:	$NAME
Version:	$VER-$REL
Architecture:	noarch
$DEPENDS
EOF
	opkg-build -C -O $OPKG_WORK_BUILD/$INSTALL_DIR $OPKG_WORK_PKGS
	ret=$?
else
	cd $INSTALL_DIR
	tar cf - . | ( cd $OPKG_WORK_TARGET; tar xf -)
	ret=$?
fi
if [ $ret -ne 0 ]; then
	echo "ERROR:	packaging in $NAME-$VER" >&2
	exit 1
fi


#CLEAN
cd  $OPKG_WORK_BUILD
rm -rf  $BUILD_DIR $INSTALL_DIR $NAME-build


#FINISH
echo "OK:	$NAME-$VER" >&2
exit 0
