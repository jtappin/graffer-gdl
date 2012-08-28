function Gr_lon_val, tag_val, num

;+
; GR_LON_VAL
;	Return long value associated with a tag
;
; Return value:
;	value	long	The value associated with the tag.
;
; Arguments:
;	tag_val	string	input	The string containing the tag value.
;	num	int	input	How many elements the value has.
;
; History:
;	Original: 5/11/96; SJT
;	Made unique in 8.3: 11/2/97; SJT
;-

if (num eq 1) then val = 0l $
else val = lonarr(num)

reads, tag_val, val

return, val
end
