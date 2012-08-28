;+
; GRAFF_RESCALE
;	Rescale the current GRAFFER dataset
;
; Usage:
;	ichange = graff_rescale(pdefs)
;
; Return value
;	ichange	int	1 if changed, 0 if not
;
; Argument:
;	prefs	struct	input	The GRAFFER data & control structure.
;
; History:
;	Original: 16/8/96; SJT
;	Made to function returning "cancel" state: 18/12/96; SJT
;	Add CAPTURE key to text inputs: 6/2/97; SJT
;	Replace handles with pointers: 28/6/05; SJT
;-

function Rescale_event, event

widget_control, event.id, get_uvalue = but
widget_control, event.handler, get_uvalue = boxes, /no_copy

iexit = 0
value = 0.

track_flag = strpos(tag_names(event, /struct), 'TRACK') ne -1
if (track_flag) then begin
    idraw = 0
    if (event.enter eq 0) then begin
        graff_msg, boxes(4), ''
        goto, miss_case
    endif
endif

case (but) of
    'CANCEL': if (track_flag) then $
      graff_msg, boxes(4), "Abandon operation and return" $
    else iexit = -1
    
    'DO': if (track_flag) then $
      graff_msg, boxes(4), "Apply scalings and shifts and return" $
    else  begin
        value = fltarr(4)
        for j = 0, 3 do begin
            widget_control, boxes(j), get_value = xy
            value(j) = xy
        endfor
        iexit = 1
    endelse
    
    'XSCALE': if (track_flag) then $
      graff_msg, boxes(4), "Specify scaling factor for X values" $
    else grf_focus_enter, boxes(1)

    'XSHIFT': if (track_flag) then $
      graff_msg, boxes(4), "Specify shift for X values (post scaling units)" $
    else grf_focus_enter, boxes(2)

    'YSCALE': if (track_flag) then $
      graff_msg, boxes(4), "Specify scaling factor for Y values" $
    else grf_focus_enter, boxes(3)

    'YSHIFT': if (track_flag) then $
      graff_msg, boxes(4), "Specify shift for Y values (post scaling units)" $
    else grf_focus_enter, boxes(0)
    
endcase

Miss_case:

widget_control, event.handler, set_uvalue = boxes, /no_copy

return, { $
          Id:      event.id, $
          Top:     event.top,  $
          Handler: 0l,  $
          Value:   value,  $
          Exited:  iexit $
        }

end

function Graff_rescale, pdefs

; Extract the datasets

if ((*pdefs.data)[pdefs.cset].type lt 0) then begin ; This a function -- can't
                                ; rescale a function!
    graff_msg, pdefs.ids.message,  $
      "This a function -- can't rescale a function!"
    return, 0
end
if ((*pdefs.data)[pdefs.cset].ndata eq 0) then begin ; This a new data
                                ; set -- can't 
                                ; rescale no data!
    graff_msg, pdefs.ids.message,  $
      "This an empty dataset -- can't rescale an empty dataset!"
    return, 0
end

widget_control, pdefs.ids.graffer, sensitive = 0

tlb = widget_base(title = 'GRAFFER rescale', group = $
                  pdefs.ids.graffer, resource = 'Graffer')

base = widget_base(tlb, /column)

popper = widget_label(base, value = 'GRAFFER Dataset rescaler')

boxes = lonarr(5)
jb = widget_base(base, /row, /frame)

boxes(0) = graff_enter(jb, label = 'X: Scaling:', value = 1.0, /float, $
                       xsize = 11, uvalue = 'XSCALE', /track, /capture)

boxes(1) = graff_enter(jb, label = 'Shift:', value = 0., /float, xsize $
                       = 11, uvalue = 'XSHIFT', /track, /capture)

jb = widget_base(base, /row, /frame)

boxes(2) = graff_enter(jb, label = 'Y: Scaling:', value = 1.0, /float, $
                       xsize = 11, uvalue = 'YSCALE', /track, /capture)

boxes(3) = graff_enter(jb, label = 'Shift:', value = 0., /float, xsize $
                       = 11, uvalue = 'YSHIFT', /track, /capture)

boxes(4) = widget_text(base, value = '')

jb = widget_base(base, /row)

junk = widget_button(jb, value = '     Cancel    ', uvalue = 'CANCEL', /track)
junk = widget_button(jb, value = '     Do  it    ', uvalue = 'DO', /track)


;	Realise the widgets and use a DIY widget handling procedure
;	(as with all the graffer popups) to facilitate getting values
;	back into the right place.

widget_control, tlb, /real
widget_control, base, set_uvalue = boxes, /no_copy, event_func = $
  'rescale_event'

repeat begin
    ev = widget_event(base)
endrep until (ev.exited ne 0)

widget_control, tlb, /destroy
widget_control, pdefs.ids.graffer, /sensitive 


if (ev.exited lt 0) then return, 0

xydata = *(*pdefs.data)[pdefs.cset].xydata

if ((*pdefs.data)[pdefs.cset].type eq 9) then begin
    
    *xydata.x = *xydata.x*ev.value(0) + ev.value(1)
    *xydata.y = *xydata.y*ev.value(2) + ev.value(3)
    
endif else begin
    xydata(0, *) = xydata(0, *)*ev.value(0) + ev.value(1)
    xydata(1, *) = xydata(1, *)*ev.value(2) + ev.value(3)
    case (*pdefs.data)[pdefs.cset].type of ; Handle error scaling
        0:                      ; No errors nothing to do
        
        1: xydata(2, *) = xydata(2, *)*ev.value(2) ; Y
        2: xydata(2:3, *) = xydata(2:3, *)*ev.value(2) ; YY
        
        3: xydata(2, *) = xydata(2, *)*ev.value(0) ; X
        4: xydata(2:3, *) = xydata(2:3, *)*ev.value(0) ; XX
        
        5: begin                ; XY
            xydata(2, *) = xydata(2, *)*ev.value(0)
            xydata(3, *) = xydata(3, *)*ev.value(2)
        end
        
        6: begin                ; XYY
            xydata(2, *) = xydata(2, *)*ev.value(0)
            xydata(3:4, *) = xydata(3:4, *)*ev.value(2)
        end
        7: begin                ; XXY
            xydata(2:3, *) = xydata(2:3, *)*ev.value(0)
            xydata(4, *) = xydata(4, *)*ev.value(2)
        end
        
        8: begin                ; XXYY
            xydata(2:3, *) = xydata(2:3, *)*ev.value(0)
            xydata(4:5, *) = xydata(4:5, *)*ev.value(2)
        end
    endcase
endelse

*(*pdefs.data)[pdefs.cset].xydata = xydata

return, 1

end
