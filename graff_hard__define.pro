pro graff_hard__define
;+
; NAME:
;	graff_hard__define
;
;
; PURPOSE:
;	Define the graffer hardcopy style structure
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
;	Add PDF viewer: 21/9/16; SJT
;	Add Fortran-only device names: 31/3/20; SJT
;-

Hardset = { graff_hard, $
            Colour: 0b, $
            Eps:    0b, $
            Orient: 0b, $
            Psize:  0b, $
            Timestamp: 0b, $
            cmyk: 0b, $
            Font:   {graff_hfont,  $
                     Family: 0, $
                     Wg_sl:  0}, $
            Size:   dblarr(2), $
            Off:    dblarr(2), $
            Action: strarr(2), $
            viewer: strarr(2), $
            pdfviewer: strarr(2), $
            name: '', $ $
            psdev: '', $        ; These are ignored in the IDL version 
            epsdev: '', $       ; but preserved for the Fortran version.
            pdfdev: '', $
            svgdev: '' $
          }

end
