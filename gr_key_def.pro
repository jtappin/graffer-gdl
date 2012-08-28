;+
; GR_KEY_DEF
;	Define the plotting of a key on the plot.
;
; Usage:
;	ichange = gr_key_def(pdefs)
;
; Return value:
;	ichange	byte	Flag indicating if change has been made
;
; Argument:
;	pdefs	struct	in/out	The GRAFFER universal structure
;
; History:
;	Original: 30/1/97; SJT
;	Changed to be function returning change flag: 30/1/97; SJT
;	Add CAPTURE key to entry boxes: 6/2/97; SJT
;	Modify to include "single point" format: 15/5/97; SJT
;	Replace handles with pointers: 28/6/05; SJT
;	Add char size option: 29/4/09; SJT
;	Replace cw_bbselector with widget_droplist: 13/12/11; SJT
;	Add support for a second Y-scale: 22/12/11; SJT
;-

function Gr_key_event, event

widget_control, event.id, get_uvalue = but
widget_control, event.handler, get_uvalue = uv, /no_copy

iexit = 0

case but of
    'CANCEL': iexit = -1
    
    'DO': begin                 ; Retrieve values
        ptr_free, uv.key.list
        widget_control, uv.listid, get_value = iuse
        locs = where(iuse, nuse)
        if (nuse ne 0) then  uv.key.list = ptr_new((*uv.ds1)[locs])
        iexit = 1
    end
    
    'X0': begin
        uv.key.x(0) = event.value
        if (event.cr) then grf_focus_enter, uv.yid0
    end
    
    'Y0': begin
        uv.key.y(0) = event.value
        if (event.cr) then grf_focus_enter, uv.xid1
    end
    
    'X1': begin
        uv.key.x(1) = event.value
        if (event.cr) then grf_focus_enter, uv.yid1
    end
    
    'Y1': begin
        uv.key.y(1) = event.value
        if (event.cr) then grf_focus_enter, uv.csid
    end
    
    'CSIZE': begin
        uv.key.csize = event.value
        if (event.cr) then grf_focus_enter, uv.cid
    end

    'COL': begin
        uv.key.cols = event.value
        if (event.cr) then grf_focus_enter, uv.tid
    end
    
    'TITLE': begin
        uv.key.title = event.value
        if (event.cr) then grf_focus_enter, uv.xid0
    end
    
    'USE': uv.key.use = event.select
    'CSYS': begin
        cn = uv.key.norm 
        uv.key.norm = event.index
        gr_coord_convert, uv.key.x, uv.key.y, xt, yt, $
          to_data = event.index eq 0, to_region = event.index eq 1, $
          to_frame = event.index eq 2, data = cn eq 0, $
          region = cn eq 1, frame = cn eq 2

        
        uv.key.x = xt
        uv.key.y = yt
        widget_control, uv.xid0, set_value = uv.key.x(0)
        widget_control, uv.xid1, set_value = uv.key.x(1)
        widget_control, uv.yid0, set_value = uv.key.y(0)
        widget_control, uv.yid1, set_value = uv.key.y(1)
    end
    
    'FRAME': uv.key.frame = event.index
    'POINT': uv.key.one_point = event.index
    'SIDE': uv.key.side = event.select

    'ALL': begin
        widget_control, uv.listid, get_value = iuse
        iuse(*) = 1
        widget_control, uv.listid, set_value = iuse
    end
    
    'PICK':                     ; Ignore it's easier to use GET_VALUE
endcase

widget_control, uv.allid, sensitive = uv.key.use
widget_control, event.handler, set_uvalue = uv, /no_copy

return, {id:event.id, $
         top:event.top, $
         handler:0l, $
         exited:iexit}

end

function Gr_key_def, pdefs


ku = bytarr(pdefs.nsets)
if ptr_valid(pdefs.key.list) then ku(*pdefs.key.list) = 1
ds1 = where((*pdefs.data).type ge -3 and (*pdefs.data).type lt 8, n1d)

if n1d eq 0 then begin
    junk = dialog_message(["The current GRAFFER environment", $
                           "doesn't contain any datasets that", $
                           "can be included in a key"], $
                          dialog_parent = pdefs.ids.graffer)
    return, 0
endif

widget_control, pdefs.ids.graffer, sensitive = 0

bub = { $
        Key: pdefs.key, $
        Allid:  0l, $
        Xid0:   0l,  $
        Yid0:   0l,  $
        Xid1:   0l,  $
        Yid1:   0l, $
        csid:   0l, $
        Cid:    0l, $
        tid:    0l, $
        Listid: 0l,  $
        Ds1:    ptr_new()}

bub.ds1 = ptr_new(ds1)
        
tlb = widget_base(title = 'Graffer Key Define', group_leader = $
                  pdefs.ids.graffer, resource = 'Graffer')

base = widget_base(tlb, /column)

jb = widget_base(base, $
                 /row, $
                 /nonexclusive)
junk = widget_button(jb, $
                     value = 'Draw a key on the plot?', $
                     uvalue = 'USE')
widget_control, junk, set_button = pdefs.key.use
;; junk = widget_droplist(base, $
;;                        value = ['No', 'Yes'], $
;;                        title = 'Draw a key on the plot?:', $
;;                        uvalue = 'USE')
;; widget_control, junk, set_droplist_select = pdefs.key.use

bub.allid = widget_base(base, /row)
jb = widget_base(bub.allid, /column)

junk = widget_droplist(jb, $
                       value = ['Data', 'Normal', '"Frame"'], $
                       title = 'Coordinate system:', $
                       uvalue = 'CSYS')
widget_control, junk, set_droplist_select = pdefs.key.norm

jjb = widget_base(jb, /row)
bub.xid0 = graff_enter(jjb, /float, xsize = 11, /all_event, label = $
                       'Lower left: X:', value = pdefs.key.x(0), $
                       uvalue = 'X0', /capture)
bub.yid0 = graff_enter(jjb, /float, xsize = 11, /all_event, label = $
                       'Y:', value = pdefs.key.y(0), uvalue = 'Y0', $
                       /capture)

jjb = widget_base(jb, /row)
bub.xid1 = graff_enter(jjb, /float, xsize = 11, /all_event, label = $
                       'Upper right: X:', value = pdefs.key.x(1), $
                       uvalue = 'X1', /capture)
bub.yid1 = graff_enter(jjb, /float, xsize = 11, /all_event, label = $
                       'Y:', value = pdefs.key.y(1), uvalue = 'Y1', $
                       /capture)
jjb = widget_base(jb, /row)
bub.csid = graff_enter(jjb, $
                       /float, $
                       xsize = 6, $
                       /all, $
                       label = 'Character Size:', $
                       value = pdefs.key.csize, $
                       uvalue = 'CSIZE', $
                       /capture)

if (pdefs.y_right) then begin
    jjjb = widget_base(jjb, $
                       /nonexclusive)
    junk = widget_button(jjjb, $
                         value = 'Show Y side?', $
                         uvalue = 'SIDE')
    widget_control, junk, set_button = pdefs.key.side
endif

jjb = widget_base(jb, /row)
bub.cid = graff_enter(jjb, /int, xsize = 3, /all_event, label = $
                      'How many columns?: ', value = pdefs.key.cols, $
                      uvalue = 'COL', /capture)
junk = widget_droplist(jjb, $
                       value = ['2', '1'], $
                       title = 'Plot 1 or 2 points', $
                       uvalue = 'POINT')
widget_control, junk, set_droplist_select = pdefs.key.one_point

junk = widget_droplist(jb, $
                     value = ['No', 'Yes'], $
                     title = 'Draw a frame round the key?:', $
                     uvalue = 'FRAME')
widget_control, junk, set_droplist_select = pdefs.key.frame

bub.tid = graff_enter(jb, value = pdefs.key.title, /text, /all_event, $
                      label = 'Key title:', xsize = 20, uvalue = $
                      'TITLE', /capture)

jb = widget_base(bub.allid, /column)

junk = widget_label(jb, value = 'Datasets to include')

bub.listid = cw_bgroup(jb, (*pdefs.data)[ds1].descript, column = $
                       ceil(n1d/10.), $ 
                       /nonexclusive, uvalue = 'PICK', set_value = $
                       ku(ds1), ids = buts)
junk = widget_button(jb, value = 'All', uvalue = 'ALL')

jb = widget_base(base, /row)
junk = widget_button(jb, value = '   Cancel   ', uvalue = 'CANCEL')
junk = widget_button(jb, value = '    Do it    ', uvalue = 'DO')

widget_control, bub.allid, sensitive = pdefs.key.use

widget_control, tlb, /real
widget_control, base, set_uvalue = bub, event_func = 'gr_key_event', $
  /no_copy

repeat begin
    ev = widget_event(base)
endrep until (ev.exited ne 0)

widget_control, base, get_uvalue = uv, /no_copy
widget_control, tlb, /destroy

widget_control, pdefs.ids.graffer, sensitive = 1

if (ev.exited eq 1) then begin
    ptr_free, pdefs.key.list
    pdefs.key = uv.key
endif

return, ev.exited eq 1

end



