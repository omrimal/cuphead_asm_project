IDEAL

MODEL SMALL 

STACK 1000h

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

    include "data.asm"

CODESEG

    call main

    proc main

        mov ax, @data
        mov ds, ax

        ; video mode
        call setup_video_mode

        ; initializing background
        call init_background

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
        
        ; graphical mode 320x200 pixels
        mov ah, 00h                     
        mov al, 13h                     
        
        int 10h 
        
        ret

    endp setup_video_mode
    
    proc init_background
        
        ; sky rectangle - light cyan  
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
        
        ; ground rectangle - light green
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

        ; underground rectangle - brown
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

        ret 

    endp init_background

    include "plyr.asm"
    include "draw.asm"

    end main