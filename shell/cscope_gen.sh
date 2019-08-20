#!/bin/bash
LNX=$PWD
mkdir $PWD/cscope
#find $LNX \
#-path "$LNX/arch/*" ! -path "$LNX/arch/i386*" -prune -o \
#-path "$LNX/include/asm-*" ! -path "$LNX/include/asm-i386*" -prune -o \
#-path "$LNX/tmp*" -prune -o \
#-path "$LNX/Documentation*" -prune -o \
#-path "$LNX/scripts*" -prune -o \
#-path "$LNX/drivers*" -prune -o \
#-name "*.[chxsS]" -print >$LNX/cscope/cscope.files

find $LNX \
-name "*.[chxsS]" -print >$LNX/cscope/cscope.files

cd $LNX/cscope
cscope -b -q -k
