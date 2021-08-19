pro tt_event, event

  widget_control, event.id, get_uvalue = uv

  if uv eq 'QUIT' then begin
     widget_control, event.top, /destroy
     return
  endif

  help, /str, event

  ;; if uv eq 'EDIT' && event.type eq 0 && event.ch eq 10 then begin
  ;;                               ; Carriage return is not correctly
  ;;                               ; inserted.
  ;;    widget_control, event.id, get_value = txt
  ;;    txtr = strmid(txt, 0, event.offset) + string(10b) + $
  ;;          strmid(txt, event.offset)
  ;;    widget_control, event.id, set_value = txtr, $
  ;;                    set_text_select = event.offset+1
  ;; endif

  widget_control, event.id, get_value = txt
  help, txt
  
end

pro test_text

  text = ['The WIDGET_TEXT function', 'creates text widgets.', $
          'Text widgets display text', 'and optionally get textual', $
          'input from the user. They can', 'have one or more lines,', $
          'and can optionally contain', 'scroll bars to allow viewing', $
          'more text than can otherwise', 'be displayed on the screen.']
  
  base = widget_base(/col)

  tw1 = widget_text(base, $
                    /edit, $
                    xsize = 30, $
                    ysize = 15, $
                    value = text, $
                    uvalue = 'EDIT')

  
  tw2 = widget_text(base, $
                    /edit, $
                    /all_events, $
                    xsize = 30, $
                    ysize = 15, $
                    value = text, $
                    uvalue = 'EDITALL')

  
  junk = widget_button(base, $
                       value = 'Quit', $
                       uvalue = 'QUIT')

  widget_control, base, /real
  xmanager, 'tt', base

end
