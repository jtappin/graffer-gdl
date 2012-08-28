pro Gr_td_mode, value, pdefs

;+
; GR_TD_MODE
;	Swap between text and draw modes of the mouse
;
; Usage:
;	gr_td_mode, value, pdefs
;
; Arguments:
;	value	int	input	The mode (0 = draw, 1 = text)
;	pdefs	struct	input	The GRAFFER control structure
;
; History:
;	Original (extracted from GRAFFER): 27/1/97; SJT
;-


gr_cross_hair, pdefs            ; Erase any existing cross hairs.

if (value) then begin
    widget_control, pdefs.ids.draw, set_uvalue = 'WRITE', $
      /draw_button_events, /track
endif else begin
    widget_control, pdefs.ids.draw, set_uvalue = 'DRAW', $
      draw_button_events = (*pdefs.data)[pdefs.cset].medit, track = $
      (*pdefs.data)[pdefs.cset].medit 
endelse
pdefs.transient.mode = value

end
