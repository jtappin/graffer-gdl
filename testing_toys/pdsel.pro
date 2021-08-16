pro pdsel_event, event

  if strpos(tag_names(event, /struct), 'TRACK') ne -1  then return
  
  widget_control, event.id, get_uvalue = object
  case object of
     'QUIT': widget_control, event.top, /destroy
     else: help, /str, event
  endcase
end

pro pdsel

  base = widget_base(title = "Test PD", $
                    /col)

  stydesc = [{AXMENU_OPTS, flag:3, label:'X style', state:0b, $
              group: 0, sensitive: 1b},  $
             {axmenu_opts, 4, 'Exact Range', 0b, 0, 1b}, $
             {axmenu_opts, 4, 'Extended Range', 0b, 0, 1b}, $
             {axmenu_opts, 4, 'Draw Axes', 0b, 0, 1b}, $
             {axmenu_opts, 4, 'Draw Box Axis', 0b, 0, 0b}, $
             {axmenu_opts, 4, 'Minor Ticks', 0b, 0, 1b}, $
             {axmenu_opts, 4, 'Annotation', 0b, 0, 1b}, $
             {axmenu_opts, 4, 'Time Labelling', 0b, 0, 1b}, $
             {axmenu_opts, 1, 'Origin Axis', 0b, 0, 0b}, $
             {axmenu_opts, 4, 'Off', 1b, 1, 1b}, $
             {axmenu_opts, 4, 'On', 0b, 1, 1b}, $
             {axmenu_opts, 6, 'Full', 0b, 1, 1b}, $
             {axmenu_opts, 1, 'Grid', 0b, 0, 1b}, $
             {axmenu_opts, 4, ' None ', 1b, 2, 1b}, $
             {axmenu_opts, 4, '______', 0b, 2, 1b}, $
             {axmenu_opts, 4, '......', 0b, 2, 1b}, $
             {axmenu_opts, 4, '_ _ _ ', 0b, 2, 1b}, $
             {axmenu_opts, 4, '_._._.', 0b, 2, 1b}, $
             {axmenu_opts, 4, '_...  ', 0b, 2, 1b}, $
             {axmenu_opts, 6, '__  __', 0b, 2, 1b}, $
             {axmenu_opts, 1, 'Autoscale', 0b, 0, 1b}, $
             {axmenu_opts, 0, 'Extend', 0b, 0, 1b}, $
             {axmenu_opts, 0, 'Extend or Shrink', 0b, 0, 1b}, $
             {axmenu_opts, 2, 'Visible Only', 0b, 0, 1b}, $
             {axmenu_opts, 2, 'Advanced ...', 0b, 0, 1b}]

  clist = [{clrlist, label: 'Black'}, $
           {clrlist, 'Red'}, $
           {clrlist, 'Green'}, $
           {clrlist, 'Blue'}, $
           {clrlist, 'White'}]

  dsops = [{ds_pd_opts, flag:0, label:'Next'}, $
           {ds_pd_opts, 0, 'Previous'}, $
           {ds_pd_opts, 0, 'New'}, $
           {ds_pd_opts, 3, 'Other'}, $
           {ds_pd_opts, 0, 'Select...'}, $
           {ds_pd_opts, 0, 'Merge...'},  $
           {ds_pd_opts, 0, 'Sort...'},  $
           {ds_pd_opts, 0, 'Erase'}, $
           {ds_pd_opts, 0, 'Delete'}, $
           {ds_pd_opts, 0, 'Write...'}, $
           {ds_pd_opts, 0, 'Copy'}, $
           {ds_pd_opts, 2, 'Export'}]
    
  jb = widget_base(base, $
                   /row)
  junk = widget_label(jb, $
                      value = 'Style:')

  junk = cw_pdmenu_plus(jb, $
                        stydesc, $
                        return_type = 'full_name', $
                        uvalue = 'STY', $
;                        /track, $
                        delimiter = '/', $
                        ids = buts)
;;  widget_control, junk, /sensitive
  
  jb = widget_base(base, $
                   /row)
  junk = widget_label(jb, $
                      value = 'Colour:')

  junk = cw_pdmenu_plus(jb, $
                        clist, $
                        return_type = 'index', $
                        uvalue = 'COLOUR', $
;                        /track, $
                        ids = butc, $
                        /select, $
                        initial = 2)
  

  junk = cw_pdmenu_plus(base, $
                      dsops, $
                      return_type = 'full_name', $
                      uvalue = 'OPTS', $
;                      /track, $
                      ids = buto, $
                      /row)
  
  junk = widget_button(base, $
                       value = 'QUIT', $
                       uvalue = 'QUIT')

  widget_control, base, /real

  xmanager, 'pdsel', base

end
