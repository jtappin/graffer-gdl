;+
; IS_GDL
;	Are we running GDL or IDL?
;
; Usage:
;	gdl = is_gdl()
;
; Returns:
;	1 if runnning GDL (the !GDL system variable is present), 0
;	otherwise.
;
; Note:
;	If you do something like defining a !GDL system variable in
;	IDL the routine will get the wrong answer.
; 
; History:
;	Original: 18/8/21; SJT
;-

function is_gdl

  defsysv, '!gdl', exist = rv
  return, rv

end
