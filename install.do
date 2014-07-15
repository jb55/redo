exec >&2
redo-ifchange _all

: ${INSTALL:=install}
: ${DESTDIR:=}
: ${PREFIX:=/usr}
: ${MANDIR:=$PREFIX/share/man}
: ${DOCDIR:=$PREFIX/share/doc/redo}
: ${BINDIR:=$PREFIX/bin}
: ${LIBDIR:=$PREFIX/lib/redo}

echo "Installing to: $DESTDIR$PREFIX"

# make dirs
$INSTALL -d $DESTDIR$DOCDIR $DESTDIR$BINDIR $LIBEXECDIR $DESTDIR$LIBDIR $DESTDIR$LIBDIR/version $DESTDIR$LIBDIR/bin
test -e Documentation/redo.1 && $INSTALL -d $DESTDIR$MANDIR/man1

# docs
for d in Documentation/*.1; do
	[ "$d" = "Documentation/*.1" ] && continue
	$INSTALL -m 0644 $d $DESTDIR$MANDIR/man1
done
$INSTALL -m 0644 README.md $DESTDIR$DOCDIR

# .py files (precompiled to .pyc files for speed)
for d in *.py version/*.py; do
	fix=$(echo $d | sed 's,-,_,g')
	if [ $d = redo.py ]; then
		$INSTALL -m 0755 $d $DESTDIR$LIBDIR/$fix
	else
		$INSTALL -m 0644 $d $DESTDIR$LIBDIR/$fix
	fi
done
python -mcompileall $DESTDIR$LIBDIR

# It's important for the file to actually be named 'sh'.  Some shells (like
# bash and zsh) only go into POSIX-compatible mode if they have that name.
cp -R redo-sh/sh $DESTDIR$LIBDIR/bin/sh

# binaries
for d in $(python -c 'from main import mains; print " ".join(mains.keys())'); do
	ln -sf $LIBDIR/redo.py $DESTDIR$LIBDIR/bin/$d
	ln -sf $LIBDIR/redo.py $DESTDIR$BINDIR/$d
done
