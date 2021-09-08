;+
; GR_NAME_WID
;	Request a variable name.
;
; Usage:
; 	name = gr_name_wid(event)
;
; Returns:
;	The name of the variable, or an empty string.
;
; Argument:
;	event	struct	The event in the caller.
;
; History:
;	Original: 3/1/18(?); SJT
;	Document: 3/7/18; SJT
;-

pro grname_event, event

  widget_control, event.top, get_uvalue = state
  widget_control, event.id, get_uvalue = mnu
  case mnu of
     'QUIT': begin
        case event.value of
           'DO': begin
              (*state).action = 1
              widget_control, (*state).namid, get_value = name
              print,  name
              (*state).name = name
           end
           'DONT': begin
              (*state).name = ''
              (*state).action = -1
           end
        endcase
        widget_control, event.top, /destroy
     end
     'NAME':
  endcase
end

function gr_name_wid, event

  defname = 'grf_image'
  
  base = widget_base(group = event.top, $
                     /modal, $
                     /column, $
                     title = "Variable name")

  namid = cw_enter(base, $
                  label = 'Variable name:', $
                   /all, $
                   /capture, $
                   /text, $
                   xsize = 20, $
                   value = defname, $
                   uvalue = 'NAME')

  junk = cw_bgroup(base, $
                   ['Apply', 'Cancel'], $
                   /row, $
                   button_uvalue = ['DO', 'DONT'], $
                   uvalue = 'QUIT')

  state = ptr_new({name: defname, $
                   action: 0, $
                   namid: namid})

  widget_control, base, /real, set_uvalue = state

  xmanager, 'grname', base

  if (*state).action gt 0 then rname = (*state).name $
  else rname = ''

  return, rname
end
