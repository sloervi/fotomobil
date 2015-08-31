#!/bin/sh
# fotomobil.sh
# sloervi McMurphy
# Make a copy of your photos with a width of 1200 pixel

MYDIR=`/bin/pwd`

for ii in `find . -type d ! -name @\* `
do
        cd $ii
        pwd
        /usr/local/bin/fotomobil/fotomobil.pl --verbose
cd $MYDIR
done
