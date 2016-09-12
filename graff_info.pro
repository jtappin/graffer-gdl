pro Graff_info, file, nsets = nsets,  title = title, subtitle = subtitle, $
                charsize = charsize, thick = thick, corners = $
                corners, $
                aspect = aspect, comment = comment, xtitle = xtitle, $
                xrange = xrange, xlog = xlog, xexact = xexact, $
                xextend = xextend, xaxes = xaxes, xbox = xbox, $
                xminor = xminor, xtime = xtime, xorigin = xorigin, $
                xgrid = xgrid, xannotate = xannotate, $
                xmajor = xmajor, xtickv = xtickv, xstyle = xstyle, $
                ytitle = ytitle, $
                yrange = yrange, ylog = ylog, yexact = yexact, $
                yextend = yextend, yaxes = yaxes, ybox = ybox, $
                yminor = yminor, ytime = ytime, yorigin = yorigin, $
                ygrid = ygrid, yannotate = yannotate, $
                ymajor = ymajor, ytickv = ytickv, ystyle = ystyle,$
                yr_enable = yr_enable, $
                yrtitle = yrtitle, $
                yrmajor = yrmajor, yrtickv = yrtickv, yrstyle = yrstyle, $
                yrrange = yrrange, yrlog = yrlog, yrexact = yrexact, $
                yrextend = yrextend, yraxes = yraxes, $ $
                yrminor = yrminor, yrtime = yrtime, yrorigin = $
                yrorigin, $
                yrgrid = yrgrid, yrannotate = $
                yrannotate, $ 
                h_orient = h_orient, $
                h_colour = h_colour, h_eps = h_eps, $
                h_xsize = h_xsize, $
                h_ysize = h_ysize, h_xmargin = h_xmargin, $
                h_ymargin = h_ymargin, isotropic = isotropic, $
                h_cmyk =  h_cmyk, ctable = ctable, $
                h_print = h_print, h_viewer $
                = h_viewer, h_file = h_file
;+
; GRAFF_INFO
;	User-callable interface to retrieve global properties of a graffer
;	file.
;
; Usage:
; Graff_info, file, nsets = nsets, title = title, subtitle = subtitle, $
;                 charsize = charsize, thick = thick, corners = $
;                 corners, $
;                 aspect = aspect, comment = comment, xtitle = xtitle, $
;                 xrange = xrange, xlog = xlog, xexact = xexact, $
;                 xextend = xextend, xaxes = xaxes, xbox = xbox, $
;                 xminor = xminor, xtime = xtime, xorigin = xorigin, $
;                 xgrid = xgrid, xannotate = xannotate, $
;                 xmajor = xmajor, xtickv = xtickv, $
;                 ytitle = ytitle, $
;                 yrange = yrange, ylog = ylog, yexact = yexact, $
;                 yextend = yextend, yaxes = yaxes, ybox = ybox, $
;                 yminor = yminor, ytime = ytime, yorigin = yorigin, $
;                 ygrid = ygrid, yannotate = yannotate, $
;                 ymajor = ymajor, ytickv = ytickv, $
;                 yr_enable = yr_enable, $
;                 yrtitle = yrtitle, $
;                 yrmajor = xmajor, yrtickv = xtickv, $
;                 yrrange = yrrange, yrlog = yrlog, yrexact = yrexact, $
;                 yrextend = yrextend, yraxes = yraxes, $ $
;                 yrminor = yrminor, yrtime = yrtime, yrorigin = yrorigin, $
;                 yrgrid = yrgrid, yrannotate = $
;                 yrannotate, h_orient = h_orient, $ $
;                 h_colour = h_colour, h_eps = h_eps, h_xsize = h_xsize, $
;                 h_ysize = h_ysize, h_xmargin = h_xmargin, $ $
;                 h_ymargin = h_ymargin, isotropic = isotropic, h_cmyk = $
;                 h_cmyk, ctable = ctable, h_print = h_print, h_viewer $
;                 = h_viewer, h_file = h_file
;
; Argument:
;	file	string	input	The graffer file to query.
;
; Keywords:
;	nsets		output	Get the number of datasets in the file
; 	title		output	Get the plot title.
; 	subtitle	output	Get the subtitle for the plot.
; 	charsize	output	Get the character size to be used for
;			 	axis labelling and plot annotations.
; 	thick		output	Get the line thickness to be used for
;			 	drawing the axes.
; 	corners		output	Get the location of the plot in
;			 	normalized coordinates by specifying
;			 	the locations of the corners
;			 	(4-elemant array [x0,y0, x1,y1])
; 	aspect		output	Get the location of the plot within
;			 	the normalized coordinate system by
;			 	aspect ratio and margin (2-element
;			 	array [aspect, margin]
;			 		N.B. Specifying both ASPECT &
;			 		CORNERS is an error and the
;			 		plot location is unchanged.
;	isotropic	output	Get the plot to use isotropic
;				coordinates.
; 	comment		output	Get a descriptive comment for the
;			 	whole file. (String array)
; 	[xyyr]title	output	Get the title for the specified axis.
;	[xyyr]range	output	Get the range of the specified axis
;				(2-element array).
; 	[xyyr]log	output	Get  the use of logarithmic
; 				axes.
; 	[xyyr]exact	output	Get  the exact range bit of
; 				the IDL axis style setting
; 	[xyyr]extend	output	Get  the extended range bit of
;			 	the IDL axis style setting
;	[xyyr]axes	output	Get  the axis plotting bit of
;				the IDL axis style setting.
;	[xy]box		output	Get  the "box-axis" bit in the
;				IDL axis style setting
;	[xyyr]style	Output	Get the IDL axis style parameter.
;	[xyyr]minor	output	If set, then display minor ticks on
;				the plot; if explicitly zero, then
;				turn off the minor ticks. If a
;				non-unit value then set the number of
;				minor intervals to that.
;	[xyyr]major	output	Get the number of major intervals.
;	[xyyr]tickv	output	Get explicit tick locations. Set to a
;				scalar value, or set [xyyr]major without
;				setting this key to revert to automatic.
;	[xyyr]time	output	If set to zero, then turn off time
;				labelling, otherwise this must be a
;				structure with the following members:
;				unit: - 0 == seconds
;				     - 1 == minutes
;				     - 2 == hours
;				     - 3 == days
;				       Gives the unit in which the
;				       time is expressed in the axis data.
;				max_unit: gives the largest unit to
;				     display on the plot (same code as
;				     for unit)
;				zero: gives the value to be used for
;				    the zero of the axis (expressed in
;				    units of  max_unit
;	[xyyr]origin	output	If set, then plot an axis at the origin.
;	[xyyr]grid	output   Make a grid from the major ticks,
;				using linestyle n-1 (0 == no grid).
;	[xyyr]annotate	output	Get this explicity to zero to suppress
;				annotations on the axis
;	yr_enable	output	If set, then enable the secondary Y-axis.
;	h_orient	output	Get landscape(0) or portrait (1)
;				orientation of the page.
;	h_colour	output	Get  the generation of a
;				colour (E)PS file.
;	h_cmyk		output	Get  the use of the CMYK model
;				for (E)PS files. Specifying this
;				keyword will force colour (E)PS.
;	h_eps		output	Get  the generation of EPS
;				file rather than PS (N.B. if h_eps is
;				set and h_orient is not specified,
;				then h_orient=1 is implied).
;	h_[xy]size	output	Get the X(Y) dimension of the page in cm
;	h_[xy]margin	output	Get the X(Y) offset of the page from
;				the lower-left corner of the page.
;	ctable		output	Get the default colour table for image display.
;	h_print		output	Specify the command to print PS output
;				files (can be a scalar or 2-element aray).
;	h_viewer	output	Specify the command to view EPS output
;				files (can be a scalar or 2-element aray).
;	h_file		output	Specify the output file for hardcopies.
;				
; Restrictions:
; 	Some settings may not return meaningful values for all files
;
;
; History:
;	Original, using graff_props as a template.
;-

;	Check that the necessary inputs are present

  on_error, 2                   ; Return to caller on error

  if (n_params() ne 1) then message, "Must specify a GRAFFER file"

  gr_state, /save

;	Open the file

@graff_version

  f0 = file
  graff_init, pdefs, f0, version = version
  igot = graff_get(pdefs, f0, /no_set, /no_warn)
  if igot ne 1 then begin
     message, "Failed to open: "+f0
     return
  endif

; Number of datasets

  if arg_present(nsets) nsets = pdefs.nsets

;	Titles & other global options

  if arg_present(title) then title = pdefs.title
  if arg_present(subtitle) then subtitle = pdefs.subtitle

  if arg_present(charsize) then charsize = pdefs.charsize
  if arg_present(thick) then axthick = pdefs.thick

; Corners etc (note may not always give meaningful results)
  if arg_present(aspect) then aspect =  pdefs.aspect
  if arg_present(corners) then corners = pdefs.position
  if arg_present(isotropic) then isotropic = pdefs.isotropic

  if arg_present(comment) then comment = *(pdefs.remarks)
 
  if arg_present(ctable) then ctable = pdefs.ctable

;	X axis settings

  if arg_present(xrange) then xrange = pdefs.xrange
  if arg_present(xtitle) then xtitle = pdefs.xtitle
  if arg_present(xlog) then xlog = pdefs.xtype

;	Standard IDL style settings

  if arg_present(xstyle) then xstyle = pdefs.xsty.idl
  if arg_present(xexact) then xexact = (pdefs.xsty and 1) ne 0
  if arg_present(xextend) then xextend =  (pdefs.xsty and 2) ne 0
  if arg_present(xaxes) then xaxes = (pdefs.xsty and 4) ne 0
  if arg_present(xbox) then xbox = (pdefs.xsty and 8) ne 0

;	Extra settings

  if arg_present(xminor) then begin
     case pdefs.xsty.minor of
        1: xminor = 0
        0: xminor = 1
        else: xminor = pdefs.xsty.minor
     endcase
  endif
  if arg_present(xmajor) then xxmajor = pdefs.xsty.major

  if n_elements(xtickv) ne 0 then begin
     if ptr_valid(pdefs.xsty.values) then ptr_free, pdefs.xsty.values
     if n_elements(xtickv) gt 1 then pdefs.xsty.values = $
        ptr_new(xtickv)
  endif

  if (n_elements(xorigin) ne 0) then begin
     if (keyword_set(xorigin)) then pdefs.xsty.extra = pdefs.xsty.extra $
        or 2 $
     else  pdefs.xsty.extra = pdefs.xsty.extra and (not 2)
  endif
  if n_elements(xannotate) ne 0 then begin
     if keyword_set(xannotate) then pdefs.xsty.extra = pdefs.xsty.extra $
        and (not 4) $
     else pdefs.xsty.extra = pdefs.xsty.extra or 4
  endif

;	time labelling

  if (n_elements(xtime) ne 0) then begin
     if (not keyword_set(xtime)) then pdefs.xsty.time = pdefs.xsty.time $
        and (not 1) $
     else begin
        pdefs.xsty.time = 1 + 2*xtime.unit + 8*xtime.max_unit
        pdefs.xsty.tzero = xtime.zero
     endelse
  endif

;	Grid

  if (n_elements(xgrid) ne 0) then pdefs.xsty.grid = xgrid

;	Y axis settings

  if (n_elements(yrange) eq 2) then pdefs.yrange = yrange $
  else if keyword_set(yauto) then  gr_autoscale, pdefs, /yaxis, /ignore

  if (n_elements(ytitle) ne 0) then pdefs.ytitle = ytitle
  if (n_elements(ylog) ne 0) then pdefs.ytype = keyword_set(ylog)

;	Standard IDL style settings

  if (n_elements(yexact) ne 0) then begin
     if keyword_set(yexact) then pdefs.ysty.idl = pdefs.ysty.idl or 1 $
     else  pdefs.ysty.idl = pdefs.ysty.idl and (not 1)
  endif
  if (n_elements(yextend) ne 0) then begin
     if keyword_set(yextend) then pdefs.ysty.idl = pdefs.ysty.idl or 2 $
     else  pdefs.ysty.idl = pdefs.ysty.idl and (not 2)
  endif
  if (n_elements(yaxes) ne 0) then begin
     if keyword_set(yaxes) then pdefs.ysty.idl = pdefs.ysty.idl or 4 $
     else  pdefs.ysty.idl = pdefs.ysty.idl and (not 4)
  endif
  if (n_elements(ybox) ne 0) then begin
     if keyword_set(ybox) then pdefs.ysty.idl = pdefs.ysty.idl or 8 $
     else  pdefs.ysty.idl = pdefs.ysty.idl and (not 8)
  endif

;	Extra settings

  if (n_elements(yminor) ne 0) then begin
     case yminor of
        1: pdefs.ysty.minor = 0
        0: pdefs.ysty.minor = 1
        else: pdefs.ysty.minor = yminor
     endcase
  endif
  if n_elements(ymajor) ne 0 then begin
     pdefs.ysty.major = ymajor
     if  ptr_valid(pdefs.ysty.values) and n_elements(ytickv) eq 0 then $
        ptr_free, pdefs.ysty.values
  endif
  if n_elements(ytickv) ne 0 then begin
     if ptr_valid(pdefs.ysty.values) then ptr_free, pdefs.ysty.values
     if n_elements(ytickv) gt 1 then pdefs.ysty.values = $
        ptr_new(ytickv)
  endif

  if (n_elements(yorigin) ne 0) then begin
     if (keyword_set(yorigin)) then pdefs.ysty.extra = pdefs.ysty.extra $
        or 2 $
     else  pdefs.ysty.extra = pdefs.ysty.extra and (not 2)
  endif
  if n_elements(yannotate) ne 0 then begin
     if keyword_set(yannotate) then pdefs.ysty.extra = pdefs.ysty.extra $
        and (not 4) $
     else pdefs.ysty.extra = pdefs.ysty.extra or 4
  endif

;	time labelling

  if (n_elements(ytime) ne 0) then begin
     if (not keyword_set(ytime)) then pdefs.ysty.time = pdefs.ysty.time $
        and (not 1) $
     else begin
        pdefs.ysty.time = 1 + 2*ytime.unit + 8*ytime.max_unit
        pdefs.ysty.tzero = ytime.zero
     endelse
  endif

;	Grid

  if (n_elements(ygrid) ne 0) then pdefs.ysty.grid = ygrid

; Secondary (Yr) Y axis settings.

  if (n_elements(yr_enable) ne 0) then pdefs.y_right = $
     keyword_set(yr_enable)

  if (n_elements(yrrange) eq 2) then pdefs.yrange_r = yrrange $
  else if keyword_set(yrauto) then  gr_autoscale, pdefs, yaxis = 2, /ignore

  if (n_elements(yrtitle) ne 0) then pdefs.ytitle_r = yrtitle
  if (n_elements(yrlog) ne 0) then pdefs.ytype_r = keyword_set(yrlog)

;	Standard IDL style settings

  if (n_elements(yrexact) ne 0) then begin
     if keyword_set(yrexact) then pdefs.ysty_r.idl = pdefs.ysty_r.idl or 1 $
     else  pdefs.ysty_r.idl = pdefs.ysty_r.idl and (not 1)
  endif
  if (n_elements(yrextend) ne 0) then begin
     if keyword_set(yrextend) then pdefs.ysty_r.idl = pdefs.ysty_r.idl or 2 $
     else  pdefs.ysty_r.idl = pdefs.ysty_r.idl and (not 2)
  endif
  if (n_elements(yraxes) ne 0) then begin
     if keyword_set(yraxes) then pdefs.ysty_r.idl = pdefs.ysty_r.idl or 4 $
     else  pdefs.ysty_r.idl = pdefs.ysty_r.idl and (not 4)
  endif

;	Extra settings

  if (n_elements(yrminor) ne 0) then begin
     case yrminor of
        1: pdefs.ysty_r.minor = 0
        0: pdefs.ysty_r.minor = 1
        else: pdefs.ysty_r.minor = yrminor
     endcase
  endif
  if n_elements(yrmajor) ne 0 then begin
     pdefs.ysty_r.major = yrmajor
     if  ptr_valid(pdefs.ysty_r.values) and n_elements(yrtickv) eq 0 then $
        ptr_free, pdefs.ysty_r.values
  endif
  if n_elements(yrtickv) ne 0 then begin
     if ptr_valid(pdefs.ysty_r.values) then ptr_free, pdefs.ysty_r.values
     if n_elements(yrtickv) gt 1 then pdefs.ysty_r.values = $
        ptr_new(yrtickv)
  endif

  if (n_elements(yrorigin) ne 0) then begin
     if (keyword_set(yrorigin)) then pdefs.ysty_r.extra = $
        pdefs.ysty_r.extra or 2 $
     else  pdefs.ysty_r.extra = pdefs.ysty_r.extra and (not 2)
  endif
  if n_elements(yrannotate) ne 0 then begin
     if keyword_set(yrannotate) then pdefs.ysty_r.extra = pdefs.ysty_r.extra $
        and (not 4) $
     else pdefs.ysty_r.extra = pdefs.ysty_r.extra or 4
  endif

;	time labelling

  if (n_elements(yrtime) ne 0) then begin
     if (not keyword_set(yrtime)) then pdefs.ysty_r.time = $
        pdefs.ysty_r.time and (not 1) $
     else begin
        pdefs.ysty_r.time = 1 + 2*yrtime.unit + 8*yrtime.max_unit
        pdefs.ysty_r.tzero = yrtime.zero
     endelse
  endif

;	Grid

  if (n_elements(yrgrid) ne 0) then pdefs.ysty_r.grid = yrgrid

;	Hardcopy options.

  if (n_elements(h_orient) ne 0) then pdefs.hardset.orient = $
     keyword_set(h_orient)
  if (n_elements(h_colour) ne 0) then pdefs.hardset.colour = $
     keyword_set(h_colour)
  if (n_elements(h_eps) ne 0) then begin
     pdefs.hardset.eps = keyword_set(h_eps)
     if (keyword_set(h_eps) and n_elements(h_orient) eq 0) then $
        pdefs.hardset.orient = 1b
  endif

  if (n_elements(h_xsize) ne 0) then pdefs.hardset.size(0) = h_xsize
  if (n_elements(h_ysize) ne 0) then pdefs.hardset.size(1) = h_ysize

  if (n_elements(h_xmargin) ne 0) then pdefs.hardset.off(0) = h_xmargin
  if (n_elements(h_ymargin) ne 0) then pdefs.hardset.off(1) = h_ymargin
  if (n_elements(h_cmyk) ne 0) then begin
     pdefs.hardset.cmyk = h_cmyk
     pdefs.hardset.colour = 1b
  endif

  case n_elements(h_print) of
     0:                         ; Not given do nothing
     1: pdefs.hardset.action = [h_print, '']
     else: pdefs.hardset.action = h_print[0:1]
  endcase
  case  n_elements(h_viewer) of
     0:                         ; Not given do nothing
     1: pdefs.hardset.viewer = [h_viewer, ' &']
     2: pdefs.hardset.viewer = h_viewer[0:1]
  endcase
  if n_elements(h_file) ne 0 then pdefs.hardset.name = h_file

;	Display or enter Graffer?

  if (keyword_set(graffer)) then begin
     gr_bin_save, pdefs
     graffer, file
     return
  endif else if (keyword_set(display)) then begin
     gr_plot_object, pdefs
  endif

  if (keyword_set(ascii)) then gr_asc_save, pdefs $
  else gr_bin_save, pdefs

  graff_clear, pdefs
  gr_state

end

