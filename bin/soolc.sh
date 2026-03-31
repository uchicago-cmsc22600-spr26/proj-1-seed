#!/bin/sh
#
# Shell wrapper for SooL compiler
#
# CMSC 22600 --- Compilers for Computer Languages
# Spring 2026
# University of Chicago
#

SOOLC=$0
BINDIR=${SOOLC%soolc.sh}

OS=$(uname -s)
case x"$OS" in
  xDarwin) HEAP_SUFFIX=x86-darwin ;;
  xLinux) HEAP_SUFFIX=x86-linux ;;
  *) echo "$OS nut supported"
     exit 1
  ;;
esac

HEAP=$BINDIR/soolc.$HEAP_SUFFIX

if test ! -r $HEAP ; then
  echo "Heap image $HEAP not found; run make to build"
  exit 1
fi

exec sml @SMLcmdname=$0 @SMLload=$HEAP $@
