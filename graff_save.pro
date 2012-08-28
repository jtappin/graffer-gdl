pro graff_save, pdefs
;+
; NAME:
;	GRAFF_SAVE
;
;
; PURPOSE:
;	Save a graffer file in its current format.
;
;
; CATEGORY:
;	graffer
;
;
; CALLING SEQUENCE:
;	graff_save,pdefs
;
;
; INPUTS:
;	pdefs	struct	The graffer plot object structure.
;
;
; MODIFICATION HISTORY:
;	Original: 1/7/05; SJT
;-

case pdefs.is_ascii of
    0b: gr_bin_save, pdefs
    1b: gr_asc_save, pdefs
endcase

end
