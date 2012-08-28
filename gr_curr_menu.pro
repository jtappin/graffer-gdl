;+
; NAME:
;	gr_curr_menu
;
;
; PURPOSE:
;	Menus for the options of the current dataset.
;
;
; CATEGORY:
;	graffer
;
;
; CALLING SEQUENCE:
;	gr_curr_menu,base,pdefs
;
;
; INPUTS:
;	base	long	The parent widget_base for the menus
;	pdefs	struct	The graffer master data structure
;
;
; MODIFICATION HISTORY:
;	Extracted from graff_one: 4/7/05; SJT
;-

pro gr_curr_menu, base, pdefs

jb = widget_base(base, $
                 /column, $
                 xpad = 0, $
                 ypad = 0, $
                 space = 0)

optbb = widget_base(jb, $
                    /frame, $
                    xpad = 0, $
                    ypad = 0, $
                    space = 0)

                                ; Plotting symbols etc.

gr_ds_menus, optbb, pdefs
gr_z_menus, optbb, pdefs

                                ; Plot a function or read data

gr_ds_create, jb, pdefs

end
