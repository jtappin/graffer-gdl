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
;	/selector	If set, then the widget behaves like a
;			droplist. If this option is set, then there
;			may not be any submenus.
;	initial_selection
;		int	For a selector menu, specify the initially
;			selected item.
;	Other keys are passed directly to the generated buttons.
;
; Notes:
; 	The descriptor is a structure, with the following tags
; 	recognized: 
;		flag  - Int - 1 = Start of menu sequence
;			      2 = End of menu sequence
;			      4 = Stateful button
;			Values may be or'ed. Buttons parented
;			to the base or with children may not be stateful.
;		label - String with the button's label.
;		bitmap - byte array or a pointer to one for a bitmap
;                        label for a button
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
;               Exactly one of the label and bitmap tags is
;               required.
;               If the flag tag is absent, then the first element has
;               a flag of 1, the last has 2 and the rest 0.
;               For a selector menu, the group settings are
;               ignored (with a warning) and set to 1 and flag is
;               implicitly or'ed with 4. A return type of index
;               is also implied.
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
;
; CW_PDMENU_PLUS_GET
;	Get which of a group is selected.
;
; Usage:
;	idx = cw_pdmenu_plus_get(wid[, group])
;
; Returns:
;	The index of the selected button within the intersection of
;	children of WID and members of GROUP.
;
; Arguments:
;	wid	long	The widget id to query (if this is the base of
;			the CW, then children of the first button will
;			be scanned, otherwise direct children of the
;			button are scanned).
;	group	int	Which button group to scan. If not given the 1
;			is used
;
; Keywords:
;	id	long	A named variable to get the widget ID of the
;			selected button.
; Notes:
;	This is mainly a slightly more flexible version of the
;	GET_VALUE function for selectors.
;
; History:
;	Merger of graffer's two extended pull downs: Sep 2016; SJT
;-


function cw_pdmenu_plus_get, wid, group, id = id

  idb = wid
  if widget_info(idb, /type) eq 0 then $
     idb = widget_info(idb, /child)

  id = 0l
  nc = widget_info(idb, /n_children)
  if nc eq 0 then return, -1

  if n_params() eq 1 then group = 1
  ids = widget_info(idb, /all_children)
  
  idx = -1l
  for j = 0, nc-1 do begin
     widget_control, ids[j], get_uvalue = uv
     if uv.group ne group then continue
     idx++
     if uv.state then begin
        id = ids[j]
        return, idx
     endif
  endfor

  return, -1l
end
function cw_pdmenu_plus_get_selector, wid
  return, cw_pdmenu_plus_get(wid, 1)
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

pro cw_pdmenu_plus_set, id, state, index = index

  if n_elements(index) eq 1 then begin
     if n_params() eq 1 then state = 1b
     if widget_info(id, /type) eq 0 then $
        idb = widget_info(id, /child) $
     else idb = id
     idlist = widget_info(idb, /all_children)

     if idlist[0] eq 0 || index ge n_elements(idlist) then begin
        message, /continue, "Widget has no children, or fewer " + $
                 "then requested index"
        return
     endif
     cw_pdmenu_plus_set, idlist[index], state
     widget_control, idlist[index], get_uvalue = uvalue
     locs = where(tag_names(uvalue) eq 'LABEL')
     if locs[0] ge 0 then $
        widget_control, idb, $
                        set_value = uvalue.label

  endif else begin
     widget_control, id, get_uvalue = uvalue
     if uvalue.state eq state then return
     uvalue.state = state
     widget_control, id, set_uvalue = uvalue, set_button = state
     if state && uvalue.group ne 0 then cw_pdmenu_plus_set_exclusive, $
        id
  endelse
end

pro cw_pdmenu_plus_set_selector, id, index
  cw_pdmenu_plus_set, id, index = index
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
     locs = where(tag_names(uvalue) eq 'LABEL')
     if locs[0] ge 0 then $
        widget_control, widget_info(event.id, /parent), $
                        set_value = uvalue.label
     if size(uvalue.val, /type) eq 7 then $
        return, {cw_pdmenu_plus_event_s, $
                 id: event.handler, $
                 top: event.top, $
                 handler: 0l, $
                 value: uvalue.val, $
                 select: uvalue.state} $
     else return, {cw_pdmenu_plus_event_l, $
                   id: event.handler, $
                   top: event.top, $
                   handler: 0l, $
                   value: long(uvalue.val), $
                   select: uvalue.state}
  endelse

end

pro cw_pdmenu_plus_build, parent, desc, idx, nbuttons, etype, is_mb, $
                          dhelp, delimiter, ids, isbitmap, $
                          tracking_events = tracking_events, $
                          prefix = prefix, selector = selector, $
                          _extra = _extra

  base_parent = widget_info(parent, /type) eq 0

  while idx lt nbuttons do begin
     menu = (desc[idx].flag and 1b) ne 0
     if menu && idx ne 0 && keyword_set(selector) then $
        message, "A selector menu cannot have submenus"
     if menu && ~is_mb then menu = 2

     check = (desc[idx].flag and 4b) ne 0
     if check && (base_parent || menu ne 0) then $
        message, "Cannot create a checked menu at the top level " + $
                 "or with children"
        
     emenu = (desc[idx].flag and 2b) ne 0

     if idx eq 0 and keyword_set(selector) then begin
        if isbitmap then bv = bytarr(size(*(desc[1].bitmap), /dim)) $
        else begin
           lmax = max(strlen(desc[1:*].label), mpos)
           bv = desc[mpos].label
           for j = 0, lmax-1 do strput, bv, ' ', j
        endelse
     endif else if isbitmap then bv = *(desc[idx].bitmap) $
     else bv = desc[idx].label
     but = widget_button(parent, $
                         value = bv, $
                         menu = menu, $
                         checked_menu = check, $
                         tracking_events = tracking_events, $
                         sensitive = desc[idx].sensitive, $
                         uname = desc[idx].uname, $
                         accel = desc[idx].accelerator, $
                         _extra = _extra)

     if keyword_set(selector) then vv = idx-1 $
     else case etype of
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

     if keyword_set(selector) &&  idx gt 0 then $
        uv = {val: vv, $
              check: check, $
              state: desc[idx].state, $
              group: desc[idx].group, $
              label: bv $
             } $
     else uv = {val: vv, $
                check: check, $
                state: desc[idx].state, $
                group: desc[idx].group $
               }

     if check then widget_control, but, set_button = desc[idx].state
     widget_control, but, set_uvalue = uv 
     if desc[idx].handler ne '' then widget_control, $
        but, event_pro = desc[idx].handler

     ids[idx] = but
     idx++
     if menu ne 0 then $
        cw_pdmenu_plus_build, but, desc, idx, nbuttons, etype, is_mb, $
                              dhelp, delimiter, ids, isbitmap, $
                              tracking_events = tracking_events, $
                              prefix = pfx, selector = selector, $
                              _extra = _extra
     
     if emenu then return

  endwhile

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
                         delimiter = delimiter, $
                         selector = selector, $
                         initial_selection = initial_selection, $
                         _extra = _extra

;  on_error, 2

  if n_params() ne 2 then message, "Must give a parent and a menu " + $
                                   "descriptor"
  
  if keyword_set(row) && keyword_set(column) then $
     message, "Cannot set both row and column keys" $
  else if ~keyword_set(row) && ~keyword_set(column) then row = 1

  if size(udesc, /type) ne 8 then message, "Descriptor must be a " + $
                                           "structure"

  dtags = tag_names(udesc)
  have_fields = [where(dtags eq 'LABEL'), $
                 where(dtags eq 'BITMAP'), $
                 where(dtags eq 'FLAG'), $
                 where(dtags eq 'ACCELERATOR'), $
                 where(dtags eq 'HANDLER'), $
                 where(dtags eq 'UNAME'), $
                 where(dtags eq 'STATE'), $
                 where(dtags eq 'SENSITIVE'), $
                 where(dtags eq 'GROUP')] ne -1
  if ~have_fields[0] && ~have_fields[1] then $
     message, "Either the LABEL field or the BITMAP field is required " + $
              "in the descriptor"

  if have_fields[0] && have_fields[1] then $
     message, "Only one of the LABEL and BITMAP fields may be given"

  isbitmap = have_fields[1]
  ioff = keyword_set(selector)

  nbuttons = n_elements(udesc) + ioff
  if isbitmap then begin
     descr = replicate({cw_pdmenu_plus_descr_bm, $
                        bitmap: ptr_new(), $
                        flag: 0b, $
                        accelerator: '', $
                        handler: '', $
                        uname: '', $
                        state: 0b, $
                        group: 0, $
                        sensitive: 0b},  nbuttons)
     if size(udesc[0].bitmap, /type) eq 10 then $
        for j = ioff, nbuttons-1 do *(descr[j].bitmap) = $
        *(udesc[j-ioff].bitmap) $
     else  for j = ioff, nbuttons-1 do descr[j].bitmap = $
        ptr_new(udesc[j-ioff].bitmap) 
  endif else begin
     descr = replicate({cw_pdmenu_plus_descr, $
                        label: '', $
                        flag: 0b, $
                        accelerator: '', $
                        handler: '', $
                        uname: '', $
                        state: 0b, $
                        group: 0, $
                        sensitive: 0b},  nbuttons)
     descr[ioff:*].label = udesc.label
  endelse

  if have_fields[2] then descr[ioff:*].flag = udesc.flag $
  else begin
     descr[0].flag = 1b
     descr[nbuttons-1].flag = 2b
  endelse
  if keyword_set(selector) then descr[1:*].flag or= 4b

  if have_fields[3] then descr[ioff:*].accelerator = udesc.accelerator
  if have_fields[4] then descr[ioff:*].handler = udesc.handler
  if have_fields[5] then descr[ioff:*].uname = udesc.uname
  if have_fields[6] then descr[ioff:*].state = udesc.state
  if have_fields[7] then begin
     descr[0].sensitive = 1b
     descr[ioff:*].sensitive = udesc.sensitive
  endif else descr.sensitive = 1b
  if keyword_set(selector) then begin
     descr[0].group = 0
     descr[1:*].group = 1
  endif else if have_fields[8] then $
     descr.group = udesc.group
  
  if ~keyword_set(return_type) || $
     keyword_set(selector) then etype = 1 $
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

  cw_pdmenu_plus_build, base, descr, 0l, nbuttons, etype, is_mb, $
                        dhelp, delimiter, ids, isbitmap, $
                        selector = selector, $
                        tracking_events = tracking_events, $
                        _extra = _extra

  if keyword_set(selector) then begin
     if n_elements(initial_selection) ne 0 then $
        cw_pdmenu_plus_set, base, index = initial_selection $
     else cw_pdmenu_plus_set, base, index = 0
     ids = ids[1:*]
     widget_control, base, $
                     pro_set_value = 'cw_pdmenu_plus_set_selector', $
                     func_get_value = 'cw_pdmenu_plus_get_selector'
  endif

  return, base

end

