pro Gr_cf_pieces, x, a, y

;+
; GR_CF_PIECES
;	A Procedure interface to GR_PIECES to keep CURVEFIT happy!
;
; As we don't know which will get called first they have to be in
; separate files!
;-

y = gr_pieces(x, a)
end
