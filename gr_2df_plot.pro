pro Gr_2df_plot, pdefs, i, csiz, grey_ps = grey_ps

;+
; GR_2DF_PLOT
;	Display a 2-d function in GRAFFER
;
; Usage:
;	gr_2df_plot, pdefs, i
;
; Argument:
;	pdefs	struct	input	The Graffer control structure.
;	i	int	input	Which 
;	csiz	float	input	Charsize scaling (hardcopy only).
;
; Keyword:
;	grey_ps		input	If set & non-zero, then the plot is to
;				a PS device without the COLOUR option.
;
; History:
;	Original: 10/12/96; SJT
;	Made unique in 8.3: 11/2/97; SJT
;	Skip if inadequate colours: 8/5/97; SJT
;	Convert handles to pointers: 27/6/05; SJT
;	Support colour inversion: 26/6/07; SJT
;	Add support for a second Y-scale: 22/12/11; SJT
;	Contour levels etc. become pointers: 11/1/12; SJT
;	Handle hidden datasets: 26/1/12; SJT
;-

  data = *pdefs.data
  if not ptr_valid(data[i].xydata) then return
  if (data[i].zopts.format eq 2) then return

  yaxis = pdefs.y_right and data[i].y_axis eq 1

  xrange = !X.crange
  if (pdefs.xtype) then xrange = 10^xrange
  yrange = !Y.crange
  if (pdefs.ytype and yaxis eq 0) or (pdefs.ytype_r and yaxis eq 1) then $
     yrange = 10^yrange

  if (data[i].zopts.format eq 1 and $
      pdefs.short_colour and $
      not keyword_set(grey_ps)) then return

  xydata = *data[i].xydata

  xmin = xrange(0)
  xmax = xrange(1)
  ymin = yrange(0)
  ymax = yrange(1)
  if (xydata.range(0, 0) ne xydata.range(1, 0)) then begin
     xmin = xmin > xydata.range(0, 0)
     xmax = xmax < xydata.range(1, 0)
  endif

  if (xydata.range(0, 1) ne xydata.range(1, 1)) then begin
     ymin = ymin > xydata.range(0, 1)
     ymax = ymax < xydata.range(1, 1)
  endif

  if (pdefs.xtype) then begin
     xmin = alog10(xmin)
     xmax = alog10(xmax)
     x = 10^(dindgen(data[i].ndata) * (xmax-xmin) $
             /  float(data[i].ndata-1) + xmin)
  endif else x = dindgen(data[i].ndata) * (xmax-xmin) $
                 /  float(data[i].ndata-1) + xmin

  if (pdefs.ytype) then begin
     ymin = alog10(ymin)
     ymax = alog10(ymax)
     y = 10^(dindgen(data[i].ndata2) * (ymax-ymin) $
             /  float(data[i].ndata2-1) + ymin)
  endif else y = dindgen(1, data[i].ndata2) * (ymax-ymin) $
                 /  float(data[i].ndata2-1) + ymin

  xx = x
  yy = y(*)

  x = x(*, intarr(data[i].ndata2))
  y = y(intarr(data[i].ndata), *)

  z = 0.                        ; Need to define z before we use it.

  iexe = execute('z = '+xydata.funct)
  s = size(z)

  if (s(0) ne 2) then graff_msg, pdefs.ids.message, $
                                 "Function:"+xydata.funct+" does not return a 2-D array" $
  else if (data[i].zopts.format eq 0) then begin
     if (data[i].zopts.set_levels) then begin
        levels = *(data[i].zopts.levels) 
        nl = n_elements(levels)
     endif else begin
        if (data[i].zopts.n_levels eq 0) then nl = 6 $
        else nl = data[i].zopts.n_levels
        rg = (max(z, min = mn, /nan)-mn)
        if (rg eq 0.) then begin
           graff_msg, pdefs.ids.message, 'Flat dataset - not able to ' + $
                      'contour'
           goto, restore
        endif
        levels = rg * (dindgen(nl)+.5)/nl + mn
     endelse

     
     if (data[i].zopts.label ne 0 and n_elements(nl) eq 1) then begin
        labels = (indgen(nl) - $
                  data[i].zopts.label/2) mod data[i].zopts.label eq 0
     endif else labels = 0
     
     if ptr_valid(data[i].zopts.colours) then colours = $
        *(data[i].zopts.colours)
     if ptr_valid(data[i].zopts.style) then linestyle = $
        *(data[i].zopts.style) 
     if ptr_valid(data[i].zopts.thick) then thick = $
        *(data[i].zopts.thick) 

     ccsize = pdefs.charsize*data[i].zopts.charsize*0.75*csiz

     contour, z, xx, yy, /overplot, /follow, $
              levels = levels, c_linestyle = linestyle, $
              c_colors = colours, c_thick = thick, $
              fill = data[i].zopts.fill eq 1b, downhill = $
              data[i].zopts.fill eq 2b, c_labels = labels, c_charsize $
              = ccsize
     
  endif else begin
     cflag = 0b
     if (keyword_set(grey_ps)) then colour_range = [0, 255] $
     else if (!d.n_colors gt 256 or !d.name eq 'PS') then begin
        colour_range = [0, 255]
        if (data[i].zopts.ctable gt 0) then $
           graff_ctable, data[i].zopts.ctable-1 $
        else graff_ctable, pdefs.ctable
        cflag = 1b
     endif else colour_range = [pdefs.transient.colmin, $
                                pdefs.transient.colmin+127 < !D.n_colors-1]
     gr_display_img, z, xx, yy, range = data[i].zopts.range, $
                     colour_range = colour_range, pixel_size = $ $
                     data[i].zopts.pxsize, logarithmic = $
                     data[i].zopts.ilog, inverted = $
                     data[i].zopts.invert, missing = data[i].zopts.missing
     if cflag then graff_colours, pdefs
     gr_pl_axes, pdefs, csiz, /overlay
     if pdefs.y_right then gr_pl_axes, pdefs, csiz, /overlay, /secondary
  endelse

Restore:

end
