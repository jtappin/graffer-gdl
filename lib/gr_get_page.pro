function Gr_get_page, ps, ori

if (ps eq 0) then sz = [21., 29.7] $
else sz = [21.59, 27.94]
if (ori eq 0) then sz = sz([1, 0])

return, sz
end
