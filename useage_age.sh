#!/bin/sh

# Copyright Karanbir Singh <kbsingh@karan.org>, Nov 2011
# 
# Util to help locate rpms on a machine which might not
# be used at all.

# XXX: carefully inspect the output, some rpms provide
# placeholder content, which is needed but not used
# eg: filesystem 


tst_dir=$(mktemp -d)

for pkg in `rpm -qa`; do
  ts=$(find `rpm -ql $pkg` -type f -printf "%AY%Am%Ad%AH%AM\n" 2>/dev/null | sort -n | tail -n1 )
  touch -t $ts $tst_dir/$pkg
done

echo 'Results in ' $tst_dir
