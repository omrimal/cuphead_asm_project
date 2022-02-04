IDEAL

MODEL SMALL 

STACK 1000h

    X_OFF         EQU  12
    Y_OFF         EQU  14 

    ROW_OFF       EQU   2
    COL_OFF       EQU   4

    HIGHT_OFF     EQU  16
    LENGTH_OFF    EQU  18
            
    WINDOW_HIGHT  EQU 200 
    WINDOW_LENGTH EQU 320

DATASEG
    
    clock dw 0d
    currX dw 160d
    currY dw 50d 

    currModel dw ?

    jumpStep db 00h  
    
    struc gameObject

        modelPtr dw ?
        
        topLeftX dw ?
        topLeftY dw ?

    ends gameObject
    
    include "data.asm"

CODESEG

    call main

    proc main

        mov ax, @data
        mov ds, ax

        call setup_video_mode
        
        mov bl, 0bh
        
        mov ax, 320
        push ax

        mov ax, 96h
        push ax

        mov ax, 0h
        push ax
        push ax

        call draw_rectangle
        
        mov bl, 0ah
        
        mov ax, 320
        push ax

        mov ax, 5h
        push ax

        mov ax, 96h
        push ax

        mov ax, 0h
        push ax

        call draw_rectangle

        mov bl, 06h
        
        mov ax, 320
        push ax

        mov ax, 2dh
        push ax

        mov ax, 9bh
        push ax

        mov ax, 0h
        push ax

        call draw_rectangle

        mov ax, [currX]       
        mov dx, [currY]
        lea bx, [flowerBossOne]

        mov [currmodel], bx
        
        call draw_model
                
        move:
            inc [clock]

            mov ah,06h
            mov dl,0FFh
            int 21h 
            
            ; Check if a key was pressed
            jz not_pressed 
            
            mov [clock], 0

            ; If a key was pressed, we can use its value       
            call move_charecter
            jmp move
            
            not_pressed:

                cmp [clock], 0fffh
                jne move

                mov [clock], 0
                ;call update_model
                                
        jmp move
                        
        ;returning control to the os  
        mov al, 00h          
        mov ah, 4Ch
        int 21h

    endp main    

    proc setup_video_mode
        
        mov ah, 00h                     ;setting video mode
        mov al, 13h                     ;to graphical mode 320x200 pixels
        
        int 10h                         ;executing
        
        ret

    endp setup_video_mode

            
    ;al - charecter pressed
            
    proc move_charecter
    
        ;mov ah, 2
        ;mov dl, al
        ;int 21h

        ;mov dl, 10
        ;int 21h

        ;move up  
        cmp al, 'w'
        je move_up
                    
        ;move left
        cmp al, 'a'
        je move_left
        
        ;move down
        cmp al, 's'
        je move_down
        
        ;move right
        cmp al, 'd'
        je move_right
        
        ;jump (spacebar)
        cmp al, 32          
        
        ;call update_jump_state:
        
        ;if none of the keys above were pressed  
        jmp moved 
        
        move_up:
            dec [currY]
            jmp draw_at_new_location
    
        move_down:
            inc [currY]
            jmp draw_at_new_location
        
        move_left:
            dec [currX]
            jmp draw_at_new_location
            
        move_right:
            inc [currX]
                
        draw_at_new_location:
        
            cmp [currY], 0 
            jl  Y_too_small
            
            cmp [currX], 0
            jl  X_too_small
            
            cmp [currY], WINDOW_HIGHT - 26
            jg  Y_too_big
            
            cmp [currX], WINDOW_LENGTH - 20
            jg  X_too_big
            
            jmp delete_previos
                        
            ;correcting coordinates in they're are out of bounds             
            coordinate_out_of_bound:
                Y_too_small:
                    inc [currY]
                    jmp moved
                    
                X_too_small:
                    inc [currX]
                    jmp moved
                    
                Y_too_big:
                    dec [currY]
                    jmp moved
                    
                X_too_big:
                    dec [currX]
                    jmp moved
            
            ;to remve the last model drawing                          
            delete_previos:

                push 22
                push 30

                dec [currY]
                dec [currX]
                
                push [currY]
                push [currX]
                
                inc [currY]
                inc [currX]

                mov bl, 00h                
                call draw_rectangle
            
            ;when the coordinates are ok, we draw the model                               
            coordinates_are_ok:
                    
                mov ax, [currX]       
                mov dx, [currY]
                lea bx, [cupheadModelStand]
                                    
                call draw_model
                
                jmp moved
        
        ;ajusting the x, y values
        ;according to the key pressed                  
        
            
        jump:
        
            
        moved:
            
            ret

    endp move_charecter 

    ;proc update_jump_state:
        
        
    ;    ret
    ;endp update_jump_state:  

    proc update_model

        push 22
        push 30

        push [currY]
        push [currX]

        mov bl, 00h                
        call draw_rectangle

        mov bx, [currmodel]
        lea ax, [cupheadModelStand]
    
        cmp ax, bx
        jne draw_standing
        
        draw_on_toes:
        
            lea bx, [cupheadModelHillsUp]
            mov [currmodel], bx
            sub [curry], 02h
            jmp draw
        
        draw_standing:

            mov bx, ax
            add [curry], 02h
            mov [currmodel], bx

        draw:

            mov ax, [currX]       
            mov dx, [currY]
            call draw_model
            
        ret

    endp update_model
    
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

    end main