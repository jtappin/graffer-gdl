pro graff_style__define
;+
; NAME:
;	graff_style__define
;
;
; PURPOSE:
;	Define the graffer axis style structure
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
;	Advanced axis style settings: 21/8/12; SJT
;	Remove Xmajor field: unused: 25/3/20; SJT
;	Add log_band values: 24/6/21; SJT
;-

Xsty = {graff_style, $
        Idl:     0, $
        Extra:   0, $
        Grid:    0, $
        Time:    0, $
        Tzero:   0l, $
        minor:   0, $
        major:   0, $
        format:  '', $
        log_bands: lonarr(3), $
        values:  ptr_new()}

end
