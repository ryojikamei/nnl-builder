#!/bin/ash -x

#INIT
. ~/.nnl-builder/settings

#PARAMS
NAME=perl
VER=5.14.4
REL=3
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.bz2
EXTERNAL_URL_0=http://www.cpan.org/src/5.0/

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|" \
	-e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = /usr/include|" \
	-e "s|LIB\s*= ./zlib-src|LIB        = /usr/lib|" \
	cpan/Compress-Raw-Zlib/config.in


#BUILD
ash Configure -des -Dprefix=/usr \
	-Dvendorprefix=/usr \
	-Dman1dir=/usr/share/man/man1 \
	-Dman3dir=/usr/share/man/man3 \
	-Dpager="less" \
	-Doptimize="$OPKG_OPTFLAGS" \
	-Dcc=gcc \
	-Darchname=$OPKG_TARGET \
	-Duseshrplib && \
make $OPKG_MAKEFLAGS && make DESTDIR=$OPKG_WORK_BUILD/$INSTALL_DIR install
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
