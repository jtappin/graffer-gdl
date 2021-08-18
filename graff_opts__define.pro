pro graff_opts__define
;+
; NAME:
;	graff_opts__define
;
;
; PURPOSE:
;	Define a graffer default options structure
;
;
; CATEGORY:
;	graffer
;
;
; CALLING SEQUENCE:
;	implicit
;
;
; MODIFICATION HISTORY:
;	Extracted: 30/6/05; SJT
;	Remove (fully) colour_menu: 21/5/20; SJT
;	Add track item (for tracking events): 18/8/21; SJT
;-

  optblock = {graff_opts, $
              Auto_delay:  0., $
              S2d:         0b, $
              Mouse:       0b, $
              track:       0b, $
              pdfviewer:   '' $
             }

end
