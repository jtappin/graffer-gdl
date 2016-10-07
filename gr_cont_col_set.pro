;+
; GR_CONT_COL_SET
;	Convert a list of contour colours to a string array.
;
; Usage:
;	cstr = gr_cont_col_set(clist)
;
; Returns:
;	A string array with the contour colours, or an empty string.
;
; Argument:
;	cstr	list	A list of contour colours, elements are
;			integer scalars or 3 element byte arrays.
;
; History:
;	Original: 7/10/16; SJT
;-

function gr_cont_col_set, clist
  ncols = n_elements(clist)

  if ~obj_valid(clist) || ncols eq 0 then return, ''

  rv = strarr(ncols)

  for j = 0, ncols-1 do begin
     tmp = clist[j]
     case n_elements(tmp) of
        0: rv[j] = ''
        1: rv[j] = string(tmp, format = "(i0)")
        3: rv[j] = string(tmp, format = "(3i4)")
        2: begin
           rv[j] = string(tmp[0], format = "(i0)")
           message, /cont, $
                    "Invalid 2-element list element, using first " + $
                    "element of it"
        end
        else: begin
           rv[j] = string(tmp[0:2], format = "(3i4)")
           message, /cont, $
                    "Too many elements in list, using first 3"
        end
     endcase
  endfor
  return, rv
end
