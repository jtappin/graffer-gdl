;+
; GR_AXIS_MENU
;	Make up an axis options menu for GRAFFER
;
; Usage:
;	gr_axis_menu, axis, base, pdefs
;
; Arguments:
;	axis	char	input	"X" or "Y" to say which axis it is.
;	base	long	input	Widget ID of the parent base.
;	pdefs	struct	in/out	The GRAFFER control & data structure.
;
; History:
;	Extracted: 6/12/96; SJT
;	Change to "Stated" pulldown & Move event handler here (to try
;	and reduce the size of the EH in GRAFFER): 17/1/97; SJT
;	Add CAPTURE key to entry boxes: 6/2/97; SJT
;	Replace most cw_bbselectors with widget_droplist: 13/12/11; SJT
;	Add support for a second Y-scale: 22/12/11; SJT
;	Add annotation suppression: 12/1/12; SJT
;	Advanced axis style settings: 21/8/12; SJT
;-

pro Gr_axis_event, event

  widget_control, event.id, get_uvalue = object

  base = widget_info(/child, event.top)
  widget_control, base, get_uvalue = pdefs, /no_copy

  idraw_flag = 1
  ichange = 1b
  track_flag = strpos(tag_names(event, /struct), 'TRACK') ne -1
  nch = 1

  if (track_flag) then begin
     idraw_flag = 0
     ichange = 0b
     if (event.enter eq 0) then begin
        graff_msg, pdefs.ids.hlptxt, ''
        goto, miss_case
     endif
  endif

  case object of
                                ; X-axis properties
     
     'XMIN': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter minimum value on X axis ' + $
                   '(floating point)' $
     else begin
        pdefs.xrange(0) = event.value
     end
     
     'XMAX': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter maximum value on X axis ' + $
                   '(floating point)' $
     else begin
        pdefs.xrange(1) = event.value
     end
     
     'XLOG': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Toggle linear or logarithmic X axis' $
     else pdefs.xtype = event.index
     
     'XSTY': begin
        val = str_sep(event.value, '/')
        if (n_elements(val) eq 1) then graff_msg, pdefs.ids.hlptxt, $
                                                  'Select X-axis style options' $
        else case val(1) of
           'Exact Range': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Select exact (On) or ' + $
                            'rounded (Off) X axis range' $
              else if (val(2) eq 'Off') then  $
                 pdefs.xsty.idl = pdefs.xsty.idl and (not 1) $
              else pdefs.xsty.idl = pdefs.xsty.idl or 1
           end
           'Extended Range': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch "Extended" ' + $
                            'X-axis range on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.xsty.idl = pdefs.xsty.idl and (not 2) $
              else pdefs.xsty.idl = pdefs.xsty.idl or 2
           end
           'Draw Axes': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch drawing of X axes ' + $
                            'on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.xsty.idl = pdefs.xsty.idl or 4 $
              else pdefs.xsty.idl = pdefs.xsty.idl and (not 4)
           end
           'Draw Box Axis': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch drawing of ' + $
                            'right-hand X axis on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.xsty.idl = pdefs.xsty.idl or 8 $
              else pdefs.xsty.idl = pdefs.xsty.idl and (not 8)
           end
           'Minor Ticks': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch drawing of ' + $
                            'X axis minor tick marks on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.xsty.minor = 1 $
              else pdefs.xsty.minor = 0
           end
           'Annotation': begin
              if (track_flag) then $ $
                 graff_msg, pdefs.ids.hlptxt, 'Switch axis annotation ' + $
                 'on or off' $
              else if (val[2] eq 'Off') then $
                 pdefs.xsty.extra = pdefs.xsty.extra or 4 $
              else pdefs.xsty.extra = pdefs.xsty.extra and (not 4)
           end
           'Time Labelling': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch time-format ' + $
                            'labelling of X axis on or off' $
              else if (val(2) eq 'On...') then begin
                 to = gr_tm_opts(pdefs.xsty.time, $ $
                                 pdefs.xsty.tzero, group = $
                                 pdefs.ids.graffer)
                 pdefs.xsty.time = to(0)
                 pdefs.xsty.tzero = to(1)
                 nch = 5
              endif else pdefs.xsty.time = pdefs.xsty.time and (not 1)
           end
           'Origin Axis': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Toggle inclusion of X ' + $
                            'axis at Y=0' $
              else case val(2) of
                 "On": pdefs.xsty.extra = (pdefs.xsty.extra or 2) $
                                          and (not 8)
                 "Off": pdefs.xsty.extra = pdefs.xsty.extra and (not 10)
                 "Full": pdefs.xsty.extra = pdefs.xsty.extra or 10
              endcase
           end
           'Grid': begin
              if (track_flag and (n_elements(val) eq 2)) then $
                 graff_msg, pdefs.ids.hlptxt, 'Select X-grid options' $
              else case val(2) of
                 ' None ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'No grid lines' $
                    else pdefs.xsty.grid = 0
                 end
                 
                 '______': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Solid grid lines' $
                    else pdefs.xsty.grid = 1
                 end
                 
                 '......': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dotted grid lines' $
                    else pdefs.xsty.grid = 2
                 end
                 
                 '_ _ _ ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dashed grid lines' $
                    else pdefs.xsty.grid = 3
                 end
                 '_._._.': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dash-dot grid lines' $
                    else pdefs.xsty.grid = 4
                 end
                 '_...  ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, $
                                  'Dash dot dot dot grid lines' $
                    else pdefs.xsty.grid = 5
                 end
                 '__  __': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Long dash grid lines' $
                    else pdefs.xsty.grid = 6
                 end
              endcase
           end
           'Autoscale': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Adjust the X-axis ' + $
                            'scaling to accomodate current data' $
              else case val[2] of
                 'Extend': gr_autoscale, pdefs, /xaxis 
                 'Extend or Shrink': gr_autoscale, pdefs, /xaxis, $
                                                   /ignore
                 'Visible Only': gr_autoscale, pdefs, /xaxis, $
                                              /visible 
              endcase
           end
           'Advanced ...': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Advanced axis ' + $
                            'settings for the X axis' $
              else ichange = gr_axis_adv_menu( pdefs, /xaxis)
           end
        endcase
     end
     'XLAB': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter label for the X axis' $
     else begin
        pdefs.xtitle = event.value
     end
     
     'YMIN': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter minimum value on Y axis ' + $
                   '(floating point)' $
     else begin
        pdefs.yrange(0) = event.value
     end
     
     'YMAX': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter maximum value on Y axis ' + $
                   '(floating point)' $
     else begin
        pdefs.yrange(1) = event.value
     end
     
     'YLOG': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Toggle linear or logarithmic Y axis' $
     else pdefs.ytype = event.index
     
     'YSTY': begin
        val = str_sep(event.value, '/')
        if (n_elements(val) eq 1) then graff_msg, pdefs.ids.hlptxt, $
                                                  'Select Y-axis style options' $
        else case val(1) of
           'Exact Range': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Select exact (On) or ' + $
                            'rounded (Off) Y axis range' $
              else if (val(2) eq 'Off') then  $
                 pdefs.ysty.idl = pdefs.ysty.idl and (not 1) $
              else pdefs.ysty.idl = pdefs.ysty.idl or 1
           end
           'Extended Range': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch "Extended" ' + $
                            'Y-axis range on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.ysty.idl = pdefs.ysty.idl and (not 2) $
              else pdefs.ysty.idl = pdefs.ysty.idl or 2
           end
           'Draw Axes': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch drawing of Y axes ' + $
                            'on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.ysty.idl = pdefs.ysty.idl or 4 $
              else pdefs.ysty.idl = pdefs.ysty.idl and (not 4)
           end
           'Draw Box Axis': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch drawing of ' + $
                            'right-hand Y axis on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.ysty.idl = pdefs.ysty.idl or 8 $
              else pdefs.ysty.idl = pdefs.ysty.idl and (not 8)
           end
           'Minor Ticks': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch drawing of ' + $
                            'Y axis minor tick marks on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.ysty.minor =  1 $
              else pdefs.ysty.minor = 0
           end
           'Annotation': begin
              if (track_flag) then $ $
                 graff_msg, pdefs.ids.hlptxt, 'Switch axis annotation ' + $
                 'on or off' $
              else if (val[2] eq 'Off') then $
                 pdefs.ysty.extra = pdefs.ysty.extra or 4 $
              else pdefs.ysty.extra = pdefs.ysty.extra and (not 4)
           end
           'Time Labelling': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch time-format ' + $
                            'labelling of Y axis on or off' $
              else if (val(2) eq 'On...') then begin
                 to = gr_tm_opts(pdefs.ysty.time, $
                                 pdefs.ysty.tzero, group = $
                                 pdefs.ids.graffer)
                 pdefs.ysty.time = to(0)
                 pdefs.ysty.tzero = to(1)
                 nch = 5
              endif else pdefs.ysty.time = pdefs.ysty.time and (not 1)
           end
           'Origin Axis': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Toggle inclusion of Y ' + $
                            'axis at Y=0' $
              else case val(2) of
                 "On": pdefs.ysty.extra = (pdefs.ysty.extra or 2) $
                                          and (not 8)
                 "Off": pdefs.ysty.extra = pdefs.ysty.extra and (not 10)
                 "Full": pdefs.ysty.extra = pdefs.ysty.extra or 10
              endcase
           end
           'Grid': begin
              if (track_flag and (n_elements(val) eq 2)) then $
                 graff_msg, pdefs.ids.hlptxt, 'Select Y-grid options' $
              else case val(2) of
                 ' None ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'No grid lines' $
                    else pdefs.ysty.grid = 0
                 end
                 
                 '______': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Solid grid lines' $
                    else pdefs.ysty.grid = 1
                 end
                 
                 '......': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dotted grid lines' $
                    else pdefs.ysty.grid = 2
                 end
                 '_ _ _ ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dashed grid lines' $
                    else pdefs.ysty.grid = 3
                 end
                 '_._._.': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dash-dot grid lines' $
                    else pdefs.ysty.grid = 4
                 end
                 '_...  ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, $
                                  'Dash dot dot dot grid lines' $
                    else pdefs.ysty.grid = 5
                 end
                 '__  __': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Long dash grid lines' $
                    else pdefs.ysty.grid = 6
                 end
              endcase
           end
           'Autoscale': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Adjust the Y-axis ' + $
                            'scaling to accomodate current data' $
              else case val[2] of
                 'Extend': gr_autoscale, pdefs, /yaxis
                 'Extend or Shrink': gr_autoscale, pdefs, /yaxis, $
                                                   /ignore
                 'Visible Only': gr_autoscale, pdefs, /yaxis, $
                                              /visible 
              endcase
           end
           'Advanced ...': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Advanced axis ' + $
                            'settings for the Y axis' $
              else ichange = gr_axis_adv_menu(pdefs, /yaxis)
           end
        endcase
     end
     'YLAB': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter label for the Y axis' $
     else begin
        pdefs.ytitle = event.value
     endelse

     'YrMIN': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter minimum value on Y axis ' + $
                   '(floating point)' $
     else begin
        pdefs.yrange_r(0) = event.value
     end
     
     'YrMAX': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter maximum value on Y axis ' + $
                   '(floating point)' $
     else begin
        pdefs.yrange_r(1) = event.value
     end
     
     'YrLOG': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Toggle linear or logarithmic Y axis' $
     else pdefs.ytype_r = event.index
     
     'YrSTY': begin
        val = str_sep(event.value, '/')
        if (n_elements(val) eq 1) then graff_msg, pdefs.ids.hlptxt, $
                                                  'Select Y(r)-axis style options' $
        else case val(1) of
           'Exact Range': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Select exact (On) or ' + $
                            'rounded (Off) Y(r) axis range' $
              else if (val(2) eq 'Off') then  $
                 pdefs.ysty_r.idl = pdefs.ysty_r.idl and (not 1) $
              else pdefs.ysty_r.idl = pdefs.ysty_r.idl or 1
           end
           'Extended Range': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch "Extended" ' + $
                            'Y(r)-axis range on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.ysty_r.idl = pdefs.ysty_r.idl and (not 2) $
              else pdefs.ysty_r.idl = pdefs.ysty_r.idl or 2
           end
           'Draw Axes': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, $
                            'Switch drawing of Y(r) axis on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.ysty_r.idl = pdefs.ysty_r.idl or 4 $
              else pdefs.ysty_r.idl = pdefs.ysty_r.idl and (not 4)
           end
           'Draw Box Axis':     ; Shouldn't happen

           'Minor Ticks': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch drawing of ' + $
                            'Y(r) axis minor tick marks on or off' $
              else if (val(2) eq 'Off') then $
                 pdefs.ysty_r.minor = pdefs.ysty_r.minor or 1 $
              else pdefs.ysty_r.minor = 0
           end
           'Annotation': begin
              if (track_flag) then $ $
                 graff_msg, pdefs.ids.hlptxt, 'Switch axis annotation ' + $
                 'on or off' $
              else if (val[2] eq 'Off') then $
                 pdefs.ysty_r.extra = pdefs.ysty_r.extra or 4 $
              else pdefs.ysty_r.extra = pdefs.ysty_r.extra and (not 4)
           end
           'Time Labelling': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Switch time-format ' + $
                            'labelling of Y(r) axis on or off' $
              else if (val(2) eq 'On...') then begin
                 to = gr_tm_opts(pdefs.ysty_r.time, $
                                 pdefs.ysty_r.tzero, group = $
                                 pdefs.ids.graffer)
                 pdefs.ysty_r.time = to(0)
                 pdefs.ysty_r.tzero = to(1)
                 nch = 5
              endif else pdefs.ysty_r.time = pdefs.ysty_r.time and (not 1)
           end
           'Origin Axis': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Toggle inclusion of Y(r) ' + $
                            'axis at Y=0' $
              else case val(2) of
                 "On": pdefs.ysty_r.extra = (pdefs.ysty_r.extra or 2) $
                                            and (not 8)
                 "Off": pdefs.ysty_r.extra = pdefs.ysty_r.extra and (not 10)
                 "Full": pdefs.ysty_r.extra = pdefs.ysty_r.extra or 10
              endcase
           end
           'Grid': begin
              if (track_flag and (n_elements(val) eq 2)) then $
                 graff_msg, pdefs.ids.hlptxt, 'Select Y(r)-grid options' $
              else case val(2) of
                 ' None ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'No grid lines' $
                    else pdefs.ysty_r.grid = 0
                 end
                 
                 '______': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Solid grid lines' $
                    else pdefs.ysty_r.grid = 1
                 end
                 
                 '......': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dotted grid lines' $
                    else pdefs.ysty_r.grid = 2
                 end
                 '_ _ _ ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dashed grid lines' $
                    else pdefs.ysty_r.grid = 3
                 end
                 '_._._.': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Dash-dot grid lines' $
                    else pdefs.ysty_r.grid = 4
                 end
                 '_...  ': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, $
                                  'Dash dot dot dot grid lines' $
                    else pdefs.ysty_r.grid = 5
                 end
                 '__  __': begin
                    if (track_flag) then $
                       graff_msg, pdefs.ids.hlptxt, 'Long dash grid lines' $
                    else pdefs.ysty_r.grid = 6
                 end
              endcase
           end
           'Autoscale': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Adjust the Y(r)-axis ' + $
                            'scaling to accomodate current data' $
              else case val[2] of
                 'Extend': gr_autoscale, pdefs, yaxis = 2  
                 'Extend or Shrink': gr_autoscale, pdefs, yaxis = $
                                                   2, /ignore
                 'Visible Only': gr_autoscale, pdefs, yaxis = 2, $
                                               /visible 
              endcase
           end
           'Advanced ...': begin
              if (track_flag) then $
                 graff_msg, pdefs.ids.hlptxt, 'Advanced axis ' + $
                            'settings for the Y(r) axis' $
              else ichange = gr_axis_adv_menu(pdefs, yaxis = 2)
           end
        endcase
     end
     'YrLAB': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter label for the Y(r) axis' $
     else begin
        pdefs.ytitle_r = event.value
     end
  endcase

  if (idraw_flag) then gr_plot_object, pdefs
  if (ichange) then begin
     pdefs.chflag = 1b
     pdefs.transient.changes = pdefs.transient.changes+nch
     if (pdefs.transient.changes gt 20) then begin
        gr_bin_save, pdefs, /auto
     endif
  endif
  widget_control, pdefs.ids.chtick, map = pdefs.chflag

Miss_case:

  widget_control, base, set_uvalue = pdefs, /no_copy

end


pro Gr_axis_menu, axis, base, pdefs

tjb = widget_base(base, /column, /frame, xpad = 0, ypad = 0, $
                  space = 0, event_pro = 'gr_axis_event')
junk = widget_label(tjb, value = axis+'-Axis')

                                ; Title

title = graff_enter(tjb, /all_events, value = '', xsize = 25, uvalue = $
                    axis+'LAB', label = axis+' Label:', /track, $
                    /capture, /graphics)


                                ; Log/linear

jb = widget_base(tjb, /row, xpad = 0, ypad = 0, space = 0)
log = widget_droplist(jb, $
                      value = ['Linear', 'Log'], $
                      uvalue = axis+'LOG', $
                      title = axis+' Log/Lin:', $
                      /track)

                                ; Exact or rounded axis range

stydesc = [{CW_PDSMENU_S, flags:3, name:axis+' style', state:0b},  $
           {cw_pdsmenu_s, 1, 'Exact Range', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On', 0b}, $
           {cw_pdsmenu_s, 1, 'Extended Range', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On', 0b}, $
           {cw_pdsmenu_s, 1, 'Draw Axes', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On', 0b}, $
           {cw_pdsmenu_s, 1, 'Draw Box Axis', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On', 0b}, $
           {cw_pdsmenu_s, 1, 'Minor Ticks', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On', 0b}, $
           {cw_pdsmenu_s, 1, 'Annotation', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On', 0b}, $
           {cw_pdsmenu_s, 1, 'Time Labelling', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On...', 0b}, $
           {cw_pdsmenu_s, 1, 'Origin Axis', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 0, 'On', 0b}, $
           {cw_pdsmenu_s, 2, 'Full', 0b}, $
           {cw_pdsmenu_s, 1, 'Grid', 0b}, $
           {cw_pdsmenu_s, 0, ' None ', 0b}, $
           {cw_pdsmenu_s, 0, '______', 0b}, $
           {cw_pdsmenu_s, 0, '......', 0b}, $
           {cw_pdsmenu_s, 0, '_ _ _ ', 0b}, $
           {cw_pdsmenu_s, 0, '_._._.', 0b}, $
           {cw_pdsmenu_s, 0, '_...  ', 0b}, $
           {cw_pdsmenu_s, 2, '__  __', 0b}, $
           {cw_pdsmenu_s, 1, 'Autoscale', 0b}, $
           {cw_pdsmenu_s, 0, 'Extend', 255b}, $
           {cw_pdsmenu_s, 0, 'Extend or Shrink', 255b}, $
           {cw_pdsmenu_s, 2, 'Visible Only', 255b}, $
           {cw_pdsmenu_s, 2, 'Advanced ...', 255b}]

junk = widget_label(jb, value = 'Style:')
junk = cw_pdtsmenu(jb, stydesc, /return_full_name, uvalue = axis+'STY', $
                  /track, delimit = '/', /states, ids = buts)
if (axis eq 'Yr' or (axis eq 'Y' and pdefs.y_right)) then $
  widget_control, buts[10], sensitive = 0
if (axis eq 'Yr') then widget_control, buts[19], sensitive = 0

if axis eq 'Y' then pdefs.ids.y_box = buts[10]
if axis eq 'X' then begin
    pdefs.ids.x_origin = buts[22]
    widget_control, buts[2], sensitive = ~pdefs.y_right
endif

asty_pos = [1, 4, 7, 10, 13, 16, 19, 22, 26]


                                ; Minimum

jb = widget_base(tjb, /row, xpad = 0, ypad = 0, space = 0)

amin = graff_enter(jb, /float, /all_events, value = 0., xsize = 12, $
                   uvalue = axis+'MIN', label = axis+' Min:', format = $
                   "(g14.7)", /track, /capture)

                                ; Maximum

amax = graff_enter(jb, /float, /all_events, value = 0., xsize = 12, $
                   uvalue = axis+'MAX', label = 'Max:', format = $
                   "(g14.7)", /track, /capture)

if (axis eq 'X') then begin
    pdefs.ids.xtitle = title
    pdefs.ids.xlog = log
    pdefs.ids.xmin = amin
    pdefs.ids.xmax = amax
    pdefs.ids.xsty = buts(asty_pos)
endif else if (axis eq 'Y') then begin
    pdefs.ids.ytitle = title
    pdefs.ids.ylog = log
    pdefs.ids.ymin = amin
    pdefs.ids.ymax = amax
    pdefs.ids.ysty = buts(asty_pos)
endif else if (axis eq 'Yr') then begin
    pdefs.ids.ytitle_r = title
    pdefs.ids.ylog_r = log
    pdefs.ids.ymin_r = amin
    pdefs.ids.ymax_r = amax
    pdefs.ids.ysty_r = buts(asty_pos)
endif else message, '** O U C H ** Unknown axis ('+axis+')'

end
