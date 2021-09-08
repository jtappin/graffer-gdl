pro Gr_fra2norm, xf, yf, xn, yn, invert=invert

;+
; GR_FRA2NORM
;	Convert "Frame" coordinates to normalized coordinates
;
; Usage:
;	gr_fra2norm, xf, yf, xn, yn
;
; Arguments:
;	xf, yf	float	input	X & Y coordinates in "Frame" system
;	xn, yn	float	output	X & Y coordinates in normalized
;				system.
;
; Keyword:
;	invert	??	input	If set, then take normalized
;				coordinates and return frame coords
;
; History:
;	Original: 30/1/97; SJT
;	Updated to use gr_coord_convert: 27/1/12; SJT
;-

if (!X.type) then xc = 10^!X.crange $
else xc = !X.crange
if (!Y.type) then yc = 10^!Y.crange $
else yc = !Y.crange

gr_coord_convert, xc, yc, fcx, fcy, /data, /to_norm
rx = fcx[1]-fcx[0]
ry = fcy[1]-fcy[0]

if (keyword_set(invert)) then begin
    xn = (xf - fcx[0])/rx
    yn = (yf - fcy[0])/ry
endif else begin
    xn = xf*rx + fcx[0]
    yn = yf*ry + fcy[0]
endelse

end
