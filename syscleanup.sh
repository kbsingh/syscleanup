#!/bin/sh
#
# (c) Karanbir Singh <kbsingh@karan.org>
#
# - check if we are running as root, not doing so can cause false positives as we might
#   not have perms to check some of the file/package payloads
# - save a load of time by not letting find descend into directories we never want to 
#   compare 

TAG=$(echo 'scu-'$(date +%Y%m%d_%H:%M:%S))
FindOpts=''

# clear list is for points that rpm never provides any files under
ClearList='/home /opt /root /srv /tmp /var/tmp'

# ignorelist is for points where we expect local content - maynot be a big deal
IgnoreList='/var/cache /var/log'

# whitelist is for things that we know dont come from rpms, but need to be ignored
WhiteList='/proc /sys /dev /selinux'

util_build_findopts() {
  # Build up the FindOpts based on ClearList, IgnoreList and Whitelist
  for point in $ClearList $IgnoreList $WhiteList; do
    FindOpts=$FindOpts" -not -wholename '$point'"
  done

}
get_AllSystemFileList() {
  # Get a list of all files we care about 
  util_build_findopts
  find / $FindOpts  
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
      echo $pkg
      echo $rpmout
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

get_AllSystemFileList > /tmp/scu-syslist.$TAG
get_AllRpmFileList > /tmp/scu-rpmlist.$TAG
find_mod_rpms > /tmp/scu-rpmmod.$TAG
