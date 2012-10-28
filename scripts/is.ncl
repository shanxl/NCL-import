undef("is_scalar")
function is_scalar(x)
begin
  return(dimsizes(dimsizes(x)) .eq. 1) .and. all(dimsizes(x) .eq. 1)
end

; test if a 1d array is ascending
undef("is_ascending")
function is_ascending(x[*]:numeric)
local test
begin
  test = isMonotonic(x)
  if(test .eq. 1) then
    return(True)
  else
    if(test .eq. 0) then
      print("is_ascending: input is not monotonic!")
    end if
    return(False)
  end if 
end

; test if the lat dimension variable is global on a fixed grid
undef("is_lat_global")
function is_lat_global(lat[*]:numeric)
local lat_new, test
begin
  lat_new = latGlobeF(dimsizes(lat), "lat", "latitude", "degrees_north")
  if(is_ascending(lat)) then
    test = all(lat .eq. lat_new)
  else
    test = all(lat .eq. lat_new(::-1))
  end if
  return(test)
end

undef("is_lon_global")
function is_lon_global(lon[*]:numeric)
local lon_new, test
begin
  lon_new  = lonGlobeF(dimsizes(lon), "lon", "longitude", "degrees_east")
  test = all(lon .eq. lon_new)
  return(test)
end

undef("is_grid_global")
function is_grid_global(lat[*]:numeric, lon[*]:numeric)
local test
begin
  test = is_lat_global(lat) .and. is_lon_global(lon)
  return(test)
end


