;+
; GR_READ_X11_BM
;	Temporary replacement for read_x11_bitmap
;-

pro gr_read_x11_bm, file, bm

  read_img, file, bym

  bm = cvttobm(reform(not bym[0, *, *]))

end
