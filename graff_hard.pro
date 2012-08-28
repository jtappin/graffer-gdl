function Graff_hard, pdefs, no_set=no_set

;+
; GRAFF_HARD
;	Make a hardcopy
;
; Usage:
;	ichange = graff_hard(pdefs)
;
; Return value
;	ichange	int	1 if changed, 0 if not
;
; Argument:
;	pdefs	struct	in/out	The plot definition structure.
;
; Keyword:
;	no_set		input	If set and non-zero, then don't call
;				gr_hardopts to set up the options.
;				
; History:
;	Carved from graffer: 17/8/95; SJT
;	Added no_set key: 8/9/95; SJT
;	Made to function returning "cancel" state: 18/12/96; SJT
;	Change STRPOS to RSTRPOS in filename generation: 23/3/98; SJT
;	Replace handles with pointers: 28/6/05; SJT
;	Add dialogue for cases where only current dataset is being
;	shown: 26/1/12; SJT
;	Handle case when current-only is selected: 26/1/12; SJT
;-

; For hard copy we don't notmally want to show current DS only.
tt = pdefs.transient.current_only
if pdefs.transient.current_only then begin
    yn = dialog_message(["Display current dataset only is", $
                         "currently selected.", $
                         "Do you really want to print just", $
                         "the current dataset"], $
                        /question, $
                        /cancel, $
                        dialog_parent = pdefs.ids.graffer)

    case yn of
        "No": pdefs.transient.current_only = 0b
        "Cancel": return, 0
        "Yes":
    endcase
endif

if pdefs.hardset.name eq '' then begin
    file = pdefs.name
    if (((dp = strpos(file, '.', /reverse_search))) ne -1) then  $
      file = strmid(file, 0, dp) 
    if pdefs.hardset.eps then file = file+'.eps' $
    else file = file+'.ps'
    pdefs.hardset.name = pdefs.dir+file
endif

if (not keyword_set(no_set)) then begin
    ido = gr_hardopts(pdefs)
    if (ido eq -1) then return, 0
endif

h = pdefs.hardset

cpl = float(!D.x_size)/float(!D.x_ch_size)

dev = !D.name
set_plot, 'ps'


!P.font = 0

locs = where(((*pdefs.data).type eq -4 or (*pdefs.data).type eq 9) and $
             ((*pdefs.data).zopts.format eq 1 or $
              ((*pdefs.data).zopts.format eq 0 and $
               (*pdefs.data).zopts.fill eq 1)), nim) 

if (nim ne 0) then bits = 8 $
else bits = 8*h.colour > 1

device, file = h.name,  encapsu = h.eps, bits = bits, color = $
  h.colour
if (h.colour) then begin
    graff_colours, pdefs
    device, cmyk = h.cmyk
endif

psize = gr_get_page(h.psize, h.orient)

if (h.eps) then device, /portrait $
else if (h.orient) then device, /portrait, xoffset = h.off(0), $
  yoffset = h.off(1) $
     else  device, /landscape, xoffset = h.off(1), yoffset = $
                   psize(0)-h.off(0)

device, xsize = h.size(0), ysize = h.size(1)

bold = h.font.wg_sl and 1
ital = (h.font.wg_sl and 2)/2

case h.font.family of
    0: device, /courier, bold = bold, oblique = ital
    1: device, /helvetica, bold = bold, oblique = ital
    2: device, /helvetica, /narrow, bold = bold, oblique = ital
    3: device, /schoolbook, bold = bold, italic = ital
    4: device, /palatino, bold = bold, italic = ital
    5: device, /times, bold = bold, italic = ital
    6: device, /avantgarde, /book, oblique = ital
    7: device, /avantgarde, /demi, oblique = ital
    8: device, /bkman, /demi, italic = ital
    9: device, /bkman, /light, italic = ital
    10: device, /zapfchancery, /medium, /italic
    11: device, /zapfdingbats
    12: device, /symbol
endcase

ncpl = float(!D.x_size)/float(!D.x_ch_size)
csiz = ncpl/cpl

gr_plot_object, pdefs, /no_null, charsize = csiz, /plot_all, grey_ps = $
  h.colour eq 0

if (h.timestamp) then begin
    st = string(getenv('USER'), systime(), pdefs.version, $
                format = "(A,' @ ',A,' from V',I0,'.',I2.2)")
    xyouts, /norm, .98, .01, st, charsize = 0.67, align = 1.0
endif

device, /close

set_plot, dev
if h.eps then begin
   if h.viewer[0] ne '' then $
      spawn, h.viewer[0]+' '+h.name+' '+h.viewer[1]
   graff_msg, pdefs.ids.message, 'Output file is: '+h.name
endif else begin
   spawn, h.action[0]+' '+h.name+' '+h.action[1], cmdout
   graff_msg, pdefs.ids.message, cmdout
endelse

!P.font = -1

graff_colours, pdefs
pdefs.transient.current_only = tt

return, keyword_set(no_set) eq 0

end
