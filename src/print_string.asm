[bits 16]

; this routine us dx as parameter register and will print a string
print_string:
loop:
    mov ah, 0x0e
    mov al, [bx]        ; no need to save ax as this is a temporary register
    cmp al, 0           ; NEVER FORGET NULL-ENDING
    je return
    int 0x10
    add bx, 1
    jmp loop
return:
    ret

print_nl:
    mov ah, 0x0e
    mov al, 0x0a        ; newline
    int 0x10
    mov ah, 0x0e
    mov al, 0x0d        ; carrage return
    int 0x10
    ret