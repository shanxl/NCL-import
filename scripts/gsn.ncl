import("gsn_code")
import("gsn_csm")
import("easy")
import("res")

; do not plot the figure, do not frame the workstation
undef("hold")
procedure hold(res[1]:logical)
begin
  res = True
  res@gsnDraw = False
  res@gsnFrame = False
end

; draw & frame
undef("flush")
procedure flush(wks:graphic, plot:graphic)
begin
  draw(plot)
  frame(wks)
end

; open a workstation and set color maps quickly
undef("gsn_wks")
function gsn_wks(fn[1]:string, cmap[*]:string)
local suffix, valid_suffix, fnbase, wks, n
begin
  ; parse the suffix of fn
  suffix = last(str_split(fn, "."))
  ; valid suffix
  valid_suffix = (/"pdf", "ps", "png", "eps"/)

  if(any(suffix.eq.valid_suffix)) then
    print("figure will be saved as " + fn)
    fnbase = str_sub_str(fn, "."+suffix, "")
    if(suffix.eq."pdf") then
      wks = gsn_open_wks("newpdf", fnbase)
    else
      wks = gsn_open_wks(suffix, fnbase)
    end if
  else
    ; default to pdf
    print("figure will be saved as " + fn + ".pdf")
    wks = gsn_open_wks("newpdf", fn)
  end if

  ; now parse the color map
  n = dimsizes(cmap)
  if(n .gt. 2) then
    print("gsn_pdf: color map ignored, its size should be 1 or 2")
  else if(n .eq. 2) then
    gsn_merge_colormaps(wks, cmap(0), cmap(1))
  else if(cmap .eq. "") then
      gsn_define_colormap(wks, "default")
  else if(cmap .eq. "g") then
      gsn_define_colormap(wks, "gsdtol")
  else if(cmap .eq. "br") then
      gsn_define_colormap(wks, "BlueDarkRed18")
  else if(cmap .eq. "brg") then
      gsn_merge_colormaps(wks, "BlueDarkRed18", "gsdtol")
  else
      gsn_define_colormap(wks, cmap)
  end if end if end if end if end if end if
  return(wks)
end

; set gsn left, center, right strings
undef("gsn_strings")
procedure gsn_strings(res[1]:logical, l[1]:string, c[1]:string, r[1]:string)
begin
  res@gsnLeftString   = l
  res@gsnRightString  = r
  res@gsnCenterString = c
end

undef("gsn_strings_clear")
procedure gsn_strings_clear(res)
begin
  gsn_strings(res, "", "", "")
end

;------------------------------------------------------------------
;                   China Map Outline
;------------------------------------------------------------------
undef("read_map_data")
function read_map_data(map[1]:string)
local mapd, fn, f
begin
  mapd = "$NCL_DEF_SCRIPTS_DIR/../data/map/"
  fn  = mapd + map + ".txt"
  if(isfilepresent(fn)) then
    f   = asciiread(fn, -1, "float")
    f@_FillValue = 0
    return(f)
  else
    print("read_map_data: " + map + " is not a valid map name.")
    print("Please select one of the maps below:")
    print(str_join(systemfunc("ls " + mapd + "|sed 's/\.txt//'"), " ,"))
    exit
  end if
end

undef("gsn_add_map")
function gsn_add_map(wks:graphic, plot:graphic, map[1]:string, res:logical)
local f, mp
begin
  f  = read_map_data(map)
  mp = gsn_add_polyline(wks, plot, f(0::2), f(1::2), res)
  return(mp)
end

; add south china sea by set the bottom left corner
undef("gsn_add_SCS")
function gsn_add_SCS(wks:graphic, plot:graphic, lon_min[1]:numeric, \
                     lat_min[1]:numeric, res:logical)
local dLon, dLat, f, mp
begin
  dLon = lon_min - 136
  dLat = lat_min - 17
  f  = read_map_data("SouthChinaSea")
  mp = gsn_add_polyline(wks, plot, f(0::2)+dLon, f(1::2)+dLat, res)
  return(mp)
end

undef("gsn_add_SCS_ndc")
function gsn_add_SCS_ndc(wks:graphic, plot:graphic, dx[1]:numeric, \
                            dy[1]:numeric, res:logical)
local f, fn, x, y, R, N, g
begin
  fn  = "$NCL_DEF_SCRIPTS_DIR/../data/SouthChinaSea.nc"
  f   = addfile(fn,"r")
  x   = f->lon_ndc + dx
  y   = f->lat_ndc + dy
  ; add background color to southsea
  R = True
  R@gsFillColor = "White"
  N = dimsizes(x)
  g = new(85, graphic)
  g(0)=gsn_add_primitive(wks, plot, x(N-5:N-1), y(N-5:N-1), True, "polygon", R)
  g(1:)=gsn_add_primitive(wks, plot, x, y, True, "polyline", res)
  return(g)
end
