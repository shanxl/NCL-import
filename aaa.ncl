;------------------------------------------------------------------------------
; Please set NCL_DEF_SCRIPTS_DIR to the directory that contains this program
; so that it will be loaded automatically every time ncl is run.
;------------------------------------------------------------------------------
DEF_SCRIPTS_DIRS  = (/"$NCL_DEF_SCRIPTS_DIR/../scripts/", \
                      "$NCARG_ROOT/lib/ncarg/nclscripts/csm/", \
                      "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/", \
                      "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/"/)
IMPORTED_SCRIPTS = (/"aaa"/)

; push an script to IMPORTED_SCRIPTS 
undef("push_script")
procedure push_script(script[1]:string)
local array
begin
  array = new(dimsizes(IMPORTED_SCRIPTS) + 1, string)
  array(1:) = IMPORTED_SCRIPTS
  array(0) = script
  delete(IMPORTED_SCRIPTS)
  IMPORTED_SCRIPTS = array
  delete(array)
end

; print imported scripts
undef("imported")
procedure imported()
begin
  print("Scripts imported: "+str_join(IMPORTED_SCRIPTS, ", "))
end

; search a file in several directories
undef("search_file")
function search_file(dirs[*]:string, fn[1]:string)
local found, path, i
begin
  found = False
  do i = 0, dimsizes(dirs) - 1
    path = dirs(i) + fn
    if (isfilepresent(path)) then
      found = True
      found@path = path
      break
    end if
  end do
  return(found)
end

; try importing a single script
undef("try_import")
procedure try_import(script[1]:string)
local i, f
begin
  if(script.eq."?".or.script.eq."") then
    print("Avalable scripts:")
    do i = 0, dimsizes(DEF_SCRIPTS_DIRS) - 1
      print(str_join(systemfunc("cd " + DEF_SCRIPTS_DIRS(i) + \
      "; ls *.ncl|sed 's/\.ncl$//'"), ", "))
    end do
  else if(.not.any(IMPORTED_SCRIPTS .eq. script)) then
    f = search_file(DEF_SCRIPTS_DIRS, script + ".ncl")
    if(f) then
      ;print("loading script "+f@path)
      loadscript(f@path)
      push_script(script)
    else
      print("Warning: failed to import " + str_get_dq + script + str_get_dq)
      print("Run import(" + str_get_dq + "?" +str_get_dq + \
      ") to show available scripts")
    end if
  end if
  end if
end

; import one or more predefined scripts
; Note: in case import of multiple scripts once fails due to dependencies,
;       try import scripts one by one
undef("import")
procedure import(script[*]:string)
local i
begin
  do i = 0, dimsizes(script) - 1
    try_import(script(i))
  end do
end
