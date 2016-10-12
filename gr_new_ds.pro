function gr_new_ds, pdefs, nds

;+
; GR_NEW_DS
;	Create a new properly initialized graffer dataset.
;
; Usage:
;	ds = gr_new_ds(pdefs)
;
; Argument:
;	pdefs	struct	input	The graffer control structure.
;
; Returns:
;	A {graff_data} structure with proper initializations.
;
; History:
; 	Original: 10/1/12; SJT
; 	Add min & max values: 4/3/15; SJT
;	Add non-linear contour level maps: 12/10/16; SJT
;-

  if n_params() eq 2 then $
     ds = replicate({graff_data}, nds) $
  else ds = {graff_data}

  ds[*].pline = 1
  ds[*].symsize =  1.
  ds[*].colour =   1
  ds[*].thick =    1.
  ds[*].zopts.n_levels = 6
  ds[*].zopts.lmap = 0
  ds[*].zopts.n_cols =  1
  ds[*].zopts.colours = list(1)
  ds[*].zopts.n_sty = 1
  ds[*].zopts.style = ptr_new(0)
  ds[*].zopts.n_thick =  1
  ds[*].zopts.thick = ptr_new(1.)
  ds[*].zopts.pxsize =  0.5

  ds[*].medit = pdefs.opts.mouse

  ds[*].max_val = !values.d_nan
  ds[*].min_val = !values.d_nan

  return, ds

end
