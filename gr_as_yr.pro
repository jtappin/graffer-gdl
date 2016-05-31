pro Gr_as_yr, data, xrange, xtype, range, visible = visible

;+
; GR_AS_YR
;	Autoscale graffer data (Y-Axis, rectangular plot)
;
; Usage:
;	gr_as_xr, data, xrange, xtype, range
;
; Arguments:
;	data	struct	input	The Graffer data structure (extracted
;				from PDEFS)
;	xrange	float	input	The X- range for functions (y=f(x))
;	xtype	int	input	log or linear X (ditto)
;	range	float	in/out	The range to use.
;
; Keyword:
; 	/visible	If set, then only consider data values that
; 			lie within yrange.
;
; History:
;	Extracted from GR_AUTOSCALE: 16/12/96; SJT
;	Change handles to pointers: 27/6/05; SJT
;	Support max & min vals: Apr 16; SJT
;	Add visible key: 31/5/16; SJT
;-

  fv = 0.                       ; Just create the variable

  case (data.type) of
     -1: begin                  ; y = f(x)
        if ((*data.xydata).range(0) ne (*data.xydata).range(1)) then begin
           amin = xrange(0) > (*data.xydata).range(0)
           amax = xrange(1) < (*data.xydata).range(1)
        endif else begin
           amin = xrange(0)
           amax = xrange(1)
        endelse
        if (xtype) then begin
           amin = alog10(amin)
           amax = alog10(amax)
           x = 10^(dindgen(data.ndata) * (amax-amin) $
                   /  float(data.ndata-1) + amin)
        endif else x = dindgen(data.ndata) * (amax-amin) $
                       /  float(data.ndata-1) + amin
        
        iexe = execute('fv = '+(*data.xydata).funct)
        
        range(0) = range(0) < min(fv, max = fvmx)
        range(1) = range(1) > fvmx
     end
     
     -2: if ((*data.xydata).range(0) ne (*data.xydata).range(1)) then begin ;x = F(y)
        range(0) = range(0) < (*data.xydata).range(0)
        range(1) = range(1) > (*data.xydata).range(1)
     endif
     
     -3: begin                  ; x = f(t), y = f(t)
        t = dindgen(data.ndata) *  $
            ((*data.xydata).range(1)-(*data.xydata).range(0)) $
            /  float(data.ndata-1) + (*data.xydata).range(0)
        
        iexe = execute('fv = '+(*data.xydata).funct(1))
        
        range(0) = range(0) < min(fv, max = fvmx)
        range(1) = range(1) > fvmx
     end
     
     -4: if ((*data.xydata).range(0, 1) ne (*data.xydata).range(1, 1)) then $
        begin                   ; z = f(x,y)
        range(0) = range(0) < (*data.xydata).range(0, 1)
        range(1) = range(1) > (*data.xydata).range(1, 1)
     endif
     
     9: begin                   ; Surface data 
        range(0) = range(0) < min(*(*data.xydata).y, max = mx)
        range(1) = range(1) > mx
     end
     
     Else: begin
        xx = (*data.xydata)[0, 0:data.ndata-1]
        if (data.type eq 0 or $
            data.type eq 3 or $
            data.type eq 4) then begin
           yp = (*data.xydata)[1, 0:data.ndata-1]
           ym = (*data.xydata)[1, 0:data.ndata-1]
           
        endif else if (data.type eq 1) then begin
           yp = (*data.xydata)[1, 0:data.ndata-1] + $
                (finite((*data.xydata)[2, 0:data.ndata-1]) and $
                 (*data.xydata)[2, 0:data.ndata-1])
           ym = (*data.xydata)[1, 0:data.ndata-1] - $
                (finite((*data.xydata)[2, 0:data.ndata-1]) and $
                 (*data.xydata)[2, 0:data.ndata-1])
           
        endif else if (data.type eq 2) then begin
           yp = (*data.xydata)[1, 0:data.ndata-1] + $
                (finite((*data.xydata)[3, 0:data.ndata-1]) and $
                 (*data.xydata)[3, 0:data.ndata-1])
           ym = (*data.xydata)[1, 0:data.ndata-1] - $
                (finite((*data.xydata)[2, 0:data.ndata-1]) and $
                 (*data.xydata)[2, 0:data.ndata-1])
           
        endif else if (data.type eq 5) then begin
           yp = (*data.xydata)(1, 0:data.ndata-1) + $
                (finite((*data.xydata)(3, 0:data.ndata-1)) and $
                 (*data.xydata)(3, 0:data.ndata-1))
           ym = (*data.xydata)(1, 0:data.ndata-1) - $
                (finite((*data.xydata)(3, 0:data.ndata-1)) and $
                 (*data.xydata)(3, 0:data.ndata-1))
           
        endif else if (data.type eq 6) then begin
           yp = (*data.xydata)(1, 0:data.ndata-1) + $
                (finite((*data.xydata)(4, 0:data.ndata-1)) and $
                 (*data.xydata)(4, 0:data.ndata-1))
           ym = (*data.xydata)(1, 0:data.ndata-1) - $
                (finite((*data.xydata)(3, 0:data.ndata-1)) and $
                 (*data.xydata)(3, 0:data.ndata-1))
           
        endif else if (data.type eq 7) then begin
           yp = (*data.xydata)(1, 0:data.ndata-1) + $
                (finite((*data.xydata)(4, 0:data.ndata-1)) and $
                 (*data.xydata)(4, 0:data.ndata-1))
           ym = (*data.xydata)(1, 0:data.ndata-1) - $
                (finite((*data.xydata)(4, 0:data.ndata-1)) and $
                 (*data.xydata)(4, 0:data.ndata-1))
           
        endif else  begin
           yp = (*data.xydata)(1, 0:data.ndata-1) + $
                (finite((*data.xydata)(5, 0:data.ndata-1)) and $
                 (*data.xydata)(5, 0:data.ndata-1))
           ym = (*data.xydata)(1, 0:data.ndata-1) - $
                (finite((*data.xydata)(4, 0:data.ndata-1)) and $
                 (*data.xydata)(4, 0:data.ndata-1))
        endelse
        
        if finite(data.max_val) then yp <= data.max_val
        if finite(data.min_val) then ym >= data.min_val

        if keyword_set(visible) then $
           locs = where(finite(ym) and $
                        xx ge xrange[0] and xx le xrange[1], nf) $
        else locs = where(finite(ym), nf)
        if (nf gt 0) then range(0) = range(0) < min(ym[locs])
        if keyword_set(visible) then $
           locs = where(finite(yp) and $
                        xx ge xrange[0] and xx le xrange[1], nf) $
        else locs = where(finite(yp), nf)
        if (nf gt 0) then range(1) = range(1) > max(yp[locs])
     end
     
  endcase

end
