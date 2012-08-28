function Gr_int_val, tag_val, num

;+
; GR_INT_VAL
;	Return int value associated with a tag
;
; Return value:
;	value	int	The value associated with the tag.
;
; Arguments:
;	tag_val	string	input	The string containing the tag value.
;	num	int	input	How many elements the value has.
;
; History:
;	Original: 5/11/96; SJT
;-

if (num eq 1) then val = 0 $
else val = intarr(num)

reads, tag_val, val

return, val
end
