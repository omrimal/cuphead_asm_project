;------------------------------------------
; File   :  Base.asm
; Author :  ******* ******
; Date   :  23/11/2005
; Class  :  jud-8
;------------------------------------------

comment/*
. . . .


*/

MODEL small

STACK 100h

DATASEG

array db 0EFFFh dup (?)

CODESEG

start:
        mov ax,@data
        mov ds,ax

        mov ax,10 


exit:

        mov ax,4C00h
        int 21h
END start
