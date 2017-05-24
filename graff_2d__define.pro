pro graff_2d__define
;+
; NAME:
;	graff_2d__define
;
;
; PURPOSE:
;	Create a 2-d dataset settings structure for graffer
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
;	Support colour inversion: 26/6/07; SJT
;	Add local colour table option: 17/11/11; SJT
;	Make colours a list: 7/10/16; SJT
;	Add non-linear contour level maps: 12/10/16; SJT
;	Add labelling offset: 2/5/17; SJT
;-

Zopts = {graff_2d, $
         Format:      0, $
         set_levels:  0b, $
         N_levels:    0, $
         lmap:        0, $ 
         Levels:      ptr_new(), $
         N_cols:      0, $ 
         Colours:     list(), $
         N_sty:       0, $
         Style:       ptr_new(), $
         N_thick:     0, $
         Thick:       ptr_new(), $
         Range:       dblarr(2), $
         missing:     0.d0, $
         Pxsize:      0.d0, $
         charsize:    0.d0, $
         Label:       0, $
         Label_off:   0, $
         Ctable:      0, $
         Gamma:       0.d0, $
         Fill:        0b, $
         ilog:        0b, $
         invert:      0b $
        }

end
