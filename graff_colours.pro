function graff_colours, index

;+
; GRAFF_COLOURS
;	Compute a colour value for graffer.
;
; Usage:
;	col = graff_colours(index)	; Not indended for use by the user.
;
; Returns:
;	A 32-bit integer decomposed colour for plotting.
;
; Argument:
;	pdefs	struct	input	GRAFFER control structure (only colour
;				table is used
; Side Effects:
;	The colour table is updated.
;	Table is W, Bla, R, G, B, Cy, Ma, Ye, Or, (G+Ye), (G+Cy),
;	(B+Cy), (B+Ma), (R+Ma), Dk Grey, Lt Grey, Dk R, Lt R, Dk G, Lt
;	G, Dk B, Lt B, Dk Cy, Lt Cy, Dk Ma, Lt Ma, Dk Ye, Lt Ye.
;
; History:
;	Original: 2/8/95; SJT
;	Rename as GRAFF_COLOURS (was s_colours): 18/9/96; SJT
;	Don't do extended colour table if not enough colours: 8/5/97; SJT
;	Extend discrete colours: 8/2/12; SJT
;	Essentially new routine for decom colours: 17/5/16; SJT
;-

  if n_elements(index) eq 1 then begin
     cmap =  [255l, 0l, 255l, 0l, 0l, 0l, 255l, 255l, 255l, 127l, 0l, $
              0l, 127l, 255l, 85l, 170l, 170l, 255l, 0l, 85l, 0l, 85l, $
              0l, 85l, 170l, 255l, 170l, 255l] + $ ; Red 
             [255l, 0l, 0l, 255l, 0l, 255l, 0l, 255l, 127l, 255l, 255l, $
              127l, 0l, 0l, 85l, 170l, 0l, 85l, 170l, 255l, 0l, 85l, $
              170l, 255l, 0l, 85l, 170l, 255l] * 256l + $ ; Green
             [255l, 0l, 0l, 0l, 255l, 255l, 255l, 0l, 0l, 0l, 127l, $
              255l, 255l, 127l, 85l, 170l, 0l, 85l, 0l, 85l, 170l, 255l, $
              170l, 255l, 170l, 255l, 0l, 85l] * 256l^2 ; Blue

     imax = n_elements(cmap)
     if index lt 0 || index ge imax then return, 0l
     
     return, cmap[index]
  endif else if n_elements(index) eq 3 then begin
     sindex = long(byte(index))
     return, sindex[0] + sindex[1]*256l + sindex[2]*256l^2
  endif else return, 0l
end
