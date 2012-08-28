pro Gr_state, id, save = save

;+
; GR_STATE
;	Restore the entry state of graffer. 
;
; Usage:
;	gr_state[, id]
;
; Argument:
;	id	long	input	Widget ID of the widget invoking
;				gr_state. 
;
; Notes:
;	This routine is intended to operate as a "KILL_NOTIFY"
;	callback procedure -- I hope that this will prevent some of
;       the problems associated with the IDL being left in a stange
;       state when GRAFFER exits out of control. It cannot free heap
;       variables other than by a garbage collection, which may not be
;       at the right level.
;
; History:
;	Original: 23/1/97; SJT
;	Call garbage collector: 30/6/05; SJT
;	Add a save key, to allow gr_entry state to be hidden.
;-

common Gr_entry_state, pstate, xstate, ystate, zstate, qstate, rstate, $
  gstate, bstate, gdstate, dstate

if keyword_set(save) then begin
    gdstate =  !D.name
    pstate = !P
    xstate = !X
    ystate = !Y
    zstate = !Z                 ; Not touched at present in graffer
                                ; but if & when GRAFFER for surfaces is
                                ; done then it may be
    tvlct, rstate, gstate, bstate, /get
    qstate = !Quiet

    if ((!D.flags and 65536) eq 0) then begin
        if strupcase(!version.os_family) eq 'UNIX' then dev = 'X' $
        else dev = 'WIN'        ; Probably won't work
        print, "GRAFFER needs widgets; current device (", !D.name, $
          ") does not support them, switching to ", dev, "."
        set_plot, dev
    endif
    device, get_decomposed = dstate, get_visual_depth = vdep
    if (dstate and vdep gt 8) then begin
        print, "GRAFFER needs undecomposed colours, setting"
        device, decomposed = 0
    endif

endif else begin
                                ; Restore system variables and colour
                                ; tables 

    device, decomposed = dstate
    set_plot, gdstate
    if (keyword_set(debug)) then !Quiet = qstate ; Restore message state
    !P = pstate
    !X = xstate
    !Y = ystate
    !Z = zstate
    tvlct, rstate, gstate, bstate
endelse

heap_gc

end
