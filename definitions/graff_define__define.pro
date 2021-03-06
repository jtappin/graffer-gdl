; LICENCE:
; Copyright (C) 1995-2021: SJT
; This program is free software; you can redistribute it and/or modify  
; it under the terms of the GNU General Public License as published by  
; the Free Software Foundation; either version 2 of the License, or     
; (at your option) any later version.                                   

pro graff_define__define
;+
; NAME:
;	graff_define__define
;
;
; PURPOSE:
;	Define the main graffer structure
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
;	Add isotropic option: 25/6/08; SJT
;	Add support for a second Y-scale: 22/12/11; SJT
;	Make coordinates double: 24/5/17; SJT
;	Add fontopt field to allow TT fonts to be used: 11/2/20; SJT
;	Remove opts field (it doesn't belong in PDEFS): 21/5/20; SJT
;-

  pdefs = {graff_define, $
           Version:   intarr(2), $
           Name:      '', $
           Dir:       '', $
           Title:     '', $
           Subtitle:  '', $
           Charsize:  0.d0, $
           Axthick:   0.d0, $
           fontopt:   0, $
           Position:  dblarr(4), $
           Aspect:    dblarr(2), $
           Isotropic: 0b, $
           match:     0b, $
           Xrange:    dblarr(2), $
           Xtitle:    '', $
           Xtype:     0, $
           Xsty:      {graff_style}, $
           Yrange:    dblarr(2), $
           Ytitle:    '', $
           Ytype:     0, $
           Ysty:      {graff_style}, $
           y_right:   0b, $
           Yrange_r:  dblarr(2), $
           Ytitle_r:  '', $
           Ytype_r:   0, $
           Ysty_r:    {graff_style}, $
           ytransform: replicate({!axis}, 2), $
           Ctable:    0, $
           Gamma:     0.d0, $
           Nsets:     0, $
           Cset:      0, $ $
           Data:      ptr_new(), $
           Ntext:     0, $
           Text:      ptr_new(), $
           Text_options: {graff_text}, $
           Key: {graff_key}, $
           Remarks:   ptr_new(), $
           Ids: { graff_ids}, $
           Hardset: { graff_hard}, $
           Transient: { graff_trans}, $
           Ds_dir:       '', $
           Chflag:       0b, $
           is_ascii:     0b $
          }

end
