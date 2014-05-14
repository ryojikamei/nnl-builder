#!/bin/ash -x

#INIT
source ~/.nnl-builder/settings

#PARAMS
NAME=ncurses
VER=5.9
REL=5
BUILD_DIR=$NAME-$VER
INSTALL_DIR=$NAME-root
SOURCE_DIR=$OPKG_WORK_SOURCES/$NAME

EXTERNAL_SRC_0=$NAME-$VER.tar.gz
EXTERNAL_URL_0=$FTP_GNU/$NAME

#PREP
cd $OPKG_WORK_BUILD
rm -rf $BUILD_DIR
tar xf $SOURCE_DIR/$EXTERNAL_SRC_0 && cd $BUILD_DIR
sed -i -e 's/linux-newlib/linux-musl/g;' config.sub


#BUILD
CONFIG_ADD=" --libdir=/lib --with-shared --enable-widec"

$OPKG_HELPER/gnu-build.sh $NAME $VER $BUILD_DIR $INSTALL_DIR "$CONFIG_ADD"
if [ $? -ne 0 ]; then
	echo "ERROR:	building in $NAME-$VER" >&2
	exit 1
fi


#PACK
cd $OPKG_WORK_BUILD
for w in `ls -1 $OPKG_WORK_BUILD/$INSTALL_DIR/lib/*w.so`; do
	wl=`basename $w`
	bn=`basename $w w.so`
	ln -s $wl $OPKG_WORK_BUILD/$INSTALL_DIR/lib/$bn.so
done
for w in `ls -1 $OPKG_WORK_BUILD/$INSTALL_DIR/lib/*w.a`; do
	wl=`basename $w`
	bn=`basename $w w.a`
	ln -s $wl $OPKG_WORK_BUILD/$INSTALL_DIR/lib/$bn.a
done
ln -s ncursesw5-config \
	$OPKG_WORK_BUILD/$INSTALL_DIR/usr/bin/ncurses5-config
for b in `ls -1 $OPKG_WORK_BUILD/$INSTALL_DIR/usr/bin/*-linux-musl-*`; do
	nn=`basename $b | cut -f4- -d-`
	mv $b $OPKG_WORK_BUILD/$INSTALL_DIR/usr/bin/$nn
done

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
