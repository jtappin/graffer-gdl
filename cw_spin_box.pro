;+
; CW_SPIN_BOX
;	Create a basic spin box widget.
;
; Usage:
;	id = cw_spin_box(parent)
;
; Returns:
;	The widget ID of the compound widget.
;
; Argument:
;	parent	long	The widget ID of the parent base widget.
;
; Keywords:
;	/row		If set then place the label to the left of the
;			box (this is the default)
;	/column		If set, then place the label above the box
;			(the spinners will still be to the right of it)
;	label	string	A label for the box.
;	/float		If set, then return a singe-precision floating
;			point value.
;	/double		If set, then return a double-precision fp value.
;	/int		If set, then return a short integer.
;	/long		If set, then return a long integer.
;	/very_long	If set, then return a 64-bit integer.
;	/byte		If set, then return a byte.
;	/unsigned	If set, then return an unsigned integer, of
;			the selected type. Ignored with a warning for
;			floats, implicit for byte.
;	format	string	A format to use to display the value (only
;			really useful for floats, the default of i0 is
;			generally fine for all ints).
;	minval	type	The lowest value allowed.
;	maxval	type	The highest value allowed.
;	step	type	How much a click on the spin buttons changes
;			the value. Defaults to 1 for integers and 1e-d
;			where d is the number of decimals in the
;			format for floats. Note this won't work
;			right with e, d or g formats.
;	value	type	The initial value for the box. If no type is
;			explicitly given, then the type of the value
;			is used. If no value is given, then minval is
;			used if given, otherwise 0.
;	xsize	int	The size of the box (in characters).		
;	uvalue	any	A user value for the widget
;	uname	string	A user-defined name for the widget.
;	sensitive int	Whether the widget is initially sensitive.
;	/tracking_events	If set, then the widget returns
;			tracking events.
;	/no_edit	If set, then the value can ONLY be changed
;			with the buttons.
;	/all_events	If set, then return events after any change in
;			the box.
;	/capture_focus	If set, then the entry box captures the input
;			focus when the pointer is moved over it.
;	/flat		If set, then generate spin buttons without a
;			"bevel" 
;
; Notes:
;	If an explicit type is not given then if a VALUE is given, it
;	determines the type, otherwise the default integer type is
;	used.
;
; History:
;	Original: 29/9/16; SJT
;-

pro cw_spin_box_mk_bitmap, bup, bdown, xextra, $
                           transparent = transparent

; Create up & down arrow bitmaps
  down =  bytarr(9, 5)
  down[4, 0] = 255b
  down[3:5, 1] = 255b
  down[2:6, 2] = 255b
  down[1:7, 3] = 255b
;  down[1:9, 4] = 255b
  down[*, 4] = 255b
  up = reverse(down, 2)

  if keyword_set(transparent) then begin
     bdown = bytarr([size(down, /dim), 4])
     bup = bytarr([size(up, /dim), 4])
     for j =  0, 2 do begin
        bdown[*, *, j] = not down
        bup[*, *, j] = not up
     endfor
     bdown[*, *, 3] = down
     bup[*, *, 3] = up
     xextra = 0
  endif else begin
     bdown = cvttobm(down)
     bup = cvttobm(up)
     xextra = 7
  endelse
end

pro cw_spin_box_focus_enter, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  widget_control, cstruct.boxid, /input_focus

end
function cw_spin_box_event, event

; Pass tracking events directly
  if tag_names(event, /struct) eq 'WIDGET_TRACKING' then begin  
     if event.handler ne event.id then begin ; Tracking event from the
                                ; text box, capture focus and return a
                                ; non-event
        id2 = widget_info(event.handler, /child)
        widget_control, id2, get_uvalue = cstruct
        if event.enter then widget_control, cstruct.boxid, $
                                            /input_focus
        return, 0l
     endif
     event.handler = 0l
     return, event
  endif

  id2 = widget_info(event.handler, /child)
  widget_control, id2, get_uvalue = cstruct
  widget_control, event.id, get_uvalue = but

  cr = 0b
  case but of
     'BOX': begin
        on_ioerror, invalid
        value = cstruct.value   ; Ensure correct type
        widget_control, event.id, get_value = inln
        reads, inln, value
        cstruct.value = value
        if cstruct.ismin &&  value lt cstruct.minval then begin
           message, "Value less than minimum, setting to minimum", $
                    /continue 
           cstruct.value = cstruct.minval
           widget_control, cstruct.boxid, set_value = $
                           string(cstruct.value, format = cstruct.format)
        endif
        if cstruct.ismax &&  value gt cstruct.maxval then begin
           message, "Value greater than maximum, setting to maximum", $
                    /continue 
           cstruct.value = cstruct.maxval
           widget_control, cstruct.boxid, set_value = $
                           string(cstruct.value, format = cstruct.format)
        endif
        cr = event.type eq 0b &&  event.ch eq 10b
     end
     'UP': begin
        cstruct.value += cstruct.step
        if cstruct.ismax then cstruct.value <= cstruct.maxval
        widget_control, cstruct.boxid, set_value = $
                        string(cstruct.value, format = cstruct.format)
     end
     'DOWN': begin
        cstruct.value -= cstruct.step
        if cstruct.ismin then cstruct.value >= cstruct.minval
        widget_control, cstruct.boxid, set_value = $
                        string(cstruct.value, format = cstruct.format)
     end
  endcase

  widget_control, cstruct.dnid, sensitive = $
                  ~cstruct.ismin || cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  ~cstruct.ismax || cstruct.value lt cstruct.maxval

  widget_control, id2, set_uvalue = cstruct
  return, {id: event.handler, $
           top: event.top, $
           handler: 0l, $
           value: cstruct.value, $
           cr: cr}

invalid:
  return, 0l                    ; Non-structure should be a non-event.

end

function cw_spin_box_get, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, cstruct.value
end
function cw_spin_box_get_min, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, cstruct.minval
end
function cw_spin_box_get_max, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, cstruct.maxval
end
function cw_spin_box_get_step, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, cstruct.step
end
function cw_spin_box_get_format, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, cstruct.format
end

pro cw_spin_box_set, id, value

  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  cstruct.value = value
  if cstruct.ismin &&  value lt cstruct.minval then begin
     message, "Value less than minimum, setting to minimum", $
              /continue 
     cstruct.value = cstruct.minval
  endif
  if cstruct.ismax &&  value gt cstruct.maxval then begin
     message, "Value greater than maximum, setting to maximum", $
              /continue 
     cstruct.value = cstruct.maxval
  endif

  widget_control, cstruct.boxid, set_value = $
                  string(cstruct.value, format = cstruct.format)
  widget_control, cstruct.dnid, sensitive = $
                  ~cstruct.ismin || cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  ~cstruct.ismax || cstruct.value lt cstruct.maxval

  widget_control, id2, set_uvalue = cstruct

end

pro cw_spin_box_set_min, id, minval, clear = clear
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  if keyword_set(clear) then begin
     cstruct.minval = 0
     cstruct.ismin = 0b
  endif else begin
     if cstruct.ismax &&  minval ge cstruct.maxval then begin
        message, "Cannot have minimum greater than maximum", /continue
        return
     endif
     cstruct.minval = minval
     cstruct.ismin = 1b
     if cstruct.value lt minval then begin
        cstruct.value = minval
        widget_control, cstruct.boxid, set_value = $
                        string(cstruct.value, format = cstruct.format)
     endif
  endelse

  widget_control, cstruct.dnid, sensitive = $
                  ~cstruct.ismin || cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  ~cstruct.ismax || cstruct.value lt cstruct.maxval

  widget_control, id2, set_uvalue = cstruct

end

pro cw_spin_box_set_max, id, maxval, clear = clear
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  if keyword_set(clear) then begin
     cstruct.maxval = 0
     cstruct.ismax = 0b
  endif else begin
     if cstruct.ismin &&  maxval ge cstruct.minval then begin
        message, "Cannot have maximum greater than minimum", /continue
        return
     endif
     cstruct.maxval = maxval
     cstruct.ismax = 1b
     if cstruct.value gt maxval then begin
        cstruct.value = maxval
        widget_control, cstruct.boxid, set_value = $
                        string(cstruct.value, format = cstruct.format)
     endif
  endelse

  widget_control, cstruct.dnid, sensitive = $
                  ~cstruct.ismin || cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  ~cstruct.ismax || cstruct.value lt cstruct.maxval

  widget_control, id2, set_uvalue = cstruct

end

pro cw_spin_box_set_step, id, step
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  if step eq 0 then return      ; Do nothing here
  if step lt 0 then message, /continue, $
                             "Step must be a positive value, using " + $
                             "abs"
  cstruct.step = abs(step)
  widget_control, id2, set_uvalue = cstruct

end

pro cw_spin_box_set_format, id, format
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  cstruct.format = format
  widget_control, cstruct.boxid, set_value = $
                  string(cstruct.value, format = cstruct.format)

  widget_control, id2, set_uvalue = cstruct

end

function cw_spin_box, parent, row = row, column = column, $
                      label = label, float = float, double = double, $
                      int = int, long = long, very_long = very_long, $
                      unsigned = unsigned, format = format, $
                      minval = minval, maxval = maxval, step = step, $
                      value = value, uvalue = uvalue, uname = uname, $
                      sensitive = sensitive, no_edit = no_edit, $
                      tracking_events = tracking_events, $
                      all_events = all_events, xsize = xsize, $
                      capture_focus = capture_focus, flat = flat, $
                      transparent = transparent

  if ~widget_info(parent, /valid) then return, 0l

; tt is a place holder to put the correct types into a structure.

  if keyword_set(float) then tt = 0. $
  else if keyword_set(double) then tt = 0.d0 $
  else if keyword_set(long) then begin
     if keyword_set(unsigned) then tt = 0ul $
     else tt = 0l
  endif else if keyword_set(very_long) then begin
     if keyword_set(unsigned) then tt = 0ull $
     else tt = 0ll
  endif else if keyword_set(int) then begin
     if keyword_set(unsigned) then tt = 0us $
     else tt = 0s
  endif else if keyword_set(byte) then tt = 0b $
  else if keyword_set(value) then tt = value-value $
  else if keyword_set(unsigned) then tt = 0u $
  else tt = 0

  tcode = size(tt, /type)

  if (tcode eq 4 || tcode eq 5) && keyword_set(unsigned) then $
     message, /continue, "UNSIGNED Key not applicable to FP types, " + $
              "ignoring"

  cstruct = {value: tt, $
             minval: tt, $
             maxval: tt, $
             step: tt, $
             ismin: 0b, $
             ismax: 0b, $
             format: '', $
             boxid: 0l, $
             upid: 0l, $
             dnid: 0l}


  if keyword_set(format) then cstruct.format = format $
  else if tcode eq 4 || tcode eq 5 then cstruct.format = "(f0.2)" $
  else cstruct.format = "(i0)"

  if keyword_set(step) then begin
     if step lt 0 then $
        message, "STEP should be positive using absolute value", $
                 /continue
     cstruct.step = abs(step)
  endif else if tcode eq 4 or tcode eq 5 then begin
     pp = strpos(cstruct.format, '.', /reverse_search)
     if pp eq -1 then cstruct.step = 0.01 $
     else begin
        pb = strpos(cstruct.format, ')', /reverse_search)
        m = fix(strmid(cstruct.format, pp+1, pb-pp-1))
        cstruct.step =  10.^(-m)
     endelse
  endif else cstruct.step = 1

  if n_elements(minval) ne 0 && n_elements(maxval) ne 0 && $
     minval ge maxval then begin
     message, "MINVAL must be less than MAXVAL, ignoring both", $
              /continue
  endif else begin
     if n_elements(minval) ne 0 then begin
        cstruct.minval = minval
        cstruct.ismin = 1b
     endif else cstruct.ismin = 0b
     if n_elements(maxval) ne 0 then begin
        cstruct.maxval = maxval
        cstruct.ismax = 1b
     endif else cstruct.ismax = 0b
  endelse

  if keyword_set(value) then begin
     cstruct.value = value
     if cstruct.ismin &&  value lt cstruct.minval then begin
        message, "Value less than minimum, setting to minimum", $
                 /continue 
        cstruct.value = cstruct.minval
     endif
     if cstruct.ismax &&  value gt cstruct.maxval then begin
        message, "Value greater than maximum, setting to maximum", $
                 /continue 
        cstruct.value = cstruct.maxval
     endif
  endif else if cstruct.ismin then cstruct.value = cstruct.minval $
  else if cstruct.ismax then cstruct.value = cstruct.maxval $
  else cstruct.value = 0

; Now the gui stuff

  if ~keyword_set(xsize) then xsize = 8
  cw_spin_box_mk_bitmap, bup, bdown, xextra, transparent = transparent

  if keyword_set(column) then base = widget_base(parent, $
                                                 /column) $
  else base = widget_base(parent, /row)

  if keyword_set(label) then junk = widget_label(base, $
                                                 value = label)

  ibase = widget_base(base, $
                      /row)
  cstruct.boxid = widget_text(ibase, $
                              xsize = xsize, $
                              ysize = 1, $
                              value = $
                              string(cstruct.value, $
                                     format = cstruct.format), $
                              editable = ~keyword_set(no_edit), $
                              uvalue = 'BOX', $
                              all_events = all_events, $
                              tracking_events = capture_focus)

  sbase = widget_base(ibase, $
                      /column, $
                      xpad = 0, $
                      ypad = 0, $
                      space = 0)
  cstruct.upid = widget_button(sbase, $
                               value = bup, $
                               x_bitmap_extra = xextra, $
                               uvalue = 'UP', $
                               flat = flat)
  cstruct.dnid = widget_button(sbase, $
                               value = bdown, $
                               x_bitmap_extra = xextra, $
                               uvalue = 'DOWN', $
                               flat = flat)

  widget_control, cstruct.dnid, sensitive = $
                  ~cstruct.ismin || cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  ~cstruct.ismax || cstruct.value lt cstruct.maxval

  uid = widget_info(base, /child) ; This will either be the label, or
                                ; the base with the box & buttons, but
                                ; both are passive widgets, so it
                                ; really doesn't matter

  widget_control, uid, set_uvalue = cstruct

  widget_control, base, pro_set_value = 'cw_spin_box_set', $
                  func_get_value = 'cw_spin_box_get', $
                  event_func = 'cw_spin_box_event', $
                  set_uvalue = uvalue, set_uname = uname, $
                  tracking_events = tracking_events, $
                  sensitive = sensitive

  return, base

end
