;+
; GR_COMMENT
;	Add a "general" comment to the plot file. This comment is not
;	displayed anywhere, it's just an arbitrary piece of text for
;	you to use as you wish.
;
; Usage:
;	ichange=gr_comment(pdefs)
;
; Argument:
;	pdefs	struct	in/out	The Graffer control structure.
;
; History:
;	Original: 1/7/97; SJT
;-

function Gr_comm_event, event

widget_control, event.id, get_uvalue = but
widget_control, event.handler, get_uvalue = txtid

iexit = 0

txt = ''

case but of
    'DO': begin
        widget_control, txtid, get_value = txt
        iexit = 1
    end
    'DONT': iexit = -1
endcase

return, {id:event.id, top:event.top, handler:event.handler, $
         Exited:iexit, value:txt}
end

function Gr_comment, pdefs

base = widget_base(title = 'Graffer comment', resource = 'Graffer', $
                   /column)

txtid = graff_enter(base, /text, /array, /column, /capture,  $
                    xsize = 40, ysize = 20, label = "File description",  $
                    /box, /no_event)
if ptr_valid(pdefs.remarks) then widget_control, txtid, $
  set_value = *pdefs.remarks

jb = widget_base(base, /row)
junk = widget_button(jb, value = '   Cancel   ', uvalue = 'DONT')
junk = widget_button(jb, value = '    Do it    ', uvalue = 'DO')

widget_control, base, /real, event_func = 'gr_comm_event', set_uvalue $
                = txtid

repeat begin
    ev = widget_event(base)
endrep until (ev.exited ne 0)

widget_control, base, /destroy

if (ev.exited eq 1) then begin      ; The DO button
    ptr_free, pdefs.remarks
    if n_elements(ev.value) gt 1 or ev.value[0] ne '' then $
      pdefs.remarks = ptr_new(ev.value)
endif

return, (ev.exited eq 1)

end
