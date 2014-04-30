#!/bin/ash

# Hidden optional values
# - STRIP_SHLIB: strip command options for shared libraries
# - STRIP_BIN: strip command options for non shared libraries
# - ARCH: architecture value. "opkg-cl print-architecture" will show

source ~/.nnl-builder/settings

if [ "x$4" == "x" ]; then
        echo "Usage: packaging.sh [name] [ver-rel] [sourcedir] [installeddir] <opts>"
        exit 1
fi

TARGET_DIR=$OPKG_WORK_BUILD/$4

# REMOVE DOCS, use documents in internet.
rm -rf $TARGET_DIR/usr/share/info
rm -rf $TARGET_DIR/usr/info
rm -rf $TARGET_DIR/usr/share/man
rm -rf $TARGET_DIR/usr/man
rmdir $TARGET_DIR/usr/share 2>/dev/null
rm -f $TARGET_DIR/usr/lib/charset.alias 
rm -f $TARGET_DIR/usr/share/locale/locale.alias 


case "$OPKG_BUILD_MODE" in
"cross" )
	echo -n "Installing into cross-tools... "
	mkdir -p $OPKG_WORK_CROSS
	cd $TARGET_DIR
	tar cf - . | ( cd $OPKG_WORK_CROSS; tar xf -)
	ret=$?
	echo "done."
	exit $ret
	;;
"target" )
	echo -n "Installing into target-tree... "
	mkdir -p $OPKG_WORK_TARGET
	cd $TARGET_DIR
	tar cf - . | ( cd $OPKG_WORK_TARGET; tar xf -)
	ret=$?
	echo "done."
	exit $ret
	;;
"native" )
	echo "Packaging..."
	;;
* )
	echo "MODE is not set or invalid."
	exit 1
	;;
esac


echo "########################################"
# Name:
P_NAME=`echo $1 | tr [A-Z] [a-z] | tr _ -`
echo "Package:	$P_NAME"

# Version:
P_VER=$2
echo "Version:	$P_VER"

# Architecture: set P_ARCH to overwrite for "noarch"
if [ x"$P_ARCH" == "x" ]; then
	P_ARCH=$OPKG_CTRL_ARCH
fi
echo "Architecture:	$P_ARCH"

# Depends:
echo "...Find dependencies..."
# Library dependencies
TARGET_LIBS=`find $TARGET_DIR -type f | xargs file | grep " dynamically linked" | \
	cut -f1 -d:`
if [ "x$TARGET_LIBS" != "x" ]; then
	rm -f $TARGET_DIR/auto-depends.libs
	rm -f $TARGET_DIR/auto-depends
	for l in $TARGET_LIBS; do
		ldd $l | cut -f3 -d' ' >> $TARGET_DIR/auto-depends.libs
	done
	# "^/" removes followings from the list;
	# - "not": The package hasn't installed yet
	# - "ldd"
	for l in `sort -b -u $TARGET_DIR/auto-depends.libs | grep ^/`; do
		DEPPKG=`opkg-cl search $l | cut -f1 -d' '`
		#FOUND=""
		if [ "x$DEPPKG" == "x" ]; then
			# eliminate self-contained libs
			n=`basename $l`
			FOUND=`find $TARGET_DIR -name $n`
			if [ "x$FOUND" == "x" ]; then
				echo "WARNING: dependency file $l is not owned by any packages!"
			fi
		else
			# eliminate itself
			if [ $DEPPKG != $P_NAME ]; then
				echo $DEPPKG >> $TARGET_DIR/auto-depends
			fi
		fi
	done
fi

rm -rf $TARGET/CONTROL
mkdir -p $TARGET_DIR/CONTROL
if [ -d $3/CONTROL ]; then
	cp -a $3/CONTROL/* $TARGET_DIR/CONTROL
	rm -f $TARGET_DIR/depends.in
	for p in `grep ^Depends: $TARGET_DIR/CONTROL/control | cut -f2- -d: | tr , ' '`; do
		echo $p >> $TARGET_DIR/depends.in
	done
fi
# marge and remove duplicates
cat $TARGET_DIR/auto-depends $TARGET_DIR/depends.in 2>/dev/null | sort -u > $TARGET_DIR/depends 2>/dev/null

echo -n "Depends:	"
P_DEPS=""
for p in `cat $TARGET_DIR/depends`; do
	if [ "x$P_DEPS" == "x" ]; then
		P_DEPS=$p
		echo -n $p
	else
		P_DEPS="$P_DEPS,$p"
		echo -n ",$p"
	fi
done
echo ""
echo "########################################"
rm -f $TARGET_DIR/auto-depends* $TARGET_DIR/depends*
	
cat > $TARGET_DIR/CONTROL/control <<EOF
Package:	$P_NAME
Version:	$P_VER
Architecture:	$P_ARCH
Depends:	$P_DEPS
EOF

# STRIP
if [ "x$STRIP_SHLIB" == "x" ]; then
	STRIP_SHLIB="strip --strip-debug"
fi
if [ "x$STRIP_BIN" == "x" ]; then
	STRIP_BIN="strip --strip-unneeded"
fi
find $TARGET_DIR -type f | xargs file | grep " not stripped" | \
	grep " shared object" | cut -f1 -d: | xargs $STRIP_SHLIB \
	>/dev/null 2>&1
find $TARGET_DIR -type f | xargs file | grep " not stripped" | \
	grep -v " shared object" | cut -f1 -d: | xargs $STRIP_BIN \
	>/dev/null 2>&1

opkg-build -C -O $TARGET_DIR $5 $OPKG_WORK_PKGS

