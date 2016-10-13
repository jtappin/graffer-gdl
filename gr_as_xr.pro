pro Gr_as_xr, data, yrange, ytype, range, visible = visible

;+
; GR_AS_XR
;	Autoscale graffer data (X-Axis, rectangular plot)
;
; Usage:
;	gr_as_xr, data, range
;
; Arguments:
;	data	struct	input	The Graffer data structure (extracted
;				from PDEFS)
;	yrange	float	input	The Y- range for functions (x=f(y))
;                                      (or data when visible is set)
;	ytype	int	input	log or linear Y (ditto)
;	range	float	in/out	The range to use.
;
; Keyword:
; 	/visible	If set, then only consider data values that
; 			lie within yrange.
;
; History:
;	Extracted from GR_AUTOSCALE: 16/12/96; SJT
;	Convert handles to pointers: 27/6/05; SJT
;	Add visible key: 31/5/16; SJT
;	Ignore undisplayed datasets: 13/10/16; SJT
;-

; Ignore undisplayed datasets

  if data.type eq 9 || data.type eq -4 then begin
     if data.zopts.format eq 2 then return
  endif else begin
     if data.colour eq -1 then return
  endelse

  fv = 0.                       ; Just create the variable

  case (data.type) of
     -1: if ((*data.xydata).range(0) ne (*data.xydata).range(1)) then $
        begin                   ;Y = F(x)
        range(0) = range(0) < (*data.xydata).range(0)
        range(1) = range(1) > (*data.xydata).range(1)
     endif
     
     -2: begin                  ; X = f(y)
        if ((*data.xydata).range(0) ne (*data.xydata).range(1)) then begin
           amin = yrange(0) > (*data.xydata).range(0)
           amax = yrange(1) < (*data.xydata).range(1)
        endif else begin
           amin = yrange(0)
           amax = yrange(1)
        endelse
        if (ytype) then begin
           amin = alog10(amin)
           amax = alog10(amax)
           y = 10^(dindgen(data.ndata) * (amax-amin) $
                   /  float(data.ndata-1) + amin)
        endif else y = dindgen(data.ndata) * (amax-amin) $
                       /  float(data.ndata-1) + amin
        
        iexe = execute('fv = '+(*data.xydata).funct)
        
        range(0) = range(0) < min(fv, max = fvmx)
        range(1) = range(1) > fvmx
     end
     
     -3: begin                  ; x = f(t), y = f(t)
        t = dindgen(data.ndata) *  $
            ((*data.xydata).range(1)-(*data.xydata).range(0)) $
            /  float(data.ndata-1) + (*data.xydata).range(0)
        
        iexe = execute('fv = '+(*data.xydata).funct(0))
        
        range(0) = range(0) < min(fv, max = fvmx)
        range(1) = range(1) > fvmx
     end
     
     -4: if ((*data.xydata).range(0, 0) ne (*data.xydata).range(1, 0)) then $
        begin                   ; z = f(x,y)
        range(0) = range(0) < (*data.xydata).range(0, 0)
        range(1) = range(1) > (*data.xydata).range(1, 0)
     endif
     
     9: begin                   ; Surface data 
        range(0) = range(0) < min(*(*data.xydata).x, max = mx)
        range(1) = range(1) > mx
     end
     
     Else: begin                ; XY data, much easier (or it was)
        yy = (*data.xydata)[1, 0:data.ndata-1]
        if (data.type le 2) then begin
           xp = (*data.xydata)[0, 0:data.ndata-1]
           xm = (*data.xydata)[0, 0:data.ndata-1]
        endif else if (data.type eq 3 or $
                       data.type eq 5 or $
                       data.type eq 6) then begin
           xp = (*data.xydata)[0, 0:data.ndata-1] +  $
                (finite((*data.xydata)[2, 0:data.ndata-1]) and $
                 (*data.xydata)[2, 0:data.ndata-1])
           xm = (*data.xydata)[0, 0:data.ndata-1] - $
                (finite((*data.xydata)[2, 0:data.ndata-1]) and $
                 (*data.xydata)[2, 0:data.ndata-1])
        endif else begin
           xp = (*data.xydata)[0, 0:data.ndata-1] +  $
                (finite((*data.xydata)[3, 0:data.ndata-1]) and $
                 (*data.xydata)[3, 0:data.ndata-1])
           xm = (*data.xydata)[0, 0:data.ndata-1] - $
                (finite((*data.xydata)[2, 0:data.ndata-1]) and $
                 (*data.xydata)[2, 0:data.ndata-1])
        endelse
        
        if keyword_set(visible) then $
           locs = where(finite(xm) and $
                        yy ge yrange[0] and yy le yrange[1], nf) $
        else locs = where(finite(xm), nf)
        if (nf gt 0) then range(0) = range(0) < min(xm(locs))
        if keyword_set(visible) then $
           locs = where(finite(xp) and $
                        yy ge yrange[0] and yy le yrange[1], nf) $
        else locs = where(finite(xp), nf)
        if (nf gt 0) then range(1) = range(1) > max(xp(locs))
        
     end
  endcase

end
