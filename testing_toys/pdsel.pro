pro pdsel_event, event
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

  clist = [{clrlist, label: 'Black', sensitive:1b}, $
           {clrlist, 'Red', 1b}, $
           {clrlist, 'Green', 1b}, $
           {clrlist, 'Blue', 1b}, $
           {clrlist, 'White', 1b}]
      
  jb = widget_base(base, $
                   /row)
  junk = widget_label(jb, $
                      value = 'Style:')

  junk = cw_pdmenu_plus(jb, $
                        stydesc, $
                        return_type = 'full_name', $
                        uvalue = 'STY', $
                        /track, $
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
                        /track, $
                        ids = butc, $
                        /select, $
                        initial = 2)
  
  junk = widget_button(base, $
                       value = 'QUIT', $
                       uvalue = 'QUIT')

  
  widget_control, base, /real

  xmanager, 'pdsel', base

end
