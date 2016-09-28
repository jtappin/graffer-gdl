;+
; CW_PDMENU_PLUS
;	An enhanced version of CW_PDMENU, supporting several extra
;	features.
;
; Usage:
;	id = cw_pdmenu_plus(parent, desc)
;
; Returns:
;	The ID of the generated compound widget.
;
; Arguments:
;	parent	long	The ID of the parent base widget.
;	desc	struct	A descriptor of the menu (see below for
;			details) 
;
; Keywords:
;	column	int	Make the top-level arrange the buttons in
;			column(s)
;	row	int	Make the top-level arrange the buttons in
;			row(s)
;	/mbar		If set and the parent is a menu bar base to
;			generate a menu bar
;	/help		If /mbar is set, then differentiate any help
;			button.
;	return_type str	Specify the type of value to return in the
;			value field of the event structure, may be any
;			of:
;				id: Return the widget id of the button
;				index: Return the index (location in desc).
;				name: Return the button label
;				full_name: Return the full name of the
;					button (i.e. prefixed with all
;					parent button labels).
;				uname: Return a user-specied name
;					(uname tag must be in the
;					descriptor)
;	ids	long	A named variable to return the button ids.
;	uvalue	any	A user-specified value for the widget.
;	uname	string	A user-specified name for the widget.
;	/align_*	The align_* keywords are appied to the
;			generated base widget
;	/tracking_events	If set, then return tracking events.
;	sensitive int	Set the sensitivity of the whole heirarchy.
;	delimiter str	Set the delimiter between the components of
;			the value if return_type is full_name, the
;			default is "."
;
;	Other keys are passed directly to the generated buttons.
;
; Notes:
; 	The descriptor is a structure, with the following tags
; 	recognized: 
;		flag  - Int - 1 = Start of menu sequence
;			      2 = End of menu sequence
;			      4 = Stateful button
;			Values may be or'ed. Buttons parented
;			to the base may not be stateful.
;		label - String with the button's label.
;		accelerator - An accelerator key combination.
;		handler - an event handler for the button and its
;                         children. 
;               uname - A user-defined name for the button.
;               state - Whether the button is initially
;                       selected. Only meaningful if flag and 4.
;               group - Set to non-zero value(s) to group together
;                       stateful buttons that form an exclusive group.        
;		sensitive - Whether a button is initially sensitive or
;                           not. 
;
;               The label tag is required. If the flag tag is absent, 
;               then the first element has a flag of 1, the last has 2
;               and the rest 0.
;
;	The event returned may either be a standard tracking event or
;	has the structure:
;	event = {id: 0, top:0l, handler: 0l, value: <>, state: 0b}
;	For non-stateful buttons, state is always 0.
;
;	The align_* and row/column keys are ignored for a menu bar.
;
;
; CW_PDMENU_PLUS_SET
;	Set the state of a stateful button in a PDMENU_PLUS
;
; Usage:
;	cw_pdmenu_plus_set, id, state
;
; Arguments:
;	id	long	The id of the button to set, or the parent of
;			an exclusive group
;	state	bool	The state to which to set it.
;
; Keyword:
;	index	int	If this is present, then set the
;			index'th child of ID. Normally used to
;			set a button within an exclusive submenu. If
;			index is present, the state argument is
;			optional and defaults to 1b
;
; History:
;	Merger of graffer's two extended pull downs: Sep 2016; SJT
;-

pro cw_pdmenu_plus_set, id, state, index = index

  if n_elements(index) eq 1 then begin
     if n_params() eq 1 then state = 1b
     idlist = widget_info(id, /all_children)
     if idlist[0] eq 0 || index ge n_elements(idlist) then begin
        message, /continue, "Widget has no children, or fewer " + $
                 "then requested index"
        return
     endif
     cw_pdmenu_plus_set, idlist[index], state
  endif else begin
     widget_control, id, get_uvalue = uvalue
     if uvalue.state eq state then return
     uvalue.state = state
     widget_control, id, set_uvalue = uvalue, set_button = state
     if state && uvalue.group ne 0 then cw_pdmenu_plus_set_exclusive, $
        id
  endelse
end

pro cw_pdmenu_plus_set_exclusive, id, parent
  widget_control, id, get_uvalue = uvalue
  group = uvalue.group

  if group eq 0 then return     ; Not a member of a group.

  if n_params() eq 1 then begin
     parent = id
     repeat $
        parent = widget_info(parent, /parent) $
     until widget_info(parent, /type) eq 0
  endif

  idlist = widget_info(parent, /all_children)
  for j = 0, n_elements(idlist)-1 do begin
     if idlist[j] eq id then continue
     if widget_info(idlist[j], /n_children) ne 0 then $
        cw_pdmenu_plus_set_exclusive, id, idlist[j] $
     else begin
        widget_control, idlist[j], get_uvalue = uvg
        if uvg.group eq group then begin
           uvg.state = 0
           widget_control, idlist[j], set_button = 0, $
                           set_uvalue = uvg
        endif
     endelse
  endfor
end

function cw_pdmenu_plus_event, event

  widget_control, event.id, get_uvalue = uvalue

  if tag_names(event, /struct) eq 'WIDGET_TRACKING' then  $
     return, {cw_pdmenu_plus_track_event, $
              id: event.handler, $
              top: event.top, $
              handler: 0l, $
              enter: event.enter, $
              value: uvalue.val} $
  else begin
     if uvalue.check then begin
        uvalue.state = ~uvalue.state
        widget_control, event.id, set_button = uvalue.state, $
                        set_uvalue = uvalue
        if uvalue.state && uvalue.group ne 0 then $
           cw_pdmenu_plus_set_exclusive, event.id, event.handler
     endif
     return, {cw_pdmenu_plus_event, $
              id: event.handler, $
              top: event.top, $
              handler: 0l, $
              value: uvalue.val, $
              select: uvalue.state}
  endelse

end

pro cw_pdmenu_plus_build, parent, desc, idx, nbuttons, etype, is_mb, $
                          dhelp, delimiter, ids, $
                          tracking_events = tracking_events, $
                          prefix = prefix, $
                          _extra = _extra

  base_parent = widget_info(parent, /type) eq 0
  while idx lt nbuttons do begin
     menu = (desc[idx].flag and 1b) ne 0
     if menu && ~is_mb then menu = 2
     check = (desc[idx].flag and 4b) ne 0
     if check && (base_parent || menu ne 0) then $
        message, "Cannot create a checked menu at the top level " + $
                 "or with children"
        
     emenu = (desc[idx].flag and 2b) ne 0
     
     but = widget_button(parent, $
                         value = desc[idx].label, $
                         menu = menu, $
                         checked_menu = check, $
                         tracking_events = tracking_events, $
                         sensitive = desc[idx].sensitive, $
                         uname = desc[idx].uname, $
                         accel = desc[idx].accelerator, $
                         _extra = _extra)
     case etype of
        0: vv = but
        1: vv = idx
        2: vv = desc[idx].label
        3: begin
           if keyword_set(prefix) then $
              vv = prefix+delimiter+desc[idx].label $
           else vv = desc[idx].label
           if menu ne 0 then pfx = vv
        end
        4: vv = desc[idx].uname
     endcase
     uv = {val: vv, $
           check: check, $
           state: desc[idx].state, $
           group: desc[idx].group}
     if check then widget_control, but, set_button = desc[idx].state
     widget_control, but, set_uvalue = uv 
     if desc[idx].handler ne '' then widget_control, $
        but, event_pro = desc[idx].handler

     ids[idx] = but
     idx++
     if menu ne 0 then $
        cw_pdmenu_plus_build, but, desc, idx, nbuttons, etype, is_mb, $
                              dhelp, delimiter, ids, $
                              tracking_events = tracking_events, $
                              prefix = pfx, $
                              _extra = _extra
     
     if emenu then return

  endwhile

  message, /info, "Unterminated menu hierarchy"

end

function cw_pdmenu_plus, parent, udesc, column = column, row = row, $
                         ids = ids, mbar = mbar, help = help, $
                         return_type = return_type, uvalue = uvalue, $
                         uname = uname, sensitive = sensitive, $
                         tracking_events = tracking_events, $
                         align_bottom = align_bottom, $
                         align_top = align_top, $
                         align_left = align_left, $
                         align_right = align_right, $
                         align_center = align_center, $
                         delimeter = delimiter, $
                         _extra = _extra

  on_error, 2

  if n_params() ne 2 then message, "Must give a parent and a menu " + $
                                   "descriptor"
  
  if keyword_set(row) && keyword_set(column) then $
     message, "Cannot set both row and column keys" $
  else if ~keyword_set(row) && ~keyword_set(column) then row = 1

  if size(udesc, /type) ne 8 then message, "Descriptor must be a " + $
                                           "structure"

  dtags = tag_names(udesc)
  have_fields = [where(dtags eq 'LABEL'), $
                 where(dtags eq 'FLAG'), $
                 where(dtags eq 'ACCELERATOR'), $
                 where(dtags eq 'HANDLER'), $
                 where(dtags eq 'UNAME'), $
                 where(dtags eq 'STATE'), $
                 where(dtags eq 'SENSITIVE'), $
                 where(dtags eq 'GROUP')] ne -1
  if ~have_fields[0] then message, "The LABEL field is required " + $
                                   "in the descriptor"

  nbuttons = n_elements(udesc)
  descr = replicate({cw_pdmenu_plus_descr, $
                     label: '', $
                     flag: 0b, $
                     accelerator: '', $
                     handler: '', $
                     uname: '', $
                     state: 0b, $
                     group: 0, $
                     sensitive: 0b},  nbuttons)

  descr.label = udesc.label
  if have_fields[1] then descr.flag = udesc.flag $
  else begin
     descr[0].flag = 1b
     descr[nbuttons-1].flag = 2b
  endelse
  if have_fields[2] then descr.accelerator = udesc.accelerator
  if have_fields[3] then descr.handler = udesc.handler
  if have_fields[4] then descr.uname = udesc.uname
  if have_fields[5] then descr.state = udesc.state
  if have_fields[6] then descr.sensitive = udesc.sensitive $
  else descr.sensitive = 1b
  if have_fields[7] then descr.group = udesc.group

  if ~keyword_set(return_type) then etype = 1 $
  else case strlowcase(return_type) of
     'id': etype = 0
     'index': etype = 1
     'name': etype = 2
     'full_name': etype = 3
     'full name': etype = 3
     'uname': etype = 4
     else: message, "Invalid return event type "+return_type
  endcase

  is_mb = keyword_set(mbar)
  dhelp = is_mb && keyword_set(help) 

  if ~keyword_set(delimiter) then delimiter = '.'

  if is_mb then begin
     base = parent
     widget_control, base, event_func = 'cw_pdmenu_plus_event'
  endif else base = widget_base(parent, $
                                row = row, $
                                column = column, $
                                uvalue = uvalue, $
                                uname = uname, $
                                sensitive = sensitive, $ 
                                align_bottom = align_bottom, $
                                align_top = align_top, $
                                align_left = align_left, $
                                align_right = align_right, $
                                align_center = align_center, $
                                event_func = 'cw_pdmenu_plus_event')
  
  ids = lonarr(nbuttons)

  cw_pdmenu_plus_build, base, descr, 0, nbuttons, etype, is_mb, dhelp, $
                        delimiter, ids, $
                        tracking_events = tracking_events, $
                        _extra = _extra

  return, base

end
  



