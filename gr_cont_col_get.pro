;+
; GR_CONT_COL_GET
;	Convert a string describing a set of contour colours to a
;	list.
;
; Usage:
;	clist = gr_cont_col_get(cstr)
;
; Returns:
;	A LIST of contour colours or 0 if it cannot do the conversion.
;
; Argument:
;	cstr	string	An array of contour colours, either a single
;			integer value or 3 integers separated by
;			spaces and/or commas.
;
; History:
;	Original: 7/10/16; SJT
;-

function gr_cont_col_get, cstr
  ncols = n_elements(cstr)

  rv = list()

  on_ioerror, fail

  for j = 0, ncols-1 do begin
     tmp = strsplit(cstr[j], '	 ,', /extr, count = nn)
     case nn of
        0: 
        1: rv.add, fix(tmp[0])
        3: begin
           ttmp = bytarr(3)
           reads, tmp, ttmp
           rv.add, ttmp
        end
        else: return, 0
     endcase
  endfor

  if n_elements(rv) eq 0 then return, 0
  return, rv

fail:
  return, 0

end
