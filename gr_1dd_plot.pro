pro Gr_1dd_plot, pdefs, i, csiz

;+
; GR_1DD_PLOT
;	Plot a 1-D Data in graffer
;
; Usage:
;	gr_1dd_plot, pdefs, i
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
; 	Add min & max values: 4/3/15; SJT
; 	Ignore min & max for polar, but use in errors: 28/7/15; SJT
;-

  data = *pdefs.data
  if not ptr_valid(data[i].xydata) then return
  if (data[i].colour eq -1) then return
  if data[i].colour eq -2 then $
     lcolour = graff_colours(data[i].c_vals) $
  else lcolour = graff_colours(data[i].colour)

  xydata = *data[i].xydata

  if data[i].mode eq 0 then begin
     if finite(data[i].min_val) then minv = data[i].min_val
     if finite(data[i].max_val) then maxv = data[i].max_val
  endif

  if (data[i].sort) then begin
     js = sort(xydata(0, *))
     xydata = xydata(*, js)
  endif
  if (data[i].mode eq 2) then pcf = !Dtor $
  else pcf = 1.0

  if (data[i].pline ne 0) then begin
     lps = ([0, 0, 10])(data[i].pline)
     oplot, xydata(0, 0:data[i].ndata-1), xydata(1, *)*pcf, color = $
            lcolour, psym = lps, linesty = data[i].line, $
            thick = data[i].thick, polar = data[i].mode, noclip = $
            data[i].noclip, min_value = minv, max_value = maxv
  endif

  if (data[i].psym ne 0) then begin
     if (data[i].psym ge 8) then gr_symdef, data[i].psym 
     oplot, xydata(0, 0:data[i].ndata-1), xydata(1, *)*pcf, color = $
            lcolour, psym = data[i].psym < 8, thick = $
            data[i].thick, $
            symsize = abs(data[i].symsize)*csiz, polar = data[i].mode, $
            $
            noclip = $
            data[i].noclip, min_value = minv, max_value = maxv
  endif

  if (data[i].mode eq 0) then begin ; A present at any rate no
                                ; errors on polar plots.
     case (data[i].type) of
        0:                      ;No error bars = no action
        
        1: begin                ; Y
           gr_err_y, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     width = data[i].symsize*csiz*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv
        end
        
        2: begin                ; YY
           gr_err_y, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     xydata(3, *), width = data[i].symsize*0.01 > $
                     0, color = lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv 
        end                    
        
        3: begin                ; X
           gr_err_x, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv 
        end
        
        4: begin                ; XX
           gr_err_x, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     xydata(3, *), width = data[i].symsize*0.01 > $
                     0, color = lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv
        end                    
        
        5: begin                ; XY
           gr_err_x, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].nocli, $
                     min_value = minv, max_value = maxvp 
           gr_err_y, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(3, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv 
        end
        
        6: begin                ; XYY
           gr_err_y, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(3, *), xydata(4, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv 
           gr_err_x, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv 
        end
        
        7: begin                ; XXY
           gr_err_y, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(4, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip 
           gr_err_x, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), xydata(3, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip 
        end
        
        8: begin                ; XXYY
           gr_err_x, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), xydata(3, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv 
           gr_err_y, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(4, *), xydata(5, *), $
                     width = data[i].symsize*0.01 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, noclip = data[i].noclip, $
                     min_value = minv, max_value = maxv 
        end
     endcase
  endif else begin
     case (data[i].type) of
        0:                      ;No error bars = no action
        
        1: begin                ; Y
           gr_err_th, xydata(0, 0:data[i].ndata-1), $
                      xydata(1, *), xydata(2, *), $
                      width = data[i].symsize*0.01 > 0, color = $
                      lcolour, thick = $
                      data[i].thick, mode = data[i].mode, noclip = data[i].noclip
        end
        
        2: begin                ; YY
           gr_err_th, xydata(0, 0:data[i].ndata-1), $
                      xydata(1, *), xydata(2, *), $
                      xydata(3, *), width = data[i].symsize*0.01 > $
                      0, color = lcolour, thick = $
                      data[i].thick, mode = data[i].mode, noclip = data[i].noclip 
        end                    
        
        3: begin                ; X
           gr_err_r, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     width = data[i].symsize*2.0 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, mode = data[i].mode, noclip = data[i].noclip
        end
        
        4: begin                ; XX
           gr_err_r, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     xydata(3, *), width = data[i].symsize*2.0 > $
                     0, color = lcolour, thick = $
                     data[i].thick, mode = data[i].mode, noclip = data[i].noclip
        end                    
        
        5: begin                ; XY
           gr_err_r, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     width = data[i].symsize*2.0 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, mode = data[i].mode, noclip = data[i].noclip
           gr_err_th, xydata(0, 0:data[i].ndata-1), $
                      xydata(1, *), xydata(3, *), $
                      width = data[i].symsize*0.01 > 0, color = $
                      lcolour, thick = $
                      data[i].thick, mode = data[i].mode, noclip = data[i].noclip
        end
        
        6: begin                ; XYY
           gr_err_th, xydata(0, 0:data[i].ndata-1), $
                      xydata(1, *), xydata(3, *), xydata(4, *), $
                      width = data[i].symsize*0.01 > 0, color = $
                      lcolour, thick = $
                      data[i].thick, mode = data[i].mode, noclip = data[i].noclip
           gr_err_r, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), $
                     width = data[i].symsize*2.0 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, mode = data[i].mode, noclip = data[i].noclip
        end
        
        7: begin                ; XXY
           gr_err_th, xydata(0, 0:data[i].ndata-1), $
                      xydata(1, *), xydata(4, *), $
                      width = data[i].symsize*0.01 > 0, color = $
                      lcolour, thick = $
                      data[i].thick, mode = data[i].mode, noclip = data[i].noclip
           gr_err_r, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), xydata(3, *), $
                     width = data[i].symsize*2.0 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, mode = data[i].mode, noclip = data[i].noclip
        end
        
        8: begin                ; XXYY
           gr_err_r, xydata(0, 0:data[i].ndata-1), $
                     xydata(1, *), xydata(2, *), xydata(3, *), $
                     width = data[i].symsize*2.0 > 0, color = $
                     lcolour, thick = $
                     data[i].thick, mode = data[i].mode, noclip = data[i].noclip
           gr_err_th, xydata(0, 0:data[i].ndata-1), $
                      xydata(1, *), xydata(4, *), xydata(5, *), $
                      width = data[i].symsize*0.01 > 0, color = $
                      lcolour, thick = $
                      data[i].thick, mode = data[i].mode, noclip = data[i].noclip
        end
     endcase
  endelse

end
