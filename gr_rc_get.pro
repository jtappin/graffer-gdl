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
; History:
;	Extracted from GRAFF_INIT: 21/8/97; SJT
;	Eliminate obsolete findfile call: 16/4/12; SJT
;	Remove colour_menu altogether: 21/5/20; SJT
;	Add tracking events control, make RC file case insensitive:
;	18/8/21; SJT
;-


  home = getenv('HOME')
  if strpos(home, path_sep(), /reverse_search) ne strlen(home)-1 then $
     rcfile = home+path_sep()+'.grafferrc' $
  else  rcfile = home+'.grafferrc'

  optblock = {graff_opts}
  optblock.Auto_delay = 300.
  optblock.Mouse = 0b
  optblock.track = ~is_gdl()
  
  if ~file_test(rcfile) then return

  openr, ilu, rcfile(0), /get
  inln = ''
  while not eof(ilu) do begin
     readf, ilu, inln
     kv = str_sep(inln, ':')
     case strupcase(kv(0)) of
        'AUTOSAVE': optblock.auto_delay = float(kv(1))
        'SUPP2D': optblock.s2d = fix(kv(1))
        'MOUSEEDIT': optblock.mouse = fix(kv(1))
        'PDFVIEW': optblock.pdfviewer = kv[1]
        'TRACK': if ~is_gdl() then  optblock.track = fix(kv[1]) $
        else print, "Warning: Tracking events don't work under GDL."
        Else: print, "Warning: Unknown item in resource file."
     endcase
  endwhile
  free_lun, ilu

end
