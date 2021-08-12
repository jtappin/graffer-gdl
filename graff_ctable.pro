pro graff_ctable, table, cmap, gamma = gamma

;+
; GRAFF_CTABLE
;	Obtain full colour table (c.f. GRAFF_COLOURS) for a 2-D
;	dataset. 
;
; Usage:
;	graff_ctable, table, cmap
;
; Argument:
;	table	int	input	The table index to load.
;	cmap	byte	output	The colour map
;
; Keyword:
;	gamma	float	input	An optional gamma setting.
;
; Side effects:
;	No longer applicable
;
; History:
;	Original: 17/11/11; SJT
;	Restructure colour handling: 16/5/16; SJT
;-

  defsysv, '!gdl', exist = is_gdl

  if is_gdl then begin
     tb = scope_traceback( /structure )
     path = file_dirname(tb[-1].filename, /mark) +'data'+path_sep()
     filename = path+'colours.table'
     openr, ilu, /get, filename

     ntab = 0b
     readu, ilu, ntab

     bname = bytarr(32)
     cmap = bytarr(256, 3)

     if table ge ntab then it = 0 $
     else it = table

     for j = 0, it do readu, ilu, bname, cmap
     
  endif else begin
     filename = filepath('colors1.tbl', subdir = ['resource', 'colors'])
     openr, ilu, /get, filename
     aa = assoc(ilu, bytarr(256, 3), 1)
  
     cmap = aa[table]
  endelse
  
  free_lun, ilu

  if keyword_set(gamma) && gamma ne 1.0 then begin
     s = long(256*((findgen(256)/256.)^gamma))
     cmap = cmap[s, *]
  endif

end
