pro Gr_pol_rect, r, th, x, y

;+
; GR_POL_RECT
;	Convert polar to rectangular coordinates.
;
; Usage:
;	gr_pol_rect, r, th, x, y
;
; Arguments:
;	r	float	input	The radial coordinate
;	th	float	input	The angular coordinate (radians)
;	x	float	output	The resulting X coordinate
;	y	float	output	The resulting Y coordinate.
;
; History:
;	Original: 16/12/96; SJT
;-

x = r * cos(th)
y = r * sin(th)

end
