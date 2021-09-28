; LICENCE:
; Copyright (C) 2016-2021: SJT
; This program is free software; you can redistribute it and/or modify  
; it under the terms of the GNU General Public License as published by  
; the Free Software Foundation; either version 2 of the License, or     
; (at your option) any later version.                                   

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
;	/transparent	If set, then the white surround of the buttons
;			is made transparent.
;	/simple		If set, then use simple text buttons for the
;			adjustments. (/transparent is ignored).
;	/roll		If set, then clicking past the limits rolls
;			the value around to the other limit. Requires
;			both limits to be set. Does not apply to typed
;			values which are still truncated to the limits.
;
; Notes:
;	If an explicit type is not given then if a VALUE is given, it
;	determines the type, otherwise the default integer type is
;	used.
;
;	Event structure:
;	 {id: 0l, $
;         top: 0l, $
;         handler: 0l, $
;         value: <type>, $
;         roll: 0, $    ; +1 if the value was rolled by clicking UP
;         		; past max, -1 if the value was rolled by
;         		; clicking DOWN past min, 0 otherwise.
;         cr: 0b}	; Set to 1 if a CR was entered in the text box.
;
; Ancilliary routines:
;	Routines used to provide functionality the would be provided by
;	widget_control or widget_info for native widgets. (set_ and
;	get_value are available). For set_value, the special values
;	"+1", "-1" (as strings) increment and decrement by 1 honouring
;	the roll settings, and "inc[rement]" and "dec[rement]"
;	increment or decrement by the step value, honouring the roll.
;
;	cw_spin_box_has_limits(id) : Get whether the box has limits
;			returned as [ismin, ismax].
;	cw_spin_box_get_min(id) : Get the minimum value allowed.
;	cw_spin_box_get_max(id) : Get the maximum value allowed.
;	cw_spin_box_get_step(id) : Get the step generated by clicking
;			up or down.
;	cw_spin_box_get_format(id) : Get the format used to display
;			the value.
;	cw_spin_box_get_roll(id) : Get whether the spin box is a
;			rolling box.
;	cw_spin_box_set_min, id, [min | /clear] : Set the lower limit
;			or clear the limit.
;	cw_spin_box_set_max, id, [max | /clear] : Set the upper limit
;			or clear the limit.
;	cw_spin_box_set_format, id, format : Set the format to display
;			the value.
;	cw_spin_box_set_roll, id, roll : Set whether the box can roll
;			over.
;
;	cw_spin_box_get(id) : Get the widget value (usually called via
;			widget_control)
;	cw_spin_box_set, id, value, rolled=rolled : Set the widget
;			value, usually called via widget_control, but
;			can be called natively to allow the rolled
;			keyword to return whether the value was rolled
;			by the increment or decrement special values.
;	cw_spin_box_focus_enter, id : Set the keyboard focus to the
;			text box of the compound.
;
; History:
;	Original: 29/9/16; SJT
;	Add transparent and roll keys: 10/10/16; SJT
;	Better handling of out-of-range values: 8/11/16; SJT
;	Don't return event on focus exit if no changes: 9/11/16; SJT
;	Add /simple option: 23/9/21; SJT
;-

pro cw_spin_box_mk_bitmap, bup, bdown, xextra, $
                           transparent = transparent

; Create up & down arrow bitmaps
  down =  bytarr(9, 5)
  down[4, 0] = 255b
  down[3:5, 1] = 255b
  down[2:6, 2] = 255b
  down[1:7, 3] = 255b
  down[*, 4] = 255b

  up = reverse(down, 2)

  if keyword_set(transparent)  then begin
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
     bdown = gr_cvttobm(down)
     bup = gr_cvttobm(up)
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
  roll = 0
  case but of
     'BOX': begin
        if tag_names(event, /struct) eq 'WIDGET_KBRD_FOCUS' then begin
           if event.enter eq 1 || ~cstruct.eflag then return, 0l
           cr = 1b
        endif else if event.type eq 3  then return, 0l $
        else cr = event.type eq 0b &&  event.ch eq 10b

        if event.type ne 3 then cstruct.eflag = 1b

        catch, an_error
        if an_error ne 0 then begin
           catch, /cancel
           return, 0l
        endif
        
        value = cstruct.value   ; Ensure correct type
        widget_control, event.id, get_value = inln
        reads, inln, value

        catch, /cancel
        
        if cstruct.ismin &&  value lt cstruct.minval then begin
           if ~cr then begin
              widget_control, id2, set_uvalue = cstruct
              return, 0l
           endif
           message, "Value less than minimum, setting to minimum", $
                    /continue 
           cstruct.value = cstruct.minval
           widget_control, cstruct.boxid, set_value = $
                           string(cstruct.value, format = cstruct.format)
        endif else if cstruct.ismax && $
           value gt cstruct.maxval then begin
           if ~cr then begin
              widget_control, id2, set_uvalue = cstruct
              return, 0l
           endif

           message, "Value greater than maximum, setting to maximum", $
                    /continue 
           cstruct.value = cstruct.maxval
           widget_control, cstruct.boxid, set_value = $
                           string(cstruct.value, format = cstruct.format)
        endif else cstruct.value = value

     end
     'UP': begin
        cstruct.value += cstruct.step
        if cstruct.rolls && cstruct.value gt cstruct.maxval then begin
           cstruct.value = cstruct.minval
           roll = 1
        endif else if cstruct.ismax then cstruct.value <= cstruct.maxval
        widget_control, cstruct.boxid, set_value = $
                        string(cstruct.value, format = cstruct.format)
     end
     'DOWN': begin
        cstruct.value -= cstruct.step
        if cstruct.rolls && cstruct.value lt cstruct.minval then begin
           cstruct.value = cstruct.maxval
           roll = -1
        endif else if cstruct.ismin then cstruct.value >= cstruct.minval
        widget_control, cstruct.boxid, set_value = $
                        string(cstruct.value, format = cstruct.format)
     end
  endcase

  widget_control, cstruct.dnid, sensitive = $
                  cstruct.rolls || ~cstruct.ismin || $
                  cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  cstruct.rolls || ~cstruct.ismax || $
                  cstruct.value lt cstruct.maxval

  cstruct.eflag = 0b
  widget_control, id2, set_uvalue = cstruct
  return, {id: event.handler, $
           top: event.top, $
           handler: 0l, $
           value: cstruct.value, $
           roll: roll, $
           cr: cr}

end

; Usually called via widget_control
function cw_spin_box_get, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, cstruct.value
end

function cw_spin_box_has_limits, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, [cstruct.ismin, cstruct.ismax]
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
function cw_spin_box_get_roll, id
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct
  return, cstruct.rolls
end
 

; Usually called via widget_control
pro cw_spin_box_set, id, value, rolled = rolled

  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  if arg_present(rolled) then rolled = 0
  if size(value, /tname) eq 'STRING' then begin
     switch strupcase(value) of
        '+1': begin
           cstruct.value ++
           if cstruct.ismax &&  cstruct.value gt cstruct.maxval then begin
              if cstruct.rolls then begin
                 cstruct.value = cstruct.minval
                 if arg_present(rolled) then rolled = 1
              endif else cstruct.value = cstruct.maxval
           endif
           break
        end
        '-1': begin
           cstruct.value --
           if cstruct.ismin &&  cstruct.value lt cstruct.minval then begin
              if cstruct.rolls then begin
                 cstruct.value = cstruct.maxval 
                 if arg_present(rolled) then rolled = -1
              endif else cstruct.value = cstruct.minval
           endif
           break
        end
        'INC':
        'INCREMENT': begin
           cstruct.value += cstruct.step
           if cstruct.ismax &&  cstruct.value gt cstruct.maxval then begin
              if cstruct.rolls then begin
                 cstruct.value = cstruct.minval 
                 if arg_present(rolled) then rolled = 1
              endif else cstruct.value = cstruct.maxval
           endif
           break
        end
        'DEC':
        'DECREMENT': begin
           cstruct.value -= cstruct.step
           if cstruct.ismin &&  cstruct.value lt cstruct.minval then begin
              if cstruct.rolls then begin
                 cstruct.value = cstruct.maxval 
                 if arg_present(rolled) then rolled = -1
              endif else cstruct.value = cstruct.minval
           endif
           break
        end
        else: begin
           message, /continue, $
                    "Invalid value, ignored"
           return
        end
     endswitch
  endif else begin
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
  endelse

  widget_control, cstruct.boxid, set_value = $
                  string(cstruct.value, format = cstruct.format)
  widget_control, cstruct.dnid, sensitive = $
                  cstruct.rolls || ~cstruct.ismin || $
                  cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  cstruct.rolls || ~cstruct.ismax || $
                  cstruct.value lt cstruct.maxval

  widget_control, id2, set_uvalue = cstruct

end

pro cw_spin_box_set_min, id, minval, clear = clear
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  if keyword_set(clear) then begin
     if cstruct.rolls then begin
        message, /continue, $
                 "Cannot clear the limits on a rolling spin box."
        return
     endif
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
                  cstruct.rolls || ~cstruct.ismin || $
                  cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  cstruct.rolls || ~cstruct.ismax || $
                  cstruct.value lt cstruct.maxval

  widget_control, id2, set_uvalue = cstruct

end

pro cw_spin_box_set_max, id, maxval, clear = clear
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  if keyword_set(clear) then begin
     if cstruct.rolls then begin
        message, /continue, $
                 "Cannot clear the limits on a rolling spin box."
        return
     endif
     cstruct.maxval = 0
     cstruct.ismax = 0b
  endif else begin
     if cstruct.ismin &&  maxval le cstruct.minval then begin
        message, "Cannot have maximum less than minimum", /continue
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
                  cstruct.rolls || ~cstruct.ismin || $
                  cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  cstruct.rolls || ~cstruct.ismax || $
                  cstruct.value lt cstruct.maxval

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

pro cw_spin_box_set_roll, id, roll
  id2 = widget_info(id, /child)
  widget_control, id2, get_uvalue = cstruct

  if roll && ~(cstruct.ismin && cstruct.ismax) then begin
     message, /continue, $
              "Both limits must be set for a rollable box"
     return
  endif

  cstruct.rolls = roll

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
                      transparent = transparent, $
                      simple = simple, roll = roll

  if keyword_set(flat) then $
     message, /continue, $
              "The FLAT keyword has been removed."
  
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
             dnid: 0l, $
             rolls: 0b, $
             eflag: 0b}


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

  if keyword_set(roll) then begin
     if ~cstruct.ismin || ~cstruct.ismax then $
        message, /continue, $
                 "ROLL requires both limits to be set" $
     else cstruct.rolls = 1b
  endif

; Now the gui stuff

  if ~keyword_set(xsize) then xsize = 8
  
  if ~keyword_set(simple) then $
     cw_spin_box_mk_bitmap, bup, bdown, xextra, transparent = $
                            transparent $
  else begin 
     bup = '+'
     bdown = '-'
  endelse

  if keyword_set(column) then base = widget_base(parent, $
                                                 /column) $
  else base = widget_base(parent, /row)

  if keyword_set(label) then junk = widget_label(base, $
                                                 value = label)

  ibase = widget_base(base, $
                      /row, $
                      /base_align_center)

  cstruct.boxid = widget_text(ibase, $
                              xsize = xsize, $
                              ysize = 1, $
                              value = $
                              string(cstruct.value, $
                                     format = cstruct.format), $
                              editable = ~keyword_set(no_edit), $
                              uvalue = 'BOX', $
                              all_events = all_events, $
                              kbrd_focus_events = all_events, $
                              tracking_events = capture_focus)

  if keyword_set(simple) then begin
     sbase = widget_base(ibase, $
                         /row, $
                         xpad = 0, $
                         ypad = 1, $
                         space = 1)

     
     cstruct.dnid = widget_button(sbase, $
                                  value = bdown, $
                                  x_bitmap_extra = xextra, $
                                  uvalue = 'DOWN')
     cstruct.upid = widget_button(sbase, $
                                  value = bup, $
                                  x_bitmap_extra = xextra, $
                                  uvalue = 'UP')
  endif else begin
     sbase = widget_base(ibase, $
                         /column, $
                         xpad = 0, $
                         ypad = 1, $
                         space = 1)

     
     cstruct.upid = widget_button(sbase, $
                                  value = bup, $
                                  x_bitmap_extra = xextra, $
                                  uvalue = 'UP')
     cstruct.dnid = widget_button(sbase, $
                                  value = bdown, $
                                  x_bitmap_extra = xextra, $
                                  uvalue = 'DOWN')
  endelse
  
  widget_control, cstruct.dnid, sensitive = $
                  cstruct.rolls || ~cstruct.ismin || $
                  cstruct.value gt cstruct.minval

  widget_control, cstruct.upid, sensitive = $
                  cstruct.rolls || ~cstruct.ismax || $
                  cstruct.value lt cstruct.maxval

  uid = widget_info(base, /child) ; This will either be the label, or
                                ; the base with the box & buttons, but
                                ; both are passive widgets, so it
                                ; really doesn't matter

  widget_control, uid, set_uvalue = cstruct

  if n_elements(sensitive) eq 0 then iss = 1b $
  else iss = keyword_set(sensitive)
  
  widget_control, base, pro_set_value = 'cw_spin_box_set', $
                  func_get_value = 'cw_spin_box_get', $
                  event_func = 'cw_spin_box_event', $
                  set_uvalue = uvalue, set_uname = uname, $
                  tracking_events = tracking_events, $
                  sensitive = iss

  return, base

end
