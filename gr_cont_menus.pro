;+
; GR_CONT_MENUS
;	Make the menu to set the properties of a contoured ds.
;
; Usage:
;	gr_cont_menus, sb, pdefs
;
; Arguments:
; 	sb	long	input	The base widget into which to put the
; 				menu.
;	pdefs	struct	input	The Graffer data & control structure.
;
; History:
;	Original (after gr_cont_menus): 13/12/11; SJT
;	Revert to original name: 5/1/12; SJT
;	Levels etc. become pointers: 11/1/12; SJT
;-

pro Cont_event, event

  base = widget_info(/child, event.top)
  widget_control, base, get_uvalue = pdefs, /no_copy
  zopts = (*pdefs.data)[pdefs.cset].zopts
  widget_control, event.id, get_uvalue = but

  track_flag = strpos(tag_names(event, /struct), 'TRACK') ne -1
  if (track_flag) then begin
     if (event.enter eq 0) then begin
        graff_msg, pdefs.ids.hlptxt, ''
        goto, miss_case
     endif
  endif

  case but of
     'CMODE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Toggle explicit/automatic contour levels' $
     else begin
        zopts.set_levels = event.index
        if (event.index eq 1) then begin
           widget_control, pdefs.ids.zopts.c_levels, get_value = $
                           levels
           if ptr_valid(zopts.levels) then ptr_free, zopts.levels
           zopts.levels = ptr_new(levels[sort(levels)])
           zopts.n_levels = n_elements(levels)
        endif
        widget_control, pdefs.ids.zopts.c_levels, sensitive = event.index eq 1
        widget_control,  pdefs.ids.zopts.c_nlevels, sensitive = $
                         event.index eq 0, set_value = zopts.n_levels
     end
     
     'LEVEL': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set explicit contour levels' $
     else begin
        widget_control, event.id, get_value = levels
        idx = uniq(levels, sort(levels))
        levels = levels[idx]
        if ptr_valid(zopts.levels) then ptr_free, zopts.levels
        zopts.levels = ptr_new(levels)
        zopts.n_levels = n_elements(levels)
     endelse

     'NLEVEL': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set number of automatic levels' $
     else begin
        widget_control, event.id, get_value = n_levels
        zopts.n_levels = n_levels
     endelse

     'COLOUR': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set contour colours' $
     else begin
        widget_control, event.id, get_value = col
        if ptr_valid(zopts.colours) then ptr_free, zopts.colours
        zopts.colours = ptr_new(col)
        zopts.n_cols = n_elements(col)
     endelse
     
     'THICK': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set contour thicknesses' $
     else begin
        widget_control, event.id, get_value = thk
        if ptr_valid(zopts.thick) then ptr_free, zopts.thick
        zopts.thick = ptr_new(thk)
        zopts.n_thick = n_elements(thk)
     endelse
     
     'STYLE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set contour line styles' $
     else begin
        widget_control, event.id, get_value = sty
        if ptr_valid(zopts.style) then ptr_free, zopts.style
        zopts.style = ptr_new(sty)
        zopts.n_sty = n_elements(sty)
     endelse
     
     'LABEL': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set contour labelling interval' $
     else begin
        widget_control, event.id, get_value = labi
        zopts.label = labi
        widget_control, pdefs.ids.zopts.c_charsize, sensitive = labi $
                        ne 0
     endelse
     
     'CCSIZE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set contour labelling character size' $
     else begin
        widget_control, event.id, get_value = ccs
        zopts.charsize = ccs
     endelse

     'FILL': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, $
                   'Toggle filled/outline/feathered contours' $
     else zopts.fill = event.index
  endcase


  if ~track_flag then begin
     (*pdefs.data)[pdefs.cset].zopts = zopts
     if ~(zopts.set_levels and zopts.n_levels eq 0) then $
        gr_plot_object, pdefs
     pdefs.chflag = 1b
     pdefs.transient.changes = pdefs.transient.changes+1
     if (pdefs.transient.changes gt 20) then begin
        gr_bin_save, pdefs, /auto
     endif
     widget_control, pdefs.ids.chtick, map = pdefs.chflag
  endif

Miss_case:

  widget_control, base, set_uvalue = pdefs, /no_copy

end

pro Gr_cont_menus, sb, pdefs

i = pdefs.cset
fflag = 0b
zopts = (*pdefs.data)[i].zopts
if (zopts.n_cols eq 0) then begin
    zopts.n_cols = 1
    zopts.colours = ptr_new(1)
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
if fflag then (*pdefs.data)[i].zopts = zopts


pdefs.ids.zopts.bases[0] = widget_base(sb, $
                                       /column, $
                                       event_pro = "cont_event", $
                                       map = ~zopts.format, $
                                       xpad = 0, $
                                       ypad = 0, $
                                       space = 0)

base = pdefs.ids.zopts.bases[0]       ; Just for convenience
obase = widget_base(base, $
                    /row, $
                    xpad = 0, $
                    ypad = 0, $
                    space = 0)

jb = widget_base(obase, $
                 /column, $
                 xpad = 0, $
                 ypad = 0, $
                 space = 0)

iexpl = zopts.set_levels
pdefs.ids.zopts.c_auto = widget_droplist(jb, $
                                         value = ['Automatic', $
                                                  'Explicit'], $
                                         uvalue = 'CMODE', $
                                         /track)
widget_control, pdefs.ids.zopts.c_auto, set_droplist_select = iexpl

if (iexpl and ptr_valid(zopts.levels)) then l0 = *(zopts.levels)  $
else l0 = 0.d0

pdefs.ids.zopts.c_levels = graff_enter(jb, $
                                       /double, $
                                       /array, $
                                       /track, $
                                       uvalue = 'LEVEL', $
                                       value = l0, $
                                       format = "(g11.4)", $
                                       xsize = 10, $
                                       ysize = 7, $
 ;                                      /scroll, $
                                       /column, $
                                       label = 'Levels', $
                                       /capture, $
                                       /all_events)

widget_control, pdefs.ids.zopts.c_levels, sensitive = iexpl

pdefs.ids.zopts.c_nlevels = graff_enter(jb, $
                                        /int, $
                                        /track, $
                                        uvalue = 'NLEVEL', $
                                        value = zopts.n_levels, $
                                        xsize = 12, $
                                        ysize = 1, $
                                        /column, $
                                        label = '# Levels', $
                                        /capture, $
                                        /all_events)

widget_control, pdefs.ids.zopts.c_nlevels, sensitive = iexpl eq 0


jbx = widget_base(obase, $
                 /column, $
                 xpad = 0, $
                 ypad = 0, $
                 space = 0)

pdefs.ids.zopts.c_type = widget_droplist(jbx, $
                                         value = ['Outline', $
                                                  'Filled', $
                                                  'Downhill'], $
                                         uvalue = 'FILL', $
                                         /track)
widget_control, pdefs.ids.zopts.c_type, set_droplist_select = zopts.fill

jby = widget_base(jbx, $
                  /row, $
                  xpad = 0, $
                  ypad = 0, $
                  space = 0)

jb = widget_base(jby, $
                 /column, $
                 xpad = 0, $
                 ypad = 0, $
                 space = 0)

pdefs.ids.zopts.c_colour = graff_enter(jb, $
                                       /int, $
                                       /array, $
                                       /track, $
                                       uvalue = 'COLOUR', $
                                       /capture, $
                                       value = *(zopts.colours), $
                                       format = "(i0)", $
                                       xsize = 6, $
                                       ysize = 5, $
;                                       /scroll, $
                                       /column, $
                                       label = 'Colours', $
                                       /all_events)


pdefs.ids.zopts.c_thick = graff_enter(jb, $
                                      /float, $ 
                                      format = "(f6.1)", $
                                      /array, $
                                      /track, $
                                      uvalue = 'THICK', $
                                      /capture, $
                                      value = *(zopts.thick), $ 
                                      xsize = 6, $
                                      ysize = 5, $
;                                      /scroll, $
                                      /column, $
                                      label = 'Thicknesses', $
                                      /all_events)

jb = widget_base(jby, $
                 /column, $
                 xpad = 0, $
                 ypad = 0, $
                 space = 0)

pdefs.ids.zopts.c_style = graff_enter(jb, $
                                      /int, $
                                      /array, $
                                      /track, $
                                      uvalue = 'STYLE', $
                                      /capture, $
                                      value = *(zopts.style), $
                                      format = "(I0)", $
                                      xsize = 6, $
                                      ysize = 5, $
;                                      /scroll, $
                                      /column, $
                                      label = 'Styles', $
                                      /all_events)


pdefs.ids.zopts.c_label = graff_enter(jb, $
                                      /int, $
                                      /track, $
                                      uvalue = 'LABEL',  $
                                      value = zopts.label, $
                                      format = '(I0)', $
                                      xsize = 6, $
                                      ysize = 1, $
                                      label = 'Label', $
                                      /capture, $
                                      /column, $
                                      /all_events)



pdefs.ids.zopts.c_charsize = graff_enter(jb, $
                                         /float, $
                                         /track, $
                                         uvalue = 'CCSIZE', $
                                         value = zopts.charsize, $
                                         format = "(F5.1)", $
                                         xsize = 6, $
                                         ysize = 1, $
                                         label = 'Charsize', $
                                         /capture, $
                                         /column, $
                                         /all_events)
widget_control, pdefs.ids.zopts.c_charsize, $
                sensitive = zopts.label ne 0
end

