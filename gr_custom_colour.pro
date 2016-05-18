function gr_cc_event, event

  widget_control, event.id, get_uvalue = mnu
  widget_control, event.handler, get_uvalue = uvs

  display = 0b
  exit = 0
  case mnu of
     'ACTION': exit = event.value
        
     'RED_E': begin
        (*uvs).colour[0] = event.value
        (*uvs).img[*, *, 0] = event.value
        widget_control, (*uvs).rs_id, set_value = event.value
        display = 1b
     end
     'RED_S': begin
        (*uvs).colour[0] = event.value
        (*uvs).img[*, *, 0] = event.value
        widget_control, (*uvs).re_id, set_value = event.value
        display = 1b
     end
     'GRN_E': begin
        (*uvs).colour[1] = event.value
        (*uvs).img[*, *, 1] = event.value
        widget_control, (*uvs).gs_id, set_value = event.value
        display = 1b
     end
     'GRN_S': begin
        (*uvs).colour[1] = event.value
        (*uvs).img[*, *, 1] = event.value
        widget_control, (*uvs).ge_id, set_value = event.value
        display = 1b
     end
     'BLU_E': begin
        (*uvs).colour[2] = event.value
        (*uvs).img[*, *, 2] = event.value
        widget_control, (*uvs).bs_id, set_value = event.value
        display = 1b
     end
     'BLU_S': begin
        (*uvs).colour[2] = event.value
        (*uvs).img[*, *, 2] = event.value
        widget_control, (*uvs).be_id, set_value = event.value
        display = 1b
     end
  endcase

  if display then tv, (*uvs).img, true = 3

  return, {id: event.id, $
           top: event.top, $
           handler: event.handler, $
           exit: exit, $
           value: (*uvs).colour}

end

function gr_custom_colour, index, w0, group = group

;+
; GR_CUSTOM_COLOUR
;	Define a custom colour for a line or text.
;
; Usage:
;	c3 = gr_custom_colour(index)
;
; Returns:
;	A 3-element RGB colour array or -1 if cancel was chosen.
;
; Argument:
;	index	int/byt	Either a scalar current colour index or a
;			3-element byte array for a current custom
;			colour.
;
; History:
;	Original: 17/5/16; SJT
;-

  if n_elements(index) eq 1 then begin
     lcolour = graff_colours(index)
     bcolour = bytarr(3)
     bcolour[0] = lcolour mod 256l
     bcolour[1] = (lcolour / 256l) mod 256l
     bcolour[2] = lcolour / 256l^2
  endif else bcolour = index

  tlb = widget_base(title = "Graffer: Custom colour", $
                    group = group, $
                    resource = 'Graffer', $
                    modal = keyword_set(group))

  base = widget_base(tlb, $
                     /column, $
                    /base_align_center)


  junk = widget_label(base, $
                      value = "Graffer define custom colour")

  jb = widget_base(base, $
                   /row)

  jbb = widget_base(jb, $
                    /column, $
                    /base_align_right)

  re_id = cw_ffield(jbb, $
                    label = 'Red', $
                    /column, $
                    format = "(I3)", $
                    /capture, $
                    xsize = 3, $
                    /int, $
                    value = bcolour[0], $
                    uvalue = 'RED_E')
  rs_id = widget_slider(jbb, $
                        /vertical, $
                        min = 0, $
                        max = 255, $
                        ysize = 300, $
                        value = bcolour[0], $
                        uvalue = 'RED_S')

  jbb = widget_base(jb, $
                    /column, $
                    /base_align_right)

  ge_id = cw_ffield(jbb, $
                    label = 'Green', $
                    /column, $
                    format = "(I3)", $
                    /capture, $
                    xsize = 3, $
                    /int, $
                    value = bcolour[1], $
                    uvalue = 'GRN_E')
  gs_id = widget_slider(jbb, $
                        /vertical, $
                        min = 0, $
                        max = 255, $
                        ysize = 300, $
                        value = bcolour[1], $
                        uvalue = 'GRN_S')


  jbb = widget_base(jb, $
                    /column, $
                    /base_align_right)

  be_id = cw_ffield(jbb, $
                    label = 'Blue', $
                    /column, $
                    format = "(I3)", $
                    /capture, $
                    xsize = 3, $
                    /int, $
                    value = bcolour[2], $
                    uvalue = 'BLU_E')
  bs_id = widget_slider(jbb, $
                        /vertical, $
                        min = 0, $
                        max = 255, $
                        ysize = 300, $
                        value = bcolour[2], $
                        uvalue = 'BLU_S')


  dr_id = widget_draw(base, $
                      xsize = 120, $
                      ysize = 30)

  junk = cw_bgroup(base, $
                   ['Do it', 'Cancel'], $
                   /row, $
                   uvalue = 'ACTION', $
                   button_uvalue = [1, -1])

  img = bytarr(120, 30, 3)
  for j = 0, 2 do img[*, *, j] = bcolour[j]

  uvs = ptr_new({re_id: re_id, $
                 rs_id: rs_id, $
                 ge_id: ge_id, $
                 gs_id: gs_id, $
                 be_id: be_id, $
                 bs_id: bs_id, $
                 colour: bcolour, $
                 img: img})

  widget_control, tlb, /real
  widget_control, dr_id, get_value = win
  wset, win
  tv, img, true = 3

  widget_control, base, set_uvalue = uvs, $
                  event_func = 'gr_cc_event'
  

  repeat begin
     ev = widget_event(base)
  endrep until (ev.exit ne 0)

  wset, w0

  widget_control, tlb, /destroy

  if ev.exit eq -1 then return, -1
  return, ev.value

end
