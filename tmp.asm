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
    currX dw 210d
    currY dw 45d 

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
            
            mov [clock], 0

            ; If a key was pressed, we can use its value    
            call move_charecter
            ;jmp move
            
            not_pressed:

                cmp [clock], 0fffh
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

        ;jump  
        cmp al, 'w'
        je jump
                    
        ;move left
        cmp al, 'a'
        je move_left
        
        ;move right
        cmp al, 'd'
        je move_right
        
        ;jump (spacebar) -> shoot 
        cmp al, 32          
        
        ;if none of the keys above were pressed  
        jmp delete_previos 
        
        jump:
            call initiate_jump
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
                lea bx, [currmodel]
                                    
                call draw_model
                
                jmp moved
        
        ;ajusting the x, y values
        ;according to the key pressed                  
            
        moved:
            
            ret

    endp move_charecter 

    proc initiate_jump

        cmp [jumpstep], 0
        jne already_jumping

        ; initial jump delta
        mov [jumpstep], 06h

        already_jumping:
            ret

    endp initiate_jump

    proc update_jump_state
        
        cmp [jumpstep], 0
        je finished_jump

        mid_jump:

            cmp [jumpstep], 03h
            jbe in_way_down

            ; each time dec by 2 (going up)
            sub [curry], 0Ah
            
            jmp dec_state

            in_way_down:

                ; each time inc by 2 (going down)
                mov ax, [jumpstep]
                add [curry], 0Ah
                
            dec_state:
                dec [jumpstep]

        finished_jump:
            ret

    endp update_jump_state

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
    
    include "drawing_funcs.asm"

    end main