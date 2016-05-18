pro Gr_2dd_plot, pdefs, i, csiz, grey_ps = grey_ps, shaded = shaded

;+
; GR_2DD_PLOT
;	Plot a 2-D Data in graffer
;
; Usage:
;	gr_2dd_plot, pdefs, i
;
; Argument:
;	pdefs	struct	input	The Graffer control structure.
;	i	int	input	Which 
;	csiz	float	input	Charsize scaling (hardcopy only).
;
; Keyword:
;	/grey_ps	input	If set & non-zero, then the plot is to
;				a PS device without the COLOUR option.
;	shaded	byte	output	Returns 1 if filled contours or an
;				image are drawn
;
; History:
;	Original: 10/12/96; SJT
;	Made unique in 8.3: 11/2/97; SJT
;	Skip if inadequate colours: 8/5/97; SJT
;	Replace handles with pointers: 27/6/05; SJT
;	Support colour inversion: 26/6/07; SJT
;	Add support for a second Y-scale: 22/12/11; SJT
;	Contour levels etc. become pointers: 11/1/12; SJT
;	Handle hidden datasets: 26/1/12; SJT
;	Send back flag if axes need redrawing: 20/1/16; SJT
;-

  data = *pdefs.data
  if not ptr_valid(data[i].xydata) then return

  xydata = *data[i].xydata
  z = *xydata.z
  x = *xydata.x
  y = *xydata.y

  if (data[i].zopts.format eq 0) then begin
     if (data[i].zopts.set_levels) then begin
        levels = *(data[i].zopts.levels) 
        nl = n_elements(levels)
     endif else begin
        if (data[i].zopts.n_levels eq 0) then nl = 6 $
        else nl = data[i].zopts.n_levels
        locs = where(finite(z), nfin)
        if (nfin ne 0) then rg = (max(z(locs), min = mn)-mn) $
        else rg = 0.
        
        if (rg eq 0.) then begin
           graff_msg, pdefs.ids.message, 'Flat dataset - not able to ' + $
                      'contour'
           return
        endif
        levels = rg * (dindgen(nl)+.5)/nl + mn
     endelse
     
     if (data[i].zopts.label ne 0 and n_elements(nl) eq 1) then begin
        labels = (indgen(nl) - $
                  data[i].zopts.label/2) mod data[i].zopts.label eq 0
     endif else labels = 0

     if ptr_valid(data[i].zopts.colours) then begin
        colours = *(data[i].zopts.colours)
        ncol = n_elements(colours)
        lcolours = lonarr(ncol)
        for j = 0, ncol-1 do lcolours[j] = graff_colours(colours[j])
     endif
     if ptr_valid(data[i].zopts.style) then linestyle = $
        *(data[i].zopts.style) 
     if ptr_valid(data[i].zopts.thick) then thick = $
        *(data[i].zopts.thick) 

     ccsize = pdefs.charsize*data[i].zopts.charsize*0.75*csiz

     contour, z, x, y, /overplot, /follow, $
              levels = levels, c_linestyle = linestyle, $
              c_colors = lcolours, c_thick = thick,  $
              fill = data[i].zopts.fill eq 1b, downhill = $
              data[i].zopts.fill eq 2b, c_labels = labels, c_charsize $
              = ccsize
     if data[i].zopts.fill eq 1b then shaded = 1b ; Don't clear it.
  endif else if (data[i].zopts.format eq 1) then begin
     if (~keyword_set(grey_ps)) then begin
        if (data[i].zopts.ctable gt 0) then begin
           table = data[i].zopts.ctable-1
           gamma = data[i].zopts.gamma 
        endif else begin
           table = pdefs.ctable
           gamma = pdefs.gamma
        endelse
     endif
     gr_display_img, z, x, y, $
                     range = data[i].zopts.range, $
                     pixel_size = data[i].zopts.pxsize, $
                     scale_mode = data[i].zopts.ilog, $
                     inverted = data[i].zopts.invert, $
                     missing = data[i].zopts.missing, $
                     ps_grey = grey_ps, $
                     table = table, $
                     gamma = gamma

     shaded = 1b
  endif

end
