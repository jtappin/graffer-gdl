; LICENCE:
; Copyright (C) 1995-2021: SJT
; This program is free software; you can redistribute it and/or modify  
; it under the terms of the GNU General Public License as published by  
; the Free Software Foundation; either version 2 of the License, or     
; (at your option) any later version.                                   

pro graff_convert, file, ofile

;+
; GRAFF_CONVERT
;	Convert an older Graffer file to the current format.
;
; Usage:
;	graff_convert, file[, ofile]
;
; Arguments:
;	file	string	The file to convert
;	ofile	string	The new name for the file, if not given, then the
;			old file is overwritten.
;
; History:
;	Original: 27/2/13; SJT
;-

  on_error, 2
  
@graff_version

  f0 = file
  graff_init, pdefs, f0, version = version
  igot = graff_get(pdefs, f0, /no_set, /no_warn)
  if igot ne 1 then begin       ; Note that here it is not meaningful to
                                ; continue if the file doesn't exist.

     message, "Failed to open: "+f0
     return
  endif

  if (n_params() eq 2) then begin
     pdefs.name = file_basename(ofile)
     pdefs.dir = file_dirname(ofile,  /mark_directory)
  endif

  gr_bin_save, pdefs

  graff_clear, pdefs

end
