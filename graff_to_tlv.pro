pro gr_tlv_event, event

  widget_control, event.top, get_uvalue = state
  widget_control, event.id, get_uvalue = mnu

  case mnu of
     "DONT": begin
        widget_destroy, event.top
        return
     end

     'DO': begin

        if state.type eq 9 then begin
           (scope_varfetch(state.names.z, level = 1, /enter)) = $
              *(state.xydata.z) 
           (scope_varfetch(state.names.x, level = 1, /enter)) = $
              *(state.xydata.x)
           (scope_varfetch(state.names.y, level = 1, /enter)) = $
              *(state.xydata.y) 

        endif else begin

           (scope_varfetch(state.names.x, level = 1, /enter)) = $
              reform(state.xydata[0, *])
           (scope_varfetch(state.names.y, level = 1, /enter)) = $
              reform(state.xydata[1, *])

           case state.type of
              1: (scope_varfetch(state.names.y_err, level = 1, /enter)) = $
                 reform(state.xydata[2, *])
              3: (scope_varfetch(state.names.x_err, level = 1, /enter)) = $
                 reform(state.xydata[2, *])
              2: begin
                 (scope_varfetch(state.names.y_err_b[0], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[2, *])
                 (scope_varfetch(state.names.y_err_b[1], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[3, *])
              end
              4: begin
                 (scope_varfetch(state.names.x_err_b[0], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[2, *])
                 (scope_varfetch(state.names.x_err_b[1], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[3, *])
              end
              5: begin
                 (scope_varfetch(state.names.x_err, level = 1, /enter)) = $
                    reform(state.xydata[2, *])
                 (scope_varfetch(state.names.y_err, level = 1, /enter)) = $
                    reform(state.xydata[3, *])
              end

              6: begin
                 (scope_varfetch(state.names.x_err, level = 1, /enter)) = $
                    reform(state.xydata[2, *])
                 (scope_varfetch(state.names.y_err_b[0], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[3, *])
                 (scope_varfetch(state.names.y_err_b[1], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[4, *])
              end

              7: begin
                 (scope_varfetch(state.names.x_err_b[0], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[2, *])
                 (scope_varfetch(state.names.x_err_b[1], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[3, *])
                 (scope_varfetch(state.names.y_err, level = 1, /enter)) = $
                    reform(state.xydata[4, *])
              end

              
              8: begin
                 (scope_varfetch(state.names.x_err_b[0], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[2, *])
                 (scope_varfetch(state.names.x_err_b[1], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[3, *])
                 (scope_varfetch(state.names.y_err_b[0], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[4, *])
                 (scope_varfetch(state.names.y_err_b[1], level = 1, $
                                 /enter)) = $
                    reform(state.xydata[5, *])
              end
              else:
           endcase
        endelse
        widget_control, event.top, /destroy
        return
     end

     'X': state.names.x = event.value
     'Y': state.names.y = event.value
     'Z': state.names.z = event.value
     'XERR': state.names.x_err = event.value
     'XERR-': state.names.x_err_b[0] = event.value
     'XERR+': state.names.x_err_b[1] = event.value
     'YERR': state.names.y_err = event.value
     'YERR-': state.names.y_err_b[0] = event.value
     'YERR+': state.names.y_err_b[1] = event.value

  endcase

  widget_control, event.top, set_uvalue = state
end
pro graff_to_tlv, pdefs

;+
; GRAFF_TO_TLV
;	Turn the data of the current dataset into variables at the
;	$MAIN$ level.
;
; Usage:
;	graff_to_tlv, pdefs
;
; Argument:
;	pdefs	struct	The main graffer data structure.
;
; History:
;	Original: 3/2/12; SJT
;	Make a gui to change names: 12/7/12; SJT
;-

  data = (*pdefs.data)[pdefs.cset]

  if not ptr_valid(data.xydata) then return
  if data.type lt 0 then return ; Not applicable to functions.


  base = widget_base(title = "Export dataset", $
                     /column, $
                     /modal, $
                     group = pdefs.ids.graffer)

  names = {gr_export_names, $
           x: "GR_X", $
           y: "GR_Y", $
           z: "GR_Z", $
           x_err: "GR_X_ERR", $
           x_err_b: ["GR_X_ERR_L", "GR_X_ERR_U"], $
           y_err: "GR_Y_ERR", $
           y_err_b: ["GR_Y_ERR_L", "GR_Y_ERR_U"]}
  
  if data.type eq 9 then begin
     junk = graff_enter(base, $
                        /text, $
                        value = names.z, $
                        xsize = 10, $
                        label = "Z:", $
                        uvalue = 'Z', $
                        /all, $
                        /capture)
     junk = graff_enter(base, $
                        /text, $
                        value = names.x, $
                        xsize = 10, $
                        label = "X:", $
                        uvalue = 'X', $
                        /all, $
                        /capture)
     junk = graff_enter(base, $
                        /text, $
                        value = names.y, $
                        xsize = 10, $
                        label = "Y:", $
                        uvalue = 'Y', $
                        /all, $
                        /capture)

  endif else begin 
     junk = graff_enter(base, $
                        /text, $
                        value = names.x, $
                        xsize = 10, $
                        label = "X:", $
                        uvalue = 'X', $
                        /all, $
                        /capture)
     junk = graff_enter(base, $
                        /text, $
                        value = names.y, $
                        xsize = 10, $
                        label = "Y:", $
                        uvalue = 'Y', $
                        /all, $
                        /capture)


     case data.type of
        1: junk = graff_enter(base, $
                              /text, $
                              value = names.y_err, $
                              xsize = 10, $
                              label = "Y err:", $
                              uvalue = 'YERR', $
                              /all, $
                              /capture)

        3: junk = graff_enter(base, $
                              /text, $
                              value = names.x_err, $
                              xsize = 10, $
                              label = "X err:", $
                              uvalue = 'XERR', $
                              /all, $
                              /capture)
        2: begin
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err_l[0], $
                              xsize = 10, $
                              label = "Y err-:", $
                              uvalue = 'YERR-', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err_l[1], $
                              xsize = 10, $
                              label = "Y err+:", $
                              uvalue = 'YERR+', $
                              /all, $
                              /capture)
        end
        4: begin
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err_l[0], $
                              xsize = 10, $
                              label = "X err-:", $
                              uvalue = 'XERR-', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err_l[1], $
                              xsize = 10, $
                              label = "X err+:", $
                              uvalue = 'XERR+', $
                              /all, $
                              /capture)
        end
        5: begin
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err, $
                              xsize = 10, $
                              label = "X err:", $
                              uvalue = 'XERR', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err, $
                              xsize = 10, $
                              label = "Y err:", $
                              uvalue = 'YERR', $
                              /all, $
                              /capture)
        end

        6: begin
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err, $
                              xsize = 10, $
                              label = "X err:", $
                              uvalue = 'XERR', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err_l[0], $
                              xsize = 10, $
                              label = "Y err-:", $
                              uvalue = 'YERR-', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err_l[1], $
                              xsize = 10, $
                              label = "Y err+:", $
                              uvalue = 'YERR+', $
                              /all, $
                              /capture)
        end

        7: begin
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err_l[0], $
                              xsize = 10, $
                              label = "X err-:", $
                              uvalue = 'XERR-', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err_l[1], $
                              xsize = 10, $
                              label = "X err+:", $
                              uvalue = 'XERR+', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err, $
                              xsize = 10, $
                              label = "Y err:", $
                              uvalue = 'YERR', $
                              /all, $
                              /capture)
        end

        
        8: begin
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err_l[0], $
                              xsize = 10, $
                              label = "X err-:", $
                              uvalue = 'XERR-', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.x_err_l[1], $
                              xsize = 10, $
                              label = "X err+:", $
                              uvalue = 'XERR+', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err_l[0], $
                              xsize = 10, $
                              label = "Y err-:", $
                              uvalue = 'YERR-', $
                              /all, $
                              /capture)
           junk = graff_enter(base, $
                              /text, $
                              value = names.y_err_l[1], $
                              xsize = 10, $
                              label = "Y err+:", $
                              uvalue = 'YERR+', $
                              /all, $
                              /capture)
        end
        else:
     endcase
  endelse

  jb = widget_base(base, $
                   /row)

  junk = widget_button(jb, $
                       value = 'Done', $
                       uvalue = 'DO')

  junk = widget_button(jb, $
                       value = 'Cancel', $
                       uvalue = 'DONT')

;  xydata = *data.xydata

  state = {xydata: *data.xydata, $
           type: data.type, $
           names: names}

  widget_control, base, /real, set_uvalue = state

  xmanager, "gr_tlv", base

end
