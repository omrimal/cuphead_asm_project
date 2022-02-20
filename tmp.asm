IDEAL

MODEL SMALL 

STACK 100h

    X_OFF         EQU   4
    Y_OFF         EQU   6

    ROW_OFF       EQU   4
    COL_OFF       EQU   6
    MODE_OFF      EQU   2

    HIGHT_OFF     EQU   8
    LENGTH_OFF    EQU  10
            
    WINDOW_HIGHT  EQU 200 
    WINDOW_LENGTH EQU 320

DATASEG
    
    clock dw 0h

    deltaX dw 0h
    deltaY dw 0h

    currX dw 210d
    currY dw 45d 

    jumpClock db 0FFh
    currModel dw ?

    jumpStep dw 00h  
    
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
        mov bh, 01h
        
        mov ax, 320
        push ax

        mov ax, 96h
        push ax

        mov ax, 0h
        push ax
        push ax

        call draw_rectangle
        
        mov bl, 0ah
        mov bh, 01h

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
        mov bh, 01h

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
        
        call draw_model

        mov [currx], 120
        mov [curry], 126

        mov ax, [currX]       
        mov dx, [currY]
        lea bx, [cupheadModelStand]

        mov [currmodel], bx
        
        call draw_model
                
        move:
            inc [clock]
            call update_jump_state   

            mov ah,06h
            mov dl,0FFh
            int 21h 
            
            ; Check if a key was pressed
            ;jz not_pressed 
            
            ;mov [clock], 0

            ; If a key was pressed, we can use its value    
            call move_charecter
            ;jmp move
            
            not_pressed:

                cmp [clock], 0FFFh
                jne move

                mov [clock], 0
                call update_model

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
                        
            ;correcting coordinates in they're are out of bounds             
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
    
    include "draw.asm"

    end main