pro bgrp_event, event

  widget_control, event.id, get_uvalue = uv
  print, uv
  help, /str, event

  if uv eq 'QUIT' then widget_control, event.top, /destroy
  
end

pro test_bg

  base = widget_base(/col)

  junk = cw_bgroup(base, $
                   ['one', 'two', 'three', 'four'], $
                   /row, $
                   uvalue = 'IDXR', $
                   label_left = 'Return Index')
  junk = cw_bgroup(base, $
                   ['one', 'two', 'three', 'four'], $
                   /row, $
                   /return_name, $
                   uvalue = 'NMR', $
                   label_left = 'Return Name')
  junk = cw_bgroup(base, $
                   ['one', 'two', 'three', 'four'], $
                   /row, $
                   uvalue = 'BIDR', $
                  /return_id, $
                   label_left = 'Return ID')
  junk = cw_bgroup(base, $
                   ['one', 'two', 'three', 'four'], $
                   button_uv = ['first', 'second', 'third','fourth'], $
                   /row, $
                   uvalue = 'UVR', $
                   label_left = 'Return uvalue')
  
  junk = cw_bgroup(base, $
                   ['one', 'two', 'three', 'four'], $
                   /row, $
                   uvalue = 'EXR', $
                   /exclusive, $
                   set_value = 1, $
                   label_left = 'Exclusive')
  junk = cw_bgroup(base, $
                   ['one', 'two', 'three', 'four'], $
                   /row, $
                   uvalue = 'EXR2', $
                   /exclusive, $
                   set_value = 1, $
                   /no_release, $
                   label_left = 'Exclusive (NR)')
   junk = cw_bgroup(base, $
                   ['one', 'two', 'three', 'four'], $
                   /row, $
                   uvalue = 'NXR', $
                   /nonexclusive, $
                   set_value = [0, 1, 1, 0], $
                   label_left = 'Non-exclusive')

  junk = widget_button(base, $
                       value = 'Quit', $
                       uvalue = 'QUIT')
  
  widget_control, base, /real
  xmanager, 'bgrp', base

end
