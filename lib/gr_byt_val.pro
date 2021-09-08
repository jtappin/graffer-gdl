function Gr_byt_val, tag_val, num

;+
; GR_BYT_VAL
;	Return byte value associated with a tag
;
; Return value:
;	value	byte	The value associated with the tag.
;
; Arguments:
;	tag_val	string	input	The string containing the tag value.
;	num	int	input	How many elements the value has.
;
; History:
;	Original: 5/11/96; SJT
;	Made unique in 8.3: 11/2/97; SJT
;-

if (num eq 1) then val = 0b $
else val = bytarr(num)

reads, tag_val, val

return, val
end
