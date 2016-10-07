pro graff_get_rec, ilu, tag, value, tcode, ndims = ndims, dims = $
                   dims, nvals = nvals

;+
; GRAFF_GET_REC
;	Read a record from a Graffer V4 file.
;
; Usage:
;	graff_get_rec, ilu, tag, value, tcode
;
; Arguments:
;	ilu	long	input	The file unit to read
;	tag	string	output	The 3-character field tag.
;	value	any	output	The value(s) read.
;	tcode	long	output	The type code for the type of value.
;
; Keywords:
;	ndims	long	output	The number of dimensions read.
;	dims	long	output	The size of each dimension.
;
; History:
;	Original: 5/1/12; SJT
;	Add ndims, nvals and dims keywords: 9/1/12; SJT
;	Support LIST values: 6/10/16; SJT
;-

; Initialize the tag header information
  tag = '   '
  tcode = 0l
  ndims = 0l

  readu, ilu, tag, tcode, ndims

  if tcode eq 0 then return     ; A tag with no values

  if ndims gt 0 then begin
     if ndims eq 1 then dims = 0l $
     else dims = lonarr(ndims)
     readu, ilu, dims
  endif else dims = 1

  if tcode ne 11 then begin
     value = make_array(dims, type = tcode)
     if arg_present(nvals) then nvals = n_elements(value)

     if tcode eq 7 then begin
        lstr = lonarr(dims)
        readu, ilu, lstr
        for j = 0, n_elements(lstr)-1 do  $
           if lstr[j] ne 0 then value[j] = string(replicate(32b, lstr[j]))
     endif

     if ndims eq 0 then value = value[0]

     readu, ilu, value
  endif else begin              ; LISTS need different handling
     value = list()

     for j = 0, dims-1 do begin
        itcode = 0l
        indims = 0l
        readu, ilu, itcode, indims
        if itcode eq 0 then begin
           value.add, !null
           continue
        endif
        if indims eq 0 then idims = 1 $
        else begin
           idims = lonarr(indims)
           readu, ilu, idims
        endelse

        ivalue = make_array(idims, type = itcode)
        if itcode eq 7 then begin
           ilstr = lonarr(idims)
           readu, ilu, ilstr
           for k = 0, n_elements(ilstr)-1 do $
              if ilstr[j] ne 0 then $
                 ivalue[j] = string(replicate(32b, ilstr[j]))
        endif
        if indims eq 0 then ivalue = ivalue[0]
        readu, ilu, ivalue
        value.add, ivalue
     endfor
  endelse

end
