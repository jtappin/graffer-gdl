pro graff_ctable, table, gamma

;+
; GRAFF_CTABLE
;	Load a full colour table (c.f. GRAFF_COLOURS) for a 2-D
;	dataset. 
;
; Usage:
;	graff_ctable, table
;
; Argument:
;	table	int	input	The table index to load.
;
; Side effects:
;	The colour table is updated. The routine using this should
;	call graff_colours after completing the image display to
;	restore the normal line colours. This routine will return
;	without doing anything if 256 or fewer colours are available
;	(8-bit displays).
;
; History:
;	Original: 17/11/11; SJT
;-

if !d.n_colors le 256 and !d.name ne 'PS' then return

filename = filepath('colors1.tbl', subdir = ['resource', 'colors'])
openr, ilu, /get, filename
aa = assoc(ilu, bytarr(256, 3), 1)
    
col = aa[table]
if keyword_set(gamma) && gamma ne 1.0 then begin
    s = long(256*((findgen(256)/256.)^gamma))
    col = col(s, *)
endif

tvlct, col[*, 0], col[*, 1], col[*, 2]

free_lun, ilu
end
