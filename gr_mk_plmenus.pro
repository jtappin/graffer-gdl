;+
; GR_MK_PLMENUS
;	Make the panel for graffer's general plot settings
;
; Usage:
;	gk_mk_plmenus, base, pdefs
;
; Arguments:
;	base	long	input	The ID of the parent widget.
;	pdefs	struct	in/out	The graffer control structure.
;
; Rationale:
;	To make it easier to keep the compact and regular GRAFFER
;	controls in step.
;
; History:
;	Original (extracted from GRAFFER): 29/11/96; SJT
;	Add CAPTURE key to entry boxes: 6/2/97; SJT
;	Add "Comment" key: 1/7/97; SJT
;	Use cw_spin_box for line width & charsize: 29/9/16; SJT
;	Replace graff_enter with cw_enter: 13/10/16; SJT
;	Add font option: 12/2/20; SJT
;-

pro Gr_pl_event, event

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
        if (object eq 'AUTOSAVE') then  $
           graff_msg, pdefs.ids.message, '' 
        goto, miss_case
     endif
  endif

  case object of
     'TITLE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter plot title (at top of plot)' $
     else begin
        pdefs.title = event.value
     end
     
     'SUBTITLE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter plot subtitle (below plot)' $
     else begin
        pdefs.subtitle = event.value
     end
     
     'CHARSIZE': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter character size for ' + $
                   'annotations (floating point value)' $
     else begin
        pdefs.charsize = event.value
     end
     
     'AXTHICK': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Enter line thickness for axes ' + $
                   '(real value 0.-99.)' $
     else begin
        pdefs.axthick = event.value
     end
     
     'POSITION': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Set positions of plot corners' $
     else begin
        ichange = gr_position(pdefs)
        idraw_flag = ichange
     endelse
     
     
     'KEY': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Control drawing of a key on the plot' $
     else begin
        ichange = gr_key_def(pdefs)
        idraw_flag = ichange
        if (ichange) then nch = 10
     endelse
     
     'COMMENT': if (track_flag) then $
        graff_msg, pdefs.ids.hlptxt, 'Control addition of a general ' + $
                   'comment to the plot' $
     else begin
        ichange = gr_comment(pdefs)
        idraw_flag = 0
        if (ichange) then nch = 5
     endelse
     
     'FONTS': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, "Select whether to use " + $
                   "Hershey/Hardware fonts or TT fonts" $
     else begin
        pdefs.fontopt = event.index
        if pdefs.fontopt eq 0 then !p.font = -1 $
        else !p.font = 1
     endelse
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

pro Gr_mk_plmenus, base, pdefs

  tjb = widget_base(base, $
                    /column, $
                    /frame, $
                    xpad = 0, $
                    ypad = 0, $
                    space = 0, $
                    event_pro = 'gr_pl_event')

  junk = widget_label(tjb, $
                      value = 'General')

  pdefs.ids.title = cw_enter(tjb, $
                             /all_events, $
                             value = '', $
                             xsize = 30, $
                             uvalue = 'TITLE', $
                             label = 'Title:', $
                             /track, $
                             /capture, $
                             /graphics) 

  pdefs.ids.subtitle = cw_enter(tjb, $
                                /all_events, $
                                value = '', $
                                xsize = 30, $
                                uvalue = 'SUBTITLE', $
                                label = 'Subtitle:', $
                                /track, $
                                /capture, $
                                /graphics)

  jb = widget_base(tjb, $
                   /row, $
                   xpad = 0, $
                   ypad = 0, $
                   space = 0)
  pdefs.ids.charsize = cw_spin_box(jb, $
                                   value = 1.0, $
                                   /all_events, $
                                   /double, $
                                   xsize = 6, $
                                   uvalue = 'CHARSIZE', $
                                   label = 'Charsize:', $
                                   format = "(F0.2)", $
                                   step = 0.1, $
                                   /track, $
                                   /capture, $
                                   minval = 0., $
                                   /trans)

  pdefs.ids.axthick = cw_spin_box(jb, $
                                  /double, $
                                  /all_events, $
                                  format = "(f0.1)", $
                                  value = 1., $
                                  xsize = 5, $
                                  uvalue = 'AXTHICK', $
                                  label = 'Line width:', $
                                  /track, $
                                  /capture, $
                                  step = 1., $
                                  minval = 0.0, $
                                  /trans)


  jb = widget_base(tjb, $
                   /row, $
                   xpad = 0, $
                   ypad = 0, $
                   space = 0)
  junk = widget_button(jb, $
                       value = 'Corners...', $
                       uvalue = 'POSITION', $
                       /track)
  junk = widget_button(jb, value = 'Key ...', uvalue = $
                       'KEY', /track)
  junk = widget_button(jb, $
                       value = 'Comment...', $
                       uvalue = 'COMMENT', $
                       /track)
  pdefs.ids.fontsel = widget_droplist(jb, $
                                      value = ['Hershey/HW', $
                                               'TrueType'], $
                                      uvalue = 'FONTS', $
                                      title = 'Fonts:', $
                                      /track)

end
