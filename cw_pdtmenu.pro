; $Id: cw_pdtmenu.pro,v 1.7 1995/07/03 15:43:54 idl Exp $

; Copyright (c) 1992-1993, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;+
; NAME:
;	CW_PDTMENU
;
; PURPOSE:
;	CW_PDTMENU is a compound widget that simplifies creating
;	pulldown menus. It has a simpler interface than the XPDTMENU
;	procedure, which it is intended to replace. Events for the
;	individual buttons are handled transparently, and a CW_PDTMENU
;	event returned. This event can return any one of the following:
;               - The Index of the button within the base.
;               - The widget ID of the button.
;               - The name of the button.
;		- The fully qualified name of the button. This allows
;		  different sub-menus to contain buttons with the same
;		  name in an unambiguous way.
;
;
; CATEGORY:
;	Compound widgets.
;
; CALLING SEQUENCE:
;	widget = CW_PDTMENU(Parent, Desc)
;
; INPUTS:
;       Parent:	The ID of the parent widget.
;	Desc:	An array of strings or structures.  Each element contains
;		a menu description with two fields, a flag field, and
;		the name of the item.  If a structure, each element
;		is defined as follows:
;			{ CW_PDTMENU_S, flags:0, name:'' }
;
;		The name tag gives the name of button. The flags
;		field is a two-bit bitmask that controls how the button is
;		interpreted:
;
;		    Value	   Meaning
;		    -------------------------------------------
;		     0     This button is neither the beginning
;			   nor the end of a pulldown level.
;		     1     This button is the root of a
;                          sub-pulldown menu. The sub-buttons
;			   start with the next button.
;		     2     This button is the last button at the
;			   current pulldown level. The next button
;			   belongs to the same level as the current
;			   parent button.
;		     3     This button is the root of a sub-pulldown
;			   menu, but it is also the last entry of
;			   the current level.
;
;	If Desc is a string, each element contains the flag field
;	followed by a backslash character, followed by the menu item's
;	contents.  See the example below.
;
;	EVENT PROCEDURES:  An event procedure may be specified for an
;	element and all its children, by including a third field
;	in Desc, if Desc is a string array.  Events for buttons without
;	an event procedure, are dispatched normally.
;	See the example below.
;
; KEYWORD PARAMETERS:
;	COLUMN:		  Make the implict base a column base (with N
;			  columns)
;	DELIMITER:        The character used to separate the parts of a
;			  fully qualified name in returned events. The
;			  default is to use the '.' character.
;	FONT:		  The name of the font to be used for the button
;			  titles. If this keyword is not specified, the
;			  default font is used.
;	HELP:		  If MBAR is specified and one of the buttons on the
;			  menubar has the label "help" (case insensitive) then
;			  that button is created with the /HELP keyword to
;			  give it any special appearance it is supposed to
;			  have on a menubar. For example, Motif expects
;			  help buttons to be on the right.
;	IDS:		  A named variable into which the button IDs will
;			  be stored as a longword vector.
;	MBAR:		  if constructing a menu-bar pulldown, set this
;			  keyword.  In this case, the parent must be the 
;			  widget id of the menu bar of a top-level base,
;			  returned by WIDGET_BASE(..., MBAR=mbar).
;	RETURN_ID:	  If present and non-zero, the VALUE field of returned
;			  events will be the widget ID of the button.
;	RETURN_INDEX:	  If present and non-zero, the VALUE field of returned
;			  events will be the zero-based index of the button
;			  within the base. THIS IS THE DEFAULT.
;	RETURN_NAME:	  If present and non-zero, the VALUE field of returned
;			  events will be the name of the selected button.
;	RETURN_FULL_NAME: If present and non-zero, the VALUE field of returned
;               	  events will be the fully qualified name of the
;			  selected button. This means that the names of all
;			  the buttons from the topmost button of the pulldown
;			  menu to the selected one are concatenated with the
;			  delimiter specified by the DELIMITER keyword. For
;			  example, if the top button was named COLORS, the
;			  second level button was named BLUE, and the selected
;			  button was named LIGHT, the returned value would be
;
;			  COLORS.BLUE.LIGHT
;
;			  This allows different submenus to have buttons with
;			  the same name (e.g. COLORS.RED.LIGHT).
;	ROW:		  Make the implict base a row base (with N
;			  rows)
;	UVALUE:		  The user value to be associated with the widget.
;	XOFFSET:	  The X offset of the widget relative to its parent.
;	YOFFSET:	  The Y offset of the widget relative to its parent.
;	TRACKING_EVENTS:  Enable widget tracking events.
;
; OUTPUTS:
;       The ID of the top level button is returned.
;
; SIDE EFFECTS:
;	This widget generates event structures with the following definition:
;
;		event = { ID:0L, TOP:0L, HANDLER:0L, VALUE:0 }
;
;	VALUE is either the INDEX, ID, NAME, or FULL_NAME of the button,
;	depending on how the widget was created.
;
; RESTRICTIONS:
;	Only buttons with textual names are handled by this widget.
;	Bitmaps are not understood.
;
; EXAMPLE:
;	The following is the description of a menu bar with two buttons,
;	"Colors" and "Quit". Colors is a pulldown containing the colors
;	"Red", "Green", Blue", "Cyan", and "Magenta". Blue is a sub-pulldown
;	containing "Light", "Medium", "Dark", "Navy", and "Royal":
;
;		; Make sure CW_PDTMENU_S is defined
;		junk = { CW_PDTMENU_S, flags:0, name:'' }
;
;		; The description
;		desc = [ { CW_PDTMENU_S, 1, 'Colors' }, $
;			     { CW_PDTMENU_S, 0, 'Red' }, $
;			     { CW_PDTMENU_S, 0, 'Green' }, $
;			     { CW_PDTMENU_S, 1, 'Blue' }, $
;			         { CW_PDTMENU_S, 0, 'Light' }, $
;			         { CW_PDTMENU_S, 0, 'Medium' }, $
;			         { CW_PDTMENU_S, 0, 'Dark' }, $
;			         { CW_PDTMENU_S, 0, 'Navy' }, $
;			         { CW_PDTMENU_S, 2, 'Royal' }, $
;			       { CW_PDTMENU_S, 0, 'Cyan' }, $
;			       { CW_PDTMENU_S, 2, 'Magenta' }, $
;			 { CW_PDTMENU_S, 2, 'Quit' } ]
;
;	The same menu may be defined as a string by equating the Desc parameter
;	to the following string array:
;	
;	desc =[ '1\Colors' , $
;		'0\Red' , $
;		'0\Green' , $
;		'1\Blue\BLUE_EVENT_PROC' , $
;		'0\Light' , $
;		'0\Medium' , $
;		'0\Dark' , $
;		'0\Navy' , $
;		'2\Royal' , $
;		'0\Cyan' , $
;		'2\Magenta\MAGENTA_EVENT_PROC' , $
;		'2\Quit'  ]
;
;
;	The following small program can be used with the above description
;	to create the specified menu:
;
;
;		base = widget_base()
;		menu = cw_pdtmenu(base, desc, /RETURN_FULL_NAME)
;		WIDGET_CONTROL, /REALIZE, base
;		repeat begin
;		  ev = WIDGET_EVENT(base)
;		  print, ev.value
;		end until ev.value eq 'Quit'
;		WIDGET_CONTROL, /DESTROY, base
;		end
;
;	Note that independent event procedures were specified for
;	the multiple Blue buttons (blue_event_proc), and the Magenta button 
;	(magenta_event_proc).

; MODIFICATION HISTORY:
;	18 June 1992, AB
;	16 Jan 1995, DMS, Added MBAR keyword, event procedures,
;			and menu descriptor strings.
;	2 July 1995, AB, Added HELP keyword.
;	1996: SJT, Tracking keyword added
;	11/11/96: SJT, ROW keyword added and COLUMN documented.
;	Support accelerators: 20/1/09; SJT
;-


function CW_PDTMENU_EVENT, ev

  WIDGET_CONTROL, ev.id, get_uvalue=uvalue
  
  if (tag_names(ev, /struct) eq 'WIDGET_TRACKING') then  $
    return, {CW_PDT_TRACK, ID:ev.handler, TOP:ev.top, HANDLER:0L, $
             Enter:ev.enter, value:uvalue } $
  else return, {CW_PDT, ID:ev.handler, TOP:ev.top, HANDLER:0L, $
                Value:uvalue }

end







pro CW_PDTMENU_BUILD, parent, desc, cur, n, ev_type, full_qual_str, $
                      delim, ids, mbars, HELP_KW, FONT=font, $
                      tracking_events=tracking_events 

; Recursive routine that builds the pulldown hierarchy described in DESC.
; Returns the ID of each button in ids.

  is_string = size(desc)
  is_string = is_string(is_string(0)+1) eq 7
  while (cur lt n) do begin
    if is_string then begin
	a = str_sep(desc(cur), '\', /TRIM)
	dflags = fix(a(0))
	dname = a(1)
        if n_elements(a) ge 3 then accel = a[2] $
        else accel = ''
    endif else begin
	dflags = desc(cur).flags
	dname = desc(cur).name
        accel = desc[cur].accel
    endelse
    if (strlen(full_qual_str) ne 0) then $
      new_qstr = full_qual_str + delim + dname $
    else new_qstr = dname
	;If parented to a menu bar, don't draw a frame.
    if (dflags and 1) then menu=2-mbars else menu = 0 
    if ((mbars ne 0) and (HELP_KW ne 0) and (strupcase(dname) eq $
                                             'HELP')) then begin 
        if (keyword_set(font)) then begin
            new = WIDGET_BUTTON(parent, value = dname, MENU = menu, $
                                FONT = font, /help, tracking_events = $
                                tracking_events, accel = accel) 
        endif else begin
            new = WIDGET_BUTTON(parent, value = dname, MENU = menu, $
                                /help, tracking_events = $
                                tracking_events, accel = accel)
        endelse
    endif else begin
        if (keyword_set(font)) then begin
            new = WIDGET_BUTTON(parent, value = dname, MENU = menu, $
                                FONT = font, tracking_events = $
                                tracking_events, accel = accel)
        endif else begin
            new = WIDGET_BUTTON(parent, value = dname, MENU = menu, $
                                tracking_events = tracking_events, $
                                accel = accel) 
        endelse
    endelse
    case ev_type of
      0: uvalue = cur
      1: uvalue = new
      2: uvalue = dname
      3: uvalue = new_qstr
    endcase
    WIDGET_CONTROL, new, SET_UVALUE=uvalue
    ids(cur) = new
    cur = cur + 1
    if (dflags and 1) then $
      CW_PDTMENU_BUILD, new, desc, cur, n, ev_type, new_qstr, delim, $
      ids, mbars, 0, FONT = font, tracking_events = tracking_events
    if ((dflags and 2) ne 0) then return
  endwhile

end






function Cw_pdtmenu, parent, desc, COLUMN=column, DELIMITER=delim, $
                     FONT=font, IDS=ids, MBAR=mbar, HELP=HELP_KW, $
                     RETURN_ID=r_id, RETURN_INDEX=ignore, $
                     RETURN_NAME=r_name, RETURN_FULL_NAME=r_full_name, $
                     UVALUE=uvalue, XOFFSET=xoffset, YOFFSET=yoffset, $
                     tracking_events=tracking_events, row=row


IF (N_PARAMS() ne 2) THEN MESSAGE, 'Incorrect number of arguments'

ON_ERROR, 2                     ;return to caller

                                ; Set default values for the keywords

if (keyword_set(row) and keyword_set(column)) then  $
  message, "Only one of ROW and COLUMN may be given."

If KEYWORD_SET(column) then row = 0  $
else if (keyword_set(row)) then column = 0 $
else begin 
    row = 1
    column = 0
endelse

IF (N_ELEMENTS(delim) eq 0)	then delim = '.'
IF (N_ELEMENTS(uvalue) eq 0)	then uvalue = 0
IF (N_ELEMENTS(xoffset) eq 0)	then xoffset = 0
IF (N_ELEMENTS(yoffset) eq 0)	then yoffset = 0

                                ; How to interpret ev_type:
                                ;	0 - Return index
                                ;	1 - Return ID
                                ;	2 - Return name
                                ;	3 - Return fully qualified name.
ev_type = 0
if (keyword_set(r_id)) 	then ev_type = 1
if (keyword_set(r_name)) 	then ev_type = 2
if (keyword_set(r_full_name))	then ev_type = 3


n = n_elements(desc)
ids = lonarr(n)
mbars = KEYWORD_SET(mbar)
help_kw = KEYWORD_SET(HELP_KW)
if mbars then base = parent $
else base = widget_base(parent, COLUMN = column, $
                        ROW = row, UVALUE = uvalue, XOFFSET = xoffset, $
                        YOFFSET = yoffset)
WIDGET_CONTROL, base, EVENT_FUNC = 'CW_PDTMENU_EVENT' 
CW_PDTMENU_BUILD, base, desc, 0, n, ev_type, '', delim, ids, mbars, $
  help_kw, FONT = font, tracking_events = keyword_set(tracking_events)

return, base

END
