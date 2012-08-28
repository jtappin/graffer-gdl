function Graff_decode_xy, txt, nt

;+
; GRAFF_DECODE_XY
;	Decode an array of X-Y[-err-err] values
;
; Usage:
;	data = graff_decode_xy(txt,nt)
;
; Return Value:
;	data	float	(nt x m) array of values & errors (nt = 2, 3 or
;			4)
;
; Arguments:
;	txt	string	input	String array of data values. 1 element
;				for each value with x y and optionally
;				1 or 2 error limits. The x value may
;				be a time in the form h:m:s.
;	nt	int	output	The number of fields in each element.
;
; History:
;	Original: 29/7/96; SJT
;	Make loop limit a long: 24/2/11; SJT
;-


dtxt = strtrim(strcompress(txt), 2)
junk = strsplit(dtxt[0], ' ',  count = nt)
nact = n_elements(dtxt)

xy_data = dblarr(nt, nact > 2)

on_ioerror, badfloat

for j = 0l, nact - 1 do begin
    dstxt = strsplit(dtxt[j], ' ',  /extr,  count = nl)
    if nl ne nt then goto, badfloat

    if (strpos(dstxt(0), ':') ne -1) then begin
        tstxt = str_sep(dstxt(0), ':')
        xy_data(0, j) = total(double(tstxt)/[1., 60., 3600.])
        xy_data(1:*, j) = double(dstxt(1:*))
    endif else xy_data(*, j) = double(dstxt)
endfor  

return, xy_data

Badfloat:

nt = -1
return, 0

end



