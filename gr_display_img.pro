pro Gr_display_img, zin, xin, yin, range = range, $
                    colour_range = colour_range, $ 
                    pixel_size = pixel_size,  $
                    scale_mode = scale_mode, $
                    inverted = inverted,  $
                    missing = missing, $
                    logarithmic = logarithmic

;+
; GR_DISPLAY_IMG
;	Colour/greyscale image display for GRAFFER
;
; Usage:
;	gr_display_img, zi, xin, yin, range=range, $
;	colour_range=colour_range pixel_size=pixel_size
;
; Arguments:
;	zin	float	input	The data to be displayed
;	xin	float	input	The X coordinates of the data.
;	yin	float	input	The Y coordinates of the data.
;
; Keywords:
;	range	float	input	The range from "black" to "white"
;	colour. int	input	The range of colour indices to use.
;	pixel.  float	input	For devices with scalable pixels, the
;				size of a displayed pixel.
;	scale_mode int	input	Scaling mode, 0/absent = linear, 1 =
;				log, 2 = square_root
;	/inverted	input	If set, then plot from "white" to "black".
;	missing	float	input	A value to use for output pixels that don't
;				map to input pixels.
;
; History:
;	Original: 10/12/96; SJT
;	Add code to clip to the viewport: 12/12/96; SJT
;	Modify to handle 2-D X or Y arrays: 10/7/05; SJT
;	Support colour inversion: 26/6/07; SJT
;	Updated to use gr_coord_convert: 27/1/12; SJT
;	Add missing keyword to set a value if we are triangulating:
;	11/7/12; SJT
;	Fix failure to display when axis reversed: 24/8/12; SJT
;	Replace logarithmic with scale_mode: 18/11/15; SJT
;-

  if n_elements(logarithmic) ne 0 then graff_msg, 0l, $
     "The LOGARTITHMIC key is obsolete, please use SCALE_MODE instead"

  if n_elements(scale_mode) ne 0 then mode = scale_mode $
  else if n_elements(logarithmic) ne 0 then mode = logarithmic $
  else mode = 0

  if (!D.flags and 1) then begin ; PS or similar with scalable pixels
     if (not keyword_set(pixel_size)) then pixel_size = 0.5 ; default
                                ; 0.5 mm pixels
     scfac = 10./([!D.x_px_cm, !D.y_px_cm] * pixel_size)
  endif else scfac = [1, 1]

;	If x &/| y are 1-D make them 2-D to unify everything.

  sx = size(xin)
  sy = size(yin)
  sz = size(zin)
  tflag = sx[0] eq 2 or sy[0] eq 2

  if tflag then begin
     if sx[0] eq 1 then x = xin[*, intarr(sz[2])] $
     else x = xin
     if sy[0] eq 1 then y = transpose(yin[*, intarr(sz[1])]) $
     else y = yin
  endif

  mnx = min(xin, max = mxx)
  mny = min(yin, max = mxy)


;	Select out those parts which are within the viewport

  cxmax = max(!x.crange, min = cxmin)
  cymax = max(!y.crange, min = cymin)

  if (!X.type eq 1) then begin
     locsx = where(xin ge 10^cxmin and xin le 10^cxmax, nx)
     mnx = mnx > 10^!x.crange[0]
     mxx = mxx < 10^!x.crange[1]
  endif else begin
     locsx = where(xin ge cxmin and xin le cxmax, nx)
     mnx = mnx > !x.crange[0]
     mxx = mxx < !x.crange[1]
  endelse

  if (!Y.type eq 1) then begin
     locsy = where(yin ge 10^cymin and yin le 10^cymax, ny)
     mny = mny > 10^!y.crange[0]
     mxy = mxy < 10^!y.crange[1]
  endif else begin
     locsy = where(yin ge cymin and yin le cymax, ny)
     mny = mny > !y.crange[0]
     mxy = mxy < !y.crange[1]
  endelse

  if (nx le 1 or ny le 1) then return ; Image is wholly outside the VP
                                ; (or just one row or column in it)

  xrange = [mnx, mxx]
  yrange = [mny, mxy]

  gr_coord_convert, xrange, yrange, xcorn, ycorn, /data, /to_device
  xcorn = round(xcorn*scfac[0])
  ycorn = round(ycorn*scfac[1])
  dvxsize = xcorn[1]-xcorn[0]
  dvysize = ycorn[1]-ycorn[0]
  cmxsize = dvxsize/(!d.x_px_cm*scfac[0])
  cmysize = dvysize/(!d.y_px_cm*scfac[1])
  cmxll = xcorn[0]/(!d.x_px_cm*scfac[0])
  cmyll = ycorn[0]/(!d.y_px_cm*scfac[1])

  if tflag then begin
     if (total(~finite(x))+total(~finite(y)) ne 0) then begin
        junk = dialog_message(["Coordinates contain non-finite", $
                               "values. Cannot warp to a plane.", $
                               "please use contouring, or fix", $
                               "the coordinates"], $
                              /error)
        return
     endif
     triangulate, x, y, triangles, tol = 1e-12*(max(abs(x)) > $
                                                max(abs(y)))
     case mode of
        0: zz = trigrid(x, y, zin, triangles, $
                        [(mxx-mnx)/dvxsize, (mxy-mny)/dvysize], $
                        [mnx, mny, mxx, mxy],  missing = missing)
        1: zz = trigrid(x, y, alog10(zin), triangles, $
                        [(mxx-mnx)/dvxsize, (mxy-mny)/dvysize], $
                        [mnx, mny, mxx, mxy],  missing = missing)
        2: zz =  trigrid(x, y, sqrt(zin), triangles, $
                         [(mxx-mnx)/dvxsize, (mxy-mny)/dvysize], $
                         [mnx, mny, mxx, mxy],  missing = missing)
     endcase
  endif else begin
     x = xin(locsx)
     y = yin(locsy)
     z = zin(locsx, *)
     z = z(*, locsy)
     gr_coord_convert, (findgen(dvxsize)+xcorn[0]) / scfac[0], $
                       fltarr(dvxsize), xd, junk, /device, /to_data

     gr_coord_convert, fltarr(dvysize),  $
                       (findgen(dvysize)+ycorn[0]) / scfac[1], $
                       junk, yd, /device, /to_data

     sz = size(z)
     xx = interpol(findgen(sz(1)), x, xd)
     yy = interpol(findgen(sz(2)), y, yd)
     case mode of
        0: zz = bilinear(z, xx, yy)
        1: zz = bilinear(alog10(z), xx, yy) 
        2: zz = bilinear(sqrt(z), xx, yy) 
     endcase
  endelse

  if (not keyword_set(colour_range)) then colours = [16, !D.n_colors-1] $
  else colours = colour_range


  if n_elements(range) eq 0 || (range(0) eq range(1)) then begin
     if keyword_set(inverted) then zrange = [max(zin, min = mnz, $
                                                 /nan), mnz] $
     else zrange = [min(zin, max = mxz, /nan), mxz] 
  endif else begin
     zrange = range
     if keyword_set(inverted) then zrange = zrange[[1, 0]]
  endelse

  case mode of
     0:
     1: zrange = alog10(zrange)
     2: zrange = sqrt(zrange)
  endcase
  locs = where(finite(zz) eq 0, nnan)

  if zrange[0] gt zrange[1] then $
     img = colours[1]-bytscl(zz, min = zrange(1), max = zrange(0), top = $
                             colours(1)-colours(0)) $
  else $
     img = bytscl(zz, min = zrange(0), max = zrange(1), top = $
                  colours(1)-colours(0)) + colours(0)
;if (nnan gt 0) then img[locs] = 0b

  if (!d.flags and 1) then $
     tv, img, cmxll, cmyll, xsize = cmxsize, ysize = cmysize, /centi $ 
  else $
     tv, img, xcorn[0], ycorn[0] ;corners(0, 0), corners(1, 0)

end

