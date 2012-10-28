function reshape(x, dims)
local xdim
begin
  xdim = dimsizes(x)
  if (product(xdim) .ne. product(dims)) then
    print("Can't reshape array because sizes are not equal.")
    exit
  else
    if (dimsizes(xdim) .eq. 1) then
      return(onedtond(x, dims))
    else
      return(onedtond(ndtooned(x), dims))
    end if
  end if
end
