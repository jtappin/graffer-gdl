function gr_find_program, name, return_path = return_path

;+
; GR_FIND_PROGRAM
;	Find a program in the user's current $PATH.
;
; Usage:
;	isprog = gr_find_program(name)
;     or:
;	ppath = gr_find_program(name, /return_path)
;
; Returns:
;	Either a boolean value, indicating whether the program is
;	found, or the path to the program
;
; Argument:
;	name	string	The name of the program to find.
;
; Keyword:
;	/return_path	If set, then the path to the program is
;			returned, otherwise a logical value is
;			returned.
;
; History:
;	Extracted from gr_find_viewer & expanded: 23/9/16; SJT
;-

  if n_elements(name) eq 1 then begin
     spawn, /sh, 'which '+name, wh
     if keyword_set(return_path) then return, wh[0]
     return, strlen(wh[0]) gt 0
  endif else begin
     nn = n_elements(name)
     if keyword_set(return_path) then rv = strarr(nn) $
     else rv = bytarr(nn)
     for j = 0, nn-1 do begin
        spawn, /sh, 'which '+name[j], wh
        if keyword_set(return_path) then rv[j] = wh[0] $
        else rv[j] = strlen(wh[0]) gt 0
     endfor
     return, rv
  endelse
end
