#!/bin/ash

source ~/.nnl-builder/settings

if [ "x$OPKG_WORK_BUILD/$4" == "x$OPKG_WORK_BUILD/" ]; then
	echo "Usage: gnu-build.sh [name] [ver] [builddir] [installroot] <opts>"
	exit 1
fi


export CFLAGS="$OPKG_OPTFLAGS"
export CXXFLAGS="$OPKG_OPTFLAGS"
export FFLAGS="$OPKG_OPTFLAGS"
if [ -d $OPKG_WORK_BUILD/$1-build ]; then
	cd $OPKG_WORK_BUILD/$1-build
	../$3/configure \
	--build=$OPKG_BUILD --host=$OPKG_HOST --target=$OPKG_TARGET \
	--prefix=/usr $5 && make $OPKG_MAKEFLAGS
else
	cd $OPKG_WORK_BUILD/$3
	./configure \
	--build=$OPKG_BUILD --host=$OPKG_HOST --target=$OPKG_TARGET \
	--prefix=/usr $5 && make $OPKG_MAKEFLAGS
fi

rm -rf $OPKG_WORK_BUILD/$4
mkdir -pv $OPKG_WORK_BUILD/$4
make DESTDIR=$OPKG_WORK_BUILD/$4 install
