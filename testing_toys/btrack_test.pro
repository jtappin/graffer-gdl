pro btrack_event, event

  et = tag_names(event, /str) 
  widget_control, event.id, get_uvalue = uv

  print, uv, ' ', et

  if et eq 'WIDGET_TRACKING' then return
  if uv eq 'QUIT' then widget_control, event.top, /destroy

end

pro btrack_test

  base = widget_base(/col)

  jb = widget_base(base, $
                   col = 3)

  for j = 0, 5 do $
     junk = widget_button(jb, $
                          value = string(j+1, format = $
                                         "('Button',i2)"), $ 
                          uvalue = string(j+1, format = $
                                          "('BUT',i2.2)"), $
                          track = j mod 2 eq 0)

  jb = widget_base(base, $
                   col = 3, $
                   /track)

  for j = 6, 11 do $
     junk = widget_button(jb, $
                          value = string(j+1, format = $
                                         "('Button',i2)"), $ 
                          uvalue = string(j+1, format = "('BUT',i2.2)"))

  jb = widget_base(base, $
                   col = 3, $
                   /nonexclusive)

  for j = 12, 17 do $
     junk = widget_button(jb, $
                          value = string(j+1, format = $
                                         "('Button',i2)"), $ 
                          uvalue = string(j+1, format = $
                                          "('BUT',i2.2)"), $
                          track = j mod 2 eq 0)

  jb = widget_base(base, $
                   col = 3, $
                   /exclusive)

  for j = 18, 23 do $
     junk = widget_button(jb, $
                          value = string(j+1, format = $
                                         "('Button',i2)"), $ 
                          uvalue = string(j+1, format = $
                                          "('BUT',i2.2)"), $
                          track = j mod 2 eq 0)

  junk = widget_button(base, $
                       value = 'Quit', $
                       uvalue = 'QUIT')

  widget_control, base, /real
  xmanager, 'btrack', base

end
                                          
  
