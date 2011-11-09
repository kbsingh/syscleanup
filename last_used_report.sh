#!/bin/sh
#
# Copyright Karanbir Singh, kbsingh@karan.org, http://www.karan.org/ ;Nov 2011
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ---------------------------------------------------------------------------
# Util to help locate rpms on a machine which might not
# be used at all. Might want to run this as the root user.
#
# ---------------------------------------------------------------------------

if [ $(mount | grep noatime | wc -l ) -gt 0 ]; then
  echo 'You have noatime mounts ~ will impact results'
fi

tst_dir=$(mktemp -d)
for pkg in `rpm -qa`; do
  ts=$(find `rpm -ql $pkg` -type f -printf "%AY%Am%Ad%AH%AM\n" 2>/dev/null | sort -n | tail -n1 )
  touch -t $ts $tst_dir/$pkg
done

echo 'Results in ' $tst_dir
