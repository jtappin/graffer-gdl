;+
; GR_HARDOPTS
;	Set hardcopy options
;
; Usage
;	gr_hardopts, pdefs	; Not intended for direct user usage
;
; Arguments:
;	pdefs	struct	in/out	The graffer data structure.
;	
; History:
;	Original: 3/8/95; SJT
;	Add timer event to push to front if obscured: 23/8/95; SJT
;	Renamed as GR_HARDOPTS (was hardopts): 18/9/96; SJT
;	Add font selection options: 10/10/96; SJT
;	Replace most cw_bbselectors with widget_droplist: 13/12/11; SJT
;	Allow selection of non-standard filename: 13/2/12; SJT
;	Allow PDF generation: 21/9/16; SJT
;-


function Hopts_event, event

  widget_control, event.id, get_uvalue = but
  widget_control, event.handler, get_uvalue = settings, /no_copy

  iexit = 0

  track_flag = strpos(tag_names(event, /struct), 'TRACK') ne -1

  if (track_flag) then begin
     if (event.enter eq 0) then begin
        graff_msg, settings.action, ''
        goto, miss_case
     endif
  endif

  case but of
     'DO': if (track_flag) then $
        graff_msg, settings.action, 'Save the settings & make the hardcopy' $
     else begin
        iexit = 1
        for j = 0, 1 do begin
           widget_control, settings.cmid(j), get_value = cmd
           if settings.opts.eps then settings.opts.viewer[j] = cmd[0] $
           else settings.opts.action[j] = cmd[0]
        endfor
        widget_control, settings.fileid, get_value = file
        settings.opts.name = file
     end
     'CANCEL': if (track_flag) then $
        graff_msg, settings.action, "Forget new settings &" + $
                   " don't make a hardcopy" $
     else iexit = -1
     
     'COL': if (track_flag) then $
        graff_msg, settings.action, 'Toggle use of colour PostScript' $
     else begin
        settings.opts.colour = event.index
        widget_control, settings.modid, sensitive = event.index
     endelse

     'CMYK': if (track_flag) then $
        graff_msg, settings.action, 'Select RGB or CMYK colour model' $
     else settings.opts.cmyk = event.index

     'EPS': if (track_flag) then $
        graff_msg, settings.action, 'Toggle use of Encapsulated '+ $
                   'PostScript and PDF generation' $
     else begin
        settings.opts.eps = event.index
        widget_control, settings.fileid, get_value = name
        dir = file_dirname(name, /mark)
        if dir eq './' then dir = ''
        fname = file_basename(name)
        dp = strpos(fname, '.', /reverse_search)
        if dp ne -1 then begin
           ;; if settings.opts.eps and 1b then extn = '.eps' $
           ;; else extn = '.ps'
           case settings.opts.eps of
              0: extn = '.ps'
              1: extn = '.eps'
              else: extn = '.pdf'
           endcase
           name = dir+strmid(fname, 0, dp)
           widget_control, settings.fileid, set_value = name+extn
           widget_control, settings.cmid[1], set_value = $
                           'LABEL:'+file_basename(name+extn) 
        endif
        case settings.opts.eps of
           1: begin
              for j = 0, 1 do widget_control, settings.cmid[j], $
                                              set_value = $
                                              settings.opts.viewer[j]
              widget_control, settings.cmid[0], set_value = "LABEL:View " + $
                              "Command:"
           end
           0: begin
              for j = 0, 1 do widget_control, settings.cmid[j], $
                                              set_value = $
                                              settings.opts.action[j]
              widget_control, settings.cmid[0], set_value = "LABEL:Spool " + $
                              "Command:"
           end
           else: begin
              for j = 0, 1 do widget_control, settings.cmid[j], $
                                              set_value = $
                                              settings.opts.pdfviewer[j]
              widget_control, settings.cmid[0], set_value = $
                              "LABEL:PDF View " + $
                              "Command:"
           end
        endcase
     endelse
     
     'ORI': if (track_flag) then $
        graff_msg, settings.action, 'Toggle landscape/portrait orientation' $
     else begin
        settings.opts.orient = event.index
        settings.psize = gr_get_page(settings.opts.psize, $
                                     settings.opts.orient)
        
                                ; Swap over the X & Y sizes of the
                                ; draw page if it overlaps the edge of
                                ; the paper but not otherwise.
        
        if ((event.index eq 1 and $
             settings.opts.size(0) gt settings.psize(0)) or $
            (event.index eq 0 and $
             settings.opts.size(1) gt settings.psize(1))) then begin
           temp = settings.opts.size(0)
           settings.opts.size(0) = settings.opts.size(1)
           settings.opts.size(1) = temp
           widget_control, settings.xsid, set_value = settings.opts.size(0)
           widget_control, settings.ysid, set_value = settings.opts.size(1)
        endif
        
                                ; re-centre
        
        xs = (settings.psize(0)-settings.opts.size(0))/2.
        settings.opts.off(0) = xs
        ys = (settings.psize(1)-settings.opts.size(1))/2.
        settings.opts.off(1) = ys
        
        widget_control, settings.xoffid, set_value = xs
        widget_control, settings.xleftid, set_value = xs
        widget_control, settings.yoffid, set_value = ys
        widget_control, settings.yleftid, set_value = ys
     end
     
     'PSIZE': if (track_flag) then $
        graff_msg, settings.action, 'Toggle A4/Letter sized paper' $
     else begin
        settings.opts.psize = event.index
        settings.psize = gr_get_page(settings.opts.psize, $
                                     settings.opts.orient)
        xlft = settings.psize(0)-settings.opts.off(0)- $
               settings.opts.size(0)
        widget_control, settings.xleftid, set_value = xlft
        ylft = settings.psize(1)-settings.opts.off(1)- $
               settings.opts.size(1)
        widget_control, settings.yleftid, set_value = ylft
     end
     
     'CENTRE': if (track_flag) then $
        graff_msg, settings.action, 'Centre the plot on the page' $
     else begin
        xs = (settings.psize(0)-settings.opts.size(0))/2.
        settings.opts.off(0) = xs
        widget_control, settings.xleftid, set_value = xs
        widget_control, settings.xoffid, set_value = xs
        
        ys = (settings.psize(1)-settings.opts.size(1))/2.
        settings.opts.off(1) = ys
        widget_control, settings.yleftid, set_value = ys
        widget_control, settings.yoffid, set_value = ys
     end
     
     'XSI': if (track_flag) then $
        graff_msg, settings.action, 'Set the X size of the plot (in cm)' $
     else begin
        widget_control, event.id, get_value = sx
        settings.opts.size(0) = sx
        xlft = settings.psize(0)-sx-settings.opts.off(0)
        widget_control, settings.xleftid, set_value = xlft
     end
     'YSI': if (track_flag) then $
        graff_msg, settings.action, 'Set the Y size of the plot (in cm)' $
     else begin
        widget_control, event.id, get_value = sy
        settings.opts.size(1) = sy
        ylft = settings.psize(1)-sy-settings.opts.off(1)
        widget_control, settings.yleftid, set_value = ylft
     end
     'XOFF': if (track_flag) then $
        graff_msg, settings.action, 'Set the X offset of the plot (in cm)' $
     else begin
        widget_control, event.id, get_value = sx
        settings.opts.off(0) = sx
        xlft = settings.psize(0)-sx-settings.opts.size(0)
        widget_control, settings.xleftid, set_value = xlft
     end
     'YOFF': if (track_flag) then $
        graff_msg, settings.action, 'Set the Y offset of the plot (in cm)' $
     else begin
        widget_control, event.id, get_value = sy
        settings.opts.off(1) = sy
        ylft = settings.psize(1)-sy-settings.opts.size(1)
        widget_control, settings.yleftid, set_value = ylft
     end
     
     'FFAMILY': if (track_flag) then $
        graff_msg, settings.action, 'Select the font family for plot ' + $
                   'annotation' $
     else begin
        settings.opts.font.family = event.index
        widget_control, settings.wsid, sensitive = event.index le 9
        for j = 1, 3, 2 do widget_control, settings.wsids(j), $
                                           sensitive = $
                                           event.index le 5
     end
     'FWS': if (track_flag) then $
        graff_msg, settings.action, 'Select the weight & slant for plot ' + $
                   'annotation' $
     else settings.opts.font.wg_sl = event.value
     
     'TIMEST': if (track_flag) then $
        graff_msg, settings.action, 'Toggle printing of a timestamp on ' + $
                   'the plot' $
     else settings.opts.timestamp = event.index
     
     'FILE': if track_flag then $
        graff_msg, settings.action, 'Set the output file name' $
     else widget_control, settings.cmid[1], set_value = $
                          'LABEL:'+file_basename(event.value)

     'PFILE': if track_flag then $
        graff_msg, settings.action, 'Pick the output file name' $
     else begin
        case settings.opts.eps of
           1: filt = '*.eps' 
           0: filt = '*.ps'
           else: filt = '*.pdf'
        endcase

        file = dialog_pickfile(title = "Plot output file", $
                               /write, $
                               /overwrite_prompt, $
                               dialog_parent = event.top, $
                               filter = filt)
        if file ne '' then begin
           widget_control, settings.fileid, set_value = file
           widget_control, settings.cmid[1], set_value = $
                           'LABEL:'+file_basename(file)
        endif
     endelse

     'DFILE': if track_flag then $
        graff_msg, settings.action, 'Reset the output file name to the ' + $
                   'default' $ 
     else begin
        case settings.opts.eps of
           1: extn = '.eps'
           2: extn = '.ps'
           else: extn = '.pdf'
        endcase
        widget_control, settings.fileid, set_value = settings.tname+extn
        widget_control, settings.cmid[1], set_value = $
                        'LABEL:'+file_basename(settings.tname+extn)
     endelse
     
     'CMD':if (track_flag) then $
        graff_msg, settings.action, 'Enter the command for spooling or ' + $
                   'viewing the plot file'
     'SFX':if (track_flag) then $
        graff_msg, settings.action, 'Enter part the command for spooling ' + $
                   'or viewing the plot after the filename'
     
     'FVIEW': if (track_flag) then $
        graff_msg, settings.action, 'Set viewer to the default PS ' + $
                   'viewer' $
     else case settings.opts.eps of
        1: widget_control, settings.cmid[0], set_value = $
                           gr_find_viewer(/ps)
        0:  widget_control, settings.cmid[0], set_value = 'lp'
        else:  widget_control, settings.cmid[0], set_value = $
                               gr_find_viewer(/pdf)
     endcase

     'NOVIEW': if (track_flag) then $
        graff_msg, settings.action, 'Set viewer to "no viewer"' $
     else begin
        widget_control, settings.cmid[0], set_value = ''
        widget_control, settings.cmid[1], set_value = ''
     endelse
     
     Else:     graff_msg, settings.action, "Whaat??????"       
  endcase

  widget_control, settings.xoffid, sensitive = ~(settings.opts.eps and 1)
  widget_control, settings.yoffid, sensitive = ~(settings.opts.eps and 1)
  widget_control, settings.xleftid, sensitive = ~(settings.opts.eps and 1)
  widget_control, settings.yleftid, sensitive = ~(settings.opts.eps and 1)
  widget_control, settings.ctrid, sensitive = ~(settings.opts.eps and 1)

Miss_case:

  widget_control, event.handler, set_uvalue = settings, /no_copy

  return, {id:event.id, $
           top:event.top, $
           handler:event.handler, $
           exited:iexit}

end

function Gr_hardopts, pdefs

  h = pdefs.hardset

  tname = pdefs.name
  dp = strpos(tname, '.', /reverse_search)
  if dp ne -1 then tname = strmid(tname, 0, dp) 
  tname = pdefs.dir+tname

  uvs = { $
        Opts:h, $
        Cmid:lonarr(2), $
        Wsid:0l, $
        Wsids:lonarr(4), $
        Spbase:0l, $
        ctrid: 0l, $
        Xsid:0l, $
        Xoffid:0l, $
        Xleftid:0l, $
        Ysid:0l, $
        Yoffid:0l, $
        Yleftid:0l, $
        fileid: 0l, $
        modid: 0l, $
        Action:0l, $
        Psize:fltarr(2), $
        tname: tname $
        }
  uvs.psize = gr_get_page(h.psize, h.orient)

  widget_control, pdefs.ids.graffer, sensitive = 0

  tlb = widget_base(title = 'Graffer Hard Copy', $
                    group_leader = pdefs.ids.graffer, $
                    resource = 'Graffer')
  base = widget_base(tlb, /column)

                                ; Basic toggle settings

  jb = widget_base(base, /row)

  junk = widget_droplist(jb, $
                         value = ['Monochrome', 'Colour'], $
                         uvalue = 'COL', $
                         /track)
  widget_control, junk, set_droplist_select = h.colour

  junk = widget_droplist(jb, $
                         value = ['Normal', 'Encapsulated', $
                                 'PDF (Print)', 'PDF (LaTeX)'], $
                         uvalue = 'EPS', $
                         /track)
  widget_control, junk, set_droplist_select = h.eps

  junk = widget_droplist(jb, $
                         value = ['Landscape', 'Portrait'], $
                         uvalue = 'ORI', $
                         /track)
  widget_control, junk, set_droplist_select = h.orient

  uvs.modid = widget_droplist(jb, $
                              value = ['RGB', 'CMYK'], $
                              uvalue = 'CMYK', $
                              /track)
  widget_control, uvs.modid, set_droplist_select = h.cmyk

  widget_control, uvs.modid, sensitive = h.colour

                                ; Page size
  cl = widget_base(base, $
                   /row, $
                   xpad = 0, $
                   ypad = 0, $
                   space = 0)

  jb = widget_base(cl, /column)
  junk = widget_droplist(jb, $
                         value = ['A4', 'Letter'], $
                         title = 'Paper size:', $
                         uvalue = 'PSIZE', $
                         /track)
  widget_control, junk, set_droplist_select = h.psize

  uvs.ctrid = widget_button(jb, $
                            value = 'Centre on page', $
                            uvalue = 'CENTRE', $
                            /track, $
                            sensitive = ~(h.eps and 1))
  junk = widget_droplist(jb, $
                         value = ['Off', 'On'], $
                         title = "Plot timestamp", $
                         uvalue = 'TIMEST', $
                         /track)
  widget_control, junk, set_droplist_select = h.timestamp

  jb = widget_base(cl, /column)
  uvs.xsid = graff_enter(jb, $
                         /float, $
                         /all, $
                         label = 'X Size (cm):', $
                         value = h.size[0], $
                         uvalue = 'XSI', $
                         format = "(F5.2)", $
                         xsize = 5, $
                         /track, $
                         /capture)
  uvs.xoffid = graff_enter(jb, $
                           /float, $
                           /all, $
                           label = 'X offset:',  $
                           value = h.off[0], $
                           uvalue = 'XOFF', $
                           format = "(F5.2)", $
                           xsize = 5, $
                           /track, $
                           /capture)
  uvs.xleftid = graff_enter(jb, $
                            /float, $
                            /display, $
                            label = 'X remain:', $
                            value = uvs.psize[0]-h.size[0]-h.off[0], $
                            format = "(F5.2)", $
                            xsize = 5)

  jb = widget_base(cl, /column)
  uvs.ysid = graff_enter(jb, $
                         /float, $
                         /all, $
                         label = 'Y Size (cm):', $
                         value  = h.size[1], $
                         uvalue = 'YSI', $
                         format = "(F5.2)", $
                         xsize = 5, $
                         /track, $
                         /capture)
  uvs.yoffid = graff_enter(jb, $
                           /float, $
                           /all, $
                           label = 'Y offset:',  $
                           value = h.off[1], $
                           uvalue = 'YOFF', $
                           format = "(F5.2)", $
                           xsize = 5, $
                           /track, $
                           /capture)
  uvs.yleftid = graff_enter(jb, $
                            /float, $
                            /display, $
                            label = 'Y remain:', $
                            value = uvs.psize[1]-h.size[1]-h.off[1], $
                            format = "(F5.2)", $
                            xsize = 5)

  jb = widget_base(base, /row)
  junk = widget_droplist(jb, $
                         value = ['Courier',  $
                                  'Helvetica',  $
                                  'Helvetica Narrow',  $
                                  'NC Schoolbook',  $
                                  'Palatino',  $
                                  'Times', $
                                  'Avant Garde Book',  $
                                  'Avant Garde Demi',  $
                                  'Bookman Demi',  $
                                  'Bookman Light',  $
                                  'Zapf Chancery',  $
                                  'Zapf Dingbats', $
                                  'Symbol'], $
                         title = 'Font: Family:', $
                         uvalue = 'FFAMILY', $
                         /track)
  widget_control, junk, set_droplist_select = h.font.family

; Keep the bbselector here as we need to make items non-selectable.
  uvs.wsid = cw_bbselector(jb, $
                           ['Normal',  $
                            'Bold', $
                            'Italic', $
                            'Bold Italic'], $
                           label_left = 'Weight/slope', $
                           set_value = h.font.wg_sl, $
                           uvalue = 'FWS', $
                           ids = bids, $
                           /track)
  uvs.wsids = bids
  widget_control, uvs.wsid, sensitive = h.font.family le 9
  for j = 1, 3, 2 do widget_control, uvs.wsids(j), sensitive = $
                                     h.font.family le 5

                                ; Filename
  jb = widget_base(base, $
                   /row)
  uvs.fileid = graff_enter(jb, $
                           label = 'File: ', $
                           value = h.name, $
                           xsize = 40, $
                           uvalue = 'FILE', $
                           /track, $
                           /capture, $
                           /all_events)
  junk = widget_button(jb, $
                       value = 'Pick ...', $
                       uvalue = 'PFILE', $
                       /track)
  junk = widget_button(jb, $
                       value = 'Default', $
                       uvalue = 'DFILE', $
                       /track)

                                ; Spool command

  uvs.spbase = widget_base(base, /row)

;jb = widget_base(uvs.spbase, /row)
  case h.eps of
     1: begin
        clab = 'View Command:'
        ccmd = h.viewer[0]
        scmd = h.viewer[1]
     end
     0: begin
        clab = 'Spool Command:'
        ccmd = h.action[0]
        scmd = h.action[1]
     end
     else: begin
        clab = 'PDF View Command:'
        ccmd = h.pdfviewer[0]
        scmd = h.pdfviewer[1]
     end
  endcase

  uvs.cmid[0] = graff_enter(uvs.spbase, $
                            label = clab, $
                            value = ccmd, $
                            uvalue = 'CMD', $
                            xsize = 12, $
                            /track, $
                            /capture)

  uvs.cmid(1) = graff_enter(uvs.spbase, $
                            value = scmd, $
                            uvalue = 'SFX', $
                            xsize = 8, $
                            label = file_basename(h.name), $
                            /track, $
                            /capture)

  junk = widget_button(uvs.spbase, $
                       value = 'Default', $
                       uvalue = 'FVIEW')

  junk = widget_button(uvs.spbase, $
                       value = 'None', $
                       uvalue = 'NOVIEW')

  widget_control, uvs.xoffid, sensitive = ~(h.eps and 1)
  widget_control, uvs.yoffid, sensitive = ~(h.eps and 1)
  widget_control, uvs.xleftid, sensitive = ~(h.eps and 1)
  widget_control, uvs.yleftid, sensitive = ~(h.eps and 1)

  uvs.action = graff_enter(base, $
                           /text, $
                           /display, $
                           value = '', $
                           xsize = 65, $
                           label = 'Action:')

                                ; Quit button
  jb = widget_base(base, /row)
  junk = widget_button(jb, $
                       value = '   Cancel   ', $
                       uvalue = 'CANCEL', $
                       /track)
  junk = widget_button(jb, $
                       value = '    Do it    ', $
                       uvalue = 'DO', $
                       /track)

  widget_control, base, set_uvalue = uvs, /no_copy

  widget_control, tlb, /real

;	RYO widget management to allow us to get the values back from
;	the event handler without using a common block, even after the
;	hierarchy has been destroyed.

  widget_control, base, event_func = 'hopts_event'

  repeat begin
     ev = widget_event(base)
  endrep until (ev.exited ne 0)

  widget_control, base, get_uvalue = uvs, /no_copy
  pdefs.hardset = uvs.opts

  widget_control, tlb, /destroy

  widget_control, pdefs.ids.graffer, /sensitive

  return, ev.exited

end
