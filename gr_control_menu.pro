;+
; GR_CONTROL_MENU
;	Make the main control menu for graffer.
;
; Usage:
;	gr_control_menu, base
;
; Argument:
;	base	long	input	The widget ID of the parent base.
;
; History:
;	Extracted from GRAFFER (& Help button added for X): 18/12/96;
;	SJT
;	Add Accelerators for Key operations: 20/1/09; SJT
;	Add accelerators for Save As operations: 4/11/09; SJT
;	Don't destroy the main structure on restore at this level
;	(allows cancel to work): 20/5/10; SJT
;	Replace cw_pdtmenu wth cw_pdmenu_plus: 28/9/16; SJT
;-

pro Gr_ctl_event, event

  base = widget_info(/child, event.top)
  widget_control, base, get_uvalue = pdefs

  idraw_flag = 1
  dmflag = 0b
  ichange = 1b
  track_flag = strpos(tag_names(event, /struct), 'TRACK') ne -1
  nch = 1

  if track_flag then begin
     idraw_flag = 0
     ichange = 0b
     
     if (event.enter eq 0) then begin
        graff_msg, pdefs.ids.hlptxt, ''
        goto, miss_case
     endif
  endif

  case event.value of
     'File.Exit': if track_flag then  $
        graff_msg, pdefs.ids.hlptxt, 'EXIT from GRAFFER' $
     else begin
        if (pdefs.chflag) then begin
           case dialog_message(['Plot has been modified', $
                                'since last saved', $
                                'Do you want to save it?'], $
                               /question, /cancel, dialog_parent = $
                               pdefs.ids.graffer, resource = 'Graffer') of
              "Cancel": ido = 0b
              "No": ido = 1b
              "Yes": begin
                 graff_save, pdefs
                 ido = 1b
              end
           endcase
        endif else ido = 1b
        if (ido) then begin
           if (not pdefs.chflag) then gr_auto_delete, pdefs
           graff_clear, pdefs
           widget_control, event.top, /destroy
           return
        endif
        idraw_flag = 0
        ichange = 0b
     end
     
     'Hard Copy': graff_msg, pdefs.ids.hlptxt, 'Make PostScript version ' + $
                             'of plot'
     
     'Hard Copy.Set up ...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Define hardcopy parameters and ' + $
                   'make copy' $
     else begin
        ichange = graff_hard(pdefs)
        if (ichange) then nch = 10
     endelse
     
     'Hard Copy.Quick': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Make hardcopy using current settings' $
     else ichange = graff_hard(pdefs, /no_set)
     
     'File': graff_msg, pdefs.ids.hlptxt, 'Saving and opening files'
     
     'File.Save': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Save plot to currently selected ' + $
                   'filename' $
     else begin
        graff_save, pdefs
        ichange = 0b
        idraw_flag = 0
     end
     'File.Save as': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Save plot to an alternative ' + $
                   'filename'  
     
     'File.Save as.Save binary as ...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Save plot to new file name in ' + $
                   'binary format' $
     else begin
        dir = pdefs.dir
        fc = dialog_pickfile(file = pdefs.name, path = dir, $
                             get_path = dir, dialog_parent = $
                             pdefs.ids.graffer, title = 'Graffer ' + $
                             'file', /overwrite_prompt, filter = $
                             "*.grf", /write, resource = 'Graffer')
        if fc ne '' then begin
           pdefs.name = file_basename(fc)
           pdefs.dir = dir
           pdefs.hardset.name = ''
           gr_bin_save, pdefs
           ichange = 0b
           graff_set_vals, pdefs
        end
     end
     'File.Save as.Save ascii as ...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Save plot to new file name in ' + $
                   'ascii format' $
     else begin
        dir = pdefs.dir
        fc = dialog_pickfile(file = pdefs.name, path = dir, $
                             get_path = dir, dialog_parent = $
                             pdefs.ids.graffer, title = 'Graffer ' + $
                             'file', /overwrite_prompt, filter = $
                             "*.grf", /write, resource = 'Graffer')
        if fc ne '' then begin
           pdefs.name = file_basename(fc)
           pdefs.dir = dir
           pdefs.hardset.name = ''
           gr_asc_save, pdefs
           ichange = 0b
           graff_set_vals, pdefs
        endif
     end
     
     'File.Dump screen': graff_msg, pdefs.ids.hlptxt, 'Make a screen ' + $
                                    'dump to an image file'
     
     'File.Dump screen.PNG': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Dump to PNG (Portable Network ' + $
                   'Graphics) file' $ 
     else begin
        graff_dump, pdefs, /png
        ichange = 0b
        idraw_flag = 0
     end
     'File.Dump screen.Tiff': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Dump to TIFF (Tagged Image File ' + $
                   'Format) file' $
     else begin
        graff_dump, pdefs, /tiff
        ichange = 0b
        idraw_flag = 0
     end
     'File.Dump screen.Nrif': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Dump to NRIF (NCAR Raster Image ' + $
                   'File) ' $
     else begin
        graff_dump, pdefs, /nrif
        ichange = 0b
        idraw_flag = 0
     end
     'File.Dump screen.Choose ...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Dump to any image format' $
     else begin
        graff_dump, pdefs, /dialogue
        ichange = 0b
        idraw_flag = 0
     end

     'File.Open ...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Select and open an existing file' $
     else begin
        if (pdefs.chflag) then begin
           case dialog_message(/question, dialog_parent = $
                               pdefs.ids.graffer, /cancel, $
                               ['The current file has not been ' + $
                                'saved', $
                                'since the last changes, do you ' + $
                                'want', $
                                'to save it now?']) of
              'Yes': begin
                 graff_save, pdefs
                 ido = 1b
              end
              'No': ido = 1b
              'Cancel': ido = 0b
           endcase
        endif else ido = 1b
        if (ido) then begin
           igot = graff_get(pdefs, previous_name = pdefs.name)
           dmflag = 1b
        endif
        ichange = 0b
     end
     
     'File.New ...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Create a new file' $
     else begin
        if (pdefs.chflag) then begin
           case dialog_message(/question, dialog_parent = $
                               pdefs.ids.graffer, /cancel, $
                               ['The current file has not been ' + $
                                'saved', $
                                'since the last changes, do you ' + $
                                'want', $
                                'to save it now?']) of
              'Yes': begin
                 graff_save, pdefs
                 ido = 1b
              end
              'No': ido = 1b
              'Cancel': ido = 0b
           endcase
        endif else ido = 1b
        if (ido) then begin
           if (not pdefs.chflag) then gr_auto_delete, pdefs
           dir = pdefs.dir
           fc = dialog_pickfile(file = pdefs.name, path = dir, $
                                get_path = dir, dialog_parent = $
                                pdefs.ids.graffer, title = 'Graffer ' + $
                                'file', /overwrite_prompt, filter = $
                                "*.grf", /write, resource = 'Graffer')
           if (fc eq '') then begin
              graff_msg, pdefs.ids.message, 'New file not given'
           endif else begin
              graff_init, pdefs, fc
              graff_set_vals, pdefs
              dmflag = 1b
           endelse
        end
        ichange = 0b
     end
     
     'Options...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Set special options' $
     else begin
        gr_opt_set, pdefs
        idraw_flag = 0
        ichange = 0b
     end
     
     'Help':  graff_msg, pdefs.ids.hlptxt, 'Display help topics'

     'Help.User Guide...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Show the User Guide' $
     else begin
        graff_docs, pdefs
        idraw_flag = 0
        ichange = 0b
     end

     'Help.File Format...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Show the file format description' $
     else begin
        graff_docs, pdefs, /file_format
        idraw_flag = 0
        ichange = 0b
     end

     'Help.About...': if track_flag then $
        graff_msg, pdefs.ids.hlptxt, 'Show a quick description of the ' + $
                   'version of GRAFFER.' $
     else begin
        msg = ['GRAFFER Version '+string(pdefs.version, format = $
                                         "(I0,'.',I2.2)"), $
               'Copyright: James Tappin 1995-2016']
        junk = dialog_message(msg, $
                              /inform, $
                              dialog_parent = pdefs.ids.graffer, $
                              title = 'About GRAFFER')
        idraw_flag = 0
        ichange = 0b
     end

  endcase

  if dmflag then begin
     widget_control, pdefs.ids.textmode, set_droplist_select = 0
     gr_td_mode, 0, pdefs
  endif

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

  widget_control, base, set_uvalue = pdefs

end


    
pro Gr_control_menu, base

  ctlmenu = [{control_opts, flag:1, label:'File', accelerator:''}, $
             {control_opts, 0, 'Save', 'Ctrl+S'}, $
             {control_opts, 1, 'Save as', ''}, $
             {control_opts, 0, 'Save binary as ...', 'Ctrl+Shift+S'}, $
             {control_opts, 2, 'Save ascii as ...', 'Ctrl+Alt+S'}, $
             {control_opts, 1, 'Dump screen', ''}, $
             {control_opts, 0, 'PNG', 'Ctrl+Alt+P'}, $
             {control_opts, 0, 'Tiff', 'Ctrl+Alt+T'}, $
             {control_opts, 0, 'Nrif', 'Ctrl+Alt+N'}, $
             {control_opts, 2, 'Choose ...', ''}, $
             {control_opts, 0, 'Open ...', 'Ctrl+O'}, $
             {control_opts, 0, 'New ...', 'Ctrl+N'}, $
             {control_opts, 2, 'Exit', 'Ctrl+Q'}, $
             {control_opts, 1, 'Hard Copy', ''}, $
             {control_opts, 0, 'Quick', 'Ctrl+P'}, $
             {control_opts, 2, 'Set up ...', 'Ctrl+Shift+P'}, $
             {control_opts, 0, 'Options...', ''}, $
             {control_opts, 3, 'Help', ''}, $
             {control_opts, 0, 'User Guide...', 'Ctrl+H'}, $
             {control_opts, 0, 'File Format...', ''}, $
             {control_opts, 2, 'About...', ''}]

  jb = widget_base(base, $
                   /row, $
                   space = 0, $
                   xpad = 0, $
                   ypad = 0, $
                   event_pro = 'gr_ctl_event')

  junk = cw_pdmenu_plus(jb, $
                        ctlmenu, $
                        return_type = 'full_name', $
                        uvalue = 'CONTROL', $
                        /track)

end
