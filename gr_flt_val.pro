function Gr_flt_val, tag_val, num

;+
; GR_FLT_VAL
;	Return floating point value associated with a tag
;
; Return value:
;	value	float	The value associated with the tag.
;
; Arguments:
;	tag_val	string	input	The string containing the tag value.
;	num	int	input	How many elements the value has.
;
; History:
;	Original: 5/11/96; SJT
;	Made unique in 8.3: 11/2/97; SJT
;-

if (num eq 1) then val = 0. $
else val = fltarr(num)

reads, tag_val, val

return, val
end
