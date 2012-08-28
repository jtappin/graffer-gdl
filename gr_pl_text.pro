pro Gr_pl_text, text, csiz, no_null=no_null

;+
; GR_PL_TEXT
;	Plot text string in GRAFFER.
;
; Usage:
;	gr_pl_text, text, csiz[, /no_null]
;
; Arguments:
;	text	struct	input	A  GRAFFER text structure.
;	csiz	float	input	The character size to use as a
;				multiplier to the pdefs sizes (for
;				hardcopies)
;
; Keyword:
;	no_null		input	If set, then don't plot null text
;				strings as "<NULL>"
;
; History:
;	Extracted from GR_PLOT_OBJECT: 12/12/96; SJT
;	Made unique in 8.3: 11/2/97; SJT
;-

opf = !p.font
!P.font = text.ffamily
if (strlen(text.text) gt 0) then  $
  tf = '!'+string(text.font, format = "(I0)")+ $
  text.text+'!3' $
else if (not keyword_set(no_null)) then $
  tf = '!3<NULL>!3' $
else tf = ''

gr_coord_convert, text.x, text.y, tx, ty, /to_norm, data = text.norm $
  eq 0, region = text.norm eq 1, frame = text.norm eq 2

xyouts, tx, ty, tf, color = text.colour, $
  charsize = text.size*csiz, orient = text.orient, align $
  = text.align, charthick = text.thick, /norm

if ~keyword_set(no_null) then begin
    usersym, [-.5, 0., 0., 0., .5], [-.866, 0., -1.77, 0., -.866]
    plots, /norm, psym = 8, tx, ty
endif

!p.font = opf

end
