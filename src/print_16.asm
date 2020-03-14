[bits 16]

; this routine let us print two byte
print_16:
    mov ah, 0x0e
    mov al, dh
    shr al, 4
    cmp al, 9
    jg  _branch1
    add al, 0x30
    jmp _print_char1
_branch1:
    add al, 0x37
_print_char1:
    int 0x10        ; print 1st hex
    mov al, dh
    and al, 0xf
    cmp al, 9
    jg  _branch2
    add al, 0x30
    jmp _print_char2
_branch2:
    add al, 0x37
_print_char2:
    int 0x10        ; print 2nd hex
    mov al, dl
    shr al, 4
    cmp al, 9
    jg  _branch3
    add al, 0x30
    jmp _print_char3
_branch3:
    add al, 0x37
_print_char3:
    int 0x10        ; print 3rd hex
    mov al, dl
    and al, 0xf
    cmp al, 9
    jg  _branch4
    add al, 0x30
    jmp _print_char4
_branch4:
    add al, 0x37
_print_char4:
    int 0x10        ; print 4th hex
    ret