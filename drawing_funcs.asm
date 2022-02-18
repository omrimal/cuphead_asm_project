;ax - x value
;dx - y value
;bx - pointer to the array

proc draw_model
    
    push bp
    mov bp, sp                      ;creating stack frame
    
    sub sp, 2                       ;for two veriables of 2 bytes each
    mov [bp - 2], ax                ;saving the x value for the loop    

        
    run_on_model_rows:
        
        mov ax, [bp - 2]            ;resetting the x (coloum) value
        
        color_model_colum:
            
            cmp [byte ptr bx], 11h

            je advance_a_pixel        
            
            push ax                 ;saving the x value in the stack
            
            mov cx, ax              ;setting the x value
            mov ah, 0Ch             ;change pixel color service
            mov al, [bx]            ;setting the color
            
            int 10h                 
                
            pop ax                  ;restoring ax
            
            advance_a_pixel:
                inc ax              ;incrementing ax
                inc bx              ;incrementing bx
            
                ;checking if we got to the end of the row
                cmp [byte ptr bx], 10h
            
            jne color_model_colum                 
        
        inc dx                      ;moving to the next row
        inc bx                      ;moving to the next element in the array
        
        ;checking if we got to the end of the array
        cmp [byte ptr bx], '$'

        jne run_on_model_rows
                            
    mov sp, bp
    pop bp
    
    ret
    
endp draw_model


;bl - color
;push length
;push hight
;push y
;push x
        
proc draw_rectangle
        
    ;to not destroy the registers's values    
    push ax                         
    push bx
    push cx
    push dx
    push bp
    
    mov bp, sp                      ;pointing to the start of the stack frame
    sub sp, 04h                
    
    mov cl, [BP + HIGHT_OFF]

    cmp cl, 0
    je func_end                     ;if the given hight is 0            

    mov cl, [BP + LENGTH_OFF] 

    cmp cl, 0
    je func_end                     ;if the given length is 0
                
    
    mov ah, 0Ch                     ;for pixel color change       
    mov al, bl                      ;using the color black   
    
    mov bx, [bp + Y_OFF]            ;getting the Y position  
    mov [bp - ROW_OFF], bx          ;updating the starting row
    
    mov bx, [bp + X_OFF]            ;getting the X position
    
    run_on_rows:
        
        mov [bp - COL_OFF], bx      ;resetting the x value
        mov dx, [bp - ROW_OFF]      ;updating the starting row
                    
        color_colum: 
                    
            mov cx, [bp - COL_OFF]
            
            int 10h
            
            ;'advancing' to the next colum    
            inc [word ptr bp - COL_OFF]                                       
                                                        
            ;checking if we got to the end of the cloums                        
            mov cx, [bp + LENGTH_OFF]
            add cx, [bp + X_OFF] 
            sub cx, [bp - COL_OFF] 
            inc cx
            
        loop color_colum              
        
        ;'advancing' to the next row 
        inc [byte ptr bp - ROW_OFF]
        
        ;checking if we got the the end of the rows              
        mov cx, [bp + HIGHT_OFF]
        add cx, [bp + Y_OFF] 
        sub cx, [bp - ROW_OFF] 
        inc cx
        
    
    loop run_on_rows 
    
    func_end:
    
        mov sp,bp                   ;restoring sp
        pop bp                      ;restoring bp
        
        ;restoring the registres we changed in the function
        pop dx
        pop cx
        pop bx
        pop ax              
            
        ret 8
        
endp draw_rectangle
