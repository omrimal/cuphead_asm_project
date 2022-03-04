;al - charecter pressed
        
proc move_charecter

    ;look up
    ;cmp al, 'w'
    ;je jump
                
    ;move left
    cmp al, 'a'
    je move_left
    
    ;move right
    cmp al, 'd'
    je move_right
    
    ;jump (spacebar)
    cmp al, ' '
    je jump          
    
    ;if neither of the keys above were pressed 
    cmp [deltax], 0 
    jne check_deltas

    cmp [deltaY], 0 
    jne check_deltas
    
    jmp moved
    
    jump:
        call initiate_jump
        jmp draw_at_new_location
    
    move_left:
        ;dec [currX]
        mov [deltax], -1
        jmp draw_at_new_location
        
    move_right:
        ;inc [currX]
        mov [deltaX], 1
            
    draw_at_new_location:
    
        cmp [currY], 0 
        jl  Y_too_small
        
        cmp [currX], 0
        jl  X_too_small
        
        cmp [currX], WINDOW_LENGTH - 20
        jg  X_too_big
        
        jmp delete_previos
                    
        ;correcting coordinates in they're out of bounds             
        coordinate_out_of_bound:
            Y_too_small:
                inc [currY]
                jmp moved
                
            X_too_small:
                inc [currX]
                jmp moved
                
            X_too_big:
                dec [currX]
                jmp moved
        
        check_deltas:

            cmp [deltax], 0
            jne delete_previos
            
            cmp [deltay], 0
            je moved

        ;to remve the last model drawing                          
        delete_previos:

            push 22
            push 30

            push [currY]
            push [currX]

            mov bh, 00h                              
            call draw_rectangle
        
        ;when the coordinates are ok, we draw the model                               
        coordinates_are_ok:
            
            mov ax, [deltax]
            add [currx], ax
            
            mov ax, [deltaY]
            add [currY], ax

            mov ax, [currX]       
            mov dx, [currY]
            mov bx, [currmodel]
                                
            call draw_model

    moved:
        ;reseting the deltas
        mov [deltax], 0
        mov [deltay], 0

        ret

endp move_charecter 

proc initiate_jump

    cmp [jumpstep], 0
    jne already_jumping

    ; initial jump delta
    mov [deltaY], -0Dh
    mov [jumpstep], 05h

    already_jumping:
        ret

endp initiate_jump

proc update_jump_state
    
    cmp [jumpstep], 0
    je finished_jump
    
    ;to make the look of a jump
    cmp [jumpclock], 0FFh
    jne finished_jump
    
    ;reseting the clock
    mov [jumpclock], 00h

    mid_jump:

        ;jump hight
        mov [deltaY], -0Dh
        mov ax, [deltay]

        cmp [jumpstep], 03h
        jbe in_way_down

        jmp dec_state

        in_way_down:

            ; each time inc by 10 px (going down)
            mov [deltaY], 0Dh
            
        dec_state:
            dec [jumpstep]

    finished_jump:
        ;incrementing the clock
        inc [jumpclock]
        ret

endp update_jump_state

proc update_model

    push 22
    push 30

    push [currY]
    push [currX]

    mov bh, 00h                        
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
