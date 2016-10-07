pro graff_put_rec, ilu, tag, value

;+
; GRAFF_PUT_REC
;	Put a component of a Graffer V4 file to the output file.
;
; Usage:
;	graff_put_rec, ilu, tag, value
;
; Arguments:
;	ilu	long	input	The logical unit to which to write.
;	tag	string	input	The name of the field tag for the variable.
;	value	any	input	The values to write in that tag.
;
; History:
;	Original: 5/1/12; SJT
;	Add list types: 6/10/16; SJT
;-

  if n_params() lt 2 then message, "GRAFF_PUT_REC requires at least " + $
                                   '2 parameters' 

  sz = size(value)
  tcode = sz[sz[0]+1]

  if tcode eq 8 || tcode eq 10 || $
     (tcode eq 11 && typename(value) ne 'LIST') then begin
     message, /continue, "GRAFF_PUT_REC cannot write structures, " + $
              "pointers or objects (other than lists)"
     return
  endif

; Adjust the tag to 3 characters.
  case strlen(tag) of
     0: message, "GRAFF_PUT_REC: tag is empty"
     1: wtag = tag+'  '
     2: wtag = tag+' '
     3: wtag = tag
     else: begin
        message, /continue, "GRAFF_PUT_RECORD Overlong tag truncated"
        wtag = strmid(tag, 0, 3)
     end
  endcase

  writeu, ilu, wtag, tcode, sz[0:sz[0]]

  if tcode eq 7 then writeu, ilu, strlen(value) 
  if tcode eq 11 then begin
     for j = 0, sz[1]-1 do begin
        tmp = value[j]
        se = size(tmp)
        tcode_e = se[se[0]+1]
        if tcode_e eq 8 || tcode_e eq 10 || tcode_e eq 11 then begin
           message, /continue, "GRAFF_PUT_REC cannot write " + $
                    "structures, pointers or objects as elements of " + $
                    "lists" 
           tcode_e = 0l
           se = 0l
        endif
        writeu, ilu, tcode_e, se[0:se[0]]
        if tcode_e eq 7 then writeu, ilu, strlen(tmp)
        if tcode_e ne 0 then writeu, ilu, tmp
     endfor
  endif else if tcode ne 0 then writeu, ilu, value

end
