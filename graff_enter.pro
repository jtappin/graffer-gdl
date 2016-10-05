;+
; GRAFF_ENTER
;	A labeled text entry field
;
; Usage:
;	id = graff_enter(parent, ...)
;
; Return:
;	id	long	The ID of the compound widget
;
; Argument:
;	parent	long	input	The ID of the base in which the widget
;				will sit.
;
; Keywords:
;	label	string	input	The label to be attached to the entry box
;	value	...	input	The initial value of the widget
;	uvalue	...	input	A user-value for the compound.
;	floating	input	If set then the values are floating point
;	double		input	If set then the values are double precision
;	integer		input	If set then the values are short
;				integers
;	long_int	input	If set then the values are long
;				integers
;	very_long	input	If set, then values are 64-bit integers.
;	unsigned	input	If set, then any integer type is
;				unsigned.
;	text		input	If set, then the values are text
;				strings (default action)
;	format	string	input	The format for displaying the value.
;	xsize	int	input	The size of the text input box (chars)
;	ysize	int	input	The number of rows in the box
;	column		input	If set then put the label above the
;				text box (default is to the left)
;	frame		input	If set, then put a box around the
;				whole compound
;	box		input	If set, then put a box around the text
;				field.
;	all_events	input	If set, then return all events except
;				selection events
;	no_event	input	If set, then don't return events at
;				all.
;	select_events	input	If set and all_events is set, then
;				even return selection events
;	tracking_events	input	If set, then enable cursor tracking
;				events in the text window.
;	capture_focus	input	If set, then putting the cursor into
;				the text-box gives the focus to the widget.
;	array_valued	input	If set, then the widget can accept &
;				return an array of values (normally
;				only scalar values are accepted)
;	scroll		input	If set then make the text widget a
;				scrolling widget.
;	graphics	input	If set and this is a text input box,
;				don't return strings ending in a
;				single pling "!" (To avoid hershey
;				character errors).
;	/empty_nan	input	If set and this is a scalar float or
;				double box, then return a NaN value
;				for an empty box.
;	uname	string	input	A user-defined name for the widget.
;
; Restrictions:
;	If the text window does not contain a valid value for the
;	given type, then the null string is returned by a get_value
;	call.
;
; Notes:
;	If widget_control, id, set_value='LABEL:...' is used, then the
;	label is reset to the part of the string after "LABEL:".
;
; History:
;	Original: 25/8/95; SJT
;	use decoders rather than internal reads: 29/8/95; SJT
;	Add tracking_events key: 4/12/95; SJT
;	Add array_valued and scroll keys: 9/12/96; SJT
;	Modify handler so tracking events can be returned by
;	"non-editable" or "non-event" widgets: 14/1/97; SJT
;	Add CAPTURE_FOCUS key: 6/2/97; SJT
;	Add GRAPHICS key: 12/2/97; SJT
;	Put in "event backlog" trapping to prevent the multiple
;	updating of the plot when a title is typed rapidly: 3/7/97; SJT
;	Add option to set the label by using widget_control: 15/2/12; SJT
;	Get/Set non-finite values as an empty field: 4/3/15; SJT
;	Few code modernizations, get rid of the no_copy's,
;	support 64-bit ints & unsigned: 4/10/16; SJT
;-


pro Grf_focus_enter, id
                                ; Set input focus to the text widget
                                ; id.

  base = widget_info(id, /child)
  widget_control, base, get_uvalue = state

  widget_control, state.text, /input_focus

end


pro Grf_set_enter, id, value
                                ; Set the value of a graff_enter
                                ; widget

  base = widget_info(id, /child)
  widget_control, base, get_uvalue = state

  on_ioerror, no_set

  if (not state.array) then v1 = value[0]  $
  else v1 = value

  sv = size(v1[0], /type)
  if (sv eq 7 && n_elements(value) eq 1 && $
      strpos(v1, 'LABEL:') eq 0) then begin
     widget_control, state.label, set_value = strmid(v1, 6)
     return
  endif

  if (sv ne state.type) then case state.type of
     4: vv = float(v1)
     5: vv = double(v1)
     2: vv = fix(v1)
     3: vv = long(v1)
     7: vv = strtrim(string(v1, /print), 2)
     12: vv = uint(v1)
     13: vv = ulong(v1)
     14: vv = long64(v1)
     15: vv = ulong64(v1)
     Else: message, 'Unknown entry field type'
  endcase else vv = v1

  if state.type eq 7 || ~state.empty_nan || finite(vv)  then $
     vv = string(vv, format = state.format) $
  else vv = ''

  widget_control, state.text, set_value = vv

  return

No_set:

  message, /continue, "Could not convert value to appropriate type."

end



function Grf_get_enter, id
                                ; Get the value of a graff_enter
                                ; widget

  base = widget_info(id, /child)
  widget_control, base, get_uvalue = state

  widget_control, state.text, get_value = txt
  if (not state.array) then txt = txt(0)

  ivv = bytarr((nv0 = n_elements(txt)))

  case state.type of
     4: begin                   ; Float
        val = fltarr(nv0)
        v0 = 0.
     end
     5: begin                   ; Double
        val = dblarr(nv0)
        v0 = 0.d0
     end
     2: begin                   ; Int
        val = intarr(nv0)
        v0 = 0
     end
     3: begin                   ; Long
        val = lonarr(nv0)
        v0 = 0l
     end
     12: begin                  ; UInt
        val = uintarr(nv0)
        v0 = 0u
     end
     13: begin                   ; ULong
        val = ulonarr(nv0)
        v0 = 0ul
     end
     14: begin                  ; Long64
        val = lon64arr(nv0)
        v0 = 0ll
     end
     15: begin                   ; ULong64
        val = ulon64arr(nv0)
        v0 = 0ull
     end
     7: begin                   ; Text
        val = txt
        if (state.graph) then for j = 0, nv0-1 do $
           ivv(j) = (strmid(txt(j), strlen(txt(j))-1, 1) ne '!') ||  $
                    (strmid(txt(j), strlen(txt(j))-2, 2) eq '!!') $
        else ivv(*) = 1b
     end
     
     Else: message, 'Unknown entry field type'
  endcase

  if state.type ne 7 then begin
     on_ioerror, badval
     for j = 0, nv0-1 do begin
        if state.empty_nan && txt[j] eq '' then begin
           val[j] = !values.f_nan
           ivv[j] = 1b
        endif else begin
           reads, txt[j], v0
           val[j] = v0
           ivv[j] = 1b
        endelse

        continue

badval:
        ivv[j] = 0b
     endfor
     on_ioerror, null
  endif

;	Only return "valid" values. If there are no valid values then
;	return a null string for numeric types and zero for text types
;	(this allows a test that the type is right to test if a proper
;	value is present!)

  locs = where(ivv, nv)
  if (nv gt 0) then val = val(locs) $
  else if (state.type eq 7) then val = 0 $
  else val = ''

  if (nv eq 1) then val = val[0] ; Make single value a
                                ; scalar

  return, val

end





function Grf_enter_ev, event
                                ; Process events from a graff_enter
                                ; widget

  if (event.id eq 0l) then return, 0l

  base = widget_info(event.handler, /child)
  widget_control, base, get_uvalue = state

  e_type = tag_names(event, /structure_name)
  if (e_type eq 'WIDGET_TRACKING') then begin
     trkopt = state.track
     if ((trkopt and 2b) ne 0 and event.enter) then $
        widget_control, state.text, /input_focus

     event.id = event.handler
     event.handler = 0l
     if (trkopt) then return, event $
     else return, 0l
  endif

  if (state.dead) then return, 0l ; Not returning events
                                ; Dummy return

  if (event.type eq 3 and not state.select) then $
     return, 0l                 ; Dummy return

  widget_control, event.handler, get_value = val
 
  sv = size(val, /type)
  if (sv ne state.type) then $
     return, 0l                 ; Value wasn't valid don't return
                                ; anything

  cr = 0b
  if (event.type eq 0) then if (event.ch eq 10b) then cr = 1b $
  else begin
     new_event = widget_event(event.handler, /nowait)
  endelse

  ev = { $
       Id:event.handler, $
       Top:event.top, $
       Handler:event.handler, $
       Value:val, $
       cr:cr, $
       Type:state.type $
       }

  widget_control, base, set_uvalue = state

  return, ev

end





function Graff_enter, parent, label=label, value=value, uvalue=uvalue, $
                      floating=floating, integer=integer, text=text, $
                      long_int=long_int, very_long = very_long, $
                      unsigned = unsigned, double = double, $
                      format=format, xsize=xsize, ysize=ysize, $
                      column=column, frame=frame, box=box, $
                      all_events=all_events, no_events=no_events, $
                      select_events=select_events, display=display, $
                      tracking_events=tracking_events, $
                      array_valued=array_valued, scroll=scroll, $
                      capture_focus=capture_focus, graphics=graphics, $
                      empty_nan = empty_nan

                                ; First step: check that unset keys
                                ; are set to something if needed.

  if n_elements(label) eq 0 then label = 'Value:'
  if n_elements(ysize) eq 0 then ysize = 1
  if n_elements(xsize) eq 0 then xsize = 0
  if n_elements(uvalue) eq 0 then uvalue = 0
  if n_elements(frame) eq 0 then frame = 0
  if n_elements(box) eq 0 then box = 0


  all = keyword_set(all_events) && (~ keyword_set(no_events))

  edit = ~keyword_set(display)
  track = keyword_set(tracking_events) or $
          2b*keyword_set(capture_focus)

                                ; Set states according to the type

;sv = size(value)
  if keyword_set(floating) then begin
     if ~keyword_set(format) then format = "(g10.3)"
     vtype = 4                  ; Use the codes from SIZE for
                                ; consistency
     if n_elements(value) eq 0 then value = 0.0
  endif else if keyword_set(double) then begin
     if ~keyword_set(format) then format = "(g12.5)"
     vtype = 5
     if n_elements(value) eq 0 then value = 0.0d0
  endif else if keyword_set(integer) then begin
     if ~keyword_set(format) then format = "(I0)"
     if keyword_set(unsigned) then begin
        vtype = 12
        if n_elements(value) eq 0 then value = 0u
     endif else begin
        vtype = 2
        if n_elements(value) eq 0 then value = 0
     endelse
  endif else if keyword_set(long_int) then begin
     if ~keyword_set(format) then format = "(I0)"
     if keyword_set(unsigned) then begin
        vtype = 13
        if n_elements(value) eq 0 then value = 0ul
     endif else begin
        vtype = 3
        if n_elements(value) eq 0 then value = 0l
     endelse
  endif else if keyword_set(very_long) then begin
     if ~keyword_set(format) then format = "(I0)"
     if keyword_set(unsigned) then begin
        vtype = 15
        if n_elements(value) eq 0 then value = 0ull
     endif else begin
        vtype = 14
        if n_elements(value) eq 0 then value = 0ll
     endelse
  endif else begin              ; No key is the same as /text
     if ~keyword_set(format) then format = "(A)"
     vtype = 7
     if n_elements(value) eq 0 then value = ''
  endelse

  return_nan = keyword_set(empty_nan) && $
     (vtype eq 4 || vtype eq 5) && $
     ~keyword_set(array_valued)

                              ; Define the heirarchy

                                ; This is the top-level base which the
                                ; user will see

  if (n_elements(parent) eq 0) then $
     tlb = widget_base(uvalue = uvalue, $
                       uname = uname) $
  else tlb = widget_base(parent, $
                         uvalue = uvalue, $
                        uname = uname)

                                ; This is the base to contain the
                                ; label and text box, and also has the
                                ; configuration structure as its
                                ; uvalue.

  if (keyword_set(column)) then  $
     base = widget_base(tlb, $
                        /column, $
                        frame = frame) $
  else base = widget_base(tlb, $
                          /row, $
                          frame = frame)

  label = widget_label(base, $
                       value = label, $
                       /dynamic)

  tbox = widget_text(base, $
                     edit = edit, $
                     all_events = all, $
                     frame = box, $
                     xsize = xsize, $
                     ysize = ysize, $
                     tracking_events = keyword_set(tracking_events) || $
                     keyword_set(capture_focus), $
                     scroll = keyword_set(scroll))

  state = { $
          Text:   tbox, $
          label:  label, $
          Dead:   keyword_set(no_events) || keyword_set(display), $
          Type:   vtype, $
          Format: format, $
          Track:  track, $
          Select: keyword_set(select_events), $
          Array:  keyword_set(array_valued), $
          Graph:  keyword_set(graphics) && (vtype eq 7), $
          empty_nan: return_nan $
          }

  widget_control, base, set_uvalue = state

  widget_control, tlb, event_func = 'grf_enter_ev', $
                  func_get_value = 'grf_get_enter', $
                  pro_set_value = 'grf_set_enter', $
                  set_value = value

  return, tlb

end
