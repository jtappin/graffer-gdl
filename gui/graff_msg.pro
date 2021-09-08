pro Graff_msg, mwid, message, help=help

;+
; GRAFF_MSG
;	Display a message in the graffer message box
;
; Usage:
;	graff_msg, mwid, message
;
; Arguments:
;	mwid	long	input	Widget ID of message box
;	message	string	input	The message
;
; History:
;	Original: 18/8/95; SJT
;	Change to take widget ID as first argument: 12/5/95; SJT
;-

if (widget_info(mwid, /valid)) then $
  widget_control, mwid, set_value = message $
else print, message

end
