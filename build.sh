#!/bin/bash

cflags="-Wall -O3 -g -std=gnu11 -fno-strict-aliasing -Isrc"
lflags="-lSDL3 -lm"

if [[ $* == *windows* ]]; then
  platform="windows"
  outfile="lite.exe"
  compiler="x86_64-w64-mingw32-gcc"
  cflags="$cflags -DLUA_USE_POPEN -Iwinlib/SDL3-3.2.16/x86_64-w64-mingw32/include"
  lflags="$lflags -Lwinlib/SDL3-3.2.16/x86_64-w64-mingw32/lib"
  lflags="-lmingw32 -lSDL3 $lflags -mwindows -o $outfile res.res"
  x86_64-w64-mingw32-windres res.rc -O coff -o res.res
else
  platform="unix"
  outfile="lite"
  compiler="gcc"
  cflags="$cflags -DLUA_USE_POSIX"
  lflags="$lflags -o $outfile"
fi

if command -v ccache >/dev/null; then
  compiler="ccache $compiler"
fi


echo "compiling ($platform)..."
for f in `find src -name "*.c"`; do
  $compiler -c $cflags $f -o "${f//\//_}.o"
  if [[ $? -ne 0 ]]; then
    got_error=true
  fi
done

if [[ ! $got_error ]]; then
  echo "linking..."
  $compiler *.o $lflags
fi

echo "cleaning up..."
rm *.o
rm res.res 2>/dev/null
echo "done"
