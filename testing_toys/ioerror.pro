pro ioerror, value, file = file, mem = mem, cvt = cvt, catch = catch, $
             wfile = wfile

  if keyword_set(file) then begin
     openw, 1, 'tmp.txt'
     printf, 1, value
     close, 1

     on_ioerror, bail1

     openr, 1, 'tmp.txt', /del
     i = 0l
     readf, 1, i
     
     print, 'File read OK'

     close, 1
     return

bail1:
     on_ioerror, null
     close, 1
     print, "File read failed"
     
  endif else if keyword_set(mem) then begin
     s = string(value)
     
     on_ioerror, bail2
     i = 0l
     reads, s, i

     print, 'Memory read OK'
     return

bail2:
     print, 'Memory read failed'

  endif else if keyword_set(cvt) then begin
     s = string(value)

     on_ioerror, bail3

     i = long(s)

     print, "Convert OK"
     return

bail3:
     print, 'Convert failed'

  endif else if keyword_set(wfile) then begin
     on_ioerror, bail4

     openr, 1, 'tmp1.txt', /del
     i = 0l
     readf, 1, i
     
     print, 'File read OK'

     close, 1
     return

bail4:
     on_ioerror, null
     print, "File read failed"
     
  endif else if keyword_set(catch) then begin

     catch, an_error
     if an_error ne 0 then begin
        catch, /cancel
        print, "Read failed"
        return
     endif

     s = string(value)
     i = 0l
     reads, s, i

     print, 'Memory read OK'
     return

  endif else print, "Need to specify an operation"

end
