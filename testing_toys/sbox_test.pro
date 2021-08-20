pro sbox_event, event

  widget_control, event.id, get_uvalue = uv

  help, /str, event

  if uv eq 'QUIT' then widget_control, event.top, /destroy
  
end

pro sbox_test

  base = widget_base(/col)

  junk = cw_spin_box(base, $
                     label = 'Integer value', $
                     uvalue = 'INT', $
                     /int, $
                     value = 2)

  junk = cw_spin_box(base, $
                     label = 'Float value', $
                     uvalue = 'FLT', $
                     /float, $
                     value = 2., $
                     format = "(f0.1)")

  junk = cw_spin_box(base, $
                     label = 'Integer value', $
                     uvalue = 'INTT', $
                     /int, $
                     value = 2, $
                     minval = 0, $
                     /track, $
                     /trans)

  junk = cw_spin_box(base, $
                     label = 'Float value', $
                     uvalue = 'FLTT', $
                     /float, $
                     value = 2., $
                     minval = -5., $
                     maxval = 5., $
                     format = "(f0.1)", $
                     /track, $
                     /trans)
  
  junk = widget_button(base, $
                       value = 'Quit', $
                       uvalue = 'QUIT')

  widget_control, base, /real

  xmanager, 'sbox', base

end

  

  
