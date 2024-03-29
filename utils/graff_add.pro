; LICENCE:
; Copyright (C) 1995-2021: SJT
; This program is free software; you can redistribute it and/or modify  
; it under the terms of the GNU General Public License as published by  
; the Free Software Foundation; either version 2 of the License, or     
; (at your option) any later version.                                   

pro Graff_add, file, a1, a2, a3, errors = errors, $
               x_errors = x_errors, y_errors = y_errors, $ 
               x_func = x_func, y_func = y_func, z_func = z_func, $
               funcx = funcx, funcy = funcy, polar = polar, rescale = $
               rescale, $
               display = display, style = style, psym = psym, join = $
               join, symsize = symsize, colour = colour, thick = $
               thick, neval = neval, description = description, frange $
               = frange, sort = sort, graffer = graffer, errtype = $
               errtype, funcz = funcz, ascii = ascii, noclip = noclip, $
               min_val = min_val, max_val = max_val, $
               mouse = mouse, z_format = z_format, z_nlevels = $
               z_nlevels, z_levels = z_levels, z_colours = z_colours, $
               z_style = z_style, z_thick = z_thick, z_range = $
               z_range, z_label = z_label, z_pxsize = z_pxsize, $
               z_invert = z_invert, z_fill = z_fill, z_log = z_log, $
               z_ctable = z_ctable, xy_file = xy_file, z_file = $
               z_file, z_lmap = z_lmap, $
               func_file = func_file, y_axis = y_axis, $
               z_missing = z_missing, z_charsize = z_charsize, z_mode $
               = z_mode

;+
; GRAFF_ADD
;	User-callable interface to add a dataset to a graffer file.
;
; Usage:
;	graff_add, file, [[[z], x,] y, errors=errors, $
;               x_errors = x_errors, y_errors = y_errors, $ 
;               x_func = x_func, y_func = y_func, z_func = z_func, 
;		errtype=errtype, $
;               polar=polar, rescale=rescale, /display, join=join, $
;               style=style, psym=psym, symsize=symsize, colour=colour, $
;               thick=thick, neval=neval, description=description, $
;               frange=frange, /graffer, /ascii, /noclip, $
;               min_val=min_val, max_val=max_val, $
;               mouse=mouse,z_format=z_format, z_nlevels = z_nlevels, $
;               z_lmap=z_lmap, z_levels = $ 
;               z_levels, z_colours = z_colours, z_style = z_style, $
;               z_thick = z_thick, z_range = z_range, z_label = $
;               z_label, z_pxsize = z_pxsize, z_invert = z_invert, $
;               z_fill = z_fill, z_log=z_log, z_ctable = z_ctable, $
;               xy_file = xy_file, z_file = z_file, func_file = $
;               func_file, y_axis=y_axis, z_missing=z_missing, $
;               z_charsize = z_charsize]
;
; Arguments:
;	file	string	input	The graffer file to modify.
;	z	double	input	The Z values for a 2-D dataset (If
;				only 2 arguments are present, then
;				they are treated as X & Y)
;	x	double	input	The x values to add.
;	y	double	input	The y values to add.
;
; Keywords:
;	errors	double	input	Array with errors, 1-d or
;				(m,n). (deprecated) 
;	x_errors dbl	inut	Array with X-axis errors.
;	y_errors dbl	inut	Array with Y-axis errors.
;	errtype string	input	Specify error types as code
;				(e.g. "XXY" for asymmetrical errors in
;				X and symmetric errors in Y). Should
;				not be used when separate, x and y
;				errors are specified.
;	x_func	string	input	Function specification for x = f(y) or
;				x = f(t)
;	y_func	string	input	Function specification for y = f(x) or
;				y = f(t)
;	z_func	string	input	Function specification for z = f(x,y)
;	frange  double	input	The range of x, y or t over which to
;				plot a function
;	polar	int	input	If unset or 0 rectangular, 1 = polar
;				in radians, 2 = polar in degrees.
;	rescale 	input	If set, then reset the scaling of the
;				plot with the autoscale routine.
;	display		input	If set, then display the plot on the
;				current device.
;	style	int	input	The standard IDL linestyle codes
;	psym	int	input	The GRAFFER symbol code - extended IDL
;                                                         symbol
;                                                         codes.
;	join	int	input	The style of joining: 0 - none
;					 	      1 - sloping lines
;						      2 - histogram
;	symsize double	input	The size for the symbols (relative to
;				standard)
;	colour	int	input	Colour number - standard GRAFFER
;                                               colours (which may
;                                               well not work on
;                                               current device).
;				May also be a triple or a long value
;				with a "packed" colour
;	thick	double	input	Line thickness.
;	neval	int	input	The number of times to evaluate a
;				function. (2-elements for funcz)
;	description str input	A description of the data set.
;	sort		input	Whether to sort the values on the X
;				axis.
;	graffer		input	If set, then invoke GRAFFER after
;				adding the dataset.
;	ascii		input	If set, then save as an ASCII GRAFFER
;				file (by default a binary graffer file
;				is generated).
;	noclip		input	If  set, then disable clipping to the
;				axis box.
;	min_val		input	Set a minimum data value to display
;	max_val		input	Set a maximum data value to display
;	mouse	int	input	If explicitly set to zero then
;				disable mouse-editing of the dataset.
;	z_format int	input	For 2-D datasets, select display
;				format (0=contour, 1=colour image)
;	z_nlevels int	input	For 2D datasets, select number of
;				automatic contours
;	z_levels double	input	For 2D datasets, select levels for
;				explicit contours
;	z_lmap  int	input	For 2-D datasets, set the mapping of
;				automatic contour levels. 0=linear,
;				1=log, 2=sqrt
;	z_colours int	input	For 2D datasets, select the colours
;				for the contours
;	z_style	int	input	For 2D datasets, select linestyles for contours
;	z_thick	double	input	For 2D datasets, select line
;				thicknesses for contours
;	z_label	int	input	Specify the interval of contours for labelling.
;	/z_fill		input	If set, then fill the contours.
;	z_range	int	input	For 2-D datasets, specify the cutoff
;				range for image displays
;	z_pxsize double	input	For 2D datasets, specify the pixel
;				size to use in images for PS device.
;	/z_invert	input	For image display, invert the colour
;				table if set.
;	z_mode	int	input	0=linear, 1=log, 2=sqrt. For colour displays.
;	z_ctable int	input	Select a colour table for 2-D display
;				of images.
;	xy_file	string	input	A file with a graffer dataset (x-y plot).
;	z_file	string	input	A file with a graffer dataset (2-D data).
;	func_file string input	A file with a graffer function dataset.
;	y_axis	int	input	Specify which Y axis to use. (0 or 1)
;	z_missing double	input	A missing value to use for warped images.
;	z_charsize double input	The character size (relative to
;				default) for contour labels.
;	
;
; Restrictions:
;	The func<xyz> and file keys and the x,y,z arguments are exclusive.
;	The GRAFFER key overrides the DISPLAY key and the ASCII key.
;
; Side Effects:
;	A graffer file is updated or created.
;	The DISPLAY option will cause your device colour table to be
;	changed.
;
; History:
;	Original: 13/8/96; SJT
;	Fix counting problem for new file: 13/9/96; SJT
;	Add GRAFFER key: 18/9/96; SJT
;	Add support for 2-D datasets: 20/12/96; SJT
;	Support index for X (i.e. filename & 1 arg): 9/1/97; SJT
;	Add ascii key: 15/1/97; SJT
;	Add mouse-editing default option: 13/8/97; SJT
;	Replace handles with pointers: 28/6/05; SJT
;	Add support for 2-D dataset settings: 16/1/09; SJT
;	Add 2-D dataset colour tables: 28/11/11; SJT
;	Add option to read a dataset from a file: 20/12/11; SJT
;	Add option to select secondary Y-axis: 23/12/11; SJT
;	Make errtype match documents, fix leak: 25/1/12; SJT
;	Deprecate func[xyz], replace with [xyz]_func: 3/2/12; SJT
;	Add min_val, max_val: 2/6/15; SJT
;	z_log -> z_mode: 18/11/15: SJT
;	Add non-linear contour level maps: 12/10/16; SJT
;	Allow long/triple colours: 1/3/19; SJT
;	Remove reference to pdefs.opts: 21/5/20; SJT
;	Treat single 2-D array as a Z dataset: 1/9/20; SJT
;	Remove spurious +1 in ctable handling: 13/1/21; SJT
;	Force Y_right to be enabled if a DS on the right axis is
;	added: 29/1/21; SJT
;	Move top level options out of PDEFS: 21/5/20; SJT
;	Treat single 1×n array as 1-D: 8/5/21; SJT
;	Add x_errors, y_errors: deprecate errors: 15/4/22; SJT
;-

;	Check that the necessary inputs are present

  on_error, 2                   ; Return to caller on error

  common graffer_options, optblock

  if keyword_set(funcx) then begin 
     if keyword_set(x_func) then $
        message, /continue, $
                 "Both X_FUNC and the obsolete FUNCX are set, ignoring FUNCX" $
     else begin
        message, /continue, $
                 "FUNCX is obsolete, please use X_FUNC " + $
                 "instead"
        x_func = funcx
     endelse
  endif
  if keyword_set(funcy) then begin 
     if keyword_set(y_func) then $
        message, /continue, $
                 "Both Y_FUNC and the obsolete FUNCY are set, ignoring FUNCY" $
     else begin
        message, /continue, "FUNCY is obsolete, please use Y_FUNC " + $
                 "instead"
        y_func = funcy
     endelse
  endif
  if keyword_set(funcz) then begin 
     if keyword_set(z_func) then $
        message, /continue, $
                 "Both Z_FUNC and the obsolete FUNCZ are set, ignoring FUNCZ" $
     else begin
        message, /continue, "FUNCZ is obsolete, please use Z_FUNC " + $
                 "instead"
        z_func = funcz
     endelse
  endif
  
  if (n_params() ge 2 && (keyword_set(x_func) || keyword_set(y_func) || $
                          keyword_set(z_func))) $
  then message, "May not specify both data and a function"
  if n_params() ge 2 && (keyword_set(xy_file) || keyword_set(z_file) || $
                         keyword_set(func_file)) $
  then message, "May not specify both data and a data file"

  if ((keyword_set(x_func) || keyword_set(y_func)) && keyword_set(z_func)) $
  then message, "May not mix 1 & 2 D function specifiers"

  if (keyword_set(xy_file) && keyword_set(z_file)) then $
     message, "May not specify both 1 & 2 D files"

  if (keyword_set(x_func) || keyword_set(y_func) || $
      keyword_set(z_func)) && $
     (keyword_set(xy_file) || keyword_set(z_file) || $
      keyword_set(func_file)) then $ 
         message, "May not specify a function and a data file"

  z1flag = 0b
  case (n_params()) of
     0: message, "Must specify a GRAFFER file"
     1: if (~keyword_set(x_func) && $
            ~keyword_set(y_func) && $
            ~keyword_set(z_func) && $
            ~keyword_set(xy_file) && $
            ~keyword_set(z_file) && $
            ~keyword_set(func_file)) then $
               message, "Must give data arrays, data file or a " + $
                        "function specification"
     2: begin
        sx = size(a1)
        if sx[0] eq 2 then begin
           if sx[1] eq 1 then begin
              y = reform(double(a1))
              x = dindgen(sx[2])
           endif else if sx[1] eq 2 then begin
              x = double(reform(a1[0, *]))
              y = double(reform(a1[1, *]))
           endif else if sx[2] eq 2 then begin
              x = double(a1[*, 0])
              y = double(a1[*, 1])
           endif else begin
              z = double(a1)
              x = dindgen(sx[1])
              y = dindgen(sx[2])
              z1flag = 1b
           endelse
        endif else if sx[sx[0]+1] eq 6 || sx[sx[0]+1] eq 9 then begin
           x = double(real_part(a1))
           y = double(imaginary(a1))
        endif else begin
           y = double(a1)
           x = dindgen(n_elements(y))
        endelse
     end
     3: begin                   ; 1-D dataset
        x = reform(double(a1), n_elements(a1))
        y = reform(double(a2), n_elements(a2))
     end
     4: begin                   ; 2-D dataset
        z = reform(double(a1))
        x = reform(double(a2))
        y = reform(double(a3))
     end
  endcase

;	Open the file

@graff_version

  f0 = file
  
  graff_init, pdefs, f0, version = version
  
  igot = graff_get(pdefs, f0, /no_set, /no_warn)
  if igot eq 0 then begin       ; Note that here it is meaningful to
                                ; continue if the file doesn't exist.

     message, "Failed to open: "+f0
     return
  endif

  if (pdefs.nsets gt 1 || (*pdefs.data)[0].ndata ne 0) then begin
     *pdefs.data = [*pdefs.data, {graff_data}]
     (*pdefs.data)[pdefs.nsets].Pline =    1
     (*pdefs.data)[pdefs.nsets].Symsize =  1.
     (*pdefs.data)[pdefs.nsets].Colour =   1
     (*pdefs.data)[pdefs.nsets].Thick =    1.
     (*pdefs.data)[pdefs.nsets].Medit =    optblock.mouse
     pdefs.nsets = pdefs.nsets+1
  endif

  pdefs.cset = pdefs.nsets-1

  zflag = 0b

  if (keyword_set(xy_file)) then begin
     istat = gr_xy_read(pdefs, xy_file)
     if (istat eq 0) then message, "Failed to add dataset from: "+ $
                                   xy_file
  endif else if keyword_set(z_file) then begin
     istat = gr_z_read(pdefs, z_file)
     if (istat eq 0) then message, "Failed to add dataset from: "+ $
                                   z_file
     
  endif else if (n_params() eq 4) || z1flag then begin ; 2-D dataset
     
     sz = size(z)
     if (sz(0) ne 2) then message, "Z array must be 2-D"
     nx = sz(1)
     ny = sz(2)
     sx = size(x)
     if sx[0] eq 1 then begin
        if (n_elements(x) ne sz(1)) then $
           message, "X-array doesn't match X-size of Z-array"
        x2d = 0b
     endif else if sx[0] eq 2 then begin
        if (sx[1] ne sz[1] || sx[2] ne sz[2]) then $
           message, "X-array doesn't match size of Z-array"
        x2d = 1b
     endif else message, "X array must have 1 or 2 dimensions"

     sy = size(y)
     if sy[0] eq 1 then begin
        if (n_elements(y) ne sz(2)) then $
           message, "Y-array doesn't match Y-size of Z-array"
        y2d = 0b
     endif else if (sy[0] eq 2) then begin
        if (sy[1] ne sz[1] || sy[2] ne sz[2]) then $
           message, "Y-array doesn't match size of Z-array"
        y2d = 1b
     endif else message, "Y array must have 1 or 2 dimensions"

     
     xydata = {graff_zdata}
     xydata.Z = ptr_new(z)
     xydata.X = ptr_new(x)
     xydata.Y = ptr_new(y)
     xydata.x_is_2d = x2d
     xydata.y_is_2d = y2d

     (*pdefs.data)[pdefs.cset].ndata = nx
     (*pdefs.data)[pdefs.cset].ndata2 = ny

     (*pdefs.data)[pdefs.cset].xydata = ptr_new(xydata)
     (*pdefs.data)[pdefs.cset].type = 9
     
     (*pdefs.data)[pdefs.cset].zopts.shade_levels = 256l
     
     zflag = 1b

  endif else if (n_params() eq 3 || n_params() eq 2) then begin ; Ordinary data
     
     nx = n_elements(x)
     ny = n_elements(y)
     if (nx ne ny) then message, 'X & Y must be the same size'

     if keyword_set(x_errors) then begin
        xerr = double(x_errors)
        sxe = size(xerr)
        if sxe[0] eq 1 then begin
           if sxe[1] ne nx then message, 'X & X errors must be the ' + $
                                         'same size'
           xerr = reform(xerr, 1, nx, /over)
           nxe = 1
        endif else if sxe[0] eq 2 then begin
           if sxe[1] eq nx then begin
              xerr = transpose(xerr)
              sxe = size(xerr)
           endif else if sxe[2] ne nx then $
              message, 'X & X errors must be the same length'
           
           if sxe[1] gt 2 then begin
              message, /continue, $
                       "Excess X-error columns ignored."
              xerr = xerr[0:1, *]
              nxe = 2
           endif else nxe = sxe[1] 
        endif else message, "X errors must have 1 or 2 dimensions."
     endif else nxe = 0
     
     if keyword_set(y_errors) then begin
        yerr = double(y_errors)
        sye = size(yerr)
        if sye[0] eq 1 then begin
           if sye[1] ne nx then message, 'Y & Y errors must be the ' + $
                                         'same size'
           yerr = reform(y_errors, 1, ny, /over)
           nye = 1
        endif else if sye[0] eq 2 then begin
           if sye[1] eq ny then begin
              yerr = transpose(yerr)
              sye = size(yerr)
           endif else if sye[2] ne ny then $
              message, 'Y & Y errors must be the same length'
           
           if sye[1] gt 2 then begin
              message, /continue, $
                       "Excess y-error columns ignored."
              yerr = yerr[0:1, *]
              nye = 2
           endif else nye = sye[1] 
        endif else message, "Y errors must have 1 or 2 dimensions."
     endif else nye = 0

     ety = gr_err_type(nxe, nye)
     
     if keyword_set(errors) then begin
        if ~(keyword_set(x_errors) || keyword_set(y_errors)) then begin
           se = size(errors)
           if (se[0] eq 1) then begin
              nerc = 1
              nerr = se[1]
              errs = double(reform(errors, 1, nerr))
           endif else if se[0] eq 2 then begin
              if se[2] eq nx && se[1] le 4 then begin
                 nerc = se[1]
                 nerr = se[2]
                 errs = errors
              endif else if se[1] eq nx && se[2] le 4 then begin
                 nerc = se[2]
                 nerr = se[1]
                 errs = double(transpose(errors))
              endif else begin
                 message, 'Must have the same number of ' + $
                          'errors as X-values, and 4 or fewer error ' + $
                          'values.'
              endelse
           endif else message, "Invalid dimensions for ERRORS"
           if (nerr ne nx) then message, 'Must have the same number of ' + $
                                         'errors as X-values'
           
           defety = [0, 1, 2, 6, 8]
           
           if (keyword_set(errtype)) then begin
              set = size(errtype, /type)
              if (set eq 7) then case strupcase(errtype) of
                 '': ety = 0
                 'Y': ety = 1
                 'YY': ety = 2
                 'X': ety = 3
                 'XX': ety = 4
                 'XY': ety = 5
                 'XYY': ety = 6
                 'XXY': ety = 7
                 'XXYY': ety = 8
              endcase else ety = fix(errtype)

              nerv = gr_n_errors(ety)
              if nerv ne nerc[0]+nerc[1] then begin
                 print, "Requested error mapping does not match the number " + $
                        "of error limits"
                 print, "Using the default for ", nt-2, " errors"
                 ety = defety[nerc]
              endif

           endif else ety = defety[nerc]
           nerv = gr_n_errors(ety)

           nxe = nerv[0]
           nye = nerv[1]
           
           if nxe ne 0 then xerr = errs[0:nerv[0]-1, *]
           if nye ne 0 then yerr = errs[nerv[0]:*, *]
        endif else message, /cont, "ERRORS may not be specified " + $
                            "alongside axis-specific errors, ignoring"
     endif
     
     
     xydata = {graff_xydata}
     xydata.x = ptr_new(double(x))
     xydata.y = ptr_new(double(y))
     
     if nxe ne 0 then xydata.x_err = ptr_new(xerr)
     if nye ne 0 then xydata.y_err = ptr_new(yerr)
     
     (*pdefs.data)[pdefs.cset].xydata = ptr_new(xydata)
     (*pdefs.data)[pdefs.cset].type = ety
     (*pdefs.data)[pdefs.cset].ndata = nx

  endif else if keyword_set(func_file) then begin
     istat = gr_fun_read(pdefs, func_file)
     if istat eq 0 then $
        message, "Failed to read function"

     zflag = (*pdefs.data)[pdefs.cset].type eq -4
     if (keyword_set(neval)) then (*pdefs.data)[pdefs.cset].ndata = neval(0) $
     else (*pdefs.data)[pdefs.cset].ndata = 25

  endif else begin              ; function
     if (keyword_set(z_func)) then begin
        if (not keyword_set(frange)) then frange = dblarr(2, 2)
        xydata = {graff_zfunct}
        xydata.Range = frange
        xydata.Funct = z_func

        (*pdefs.data)[pdefs.cset].type = -4
        if (keyword_set(neval)) then (*pdefs.data)[pdefs.cset].ndata2 $
           = neval(1) $ 
        else (*pdefs.data)[pdefs.cset].ndata2 = 25
        
        zflag = 1b
     endif else if (keyword_set(x_func) && keyword_set(y_func)) then begin ;
                                ; parametric
        if (not keyword_set(frange)) then frange = dindgen(2)
        xydata = {graff_pfunct}
        xydata.Range = frange
        xydata.Funct = [x_func, y_func]

        (*pdefs.data)[pdefs.cset].type = -3
        
     endif else if keyword_set(y_func) then begin
        if (not keyword_set(frange)) then frange = dblarr(2)
        xydata = {graff_funct}
        xydata.Range = frange
        xydata.Funct = y_func

        (*pdefs.data)[pdefs.cset].type = -1
        
     endif else begin
        if (not keyword_set(frange)) then frange = dblarr(2)
        xydata = {graff_funct}
        xydata.Range = frange
        xydata.Funct = x_func

        (*pdefs.data)[pdefs.cset].type = -2
        
     endelse
     (*pdefs.data)[pdefs.cset].xydata = ptr_new(xydata)
     
     if (keyword_set(neval)) then (*pdefs.data)[pdefs.cset].ndata = neval(0) $
     else (*pdefs.data)[pdefs.cset].ndata = 25
     
  endelse

  if (keyword_set(polar) && ((*pdefs.data)[pdefs.cset].type ge -3 && $
                             (*pdefs.data)[pdefs.cset].type le 8)) then $
                                (*pdefs.data)[pdefs.cset].mode = polar
  if (n_elements(psym) ne 0) then  (*pdefs.data)[pdefs.cset].psym = psym
  if (n_elements(join) ne 0) then (*pdefs.data)[pdefs.cset].pline = join
  if (n_elements(symsize) ne 0) then  (*pdefs.data)[pdefs.cset].symsize $
     = symsize
  if (n_elements(style) ne 0) then (*pdefs.data)[pdefs.cset].line = style
  if (n_elements(colour) ne 0) then begin
     if n_elements(colour) eq 3 then begin
        (*pdefs.data)[pdefs.cset].colour = -2
        (*pdefs.data)[pdefs.cset].c_vals = colour
     endif else if colour gt 255 then begin
        (*pdefs.data)[pdefs.cset].colour = -2
        (*pdefs.data)[pdefs.cset].c_vals = $
           graff_colours(colour, /triple)
     endif else (*pdefs.data)[pdefs.cset].colour = colour
  endif
  if (n_elements(thick) ne 0) then  (*pdefs.data)[pdefs.cset].thick = thick
  if (keyword_set(sort)) then (*pdefs.data)[pdefs.cset].sort = 1
  if (n_elements(description) ne 0) then $
     (*pdefs.data)[pdefs.cset].descript = description 
  if (n_elements(noclip)  ne 0) then (*pdefs.data)[pdefs.cset].noclip $
     = noclip

  if n_elements(min_val) ne 0 then $
     (*pdefs.data)[pdefs.cset].min_val = min_val $
  else (*pdefs.data)[pdefs.cset].min_val = !values.d_nan
  if n_elements(max_val) ne 0 then $
     (*pdefs.data)[pdefs.cset].max_val = max_val $
  else (*pdefs.data)[pdefs.cset].max_val = !values.d_nan

  if (n_elements(mouse) ne 0) then (*pdefs.data)[pdefs.cset].medit = mouse
  if (n_elements(y_axis) ne 0) then begin
     (*pdefs.data)[pdefs.cset].y_axis = y_axis
     if y_axis eq 1 then pdefs.y_right = 1b
  endif
  
  if (keyword_set(rescale)) then begin
     gr_autoscale, pdefs, /xaxis, /ignore
     gr_autoscale, pdefs, /yaxis, /ignore
  endif

  if zflag then begin
     (*pdefs.data)[pdefs.cset].zopts.format = keyword_set(z_format)
     if keyword_set(z_levels) then begin
        (*pdefs.data)[pdefs.cset].zopts.levels = ptr_new(z_levels)
        (*pdefs.data)[pdefs.cset].zopts.N_levels = $
           n_elements(z_levels)
        (*pdefs.data)[pdefs.cset].zopts.set_levels = 1b
     endif else if keyword_set(z_nlevels) then $
        (*pdefs.data)[pdefs.cset].zopts.N_levels = z_nlevels $
     else (*pdefs.data)[pdefs.cset].zopts.N_levels = 6
     if keyword_set(z_lmap) then (*pdefs.data)[pdefs.cset].zopts.lmap $
        = z_lmap

     if n_elements(z_colours) gt 0 then begin
        (*pdefs.data)[pdefs.cset].zopts.N_cols = n_elements(z_colours)
        case size(z_colours, /type) of
           11: begin
              (*pdefs.data)[pdefs.cset].zopts.colours = $
                 ptr_new(intarr(ncolss))
              (*pdefs.data)[pdefs.cset].zopts.raw_colours = $
                 ptr_new(intarr(3, ncolss))
              for j = 0, ncolss-1 do begin
                 if n_elements(z_colours[j]) eq 1 then begin
                    (*(*pdefs.data)[pdefs.cset].zopts.colours)[j] = $
                       z_colours[j]
                    (*(*pdefs.data)[pdefs.cset].zopts.raw_colours)[*, $
                                                                   j] $
                       = 0
                 endif else begin
                    (*(*pdefs.data)[pdefs.cset].zopts.colours)[j] = $
                       -2
                    (*(*pdefs.data)[pdefs.cset].zopts.raw_colours)[*, $
                                                                   j] $
                       = graff_colours(z_colours[j])
                 endelse
              endfor
           end
           7: begin
              gr_cont_col_get, z_colours, icol, rcol
              (*pdefs.data)[pdefs.cset].zopts.N_cols = n_elements(icol)
              (*pdefs.data)[pdefs.cset].zopts.Colours = ptr_new(icol)
              (*pdefs.data)[pdefs.cset].zopts.raw_colours = ptr_new(rcol)
           end
           else: begin
              (*pdefs.data)[pdefs.cset].zopts.Colours = $
                 ptr_new(fix(z_colours))
              (*pdefs.data)[pdefs.cset].zopts.raw_colours = $
                 ptr_new(intarr(3, $
                                (*pdefs.data)[pdefs.cset].zopts.N_cols))
           end
        endcase
     endif else begin
        (*pdefs.data)[pdefs.cset].zopts.N_cols = 1
        (*pdefs.data)[pdefs.cset].zopts.Colours = ptr_new(1)
     endelse

     if n_elements(z_ctable) ne 0 then $
        (*pdefs.data)[pdefs.cset].zopts.ctable = z_ctable

     if keyword_set(z_style) then begin
        (*pdefs.data)[pdefs.cset].zopts.N_sty = n_elements(z_style)
        (*pdefs.data)[pdefs.cset].zopts.style = ptr_new(z_style)
     endif else begin
        (*pdefs.data)[pdefs.cset].zopts.N_sty =   1
        (*pdefs.data)[pdefs.cset].zopts.style = ptr_new(0)
     endelse

     if keyword_set(z_thick) then begin
        (*pdefs.data)[pdefs.cset].zopts.N_thick = n_elements(z_thick)
        (*pdefs.data)[pdefs.cset].zopts.thick = ptr_new(double(z_thick))
     endif else begin
        (*pdefs.data)[pdefs.cset].zopts.N_thick = 1
        (*pdefs.data)[pdefs.cset].zopts.Thick = ptr_new(1.)
     endelse

     if keyword_set(z_range) then (*pdefs.data)[pdefs.cset].zopts.range $
        = z_range
     if keyword_set(z_label) then (*pdefs.data)[pdefs.cset].zopts.label $
        = z_label

     if keyword_set(z_charsize) then $
        (*pdefs.data)[pdefs.cset].zopts.charsize = z_charsize $
     else  (*pdefs.data)[pdefs.cset].zopts.charsize = 1.

     if keyword_set(z_pxsize) then $
        (*pdefs.data)[pdefs.cset].zopts.pxsize = z_pxsize $
     else (*pdefs.data)[pdefs.cset].zopts.Pxsize = 0.1

     (*pdefs.data)[pdefs.cset].zopts.invert = keyword_set(z_invert)
     if (n_elements(z_missing) ne 0) then $
        (*pdefs.data)[pdefs.cset].zopts.missing = z_missing
     (*pdefs.data)[pdefs.cset].zopts.fill = keyword_set(z_fill)

     if n_elements(z_mode) ne 0 then begin
        (*pdefs.data)[pdefs.cset].zopts.ilog = z_mode
     endif else if n_elements(z_log) ne 0 then begin
        (*pdefs.data)[pdefs.cset].zopts.ilog = z_log
        print, "Z_LOG is now deprecated, use Z_MODE"
     endif else (*pdefs.data)[pdefs.cset].zopts.ilog = 0
  endif

  if keyword_set(graffer) && graff_have_gui() then begin
     gr_state, /save            ;?
     if (keyword_set(ascii)) then gr_asc_save, pdefs $
     else gr_bin_save, pdefs

     graffer, file
     return
  endif else if (keyword_set(display)) then begin
     gr_state, /save            ;?
     gr_plot_object, pdefs
     gr_state
  endif

  if (keyword_set(ascii)) then gr_asc_save, pdefs $
  else gr_bin_save, pdefs

  graff_clear, pdefs

end

