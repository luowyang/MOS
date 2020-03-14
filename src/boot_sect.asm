;;; this serves as a demo boot section

loop:
    jmp loop            ; jump to the label loop

times 510-($-$$) db 0   ; padding 510 bytes 0

dw 0xaa55               ; the magic number