import("constants")
import("contributed")

;------------------------------------------------------------------
; Simple
;------------------------------------------------------------------
  ; shortcut of dimsizes
  undef("_")
  function _(x) begin return(dimsizes(x)) end

  ; return the number of dimensions of x
  undef("rank")
  function rank(x) begin return(_(_(x))) end

  ; print a message and exit immediately
  undef("throw")
  procedure throw(message[1]:string)
  begin
    print(""+message)
    exit
  end

  ; return the last element in an array
  undef("last")
  function last(x)
  local n, x1d
  begin
    n = _(x)
    if(_(n).eq.1) then
      return(x(n-1))
    else
      x1d = ndtooned(x)
      return(x1d(product(n)-1))
    end if
  end
  
  ; make a new directory if it's not there
  undef("make_dir")
  procedure make_dir(dir)
  local cmd
  begin
    cmd = "if [ ! -d "+dir+" ];then mkdir -p "+dir+"; fi"
    system(cmd)
  end

  ; return the non-empty string part after the last /
  undef("base_name")
  function base_name(s[1]:string)
  begin
    return(last(str_split(s, "/")))
  end
  
  ; pad zeros in a number to be n digits long
  undef("padn")
  function padn(number:integer, n[1]:integer)
  begin
    return sprinti("%0."+n+"i", number)
  end

  undef("pad")
  function pad(number:integer)
  begin
    return padn(number, 2)
  end

  undef("pad3")
  function pad3(number:integer)
  begin
    return padn(number, 3)
  end

  ; test if variable is 1-D and 1 element, e.g. x = 1
  undef("isscalar")
  function isscalar(x)
  begin
    return(rank(x).eq.1 .and. _(x).eq.1)
  end
  
  ; when a function/procedure has optional arguments, check if it's ignored
  undef("ignore")
  function ignore(x)
  begin
    return((typeof(x).eq."logical") .and. isscalar(x) .and. \
           (.not.ismissing(x)) .and. (.not.x))
  end

;------------------------------------------------------------------
; String
;------------------------------------------------------------------
  ; test if a string starts with a subStr pattern
  undef("string_start_with")
  function string_start_with(str[*]:string, subStr[1]:string)
  begin
    return(str_get_cols(str, 0, strlen(subStr)-1) .eq. subStr)
  end

  ; test if a string ends with a endStr pattern
  undef("string_end_with")
  function string_end_with(str[*]:string, endStr[1]:string)
  begin
    return(str_get_cols(str, strlen(endStr)*-1, -1) .eq. endStr)
  end

  ; test if string has substring in it
  undef("string_has")
  function string_has(str[*]:string, s[1]:string)
  begin
    if(s.eq."")
      print("Waring from string_has: the substring is empty")
    end if
    return(.not.(str.eq.str_sub_str(str, s, "")))
  end
  
  ; read a text file as strings by lines
  undef("readlines")
  function readlines(fn[1]:string)
  begin
    return(asciiread(fn, -1, "string"))
  end

  ; filter empty or space/tab lines
  undef("filter_blank")
  function filter_blank(s[*]:string)
  local test
  begin
    test = .not.str_is_blank(s)
    if(any(test)) then
      return(s(ind(test)))
    else
      return(new(1, string))
    end if
  end

  ; filter comments
  undef("filter_comment")
  function filter_comment(x[*]:string, commenter[1]:string)
  local test
  begin
    test = .not.string_start_with(x, commenter)
    if(any(test)) then
      return(x(ind(test)))
    else
      return(new(1, string))
    end if
  end

;------------------------------------------------------------------
; Convert
;------------------------------------------------------------------
  ; convert from degree to radius
  undef("deg2rad")
  function deg2rad(x:numeric)
  begin
    return(x * acos(-1) / 180.0)
  end

  undef("rad2deg")
  function rad2deg(x:numeric)
  begin
    return(x * 180.0 / acos(-1))
  end

  ; convert string codec 
  undef("gbk2uni")
  function gbk2uni(s[1]:string)
  local cmd
  begin
    cmd = "echo '" + s +"' | iconv -f gbk -t utf8"
    return(systemfunc(cmd))
  end

  undef("uni2gbk")
  function uni2gbk(s[1]:string)
  local cmd
  begin
    cmd = "echo '" + s +"' | iconv -f utf8 -t gbk"
    return(systemfunc(cmd))
  end

;------------------------------------------------------------------
; Lat/Lon
;------------------------------------------------------------------
  ; set lat/lon attributes quickly
  undef("set_lon")
  procedure set_lon(lon[*])
  begin
    lon@long_name   =   "Longitude"
    lon@units       =   "degrees_east"
  end

  undef("set_lat")
  procedure set_lat(lat[*])
  begin
    lat@long_name = "Latitude"
    lat@units = "degrees_north"
  end

  ; make longtitude as east
  undef("lon_degE")
  function lon_degE(lon:numeric)
  local x
  begin
    x= where(lon .lt. 0, lon + 360, lon)
    return(x)
  end

  ; make sure longitude like 45E -45W
  undef("lon_degWE")
  function lon_degWE(lon:numeric)
  local x
  begin
    x= where(lon .gt. 180, lon - 360, lon)
    return(x)
  end

  ; the rightmost dimension should be lon
  undef("zonal_mean")
  function zonal_mean(x:numeric)
  local ndim, xZon
  begin
    if(rank(x) .ge. 2) then
      ndim = ispan(0, rank(x)-2, 1)
    else
      ndim = -1
    end if
    xZon = conform(x, dim_avg_Wrap(x), ndim)
    copy_VarCoords(x, xZon)
    return(xZon)
  end

  ; great circle distance, units km
  undef("gc_distance")
  function gc_distance(lat1[1]:numeric,lon1[1]:numeric,\
                       lats[*]:numeric,lons[*]:numeric)
  local nlat, dist, i
  begin
    nlat = _(lats)
    dist = new(nlat, float)
    do i=0, nlat-1
      dist(i) = gc_latlon(lat1, lon1, lats(i), lons(i), 2, 4)
    end do
    return(dist)
  end

;------------------------------------------------------------------
; Array Manipulation
;------------------------------------------------------------------
  undef("fork")
  function fork(var[*]:numeric, name[1]:string, dataType[1]:string)
  local x
  begin
    x = new(_(var), dataType)
    x!0 = name
    x&$name$ = var
    return(x)
  end

  undef("fork2")
  function fork2(var1[*]:numeric, var2[*]:numeric, name1[1]:string, \
                 name2[1]:string, dataType[1]:string)
  local x
  begin
    x = new((/_(var1), _(var2)/), dataType)
    x!0 = name1
    x!1 = name2
    x&$name1$ = var1
    x&$name2$ = var2
    return(x)
  end

  undef("fork3")
  function fork3(var1[*]:numeric, var2[*]:numeric, var3[*]:numeric, \
                 name1[1]:string, name2[1]:string, name3[1]:string, \
                 dataType[1]:string)
  local x
  begin
    x = new((/_(var1), _(var2), _(var3)/), dataType)
    x!0 = name1
    x!1 = name2
    x!2 = name3
    x&$name1$ = var1
    x&$name2$ = var2
    x&$name3$ = var3
    return(x)
  end

  undef("fork4")
  function fork4(var1[*]:numeric, var2[*]:numeric, var3[*]:numeric, \
  var4[*]:numeric, name1[1]:string, name2[1]:string, name3[1]:string, \
  name4[1]:string, dataType[1]:string)
  local x
  begin
    x = new((/_(var1), _(var2), _(var3), _(var4)/), dataType)
    x!0 = name1
    x!1 = name2
    x!2 = name3
    x!3 = name4
    x&$name1$ = var1
    x&$name2$ = var2
    x&$name3$ = var3
    x&$name4$ = var4
    return(x)
  end

  ; return unique values in a 1-D array
  undef("unique_values")
  function unique_values(data[*])
  local x, i, y, u, idx
  begin
    x = data
    if (.not. isatt(x, "_FillValue")) then
      x@_FillValue = default_fillvalue(typeof(x))
    end if

    do i=0, _(x) - 2
      if (.not. ismissing(x(i))) then
        y = x(i)
        x = where(x .eq. y, x@_FillValue, x)
        x(i) = y
      end if
    end do
    
    if(all(ismissing(x))) then
      return(x@_FillValue)
    else
      idx = ind(.not.ismissing(x))
      u = x(idx)
      u@unique_idx = idx
      return(u)
    end if
  end

  ; find the common elements of two 1-D arrays
  undef("common_values")
  function common_values(x[*], y[*])
  local n, i, common
  begin
    ; number of common values
    n = 0
    ; a container to store common elements, NCL only support fixed sized arrays
    common = new(min((/_(x), _(y)/)), typeof(x))

    do i=0, _(x)-1
      if(any(y .eq. x(i))) then
        common(n) = x(i)
        n = n+1
      end if
    end do

    if(n .gt. 0) then
      return(common(:n-1))
    else
      return(common(0))     ; return a missing value
    end if
  end

;------------------------------------------------------------------
; Date Object, to replace Time functions
;------------------------------------------------------------------
  ; day and hour is optional, can be set to False
  undef("Date")
  function Date(y[*], m[*], d[*], h[*])
  local vars
  begin
    z = y - y
    if(ignore(d)) then
      units = "months since 1-1-1"
      return cd_inv_calendar(y, m, z+1, z, z, z, units, 0)
    else if(ignore(h)) then
      units = "days since 1-1-1"
      return cd_inv_calendar(y, m, d, z, z, z, units, 0)
    else
      units = "hours since 1900-1-1 0:0:0"
      return cd_inv_calendar(y, m, d, h, z, z, units, 0)
    end if end if
  end

  ; test if a moment is in an array time, compare all the elements
  undef("when")
  function when(time[*], moment[1])
  local n, i, test
  begin
    n = _(time)
    test = new(n, logical)
    test = False
    do i=0, n - 1
      if(all(cd_calendar(time(i),0) .eq. cd_calendar(moment, 0))) then
        test(i) = True
      end if
    end do
    return(test)
  end

  ; test if a moment is in an array time, return the first index if found 
  undef("anytime")
  function anytime(time[*], moment[1])
  local found, i
  begin
    found = False
    do i=0, _(time)-1
      if(all(cd_calendar(time(i),0) .eq. cd_calendar(moment, 0))) then
        found = True
        found@idx = i
        break
      end if
    end do
    return(found)
  end

  ; recognizable strings: YYYYMM[DD][hh] Y-M[-D][-h] Y.M[.D][.h]
  undef("parseDate")
  function parseDate(s[1]:string)
  local part, len, n
  begin
    if(string_has(s, "-")) then
      part = stringtoint(str_split(s, "-"))
    else if(string_has(s, ".")) then
      part = stringtoint(str_split(s, "."))
    else
      len = strlen(s)
      if(len.eq.6) then
        part = stringtoint(str_split_by_length(s, (/4, 2/)))
      else if(len.eq.8) then
        part = stringtoint(str_split_by_length(s, (/4, 2, 2/)))
      else if(len.eq.10) then
        part = stringtoint(str_split_by_length(s, (/4, 2, 2, 2/)))
      end if end if end if
    end if end if

    n = _(part)
    if(n.eq.2) then
      return(Date(part(0), part(1), False, False))
    else if(n.eq.3) then
      return(Date(part(0), part(1), part(2), False))
    else if(n.eq.4) then
      return(Date(part(0), part(1), part(2), part(3)))
    else
      throw("parseDate: can't parse "+s)
    end if end if end if
  end

  undef("get_year")
  function get_year(date[*])
  local T
  begin
    T = cd_calendar(date, -5)
    return T(:, 0)
  end

  undef("get_month")
  function get_month(date[*])
  local T
  begin
    T = cd_calendar(date, -5)
    return T(:, 1)
  end

  undef("get_day")
  function get_day(date[*])
  local T
  begin
    T = cd_calendar(date, -5)
    return T(:, 2)
  end
  
  undef("get_hour")
  function get_hour(date[*])
  local T
  begin
    T = cd_calendar(date, -5)
    return T(:, 3)
  end
  
  undef("month_abbr")
  function month_abbr(month[*]:integer)
  local x
  begin
    x = (/"Jan", "Feb", "Mar", "Apr", "May", "Jun", \
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"/)
    return x(month - 1)
  end

  undef("pentad72")
  function pentad72(year[1]:integer)
  local fn, f, p
  begin
    fn="$NCL_DEF_SCRIPTS_DIR/../data/pentads-72.nc"
    f=addfile(fn,"r")
    if (isleapyear(year)) then
      p=f->p_leap
    else
      p=f->p_noleap
    end if
    delete(f)
    return(p)
  end

  undef("recent_date")
  function recent_date(n[1]:integer)
  local today, x 
  begin
    today = parseDate(systemfunc("date +%Y%m%d"))
    x = today + ispan(0, n-1, 1)*-1
    copy_VarAtts(today, x)
    return(x)
  end

  ; format a date, function cd_string in NCL V6.1
  ; Y => 4-digit year (e.g., 2007).
  ; y => 2-digit year (e.g., 07).
  ; N => 2-digit month (e.g., 06).
  ; n => 1 or 2 digit month (e.g., 6 for June, 12 for December).
  ; D => 2-digit day (e.g., 04).
  ; d => 1 or 2 digit day (e.g., 4)
  ; H => 2-digit hour (e.g., 09).
  ; h => 1 or 2 digit hour (e.g., 9 or 11).
  undef("format_date")
  function format_date(time[*], fmt[1]:string)
  local s, keys, n, yyyymmddhh, values, i, j
  begin
    keys = "%" + (/"Y", "y", "N", "n", "D", "d", "H", "h"/)
    n = _(time)
    s = new(n, string)
    s = fmt
    do i=0, n-1
      yyyymmddhh = tostring(cd_calendar(time(i), -3))
      values = (/str_get_cols(yyyymmddhh, 0, 3), \
                 str_get_cols(yyyymmddhh, 2, 3), \
                 str_get_cols(yyyymmddhh, 4, 5), \
                 tostring(get_month(time(i))), \
                 str_get_cols(yyyymmddhh, 6, 7), \
                 tostring(get_day(time(i))), \
                 str_get_cols(yyyymmddhh, 8, 9), \
                 tostring(get_hour(time(i)))/)
      do j=0, dimsizes(keys)-1
        s(i) = str_sub_str(s(i), keys(j), values(j))
      end do
    end do
    return(s)
  end

;------------------------------------------------------------------
; File I/O
;------------------------------------------------------------------
  ; generate a temp file name
  undef("tmpFile")
  function tmpFile()
  begin
    return("/tmp/" + unique_string("ncl_tmpfile_"))
  end

  ; create a file object to write data
  undef("make_nc")
  function make_nc(fn[1]:string)
  local fout, ncFilename
  begin
    if (string_end_with(fn, ".nc")) then
      ncFilename = fn
    else
      ncFilename = fn + ".nc"
    end if
    print("Creating " + ncFilename)
    system("rm -f " + ncFilename)
    fout                = addfile(ncFilename, "c")
    fout@creation_date  = systemfunc("date '+%H:%M:%S %F %z'")
    fout@author         = "Shan Xiaolong, PKU"
    fout@email          = "ericalways@gmail.com"
    return(fout)
  end

  ; a short cut to read a variable from a nc file
  undef("read")
  function read(fn, var)
  local f, fx
  begin
    if (string_end_with(fn, ".nc")) then
      fx = fn
    else
      fx = fn + ".nc"
    end if
    if(isfilepresent(fx)) then
      f = addfile(fx, "r")
      return f->$var$
    else
      throw("read: cannot find " + fx)
    end if
  end

  ; count lines in a text file
  undef("line_count")
  function line_count(fn[1]:string)
  local n
  begin
    n = new(1, "integer")
    n = stringtointeger(systemfunc("wc -l "+fn+" | awk '{print $1}'"))
    return(n)
  end

  undef("read_txt")
  function read_txt(fn[1]:string, dType[1]:string)
  local nrow, ncol, data
  begin
    nrow = line_count(fn)
    ncol = stringtointeger(systemfunc("tail -1 " + fn + " | wc -w"))
    data = asciiread(fn, (/nrow,ncol/), dType)
    return(data)
  end

  ; read text data file except for the first N lines
  undef("read_txt_noheader")
  function read_txt_noheader(fn[1]:string, N[1]:integer, dType[1]:string)
  local nrow,ncol,tmpfile,data
  begin
    nrow = line_count(fn) - N
    tmpfile = tmpFile()
    system("tail -" + nrow + " " + fn + " > " + tmpfile)
    ncol = stringtointeger(systemfunc("tail -1 " + tmpfile + " | wc -w"))
    data = asciiread(tmpfile, (/nrow,ncol/), dType)
    system("rm -f " + tmpfile)
    return(data)
  end

  undef("read_txt_noheader_1d")
  function read_txt_noheader_1d(fn[1]:string, N[1]:integer, dType[1]:string)
  local nrow,ncol,tmpfile,data
  begin
    nrow = line_count(fn) - N
    tmpfile = tmpFile()
    system("tail -" + nrow + " " + fn + " > " + tmpfile)
    data = asciiread(tmpfile, -1, dType)
    system("rm -f " + tmpfile)
    return(data)
  end

  ; read one line of data in a text file
  undef("read_txt_line")
  function read_txt_line(fn[1]:string, nline[1]:integer)
  local tmpfile, data
  begin
    tmpfile = tmpFile()
    system("head -" + nline + " " + fn + " | tail -1 > " + tmpfile)
    data = asciiread(tmpfile, -1, "float")
    system("rm -f " + tmpfile)
    return(data)
  end

;------------------------------------------------------------------
; Percentile
;------------------------------------------------------------------
  ; ref: http://en.wikipedia.org/wiki/Percentile
  undef("percentile_round")
  function percentile_round(x[*]:numeric, P[1]:integer)
  local xNew, rank, N
  begin
    if(all(ismissing(x))) then
      return(new(1, typeof(x)))
    else
      xNew = x(ind(.not.ismissing(x)))
      qsort(xNew)
      N    = _(xNew)
      rank = round(P*N/100.0 + 0.5, 3)
      rank = min((/rank, N/))
      return(xNew(rank-1))
    end if
  end

  undef("percentile")
  function percentile(x[*]:numeric, P[1]:integer)
  local v, N, p_rank, k
  begin
    if(all(ismissing(x))) then
      return(new(1, typeof(x)))
    else
      v= x(ind(.not.ismissing(x)))
      qsort(v)
      N    = _(v)
      p_rank = (ispan(1, N, 1) - 0.5) * 100 / N
      if (P .lt. p_rank(0)) then
        return v(0)
      else if(P .ge. p_rank(N-1)) then
        return v(N-1)
      else
        k = max(ind(p_rank .le. P))
        return v(k) + N * (P - p_rank(k)) / 100.0 * (v(k+1) - v(k))
      end if end if
    end if
  end

;------------------------------------------------------------------
; Indexing
;------------------------------------------------------------------
  ; seperate indice into groups, index in each group is monotonica in
  ; asending order
  ; examples:
  ; 1-D array --> (iStart, iEnd, iLength)
  ; (/1,2,3,...,1000/)  --> (1, 1000, 1001)
  ; (/3,4,5,1,2,9/) --> (3, 5, 3), (1, 2, 2), (9, 9, 1)
  undef("iGroup")
  function iGroup(x[*]:integer)
  local nx, diff, mygroup, pos_group_start, pos_group_end
  begin
    nx  = _(x)
    diff = new(nx, integer)
    diff(nx - 1) = 2 ; arbitrary integer != 1
    if (nx .gt. 1) then
      diff(0:nx - 2) = x(1:nx - 1) - x(0:nx-2)
    end if

    pos_group_end   = ind(diff .ne. 1)
    mygroup           = _(pos_group_end)
    pos_group_start = new(mygroup, integer)

    pos_group_start(0) = 0
    ; mygroup start position is next to the previous end position
    if (mygroup .gt. 1) then
      pos_group_start(1:mygroup-1) = pos_group_end(0:mygroup-2) + 1
    end if

    mygroup@iStart  = x(pos_group_start)
    mygroup@iEnd    = x(pos_group_end)
    mygroup@iLength = pos_group_end - pos_group_start + 1
    return(mygroup)
  end

  ; given a 2D variable of dim (/m, n/), return a [2]x[m]x[n] matrix
  ; containing the X and Y indice for each value
  undef("ind_matrix")
  function ind_matrix(dim[2]:integer)
  local xy
  begin
    xy  = new((/2,dim(0),dim(1)/), "integer")
    xy(0,:,:)=conform_dims(dim, ispan(0,dim(0)-1,1), 0) ; x indice
    xy(1,:,:)=conform_dims(dim, ispan(0,dim(1)-1,1), 1) ; y indice
    return(xy)
  end

  ; find X and Y indices in a 2D array where the input is True
  ; Return Value: R
  ; if all the elements are False, then R = False
  ; else R = True, R@Xi R@Yi are the indices of X and Y, respectively
  undef("ind_2D")
  function ind_2D(p[*][*]:logical)
  local idx, xy, x, y, R
  begin
    if(num(p) .eq. 0) then
      return(False)
    else
      idx = ind(ndtooned(p))
      xy  = ind_matrix(_(p))
      x   = ndtooned(xy(0, :, :))
      y   = ndtooned(xy(1, :, :))

      R     = True
      R@Xi  = x(idx)
      R@Yi  = y(idx)
      return(R)
    end if
  end

; NCL 6.1.0 beta introduced new function reshape
if(.not. isdefined("reshape"))
  import("reshape")
end if
