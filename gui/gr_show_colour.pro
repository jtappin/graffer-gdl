pro gr_show_colour, pdefs

;+
; GR_SHOW_COLOUR
;	Update the colour patch for the current DS.
;
; Usage:
;	gr_show_colour, pdefs
;
; Argument:
;	pdefs	struct	in	The Graffer data & control structure.
;
; History:
;	Original: 24/8/16; SJT
;-

  cind = (*pdefs.data)[pdefs.cset].colour
  if cind eq -1 then widget_control, pdefs.ids.dscolour_base, map = 0 $
  else begin
     widget_control, pdefs.ids.dscolour_base, map = 1
     wset, pdefs.ids.dscolour_win
     if cind eq -2 then clr = (*pdefs.data)[pdefs.cset].c_vals $
     else clr = graff_colours(cind, /triple)
     img = bytarr(3, !d.x_size, !d.y_size)
     for j = 0, 2 do img[j, *, *] = clr[j]
     tv, img, true = 1
     wset, pdefs.ids.windex
  endelse

end
