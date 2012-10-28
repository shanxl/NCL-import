;------------------------------------------------------------------
; Resources
; version: 2012-2-24
;------------------------------------------------------------------
; limit map range with lat/lon
undef("map_latlon")
procedure map_latlon(res[1]:logical, N[1]:numeric, S[1]:numeric,\
                     W[1]:numeric, E[1]:numeric)
begin
  res@mpLimitMode = "LatLOn"
  res@mpMaxLatF   = N
  res@mpMinLatF   = S
  res@mpMinLonF   = W
  res@mpMaxLonF   = E
end

undef("map_set_range")
procedure map_set_range(res[1]:logical, r[4]:numeric)
begin
  res@mpLimitMode = "LatLOn"
  res@mpMaxLatF   = r(0)
  res@mpMinLatF   = r(1)
  res@mpMinLonF   = r(2)
  res@mpMaxLonF   = r(3)
end

undef("aspect")
procedure aspect(res[1]:logical, width[1]:numeric, height[1]:numeric)
begin
  res@vpWidthF = width
  res@vpHeightF = height
end

undef("map_aspect")
procedure map_aspect(res[1]:logical, width[1]:numeric, height[1]:numeric)
begin
  res@mpShapeMode = "FreeAspect"
  aspect(res, width, height)
end

; TODO: specify the map database version
undef("map_nochina")
procedure map_nochina(res[1]:logical)
begin
  res@mpOutlineMaskingOn = "True"
  res@mpMaskOutlineSpecifiers = (/"China", "Taiwan", "China-Hainan-Dao-Island"/)
end

undef("map_grids")
procedure map_grids(res[1]:logical, degree[1]:integer)
begin
  res@mpGridAndLimbOn       = True
  res@mpGridSpacingF        = degree
  res@mpGridLineDashPattern = 2
  res@mpGridLineColor       = "gray60"
end

undef("vc_labels")
procedure vc_labels(res[1]:logical, str1[1], str2[1])
begin
  if (str1 .ne. "") then
    res@vcRefAnnoString1On = True
    res@vcRefAnnoString1 = str1
  end if

  if (str2 .ne. "") then
    res@vcRefAnnoString2On = True
    res@vcRefAnnoString2 = str2
  end if
end

undef("vc_ref")
procedure vc_ref(res[1]:logical, value[1]:numeric, length[1]:numeric)
begin
  res@vcRefMagnitudeF = value
  res@vcRefLengthF    = length
end

undef("vc_corner")
procedure vc_corner(res[1]:logical, corner[1]:string)
local vars
begin
  if (corner .eq. "BottomRight" .or. corner .eq. "_") then
    res@vcRefAnnoSide = "Top"
    res@vcRefAnnoJust = "BottomRight"
    res@vcRefAnnoOrthogonalPosF = -1
  end if

  if (corner .eq. "TopRight" .or. corner .eq. "^") then
    res@vcRefAnnoSide = "Bottom"
    res@vcRefAnnoJust = "TopRight"
    res@vcRefAnnoOrthogonalPosF = -1
  end if
end

;------------------------------------------------------------------
; TESTING
;------------------------------------------------------------------
res_basic = True
res_basic@gsnMaximize = True

res_portrait = res_basic
res_portrait@gsnPaperOrientation = "portrait"

res_landscape = res_basic
res_landscape@gsnPaperOrientation = "landscape"

res_cn_line = res_basic
res_cn_line@cnLinesOn = True
res_cn_line@cnLineLabelsOn = True
res_cn_line@cnLineLabelPlacementMode = "Computed"

res_vc = res_basic
res_vc@vcGlyphStyle  = "CurlyVector"

; china map
res_map_china_lc                       = res_portrait
res_map_china_lc@gsnDraw               = False
res_map_china_lc@gsnFrame              = False

res_map_china_lc@mpDataBaseVersion = "Ncarg4_1"
res_map_china_lc@mpDataSetName     = "Earth..4"
res_map_china_lc@mpLimitMode       = "LatLOn"

res_map_china_lc@mpProjection      = "LambertConformal"
res_map_china_lc@mpLambertParallel1F = 25
res_map_china_lc@mpLambertParallel2F = 45
res_map_china_lc@mpLambertMeridianF  = 105
res_map_china_lc@mpMinLatF           = 17
res_map_china_lc@mpMaxLatF           = 54
res_map_china_lc@mpMinLonF           = 80
res_map_china_lc@mpMaxLonF           = 130
res_map_china_lc@pmTickMarkDisplayMode = "Conditional"
res_map_china_lc@tmXTOn              = False
res_map_china_lc@tmYROn              = False

; Map grid lines
res_map_china_lc@mpGridAndLimbOn       = True
res_map_china_lc@mpGridSpacingF        = 10
res_map_china_lc@mpGridLineDashPattern = 2
res_map_china_lc@mpGridLineColor       = "gray40"
; res_map_china_lc@mpGridLineThicknessF  = 0.5
; res_map_china_lc@mpGridMaskMode      = "MaskOcean"

res_map_china_lc@mpFillOn              = False
res_map_china_lc@mpOutlineOn           = False 


undef("_cn_level_span")
procedure _cn_level_span(res[1]:logical, level_min[1]:numeric, \
                         level_max[1]:numeric, level_spacing[1]:numeric)
begin
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = level_min
  res@cnMaxLevelValF        = level_max
  res@cnLevelSpacingF       = level_spacing
end

undef("_cn_levels")
procedure _cn_levels(res, levels)
begin
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = levels
end
