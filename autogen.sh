#!/bin/sh
aclocal $ACLOCAL_FLAGS -I build -I /usr/share/aclocal && \
autoheader && \
libtoolize --force && \
automake --add-missing --gnu && \
autoconf
