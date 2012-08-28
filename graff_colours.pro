pro Graff_colours, pdefs

;+
; GRAFF_COLOURS
;	Sets up the colour table for graffer.
;
; Usage:
;	graff_colours, pdefs	; Not indended for use by the user.
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
;-

red = [255b, 0b, 255b, 0b, 0b, 0b, 255b, 255b, 255b, 127b, 0b, 0b, $
       127b, 255b, 85b, 170b, 170b, 255b, 0b, 85b, 0b, 85b, 0b, 85b, $
       170b, 255b, 170b, 255b] 
gre = [255b, 0b, 0b, 255b, 0b, 255b, 0b, 255b, 127b, 255b, 255b, 127b, $
       0b, 0b, 85b, 170b, 0b, 85b, 170b, 255b, 0b, 85b, 170b, 255b, $
       0b, 85b, 170b, 255b]
blu = [255b, 0b, 0b, 0b, 255b, 255b, 255b, 0b, 0b, 0b, 127b, 255b, $
       255b, 127b, 85b, 170b, 0b, 85b, 0b, 85b, 170b, 255b, 170b, $
       255b, 170b, 255b, 0b, 85b]

tvlct, red, gre, blu

!P.color = 1

if (!D.n_colors lt 20) then begin
    graff_msg, pdefs.ids.message,  $
      ["Insufficient colours for loading extended colour table",  $
       '2-D datasets with "Image" display will be skipped']
    pdefs.short_colour = 1b
    return
endif

;	Here we get the colour table (do it explicitly because we
;	don't want all the side effects of LOADCT

pdefs.transient.colmin = n_elements(red)

filename = filepath('colors1.tbl', subdir = ['resource', 'colors'])
openr, ilu, /get, filename
aa = assoc(ilu, bytarr(256, 3), 1)
    
col = aa(pdefs.ctable)
if (pdefs.gamma ne 1.0) then begin
    s = long(256*((findgen(256)/256.)^pdefs.gamma))
    col = col(s, *)
endif


nc = (!D.n_colors-pdefs.transient.colmin) < 128
col = congrid(col, nc, 3)

tvlct, col(*, 0), col(*, 1), col(*, 2), pdefs.transient.colmin
free_lun, ilu

end
