pro Gr_rc_get, optblock

;+
; GR_RC_GET
;	Read the user's .grafferrc file.
;
; Usage:
;	gr_rc_get, opts
;
; Argument:
;	opts	struct	output	The graffer options sub-structure.
;
; Note:
;	This is a procedure rather than a function as functions tend
;	to croak if asked to return undefined values.
;
; History:
;	Extracted from GRAFF_INIT: 21/8/97; SJT
;	Eliminate obsolete findfile call: 16/4/12; SJT
;	Remove colour_menu altogether: 21/5/20; SJT
;-


  home = getenv('HOME')
  if strpos(home, path_sep(), /reverse_search) ne strlen(home)-1 then $
     rcfile = home+path_sep()+'.grafferrc' $
  else  rcfile = home+'.grafferrc'

  optblock = {graff_opts}
  optblock.Auto_delay = 300.
  optblock.Mouse = 0b

  if ~file_test(rcfile) then return

  openr, ilu, rcfile(0), /get
  inln = ''
  while not eof(ilu) do begin
     readf, ilu, inln
     kv = str_sep(inln, ':')
     case kv(0) of
        'Autosave': optblock.auto_delay = float(kv(1))
        'Supp2D': optblock.s2d = fix(kv(1))
        'MouseEdit': optblock.mouse = fix(kv(1))
        'PDFView': optblock.pdfviewer = kv[1]
        Else: print, "Warning: Unknown item in resource file"
     endcase
  endwhile
  free_lun, ilu

end
