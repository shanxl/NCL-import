;------------------------------------------------------------------
; MICAPS data
;------------------------------------------------------------------
undef("get_diamond2_site")
function get_diamond2_site(x[*][*]:float)
local site
begin
  site = floattoint(x(:, 0))
  return(site)
end

undef("get_diamond2_lon")
function get_diamond2_lon(x[*][*]:float)
local lon
begin
  lon = x(:, 1)
  lon!0 = "site"
  lon&site = get_diamond2_site(x)
  lon@long_name = "Longitude"
  return(lon)
end

undef("get_diamond2_lat")
function get_diamond2_lat(x[*][*]:float)
local lat
begin
  lat = x(:, 2)
  lat!0 = "site"
  lat&site = get_diamond2_site(x)
  lat@long_name = "Latitude"
  return(lat)
end

undef("get_diamond2_alt")
function get_diamond2_alt(x[*][*]:float)
local alt
begin
  alt = x(:, 3)
  alt!0 = "site"
  alt&site = get_diamond2_site(x)
  alt@long_name = "Altitude"
  return(alt)
end

undef("get_diamond2_site_grade")
function get_diamond2_site_grade(x[*][*]:float)
local site_grade
begin
  site_grade = floattoint(x(:, 4))
  site_grade!0 = "site"
  site_grade&site = get_diamond2_site(x)
  return(site_grade)
end

undef("get_diamond2_hgt")
function get_diamond2_hgt(x[*][*]:float)
local hgt
begin
  hgt = x(:, 5)
  hgt!0 = "site"
  hgt&site = get_diamond2_site(x)
  hgt@units = "10m"
  hgt@long_name = "Geopotential Height"
  return(hgt)
end

undef("get_diamond2_temp")
function get_diamond2_temp(x[*][*]:float)
local temp
begin
  temp = x(:, 6)
  temp!0 = "site"
  temp&site = get_diamond2_site(x)
  temp@units = "degC"
  temp@long_name = "Temperature"
  return(temp)
end

undef("get_diamond2_TTd")
function get_diamond2_TTd(x[*][*]:float)
local TTd
begin
  TTd = x(:, 7)
  TTd!0 = "site"
  TTd&site = get_diamond2_site(x)
  TTd@units = "degC"
  TTd@long_name = "Dew point temp deficit"
  return(TTd)
end

undef("get_diamond2_wind_angle")
function get_diamond2_wind_angle(x[*][*]:float)
local wind_angle
begin
  wind_angle = x(:, 8)
  wind_angle!0 = "site"
  wind_angle&site = get_diamond2_site(x)
  wind_angle@units = "deg"
  return(wind_angle)
end

undef("get_diamond2_wind_speed")
function get_diamond2_wind_speed(x[*][*]:float)
local wind_speed
begin
  wind_speed = x(:, 9)
  wind_speed!0 = "site"
  wind_speed&site = get_diamond2_site(x)
  wind_speed@units = "m/s"
  return(wind_speed)
end

undef("get_diamond2_uwnd")
function get_diamond2_uwnd(x[*][*]:float)
local u, a
begin
  u = get_diamond2_wind_speed(x)
  a = get_diamond2_wind_angle(x)
  u = -1.0 * u * sin(deg2rad(a))
  u@long_name = "U wind"
  return(u)
end

undef("get_diamond2_vwnd")
function get_diamond2_vwnd(x[*][*]:float)
local v, a
begin
  v = get_diamond2_wind_speed(x)
  a = get_diamond2_wind_angle(x)
  v = -1.0 * v * cos(deg2rad(a))
  v@long_name = "V wind"
  return(v)
end

undef("get_diamond2_wind_2d")
function get_diamond2_wind_2d(x[*][*]:float, uv_type[1]:string)
local lat, lon, dims, w, w2d
begin
  lat = (/ unique_values(get_diamond2_lat(x)) /)
  lon = (/ unique_values(get_diamond2_lon(x)) /)
  lat = lat(::-1)
  set_lat(lat)
  set_lon(lon)

  if(uv_type .eq. "u") then
    w = get_diamond2_uwnd(x)
  end if
  if(uv_type .eq. "v") then
    w = get_diamond2_vwnd(x)
  end if

  dims  = (/dimsizes(lat), dimsizes(lon)/)
;   printVarSummary(w)
;   print(dims)

  w2d   = reshape(w, dims)
  w2d!0 = "lat"
  w2d!1 = "lon"
  w2d&lat = lat
  w2d&lon = lon
  return(w2d)
end


undef("uv2speed")
function uv2speed(u:numeric, v:numeric)
local speed
begin
  speed = sqrt(u^2 + v^2)
  return(speed)
end

; down 0; left 90, up 180; right 270
undef("uv2angle")
function uv2angle(u, v)
local c, a, theta
begin
  c = u / uv2speed(u, v)
  theta = rad2deg(acos(c))
  theta = where(v .ge. 0, theta, 360 - theta)
  a = where(theta .le. 270, 270-theta, 270+360-theta)
  return(a)
end


; find numbers in a string
undef("string2numbers")
function string2numbers(s[1]:string)
local fn, x, cmd
begin
  fn = tmpFile()
  asciiwrite(fn, s)
  x = asciiread(fn, -1, "float")
  x@_FillValue = new(1, float)
  cmd = "rm -f " + fn
  system(cmd)
  return(x)
end

undef("get_micaps_head_info")
function get_micaps_head_info(fn[1]:string)
local r, s, intro
begin
  r = systemfunc("head -1 "+fn)
  s = str_split(gbk2uni(r), " ")
  intro = s(:2)
  return(intro)
end

undef("read_micaps_data")
function read_micaps_data(fn[1]:string)
local head, micaps_declare, micaps_format, supported_format, micaps_title, micaps_title_numbers, n_skip, numbers, body, meta, meta_int, data, data2d, data3d, ncol, nrow, n, lat, lon, dims
begin
  head = get_micaps_head_info(fn)

  micaps_declare = head(0)
  if(micaps_declare .ne. "diamond") then
    throw(fn + " is not a valid MICAPS file.")
  end if

  print("Read: "+fn)
  micaps_format = stringtointeger(head(1))
  supported_format = (/2, 4, 11/)
  if(num(supported_format .eq. micaps_format) .eq. 0) then
    throw("MICAPS format "+ micaps_format + " is not supported yet")
  end if

  micaps_title  = head(2)
  micaps_title_numbers = string2numbers(micaps_title)

  ; skip the first several numbers in declare and title
  n_skip = 1 + num(.not. ismissing(micaps_title_numbers)) 
  numbers = asciiread(fn, -1, "float")
  body = numbers(n_skip:)
  
  if(micaps_format .eq. 2) then
    meta = floattoint(body(:5))
    data = body(6:)

    ncol = 10
    nrow = dimsizes(data)/ncol

    if(nrow .ne. meta(5)) then
      throw("read_micaps_data: number of sites != rows")
    end if

    data2d = reshape(data, (/nrow, ncol/))
    data2d@_FillValue = 9999
    data2d@year   = meta(0)
    data2d@month  = meta(1)
    data2d@day    = meta(2)
    data2d@hour   = meta(3)
    data2d@level  = meta(4)
    data2d@n_site = meta(5)
    data2d@micaps_title   = micaps_title
    data2d@micaps_format  = micaps_format
    data2d@micaps_declare = micaps_declare
    return(data2d)
  end if
  
  if(micaps_format .eq. 4) then
    meta = body(:18)
    data = body(19:)

    meta_int = floattoint(meta)

    ; lat/lon information
    lat = fspan(meta(10), meta(11), meta_int(13))
    set_lat(lat)
    lon = fspan(meta(8), meta(9), meta_int(12))
    set_lon(lon)

    ; data
    data2d = fork2(lat, lon, "lat", "lon", "float")
    if(string_has(micaps_title, "高度")) then
      data2d@_FillValue = -1000.0
    end if
    if(string_has(micaps_title, "温度")) then
      data2d@_FillValue = -9999.9
    end if
    data2d = reshape(data, dimsizes(data2d))
    data2d@year   = meta_int(0)
    data2d@month  = meta_int(1)
    data2d@day    = meta_int(2)
    data2d@hour   = meta_int(3)
    data2d@forecastHours = meta_int(4)
    data2d@level = meta_int(5)
    data2d@cnSpacing = meta(14)
    data2d@cnStart = meta(15)
    data2d@cnEnd = meta(16)
    data2d@smooth = meta(17)
    data2d@cnBold = meta(18)
    data2d@micaps_title   = micaps_title
    data2d@micaps_format  = micaps_format
    data2d@micaps_declare = micaps_declare
    return(data2d)
  end if

  ; Read diamond 11 data, wind u v components
  ; 0年  1月  2日  3时次  4时效  5层次（均为整数）
  ; 6经度格距  7纬度格距  8起始经度  9终止经度  10起始纬度  
  ; 11终止纬度（均为浮点数）12纬向格点数  13经向格点数（均为整数）
  if(micaps_format .eq. 11) then
    meta = body(:13)
    data = body(14:)
    meta_int = floattoint(meta)

    ; number of records
    n= dimsizes(data) / 2

    ; lat/lon information
    lat = fspan(meta(10), meta(11), meta_int(13))
    set_lat(lat)
    lon = fspan(meta(8), meta(9), meta_int(12))
    set_lon(lon)
    dims = (/dimsizes(lat), dimsizes(lon)/)

    ; data
    data3d = fork3((/1, 2/),  lat, lon, "wind", "lat", "lon", "float")
    data3d(0, :, :)  = reshape(data(:n-1), dims)
    data3d(1, :, :)  = reshape(data(n:), dims)
    data3d@_FillValue = -9999.9
    data3d@units = "m/s"
    data3d@year   = meta_int(0)
    data3d@month  = meta_int(1)
    data3d@day    = meta_int(2)
    data3d@hour   = meta_int(3)
    data3d@forecastHours = meta_int(4)
    data3d@level = meta_int(5)
    data3d@micaps_title   = micaps_title
    data3d@micaps_format  = micaps_format
    data3d@micaps_declare = micaps_declare
    return(data3d)
  end if
end

;------------------------------------------------------------------
; 2012-2-3
;------------------------------------------------------------------
  ; make a header
undef("make_micaps_header")
function make_micaps_header(x:numeric)
local vt, T, info, header
begin
  vt = x@forecastHours
  if(vt .eq. 0) then
    info = "分析"
  else
    vt@units = "hours since " + x@year + "-" + x@month + "-" + x@day + " " + x@hour +":00:00"
    T = cd_calendar(vt, -5)
    info = T(:, 1) + "月" + T(:,2) + "日" + T(:,3) + "时预报"
  end if
  header = x@micaps_declare + " " + x@micaps_format + " " + \
           x@year + "年" + x@month + "月" + x@day + "日" + x@hour + "时" + \
           x@level + "hPa" + x@micaps_title + "(" + x@units + ")" + info
  header = uni2gbk(header)
  return(header)
end


undef("write_diamond4")
procedure write_diamond4(fn[1]:string, x[*][*]:numeric)
local opt, fmt, nlon, nlat, header
begin
  nlon = dimsizes(x&lon)
  nlat = dimsizes(x&lat)
  
  header = make_micaps_header(x)
  
  opt = True
  opt@fout  = fn
  opt@title = header + str_get_nl() + \
    pad(x@year) + " " + pad(x@month) + " "+ pad(x@day) + " " + \
    pad(x@hour)+ " " + x@forecastHours + " " + x@level + " " + \
    (x&lon(1)-x&lon(0)) + " " + (x&lat(1)-x&lat(0))+ " " + \
    x&lon(0) + " " + x&lon(nlon-1) + " " + \
    x&lat(0) + " " + x&lat(nlat-1) + " " + \
    nlon + " " + nlat + " " + x@cnSpacing + " " + \
    x@cnStart + " " + x@cnEnd + " " + x@smooth + " " + x@cnBold
  fmt = nlon + "f10.3"
  print("Write: "+opt@fout)
  write_matrix(x, fmt, opt)
end

undef("write_diamond2_wind")
procedure write_diamond2_wind(fn[1]:string, u[*][*]:numeric, v[*][*]:numeric)
local wind_angle, wind_speed, x, fmt, opt, n, header
begin
  wind_angle = uv2angle(ndtooned(u), ndtooned(v))
  wind_speed = uv2speed(ndtooned(u), ndtooned(v))

  n = dimsizes(wind_angle) 
  x = new((/n, 10/), "float")
  x(:, 0) = ispan(1, n, 1)
  x(:, 1) = ndtooned(conform(u, u&lon, 1))
  x(:, 2) = ndtooned(conform(u, u&lat, 0))
  x(:, 3) = 0
  x(:, 4) = 1
  x(:, 5:7) = 9999.
  x(:, 8) = wind_angle
  x(:, 9) = wind_speed

  fmt = "f9.0, 2f10.2, 5f9.0, 2f10.3"
  opt = True
  header = make_micaps_header(u)
  opt@title = header + str_get_nl()  + pad(u@year) + " " + pad(u@month) + " " + pad(u@day) + " " + pad(u@hour) + " " + u@level + " " + n
  opt@fout  =  fn
  print("Write: "+fn)
  write_matrix(x, fmt, opt)
end

undef("write_diamond11")
procedure write_diamond11(fn[1]:string, u[*][*]:numeric, v[*][*]:numeric)
local uv, fmt, opt, n, header
begin
  uv = array_append_record(u, v, 0)
  header = make_micaps_header(u)
  nlat = dimsizes(u&lat)
  nlon = dimsizes(u&lon)
  fmt = nlon + "f8.1"
  opt = True
  opt@title = header + str_get_nl() + \
    pad(u@year) + " " + pad(u@month) + " "+ pad(u@day) + " " + \
    pad(u@hour)+ " " + u@forecastHours + " " + u@level + " " + \
    (u&lon(1)-u&lon(0)) + " " + (u&lat(1)-u&lat(0))+ " " + \
    u&lon(0) + " " + u&lon(nlon-1) + " " + \
    u&lat(0) + " " + u&lat(nlat-1) + " " + \
    nlon + " " + nlat
  opt@fout  =  fn
  print("Write: "+fn)
  write_matrix(uv, fmt, opt)
end
