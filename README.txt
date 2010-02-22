syscleanup is a script that:
  - Finds files on a machine that did not come from RPM's
  - Finds files that did come from RPM which have been changed
  - Restore files that did come from RPM to their original state
    * with excludes for rpm names, file names and repositories
  - Helps identify source ( Vendor / Repo ) of installed RPMS

Usage:
  Just download and run the script
  Run it as root, so you dont have permissions issues. 
  Output is all created in /tmp/scu* files, needs about 10MiB of space there


Contributing:
  Hosted at http://gitorious.org/syscleanup/syscleanup; feel free to fork
  but do push merge requests :)

ToDo:
  * Create a yum loop that does 'reinstall' for packages that need restored 
  * Add a getopts based options parser and allow user to just run some parts
    of the script
  * Make smart enough to handle changed-but-config files
  * Check and report origin of all rpms installed on the machine ( repo
    identification )

Authors
  Karanbir Singh <kbsingh@karan.org>
