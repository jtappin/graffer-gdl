;+
; GR_DS_MENUS
;	Make the menu to set the properties of an XY dataset
;
; Usage:
;	gr_ds_menus, optbb, pdefs
;
; Arguments:
;	optbb	long	input	The widget ID of the parent base
;	pdefs	struct	in/out	The Graffer data & control structure.
;
; History:
;	Farmed out from GRAFFER to facilitate maintenance: 6/12/96;
;	SJT
;	Moved event handler in: 17/1/97; SJT
;	Modify for extended symbol definitions + add compact key:
;	20/1/97; SJT
;	Add CAPTURE key to entry boxes, remove compact key: 6/2/97; SJT
;	Change handles to pointers: 27/6/05
;	Replace most cw_bbselectors with widget_droplist: 13/12/11; SJT
;	Add extra colours: 8/2/12; SJT
; 	Add min & max values: 4/3/15; SJT
;-

pro Gr_dsp_event, event

  widget_control, event.id, get_uvalue = object

  base = widget_info(/child, event.top)
  widget_control, base, get_uvalue = pdefs, /no_copy

  idraw_flag = 1
  ichange = 1b
  track_flag = strpos(tag_names(event, /struct), 'TRACK') ne -1

  if (track_flag) then begin
     idraw_flag = 0
     ichange = 0b
     
     if (event.enter eq 0) then begin
        graff_msg, pdefs.ids.hlptxt, ''
        goto, miss_case
     endif
  endif

  case object of
     'PSYM': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Select plotting symbol for current ' + $
                   'data set' $
     else (*pdefs.data)[pdefs.cset].psym = event.value
     
     'PLINE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Select joining style for current ' + $
                   'data set' $
     else (*pdefs.data)[pdefs.cset].pline = event.index
     
     'SSIZE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set size for plot symbol ' + $
                   'in current data set (floating point)' $
     else (*pdefs.data)[pdefs.cset].symsize = event.value
     
     
     'COLOUR': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Select colour for current data set' $
     else begin
        ncmax = widget_info(event.id, /droplist_number)
        if event.index eq ncmax-1 then begin
           ci = (*pdefs.data)[pdefs.cset].colour
           if ci eq -2 then $
              cc = gr_custom_colour((*pdefs.data)[pdefs.cset].c_vals, $
                                    pdefs.ids.windex) $
           else cc = gr_custom_colour(ci > 0, pdefs.ids.windex)
           if n_elements(cc) eq 1 then begin
              if ci ne -2 then $
                 widget_control, event.id, set_droplist_select = ci+1
           endif else begin
              (*pdefs.data)[pdefs.cset].colour = -2
              (*pdefs.data)[pdefs.cset].c_vals = cc
           endelse
        endif else (*pdefs.data)[pdefs.cset].colour = event.index-1
     endelse

     'STYLE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Select line style for current data set' $
     else (*pdefs.data)[pdefs.cset].line = event.index
     
     'THICK': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set line thickness for current ' + $
                   'data set (integer)' $
     else (*pdefs.data)[pdefs.cset].thick = event.value
     
     'POLAR': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Select rectangular or polar mode' $
     else (*pdefs.data)[pdefs.cset].mode = event.index
     
     'MINVAL': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, $
                   'Set min value to plot for current dataset' $
     else (*pdefs.data)[pdefs.cset].min_val = event.value
     'MAXVAL': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, $
                   'Set max value to plot for current dataset' $
     else (*pdefs.data)[pdefs.cset].max_val = event.value

     'XTRA': begin
        val = str_sep(event.value, '.')
        if (n_elements(val) eq 1) then graff_msg, pdefs.ids.hlptxt, $
                                                  'Set other dataset options' $
        else case val(1) of
           'Sort X axis': if (track_flag) then $
              graff_msg, pdefs.ids.hlptxt, 'Toggle sorting of X axis' + $
                         ' values before plotting current data set' $
           else if (val(2) eq 'On') then $
              (*pdefs.data)[pdefs.cset].sort = 1b $
           else (*pdefs.data)[pdefs.cset].sort = 0b
           
           'Clip to box': if (track_flag) then $
              graff_msg, pdefs.ids.hlptxt, 'Toggle clipping of' + $
                         ' current dataset to plot axes' $
           else  if (val(2) eq 'On') then $
              (*pdefs.data)[pdefs.cset].noclip = 0b $ 
           else (*pdefs.data)[pdefs.cset].noclip = 1b
           
           'Mouse editing':  if (track_flag) then $
              graff_msg, pdefs.ids.hlptxt, 'Toggle use of mouse to ' + $
                         'edit dataset' $
           else begin
              if (val(2) eq 'Enabled') then $
                 (*pdefs.data)[pdefs.cset].medit = 1b $
              else (*pdefs.data)[pdefs.cset].medit = 0b
              
              widget_control, pdefs.ids.draw, get_uvalue = state
              if (state eq 'DRAW') then widget_control, $
                 pdefs.ids.draw, draw_button_events = $
                 (*pdefs.data)[pdefs.cset].medit, track = $
                 (*pdefs.data)[pdefs.cset].medit 
           endelse
        endcase
     end
     
  endcase

  if (idraw_flag) then gr_plot_object, pdefs
  if (ichange) then begin
     pdefs.chflag = 1b
     pdefs.transient.changes = pdefs.transient.changes+1
     if (pdefs.transient.changes gt 20) then begin
        gr_bin_save, pdefs, /auto
     endif
  endif
  widget_control, pdefs.ids.chtick, map = pdefs.chflag

Miss_case:

  widget_control, base, set_uvalue = pdefs, /no_copy

end


pro Gr_ds_menus, optbb, pdefs

  common Gr_psym_maps, psym_bm  ;, col_bm

  if (n_elements(psym_bm) eq 0) then gr_psym_bitm
                                ;, pdefs.transient.colmin

  pdefs.ids.plopts[0] = widget_base(optbb, $
                                    /column, $
                                    event_pro = 'gr_dsp_event')

  jjb = widget_base(pdefs.ids.plopts[0], /row)

  ;; if pdefs.opts.colour_menu then begin
  ;;                               ; We fix the background here rather
  ;;                               ; than at the read stage because:
  ;;                               ; 1) We may not be able to determine
  ;;                               ; the bg at the read stage.
  ;;                               ; 2) It could have changed.
  ;;    wc = widget_info(jjb, /system_colors)
  ;;    col_swatch = col_bm
  ;;    for j = 0, 2 do col_swatch[*, *, j, 0] and= wc.window_bk[j]

  ;;    pdefs.ids.colour = cw_bbselector(jjb, $
  ;;                                     col_swatch, $
  ;;                                     uvalue = 'COLOUR', $
  ;;                                     label_left = 'Colour:', $
  ;;                                     set_value = 2, $
  ;;                                     /track)
  ;; endif else begin
     col_list = ['Omit', $
                 'White (bg)', $
                 'Black', $
                 'Red', $
                 'Green', $
                 'Blue', $
                 'Cyan', $
                 'Magenta', $
                 'Yellow', $
                 'Orange', $
                 '#7f ff 00', $
                 '#00 ff 7f', $
                 '#00 7f ff', $
                 '#7f 00 ff', $
                 'Mauve', $
                 'Dark Grey', $
                 'Light Grey', $
                 'Dark Red', $
                 'Light Red', $
                 'Dark Green', $
                 'Light Green', $
                 'Dark Blue', $
                 'Light Blue', $
                 'Dark Cyan', $
                 'Light Cyan', $
                 'Dark Magenta', $
                 'Light Magenta', $
                 'Dark Yellow', $
                 'Light Yellow', $
                 'Custom']
     pdefs.ids.colour = widget_droplist(jjb, $
                                        value = col_list, $
                                        uvalue = 'COLOUR', $
                                        title = 'Colour:', $
                                        /track)
     widget_control, pdefs.ids.colour, set_droplist_select = 1
  ;; endelse

; This stays as a bbselector as droplists don't do bitmaps
  pdefs.ids.psym = cw_bbselector(jjb, $
                                 psym_bm, $
                                 uvalue = 'PSYM', $
                                 label_left = 'Symbol:', $
                                 /track) 

                                ; Colour, linestyle, thickness etc.

  jjb = widget_base(pdefs.ids.plopts[0], /row)


  pdefs.ids.line = widget_droplist(jjb, $
                                   value = ['____',  $
                                            '....', $
                                            '_ _ ', $
                                            '_._.', $
                                            '_...', $
                                            '__  '], $
                                   uvalue = 'STYLE', $
                                   title = 'Style:', $
                                   /track)


  pdefs.ids.pline = widget_droplist(jjb, $
                                    value = ['None', 'Line', 'Histo'], $
                                    uvalue = 'PLINE', $
                                    title = 'Join:', $
                                    /track)


  jjb = widget_base(pdefs.ids.plopts[0], /row)
  pdefs.ids.thick = graff_enter(jjb, $
                                /float, $
                                format = "(f6.1)", $
                                /all_ev, $
                                xsize = 6, $
                                value = 1., $
                                uvalue = 'THICK', $
                                label = 'Thickness:', $
                                /track, $
                                /capture)

                                ; Change symbol size

  pdefs.ids.symsize = graff_enter(jjb, /float, /all_ev, value = '1.0', $
                                  uvalue = 'SSIZE', xsize = 5, label = $
                                  'Size:', format = "(f5.1)", $
                                  /track, /capture)

  jjb = widget_base(pdefs.ids.plopts[0], $
                    /row)

  pdefs.ids.mode = widget_droplist(jjb, $
                                   value = ['Rect', 'Polar', $
                                            'Polar (°)'], $
                                   uvalue = 'POLAR', $
                                   /track, $
                                   title = 'Coords:')

  xtras = [{CW_PDSMENU_S, flags:3, name:'Extras', state:0b}, $
           {cw_pdsmenu_s, 1, 'Sort X axis', 0b}, $
           {cw_pdsmenu_s, 0, 'Off', 0b}, $
           {cw_pdsmenu_s, 2, 'On', 0b}, $
           {cw_pdsmenu_s, 1, 'Clip to box', 0b}, $
           {cw_pdsmenu_s, 0, 'On', 0b}, $
           {cw_pdsmenu_s, 2, 'Off', 0b}, $
           {cw_pdsmenu_s, 3, 'Mouse editing', 0b}, $
           {cw_pdsmenu_s, 0, 'Disabled', 0b}, $
           {cw_pdsmenu_s, 2, 'Enabled', 0b}]


  junk = cw_pdtsmenu(jjb, xtras, /return_full_name, uvalue = 'XTRA', $
                     /track, /states, ids = buts)
  xpos = [1, 4, 7]
  pdefs.ids.dsxtra = buts(xpos)

  pdefs.ids.minmaxbase = widget_base(pdefs.ids.plopts[0], $
                                     /column)
  pdefs.ids.minval = graff_enter(pdefs.ids.minmaxbase, $
                                 /double, $
                                 format="(g12.4)", $
                                 /all_event, $
                                 xsize=13, $
                                 uvalue='MINVAL', $
                                 label='Min Value:', $
                                 /track, $
                                 /capture, $
                                 /empty_nan)
  pdefs.ids.maxval = graff_enter(pdefs.ids.minmaxbase, $
                                 /double, $
                                 format="(g12.4)", $
                                 /all_event, $
                                 xsize=13, $
                                 uvalue='MAXVAL', $
                                 label='Max Value:', $
                                 /track, $
                                 /capture, $
                                 /empty_nan)

end
