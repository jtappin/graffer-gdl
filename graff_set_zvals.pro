pro graff_set_zvals, pdefs

;+
; GRAFF_SET_ZVALS
;	Setup the values of the graffer widgets specific to 2-D datasets
;
; Usage:
;	graff_set_zvals, pdefs
;
; Argument:
;	pdefs	struct	input	The graffer control structure
;
; History:
; 	Original: 13/12/11; SJT
; 	Handle hidden datasets: 26/1/12; SJT
;	Add non-linear contour level maps: 12/10/16; SJT
;-

; First make sure uninitialzed things are initialized.
  zopts = (*pdefs.data)[pdefs.cset].zopts
  fflag = 0b
  if (zopts.n_cols eq 0) then begin
     zopts.n_cols = 1
     zopts.colours = list(1)
     fflag = 1b
  endif
  if (zopts.n_thick eq 0) then begin
     zopts.n_thick = 1
     zopts.thick = ptr_new(1.)
     fflag = 1b
  endif
  if (zopts.n_sty eq 0) then begin
     zopts.n_sty = 1
     zopts.style = ptr_new(0)
     fflag = 1b
  endif
  if fflag then (*pdefs.data)[pdefs.cset].zopts = zopts

  zids = pdefs.ids.zopts

  localct = !d.n_colors gt 256

; Map the proper menu set.

  fmt = zopts.format
  widget_control, zids.bases[0], map = fmt eq 0
  widget_control, zids.bases[1], map = fmt eq 1

; Set the contour menu

  iexpl = zopts.set_levels
  widget_control, zids.c_auto, set_droplist_select = iexpl
  widget_control, zids.cl_base[0], map = ~iexpl
  widget_control, zids.cl_base[1], map = iexpl

  if (iexpl and ptr_valid(zopts.levels)) then $
     l0 = *(zopts.levels)  $
  else l0 = 0.d0
  widget_control, zids.c_levels, set_value = l0


  widget_control, zids.c_nlevels, set_value = zopts.n_levels
  widget_control, zids.c_map, set_droplist_select = zopts.lmap

  widget_control, zids.c_colour, set_value = zopts.colours
  widget_control, zids.c_thick, set_value = *(zopts.thick)
  widget_control, zids.c_style, set_value = *(zopts.style)

  widget_control, zids.c_type, set_droplist_select = zopts.fill

  widget_control, zids.c_label, set_value = zopts.label
  if (zopts.charsize eq 0.) then zopts.charsize = 1.
  widget_control, zids.c_charsize, set_value = zopts.charsize, sensitive $
                  = zopts.label ne 0

; And the image menu

  if localct then begin
     ctable = zopts.ctable-1
     gamma = zopts.gamma
  endif else begin
     ctable = pdefs.ctable
     gamma = pdefs.gamma
  endelse

  for j = 0, 1 do $
     widget_control, zids.i_range[j], set_value = zopts.range[j]

  widget_control, zids.i_log, set_droplist_select = zopts.ilog
  widget_control, zids.i_invert, set_button = zopts.invert

  widget_control, zids.i_pxsz, set_value = zopts.pxsize
  widget_control, zids.i_ctable, set_list_select = ctable
  widget_control, zids.i_gamma, set_value = gamma
  widget_control, zids.i_missid, set_value = zopts.missing


end
