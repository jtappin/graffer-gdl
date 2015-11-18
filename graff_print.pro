pro graff_print, file, predraw = predraw, _extra = _extra

;+
; GRAFF_PRINT
;	User-callable interface to print a graffer file.
;
; Usage:
;	graff_print, file[, <graff_props keywords>]
;
;
; Arguments:
;	file	string	input	The graffer file to modify.
; 
;
; Keywords:
; 	/predraw	If set, then draw the plot to a pixmap window
; 			first (can be needed to get the scaling right)
;	Any keyword used by GRAFF_PROPS may be supplied.
;
; History:
;	Original: 18/5/05; SJT
;	Add PREDRAW keyword: 20/5/09; SJT
;	Fix pixmap size to get consistent charsizes: 3/11/15; SJT
;-

on_error, 2                     ; Return to caller on error

if n_params() eq 0 then message, "Must specify a GRAFFER file"
gr_state, /save

if keyword_set(_extra) then graff_props, file, _extra = _extra

;	Open the file

@graff_version

f0 = file
graff_init, pdefs, f0, version = version
igot = graff_get(pdefs, f0, /no_set, /no_warn)
if igot ne 1 then begin
   message, "Failed to open: "+f0
   return
endif

if keyword_set(predraw) then begin
    set_plot, 'x'
    window, /free, /pixmap,  xsize = 600, ysize = 600
    graff_colours, pdefs
    gr_plot_object, pdefs
    wdelete
endif

istat = graff_hard(pdefs, /no_set)

graff_clear, pdefs
gr_state

end
