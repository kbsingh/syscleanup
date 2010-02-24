#!/bin/sh
#
# (c) Karanbir Singh <kbsingh@karan.org>, Feb 2010
#
# - check if we are running as root, not doing so can cause false positives as we might
#   not have perms to check some of the file/package payloads
# - save a load of time by not letting find descend into directories we never want to 
#   compare 
#
#  NOTE: This is *not* a security audit tool
#

TAG=$(date +%Y%m%d_%H:%M:%S)
FindOpts=()
SysFileList=/tmp/scu-syslist.$TAG
RpmFileList=/tmp/scu-rpmlist.$TAG
RpmModList=/tmp/scu-rpmmod.$TAG

# clear list is for points that rpm never provides any files under
ClearList=(/home /opt /root /srv /tmp /var/tmp)

# ignorelist is for points where we expect local content - maynot be a big deal
IgnoreList=(/var/cache /var/log)

# whitelist is for things that we know dont come from rpms, but need to be ignored
WhiteList=(/proc /sys /dev /selinux)

check_sanity(){
  # make sure that rpmdb can be queried 
  rpmout=$( rpm --qf '%{name}\n' -qf /etc/inittab )
  if [ $rpmout != 'initscripts' ] ; then
    echo "RPM faild sanity test"
    return -1
  fi
  # Just a basic test to make sure yum is usable on the machine 
  python -c 'import yum'
  if [ $? -ne 0 ]; then
    echo 'YUM failed sanity test'
    return -1
  fi
}

build_findopts() {
  i=${#FindOpts[*]}
  for d in "${ClearList[@]} ${IgnoreList[@]} ${WhiteList[@]}"; do
    FindOpts[i++]="-not"
    FindOpts[i++]="-wholename"
    FindOpts[i++]="$d/*"
  done
}
get_AllSystemFileList() {
  # Get a list of all files we care about 
  build_findopts
  find / "${FindOpts[@]}"
}

get_AllRpmFileList() {
  # Get a list of all files in the rpmdb 
  rpm -qal 
}

find_non_rpm_files() {
  # All files under points defied as ClearList are non-rpm-packaged
  for point in $ClearList; do
    find $point
  done
}

find_mod_rpms() {
  #get a list of rpms that provided files which have been locally modified
  for pkg in `rpm -qa`; do
    rpmout=$(rpm -V $pkg )
    if [ `echo $rpmout | grep -v '^$' | wc -l` -gt 0 ]; then
      echo '--: ' $pkg 
      echo "$rpmout"
    fi
  done
}

runas_root(){
# Check if were running as root
  if [ `id -n -u` != 'root' ]; then
    return 1
  fi
}

runas_root
if [ $? -ne 0 ];then echo -e ' .. \n .. Running this script as root would reduce false positives reported!' ; fi
check_sanity
if [ $? -ne 0 ];then exit 1 ; fi

get_AllSystemFileList | sort > ${SysFileList}
get_AllRpmFileList | sort | uniq > ${RpmFileList}
find_mod_rpms > ${RpmModList}

echo "Sysclean Run : " `date`
diff -uNr ${RpmFileList} ${SysFileList}
echo -e " .. \n .. Content that has changed from what RPM brought in"
cat ${RpmModList}
