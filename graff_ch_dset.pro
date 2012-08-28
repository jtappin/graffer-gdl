;+
; GRAFF_CH_DSET
;	Change data set
;
; Usage:
;	graff_ch_dset, pdefs
;
; Argument:
;	pdefs	struct	in/out	The plot definition structure.
;
; History:
;	Original (essentially a widget version of graff_dset): 7/9/95; SJT
;	Add mouse-editing default option: 13/8/97; SJT
;	Replace handles with pointers: 28/6/05; SJT
;-

function Grf_ch_event, event

base = widget_info(event.top, /child)
widget_control, base, get_uvalue = uv, /no_copy
widget_control, event.id, get_uvalue = but

iexit = 0
case (but) of
    'CHOOSE': begin
        uv.select = event.index
        iexit = 1
    end
    
    'DONT': iexit = -1
end

widget_control, base, set_uvalue = uv, /no_copy

return, {id:event.handler, $
         top:event.top, $
         handler:event.handler, $
         Exit:iexit}
end






pro Graff_ch_dset, pdefs

tc = ['F(XY)', 'PF', 'F(Y)', 'F(X)', 'XY', 'XYE', 'XYEE', 'XYF', 'XYFF', $
      'XYFE', 'XYFEE', 'XYFFE', 'XYFFEE', 'Z']

dlist = [(*pdefs.data).descript, '<New>']

nlist = string(indgen(n_elements(dlist))+1, $
               format = "(I3,')')")

llist = string([(*pdefs.data).ndata, 0], format = "(' <',I0,'> ')")
lll = max(strlen(llist))
fmt = "(A"+string(lll, format = "(I0)")+")"
llist = string(llist, format = fmt)

clist = replicate(' ', n_elements(llist))
clist(pdefs.cset) = '*'

nlist = nlist+llist+clist

nlist = nlist+string([tc((*pdefs.data).type+4), ''], format = "(A6, ' - ')")

dlist = nlist+dlist

widget_control, pdefs.ids.graffer, sensitive = 0

tlb = widget_base(title = 'Graffer data set select', $
                  group = pdefs.ids.graffer, $
                  resource = 'Graffer')
base = widget_base(tlb, /column)

curr = widget_label(base, value = 'Data Sets')
junk = widget_list(base, value = dlist, uvalue = 'CHOOSE',  $
                   ysize = (12 < n_elements(dlist)))

junk = widget_button(base, value = 'Cancel', uvalue = 'DONT')

widget_control, base, set_uvalue = {dlist:dlist,  $
                                    Select:pdefs.cset}, $
  event_func = 'grf_ch_event'

widget_control, tlb, /real

;			DIY widget management here

repeat ev = widget_event(base) until ev.exit ne 0

widget_control, base, get_uvalue = uv, /no_copy
widget_control, tlb, /destroy
widget_control, pdefs.ids.graffer, sensitive = 1

if (ev.exit eq -1) then begin
    return
endif

pdefs.cset = uv.select
    
if (pdefs.cset eq pdefs.nsets) then begin ; Need to extend the data
                                ; structure
        
    (*pdefs.data) = [(*pdefs.data), {graff_data}]
;    (*pdefs.data)[pdefs.cset].Xydata =   ptr_new(dblarr(2, 2))
    (*pdefs.data)[pdefs.cset].Pline =    1
    (*pdefs.data)[pdefs.cset].Symsize =  1.
    (*pdefs.data)[pdefs.cset].Colour =   1
    (*pdefs.data)[pdefs.cset].Thick =    1.
    (*pdefs.data)[pdefs.cset].Medit =    pdefs.opts.mouse

    (*pdefs.data)[pdefs.cset].zopts.N_levels =  6
    (*pdefs.data)[pdefs.cset].zopts.N_cols =    1
    (*pdefs.data)[pdefs.cset].zopts.Colours =   ptr_new(1)
    (*pdefs.data)[pdefs.cset].zopts.N_sty =     1
    (*pdefs.data)[pdefs.cset].zopts.style = ptr_new(0)
    (*pdefs.data)[pdefs.cset].zopts.N_thick =   1
    (*pdefs.data)[pdefs.cset].zopts.Thick =     ptr_new(1.)
    (*pdefs.data)[pdefs.cset].zopts.Pxsize =    0.5

    pdefs.nsets = pdefs.nsets+1
endif

graff_set_vals, pdefs, /set_only

end
