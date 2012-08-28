;+
; GR_APP_W
;	Menu to control GR_APPEND
;
; Usage:
;	gr_app_w, pdefs
;
; Argument:
;	pdefs	struct	in/out	The GRAFFER data structure
;
; History:
;	Original: 12/11/96; SJT
;	Shorten name: 25/11/96; SJT
;	Convert handles to pointers: 27/6/05; SJT
;	Fix labelling: 11/1/12; SJT
;-

function Gr_app_event, event

base = widget_info(event.top, /child)
widget_control, base, get_uvalue = uv, /no_copy
widget_control, event.id, get_uvalue = but

iexit = 0
case (but) of
    'CANCEL': iexit = -1
    'DONE': iexit = 1
    
    'EXTEND': if (event.select eq 0) then begin
        if (uv.sflag(0) eq 0) then  begin
            widget_control, uv.apid, sensitive = 0
            uv.res(0) = -1
        endif
        uv.sflag(0) = 0b
        widget_control, uv.dobut, sensitive = 0
    endif else begin
        widget_control, uv.apid, /sensitive
        uv.res(0) = event.value
        
        for j = 0, n_elements(uv.apids)-1 do $
          widget_control, uv.apids(j), sensitive =  $
          (uv.dtypes(j) eq uv.dtypes(uv.res(0))) and j ne uv.res(0)
        
        if (uv.res(1) ne -1) then begin
            widget_control, uv.apids(uv.res(1)), set_button = 0
            uv.res(1) = -1
        endif
        
        widget_control, uv.dobut, sensitive = 0
        uv.sflag(0) = 1b
    end
    
    'APPEND': if (event.select eq 0) then begin
        if (uv.sflag(1) eq 0) then begin
            uv.res(1) = -1
            widget_control, uv.dobut, sensitive = 0
        endif
    endif else begin
        uv.res(1) = event.value
        widget_control, uv.dobut, /sensitive
    endelse
    
    'DELETE': uv.delete = event.select
    'SORT': uv.sort = event.select
endcase

widget_control, base, set_uvalue = uv, /no_copy

return, {id:event.handler, top:event.top, handler:event.handler, $
         Exit:iexit}

end

pro Gr_app_w, pdefs

;	First generate the list of DSS

data = *pdefs.data

tc = ['XY', 'XYE', 'XYEE', 'XYF', 'XYFF', 'XYFE', 'XYFEE', 'XYFFE', $
      'XYFFEE']
xydi = where(data.type ge 0 and data.type le 8, nxy) ; X/Y data only
if (nxy eq 0) then begin
    junk = dialog_message(["No mergable datasets", $
                           "All datasets are functions or 2-D"], $
                          dialog_parent = pdefs.ids.graffer)
    return
endif

dlist = data(xydi).descript
dtypes = data(xydi).type
nlist = string(xydi+1, $
               format = "(I3,')')")

llist = string(data(xydi).ndata, format = "(' <',I0,'> ')")
lll = max(strlen(llist))
fmt = "(A"+string(lll, format = "(I0)")+")"
llist = string(llist, format = fmt)
nlist = nlist+llist
nlist = nlist+string(tc(dtypes), format = "(A6, ' - ')")

dlist = nlist+dlist


;	Build the menus.

widget_control, pdefs.ids.graffer, sensitive = 0

tlb = widget_base(title = 'Graffer data set merge', group = $
                  pdefs.ids.graffer, resource = 'Graffer')
base = widget_base(tlb, /column)

pbase = widget_base(base, /row)

exid = cw_bgroup(pbase, dlist, /column, /exclusive, label_top = $
                 'Dataset to extend', /return_index, ids = exids, $
                 uvalue = 'EXTEND') 
apid = cw_bgroup(pbase, dlist, /column, /exclusive, label_top = $
                 'Dataset to append', /return_index, ids = apids, $
                 uvalue = 'APPEND')
widget_control, apid, sensitive = 0

jb = widget_base(base, /row, /nonexclusive)
junk = widget_button(jb, value = 'Delete appended', uvalue = 'DELETE')
junk = widget_button(jb, value = 'Sort resultant', uvalue = 'SORT')

jb = widget_base(base, /row)
junk = widget_button(jb, value = '      Cancel      ', uvalue = $
                     'CANCEL')
dobut = widget_button(jb, value = '       Do it       ', uvalue = $
                     'DONE')
widget_control, dobut, sensitive = 0

sflags = bytarr(2)

widget_control, base, set_uvalue = {exid:exid,  $
                                    Exids:exids,  $
                                    Apid:apid,  $
                                    Apids:apids, $
                                    Dobut:dobut, $
                                    Sflag:sflags, $
                                    Dtypes:dtypes, $
                                    Res:intarr(2)-1, $
                                    Delete:0, sort:0}, $
  event_func = 'gr_app_event'

widget_control, tlb, /real

;			DIY widget management here

repeat ev = widget_event(base) until ev.exit ne 0

widget_control, base, get_uvalue = uv, /no_copy
widget_control, tlb, /destroy
widget_control, pdefs.ids.graffer, sensitive = 1

if (ev.exit eq -1) then return

gr_append, pdefs, xydi(uv.res(0)), xydi(uv.res(1)), delete = $
  uv.delete, sort = uv.sort

end
