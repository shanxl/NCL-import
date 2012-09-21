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

## Install
1. Set [NCL_DEF_SCRIPTS_DIR][1] environment variable
2. Put _aaa.ncl_ in NCL_DEF_SCRIPTS_DIR


## Known Issues
1. Scripts with dependencies should be imported one by one in order, e.g., "gsn_csm" depends on "gsn_code".
2. NCL (6.0 and 6.1 beta) for Mac might have arbitrary errors or quit unexpectedly sometimes with custom scripts

[1]:http://www.ncl.ucar.edu/Document/Manuals/Ref_Manual/NclDefaultScript.shtml