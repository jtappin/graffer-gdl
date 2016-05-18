pro Gr_1df_plot, pdefs, i, csiz

;+
; GR_1DF_PLOT
;	Plot a 1-D function in graffer
;
; Usage:
;	gr_1df_plot, pdefs, i
;
; Argument:
;	pdefs	struct	input	The Graffer control structure.
;	i	int	input	Which 
;	csiz	float	input	Charsize scaling (hardcopy only).
;
; History:
;	Farmed out from GR_PLOT_OBJECT: 10/12/96; SJT
;	Modify for extended symbol definitions: 20/1/97; SJT
;	Made unique in 8.3: 11/2/97; SJT
;	Convert handles to pointers: 27/6/05; SJT
;-

  xrange = !X.crange
  if (pdefs.xtype) then xrange = 10^xrange
  yrange = !Y.crange
  if (pdefs.ytype) then yrange = 10^yrange

  maxrange = sqrt(max(xrange^2)+max(yrange^2))

  data = *pdefs.data
  if not ptr_valid(data[i].xydata) then return

  if (data[i].colour eq -1) then return
  if data[i].colour eq -2 then $
     lcolour = graff_colours(data[i].c_vals) $
  else lcolour = graff_colours(data[i].colour)

  xydata = *data[i].xydata

  case (data[i].type) of
     -1: begin                  ; Y=f(x) | theta=f(r)
        case (data[i].mode) of
           0: begin
              arange = xrange
              atype = pdefs.xtype
           end
           Else: begin
              arange = [0., maxrange]
              atype = 0
           end
        endcase
        exceed = 0
     end
     -2: begin                  ; x=f(y) | r = f(theta)
        case (data[i].mode) of
           0: begin
              arange = yrange
              atype = pdefs.ytype
              exceed = 0
           end 
           1: begin
              arange = [0., 2.*!Pi]
              atype = 0
              exceed = 1
           end
           2: begin
              arange = [0., 360.]
              atype = 0
              exceed = 1
           end
        endcase
     end
     -3: begin
        arange = xydata.range
        atype = 0
        exceed = 0
     end
  endcase

  if (xydata.range(0) ne xydata.range(1)) then begin
     if (exceed) then begin 
        amin = xydata.range(0)
        amax = xydata.range(1)
     endif else begin
        amin = arange(0) > xydata.range(0)
        amax = arange(1) < xydata.range(1)
     endelse
  endif else begin
     amin = arange(0)
     amax = arange(1)
  endelse

  if (atype) then begin
     amin = alog10(amin)
     amax = alog10(amax)
     t = 10^(dindgen(data[i].ndata) * (amax-amin) $
             /  float(data[i].ndata-1) + amin)
  endif else t = dindgen(data[i].ndata) * (amax-amin) $
                 /  float(data[i].ndata-1) + amin

  case (data[i].type) of
     -1: begin                  ;  y = f(x)
        x = t
        y = 0.                  ; Must make y defined before using it
                                ; in an execute

        iexe = execute('y = '+xydata.funct)
        s = size(y, /n_dimensions)
     end
     -2: begin                  ;  x = f(y)
        y = t
        x = 0.                  ; Must make x defined before using it
                                ; in an execute

        iexe = execute('x = '+xydata.funct)
        s = size(x, /n_dimensions)
     end
     -3: begin                  ;  x = f(t) & y = g(t)
        x = 0.
        y = 0.                  ; Must make y defined before using it
                                ; in an execute

        iexe = execute('x = '+xydata.funct(0))
        iexe = execute('y = '+xydata.funct(1))
        s = size(y, /n_dimensions) < size(x, /n_dimensions)
     end
  endcase

  if (s eq 0) then graff_msg, pdefs.ids.message, $
                              "Function:"+xydata.funct+" does not return an array" $
  else begin
     if (data[i].mode eq 2) then pcf = !Dtor $
     else pcf = 1.0
     if (data[i].pline ne 0) then begin
        lps = ([0, 0, 10])(data[i].pline)
        oplot, x, y*pcf, color = lcolour, psym = $
               lps, linesty = data[i].line, thick = $
               data[i].thick, polar = (data[i].mode ne 0), noclip = $
               data[i].noclip
     endif
     
     if (data[i].psym ne 0) then begin
        if (data[i].psym ge 8) then gr_symdef, data[i].psym 
        oplot, x, y*pcf, color = lcolour, psym = $
               data[i].psym < 8, thick = data[i].thick, symsize = $
               abs(data[i].symsize)*csiz, polar = (data[i].mode ne 0), $
               noclip = data[i].noclip  
     endif
  endelse

end
