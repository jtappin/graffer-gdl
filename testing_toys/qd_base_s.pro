pro bs_event, event

  widget_control, event.top, /destroy
  
end

pro qd_base_s, sensitive = sensitive

  base = widget_base(/col)

  jb = widget_base(base, $
                   /row, $
                   sensitive = sensitive)

  for j = 0, 3 do junk = widget_button(jb, $
                                       value = string(j+1, format = $
                                                      "('Button',i2)"))

  jb = widget_base(base, $
                   /row)
  for j = 4, 7 do junk = widget_button(jb, $
                                       sensitive = sensitive, $
                                       value = string(j+1, format = $
                                                      "('Button',i2)"))

  widget_control, base, /real
  xmanager, 'bs', base

end
  
