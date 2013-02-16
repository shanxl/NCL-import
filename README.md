## Introduction
When writing a NCL script, some high level graphics and contributed scripts often need to be loaded first. So, the head of a script looks like this:

```
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "THE_PATH_OF_MY_SCRIPT.ncl"
```
With "NCL-import", you can write cleaner code:

```
import("gsn_code")
import((/"gsn_csm", "contributed"/))
import("MY_SCRIPT")
```

The license for NCL-import is [GPLv3][2].


## Install
1. Set [NCL_DEF_SCRIPTS_DIR][1] environment variable
2. Put _ncl_import.ncl_ in NCL_DEF_SCRIPTS_DIR

## Scripts
NCL scripts in scripts/ directory are functions I use to make writing NCL code easier and faster. To use one of these scripts, just *import* it. Well, I will write documentation for these scripts later.

## Known Issues
1. Scripts with dependencies should be imported one by one in order, e.g., "gsn_csm" depends on "gsn_code".
2. NCL (6.0 and 6.1) for Mac might have arbitrary errors or quit unexpectedly sometimes with custom scripts

[1]:http://www.ncl.ucar.edu/Document/Manuals/Ref_Manual/NclDefaultScript.shtml
[2]:http://www.gnu.org/licenses/gpl.html