----------------------------------------------------------------------------
syscleanup.sh is a script that:
  - Finds files on a machine that did not come from RPM's
  - Finds files that did come from RPM which have been changed
  - Restore files that did come from RPM to their original state
    * with excludes for rpm names, file names and repositories
  - Helps identify source ( Vendor / Repo ) of installed RPMS
Usage:
  Just download and run the script
  Run it as root, so you dont have permissions issues. 
  Output is all created in /tmp/scu* files, needs about 10MiB of space there

----------------------------------------------------------------------------
last_used_report.sh will look at all rpm payloads ( i.e files ) and 
generate a date order list in /tmp based on when content was last accessed
on the machine ( atime for files ).

Couple of things that are worth keeping in mind here :
 - we are not considering files created by actions in rpm %pre / %post scripts
 - ideally, run the script as root; but you dont haveto
 - Some files will end up with really old dates - thats fine, its just the way
   the rpms were built and the original payload has not been touched.
 - Some rpms ( like filesystem ) will have content that is *needed* but not
   really accessed.

Word of warning : dont just pipe the output from this list into a yum erase 
operation. Crazy things are likely to happen.
----------------------------------------------------------------------------

Contributing:
  Hosted at https://github.com/kbsingh/syscleanup; feel free to fork
  but do push merge requests :)

ToDo:
  * Create a yum loop that does 'reinstall' for packages that need restored 
  * Add a getopts based options parser and allow user to just run some parts
    of the script
  * Make smart enough to handle changed-but-config ( and ghost ) files

Authors
  Karanbir Singh <kbsingh@karan.org>
