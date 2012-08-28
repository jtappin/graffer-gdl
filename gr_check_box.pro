function Gr_check_box, nx, ny

;+
; GR_CHECK_BOX
;	Read the bitmap for the checkbox image.
;
; Usage:
;	bitmap=gr_check_box(nx,ny)
;
; Return Value:
;	bitmap	byte	The bitmap
;
; Arguments:
;	nx, ny	int	output	The size of the bitmap
;
; History:
;	Original: 29/1/97; SJT
;	Just return the bitmap: 20/2/97; SJT
;	Tidy: 12/1/12; SJT
;-

help, calls = cstack
ltpos = strpos(cstack(0), '<')+1
rtpos = strpos(cstack(0), 'gr_check_box.pro')
len = rtpos - ltpos
case !version.os_family of
    'unix': bmpath = strmid(cstack(0), ltpos, len) + 'bitmaps/'
    else: bmpath = strmid(cstack(0), ltpos, len) + 'bitmaps\' 
endcase

read_x11_bitmap, bmpath+'3floppy_unmount.xbm', cross, nx, ny

return, cross
end


