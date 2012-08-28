; $Id: cw_bbselector.pro,v 1.6 1993/12/22 23:34:09 kirk Exp $

; Copyright (c) 1993, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;+
; NAME:
;	CW_BBSELECTOR
;
; PURPOSE:
;	CW_BBSELECTOR is a compound widget that appears as a pull-down
;	menu whose label shows the widget's current value. When the button
;	is pressed, the menu appears and the newly selected value becomes
;	the new title of the pull-down menu.
;
; CATEGORY:
;	Compound widgets.
;
; CALLING SEQUENCE:
;		widget = CW_BBSELECTOR(Parent, Names)
;
;	To get or set the value of a CW_BBSELECTOR, use the GET_VALUE and
;	SET_VALUE keywords to WIDGET_CONTROL. The value of a CW_BBSELECTOR
;	is the index of the selected item.
;
; INPUTS:
;       Parent:		The ID of the parent widget.
;	Names:		A string array, containing one string per button,
;			giving the name of each button.
;
; KEYWORD PARAMETERS:
;	EVENT_FUNCT:	The name of an optional user-supplied event function 
;			for buttons. This function is called with the return
;			value structure whenever a button is pressed, and 
;			follows the conventions for user-written event
;			functions.
;	FONT:		The name of the font to be used for the button
;			titles. If this keyword is not specified, the default
;			font is used.
;	FRAME:		Specifies the width of the frame to be drawn around
;			the base.
;	IDS:		A named variable into which the button IDs will be
;			stored, as a longword vector.
;	LABEL_LEFT:	Creates a text label to the left of the buttons.
;	LABEL_TOP:	Creates a text label above the buttons.
;	MAP:		If set, the base will be mapped when the widget
;			is realized (the default).
;	RETURN_ID:	If set, the VALUE field of returned events will be
;			the widget ID of the button.
;	RETURN_INDEX:	If set, the VALUE field of returned events will be
;			the zero-based index of the button within the base.
;			THIS IS THE DEFAULT.
;	RETURN_NAME:	If set, the VALUE field of returned events will be
;			the name of the button within the base --
;			N.B. this is ignored if the button has a
;			bitmap label.
;	RETURN_UVALUE:	An array of user values to be associated with
;			each button. Selecting the button sets the uvalue
;			of the CW_BBSELECTOR to the button's uvalue and
;			returns the uvalue in the value field of the event
;			structure.  If this keyword isn't specified, the
;			CW_BBSELECTOR's uvalue remains unchanged.
;	SET_VALUE:	The initial value of the buttons. This keyword is 
;			set to the index of the Names array element desired.
;			So if it is desired that the initial value be the 
;			second element of the Names array, SET_VALUE would
;			be set equal to 1. This is equivalent to the later 
;			statement:
;
;			WIDGET_CONTROL, widget, set_value=value
;
;	TRACKING_EVENTS: Return tracking events
;	UVALUE:		The user value to be associated with the widget.
;	XOFFSET:	The X offset of the widget relative to its parent.
;	YOFFSET:	The Y offset of the widget relative to its
;			parent.
;	X_BITMAP_EXTRA	Number of bits at the end of each row of a
;			bitmap label to ignore, only used for bitmap
;			buttons.
;	
;
; OUTPUTS:
;       The ID of the created widget is returned.
;
; SIDE EFFECTS:
;	This widget generates event structures with the following definition:
;
;		event = { ID:0L, TOP:0L, HANDLER:0L, INDEX:0, VALUE:0 }
;
;	The INDEX field is the index (0 based) of the menu choice. VALUE is
;	either the INDEX, ID, NAME, or BUTTON_UVALUE of the button,
;	depending on how the widget was created.
;
; RESTRICTIONS:
;	Bitmap restriction removed, but return_name and bitmap are
;	still incompatible.
;
; MODIFICATION HISTORY:
;	1 April 1993, DMS,  Adapted from CW_BGROUP.
;	22 Dec. 1993, KDB,  Corrected documentation for keyword SET_VALUE.
;	Sept 95, SJT (U. of B'ham) Modify to allow bitmap buttons
;	(rename CW_BBSELECTOR to avoid potential confusion)
;	4/12/95; SJT: Add the tracking_events keyword
;	5/7/05; SJT: Modify to allow colour bitmap labels.
;-


pro Cw_bbselector_setv, id, value

ON_ERROR, 2                     ;return to caller

stash = WIDGET_INFO(id, /CHILD)	;Get state from 1st child
WIDGET_CONTROL, stash, GET_UVALUE = s, /NO_COPY

if value lt 0 or value ge n_elements(s.ids) then $
  MESSAGE, 'Button value must be from 0 to n_buttons -1.', /INFO $
ELSE BEGIN
    if (s.bits eq 1b) then $
      WIDGET_CONTROL, s.menu, SET_VALUE = s.names(*, *, value), $
      x_bitmap_extra = s.x_bm_ex $
                                ;Set menu label
    else if (s.bits eq 2b) then $
      WIDGET_CONTROL, s.menu, SET_VALUE = s.names(*, *, *, value) $
    else WIDGET_CONTROL, s.menu, SET_VALUE = s.names(value) 
    s.select = value            ;save button that's selected
ENDELSE

WIDGET_CONTROL, stash, SET_UVALUE = s, /NO_COPY  

end



function Cw_bbselector_getv, id

ON_ERROR, 2                     ;return to caller

stash = WIDGET_INFO(id, /CHILD)	;Get state from 1st child
WIDGET_CONTROL, stash, GET_UVALUE = s, /NO_COPY

ret = s.select
WIDGET_CONTROL, stash, SET_UVALUE = s, /NO_COPY  

return, ret

end



function Cw_bbselector_event, ev

base = ev.handler
stash = WIDGET_INFO(base, /CHILD) ;Get state from 1st child

WIDGET_CONTROL, stash, GET_UVALUE = s, /NO_COPY
if (ev.id eq s.menu) then begin
    st = ev
    st.id = base
    st.handler = 0l
    efun = s.efun
    WIDGET_CONTROL, stash, SET_UVALUE = s, /NO_COPY
    if efun ne '' then return, CALL_FUNCTION(efun, st) $
    else return, st
endif
WIDGET_CONTROL, ev.id, get_uvalue = uvalue ;The button index

s.select = uvalue               ;Save the selected index
rvalue = s.ret_arr(uvalue)

if (s.bits eq 1b) then WIDGET_CONTROL, s.menu, SET_VALUE =  $
  s.names(*, *, uvalue), x_bitmap_extra = s.x_bm_ex $ 
                                ;Copy button's label to menu
else if (s.bits eq 2b) then WIDGET_CONTROL, s.menu, SET_VALUE =  $
  s.names(*, *, *, uvalue) $ 
else WIDGET_CONTROL, s.menu, SET_VALUE = s.names(uvalue)

efun = s.efun
WIDGET_CONTROL, stash, SET_UVALUE = s, /NO_COPY

st = { ID:base, TOP:ev.top, HANDLER:0L, INDEX: uvalue, $ ;Return value
       Value: rvalue }

if efun ne '' then return, CALL_FUNCTION(efun, st) $
else return, st

end







function Cw_bbselector, parent, names, EVENT_FUNCT=efun, $
                        RETURN_UVALUE=return_uvalue, $
                        FONT=font, FRAME=frame, IDS=ids, $
                        LABEL_TOP=label_top, LABEL_LEFT=label_left, $
                        MAP=map, RETURN_ID=return_id, $
                        RETURN_NAME=return_name, $
                        RETURN_INDEX=return_index, SET_VALUE=sval, $
                        UVALUE=uvalue, $ XOFFSET=xoffset, XSIZE=xsize, $
                        YOFFSET=yoffset, YSIZE=ysize, $
                        x_bitmap_extra=xbme, $
                        tracking_events=tracking_events



ON_ERROR, 2						;return to caller

                                ; Set default values for the keywords

IF (N_ELEMENTS(frame) eq 0)		then framet = 0  $
else                                         framet = frame

IF (N_ELEMENTS(map) eq 0)		then map = 1
IF (N_ELEMENTS(uvalue) eq 0)		then uvalue = 0
IF (N_ELEMENTS(xoffset) eq 0)		then xoffset = 0
IF (N_ELEMENTS(xsize) eq 0)		then xsize = 0
IF (N_ELEMENTS(yoffset) eq 0)		then yoffset = 0
IF (N_ELEMENTS(ysize) eq 0)		then ysize = 0
if (n_elements(xbme) eq 0)              then xbme = 0

top_base = 0L
next_base = parent
if (n_elements(label_top) ne 0) then begin
    next_base = WIDGET_BASE(next_base, XOFFSET = xoffset, YOFFSET = $
                            yoffset, FRAME = framet, /COLUMN)
    top_base = next_base
    framet = 0                  ;Only one frame
    junk = WIDGET_LABEL(next_base, value = label_top)
endif else next_base = parent

if (n_elements(label_left) ne 0) then begin
    next_base = WIDGET_BASE(next_base, XOFFSET = xoffset, YOFFSET = $
                            yoffset, FRAME = framet, /ROW)
    junk = WIDGET_LABEL(next_base, value = label_left)
    framet = 0                  ;Only one frame
    if (top_base eq 0L) then top_base = next_base
endif

                                ; We need some kind of outer base to
                                ; hold the users UVALUE

if (top_base eq 0L) then begin
    top_base = WIDGET_BASE(next_base, XOFFSET = xoffset, YOFFSET = $
                           yoffset, FRAME = framet)
    next_base = top_base
endif

                                ; Set top level base attributes

WIDGET_CONTROL, top_base, MAP = map, EVENT_FUNC = $
  'CW_BBSELECTOR_EVENT', FUNC_GET_VALUE = 'CW_BBSELECTOR_GETV', $
  PRO_SET_VALUE = 'CW_BBSELECTOR_SETV', SET_UVALUE = uvalue
if n_elements(sval) le 0 then sval = 0 ;Default selection index


s = size(names)
n = s(s(0))

if (s(s(0)+1) eq 1) then begin  ; Bitmap buttons
    if s[0] eq 4 then i = names[*, *, *, sval] $
    else i = names(*, *, sval)
    menu = WIDGET_BUTTON(next_base, /MENU, value = i, x_bitmap_extra = $
                         xbme, tracking_events = $
                         keyword_set(tracking_events))
    
    ids = lonarr(n)
    if s[0] eq 3 then begin
        for i = 0, n-1 do  $
          ids(i) = WIDGET_BUTTON(menu, value = names(*, *, i), UVALUE $
                                 = i, $
                                 x_bitmap_extra = xbme)
        bitflag = 1b
    endif else begin
        for i = 0, n-1 do  $
          ids(i) = WIDGET_BUTTON(menu, value = names(*, *, *, i), UVALUE $
                                 = i)
        bitflag = 2b
    endelse
endif else if (s(s(0)+1) eq 7) then begin
    len = max(strlen(names), i) ;Longest string = 1st value
    len1 = strlen(names(sval))  ;Initial string length
    if len gt len1 then $
	i = names(sval) + string(replicate(32B, len-len1+2)) $  ;+ slop
    else i = names(sval)
    if (n_elements(font) eq 0) then $
      menu = WIDGET_BUTTON(next_base, /MENU, value = i, tracking_events $
                           = keyword_set(tracking_events))  $
    else menu = WIDGET_BUTTON(next_base, /MENU, value = i, tracking_events $
                           = keyword_set(tracking_events), font = font)
    
    ids = lonarr(n)
    for i = 0, n-1 do begin
        if (n_elements(font) eq 0) then begin
            ids(i) = WIDGET_BUTTON(menu, value = names(i), UVALUE = i)
        endif else begin
            ids(i) = WIDGET_BUTTON(menu, value = names(i), FONT = $
                                   font, UVALUE = i)
        endelse
    endfor
    bitflag = 0b
endif else message, "Illegal type for names array."

                                ;Make returned value array
return_uvals = 0
if KEYWORD_SET(RETURN_ID) then ret_arr = ids $
else if KEYWORD_SET(RETURN_NAME) and not bitflag then ret_arr = names $
else if KEYWORD_SET(RETURN_UVALUE) then begin
    ret_arr = return_uvalue
    return_uvals = 1
endif else ret_arr = indgen(n)

stash = WIDGET_INFO(top_base, /CHILD) ;Affix state to 1st child

if n_elements(efun) le 0 then efun = ''

WIDGET_CONTROL, stash,  $
  SET_UVALUE = { $
                 Menu: menu, $
                 Efun: efun, $  ; Name of event fcn
                 Ret_arr: ret_arr, $ ; Vector of event values
                 Select: sval, $
                 Uvret: return_uvals, $
                 Names:names, $ ; Button names must be stored as there
                                ; is no way to get_value a bitmap
                                ; button
                 Bits:bitflag, $ ; Is it a bitmap array?
                 X_bm_ex: xbme, $ ; pad bits for bitmap labels.
                 Ids:ids }      ; Ids of buttons
                 
return, top_base

END
