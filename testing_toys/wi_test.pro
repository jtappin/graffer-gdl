pro wi_event, event

  widget_control, event.id, get_uvalue = uv

  help, /str, event
  pp = widget_info(event.id, /parent)
  print, uv, event.id,  ' Parent', pp

  print, 'NCH', widget_info(pp, /n_children), ' First C', $
         widget_info(pp, /child), $
         ' type', widget_info(pp, /type)
  print, 'All C', widget_info(pp, /all_children)
  
  if uv eq 'QUIT' then widget_control, event.top, /destroy
  
end

pro wi_test

  base = widget_base(/col)

  jb = widget_base(base, $
                   /row)
  
  junk = widget_label(jb, $
                      value = 'Label')

  junk = widget_button(jb, $
                       value = 'Button', $
                       uvalue = 'BUTTON')

  
  jb = widget_base(base, $
                   /row, $
                   /nonexclusive)

  for j = 0, 2 do $
     junk = widget_button(jb, $
                          value = string(j+1, format = "('Opt',i1)"), $
                          uvalue = string(j+1, format = $
                                          "('OPT',i1)"))
  
                          
  jb = widget_base(base, $
                   /row, $
                   /exclusive)

  for j = 0, 2 do $
     junk = widget_button(jb, $
                          value = string(j+1, format = "('Ch',i1)"), $
                          uvalue = string(j+1, format = $
                                          "('CH',i1)"))

  jb = widget_base(base, $
                   /row)
  
  junk = widget_label(jb, $
                      value = 'Menu')

  mb = widget_button(jb, $
                       value = 'Menu', $
                       uvalue = 'MENU', $
                       /menu)

  for j = 0, 4 do $
     junk = widget_button(mb, $
                          value = string(j+1, format = "('Menu ',i1)"), $
                          uvalue = string(j+1, format = $
                                          "('MENU',i1)"))

  junk = widget_button(base, $
                       value = "Quit", $
                       uvalue = "QUIT")

  widget_control, base, /real

  xmanager, 'wi', base
end
                          
