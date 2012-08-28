pro Gr_symdef, index

;+
; GR_SYMDEF
;	User USERSYM to define the GRAFFER symbols that aren't part of
;	the standard IDL set.
;
; Usage:
;	gr_symdef, index
;
; Argument:
;	index	int	input	The symbol index (8->n)
;					8 - circle
;					9 - filled diamond
;					10 - filled triangle
;					11 - filled square
;					12 - filled circle
;					13 - inverted triangle
;					14 - filled inverted triangle
;					any other value "?"
;
; History:
;	Original: Jan 97; SJT
;-

case index of
    8: begin
        th = findgen(31)*12*!Dtor
        x = cos(th)
        y = sin(th)
        ifill = 0
    end
    9: begin
        x = [0., 1., 0., -1.]
        y = [-1., 0., 1., 0.]
        ifill = 1
    end
    10: begin
        x = [-1., 1., 0., -1]
        y = [-1., -1., 1., -1]
        ifill = 1
    end
    11: begin
        x = [-1., 1., 1., -1.]
        y = [-1., -1., 1., 1.]
        ifill = 1
    end
    12: begin
        th = findgen(30)*12*!Dtor
        x = cos(th)
        y = sin(th)
        ifill = 1
    end
    13: begin
        x = [-1., 1., 0., -1]
        y = [1., 1., -1., 1]
        ifill = 0
    end
    14: begin
        x = [-1., 1., 0., -1]
        y = [1., 1., -1., 1]
        ifill = 1
    end
    Else: begin
        x = [0., 0., .8, .8, .6, -.6, -.8]
        y = [-1., -.2, .2, .7, .9, .9, .7]
        ifill = 0
    end
endcase

usersym, fill = ifill, x, y

end
