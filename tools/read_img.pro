;+
; READ_IMG
;	Read an image file into GDL, a replacement for READ_PNG
;	etc. owing to crash error with libmagick
;
; Usage:
;	read_img, file, image
;
; Arguments:
;	file	string	The file to read.
;	image	byte/uint A variable to return the image.
;
; Keywords:
;	/retain	If set, then do not delete the intermediate raw file.
;
; Notes:
;	Currently limited to 8 or 16 bit greyscale and rgb files.
;	Requires imagemagick.
;
; History:
;	Original: 17-18/2/21; SJT
;-


pro read_img, file, img, retain = retain

  inln = ''
  spawn, 'magick identify '+file, unit = ilu
  readf, ilu, inln
  free_lun, ilu

  cpts = strsplit(inln, /extr)

  sz = long(strsplit(cpts[2], 'x', /extr))

  sbits = strsplit(cpts[4], '-', /extr)
  bits = fix(sbits[0])
  if bits ne 8 && bits ne 16 then begin
     print, "Unknown depth: ", bits
     print, inln
     return
  endif
  
  type = strupcase(cpts[5])
  case type of
     'SRGB': begin
        if bits eq 8 then $
           img = bytarr(3, sz[0], sz[1]) $
        else img = uintarr(3, sz[0], sz[1])
        
        tfile = file_basename(file) + '.rgb'
        idx = 3
     end
     'GRAY': begin
        if bits eq 8 then img = bytarr(sz) $
        else img = uintarr(sz)
        
        tfile = file_basename(file) + '.gray'
        idx = 2
     end
     else: begin
        print, "Unknown type: ", type
        print, inln
        return
     end
  endcase
  
  spawn, "magick convert "+file+" "+tfile

  openr, ilu, /get, tfile
  readu, ilu, img
  free_lun, ilu
  img = reverse(img, idx)
  
  if ~keyword_set(retain) then file_delete, tfile
end
