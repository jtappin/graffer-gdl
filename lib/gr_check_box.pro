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
fd = [[ 0b, 0b, 0b], $
      [ 252b, 255b, 31b], $
      [ 14b, 192b, 31b], $
      [ 239b, 223b, 31b], $
      [ 239b, 223b, 31b], $
      [ 239b, 223b, 31b], $
      [ 239b, 223b, 31b], $
      [ 31b, 192b, 31b], $
      [ 255b, 255b, 31b], $
      [ 255b, 255b, 31b], $
      [ 255b, 255b, 31b], $
      [ 7b, 0b, 30b], $
      [ 7b, 0b, 28b], $
      [ 7b, 0b, 28b], $
      [ 231b, 255b, 28b], $
      [ 7b, 0b, 28b], $
      [ 7b, 0b, 28b], $
      [ 231b, 255b, 28b], $
      [ 7b, 0b, 28b], $
      [ 7b, 0b, 28b], $
      [ 255b, 255b, 31b], $
      [ 254b, 255b, 15b]]


  return, fd
  ;; help, calls = cstack
  ;; ltpos = strpos(cstack(0), '<')+1
  ;; rtpos = strpos(cstack(0), 'gr_check_box.pro')
  ;; len = rtpos - ltpos
  ;; case !version.os_family of
  ;;    'unix': bmpath = strmid(cstack(0), ltpos, len) + 'bitmaps/'
  ;;    else: bmpath = strmid(cstack(0), ltpos, len) + 'bitmaps\' 
  ;; endcase

  ;; print, bmpath
  ;; read_x11_bitmap, bmpath+'3floppy_unmount.xbm', cross, nx, ny

  ;; help, cross

  ;; return, cross
end


