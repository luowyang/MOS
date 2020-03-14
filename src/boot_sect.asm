;;; this serves as a demo boot section

[org 0x7c00]                ; BIOS will always put boot section from 0x7c00

;%include "print_string.asm"

[bits 16]

; below is a test of stack
    mov ah, 0x0e            ; set tele-type mode
    mov bp, 0x9000          ; set stack base pointer
    mov sp, bp              ; by now, stack top is the same as bottom

    mov bx, MSG_REAL_MODE
    call print_string
    call print_nl

; switch to 32-bit protected mode
switch_to_pm:
    cli                     ; clear interrupt because we don't have a valid IVT now
    lgdt [gdt_descriptor]   ; load global descriptor table
    mov eax, cr0            ; get the value of control register
    or  eax, 0x1            ; set last bit to 1, use OR so we don't mess up other bits
    mov cr0, eax            ; update control register
    jmp CODE_SEG:init_pm    ; use a far jump to a 32-bit segment to force CPU to flush pipeline

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

[bits 32]

init_pm:
    mov ax, DATA_SEG        ; we shall update all segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; set new stack base
    mov esp, ebp

BEGIN_PM:
    ;mov ebx, MSG_PROT_MODE
    ;call print_string_pm
    mov edx, 0xb8000            ; edx stores video memory pointer
    mov al, 'A'                 ; first byte is ASCII
    mov ah, 0x1F                ; second byte is description
    mov [edx], ax           ; save ax to [edx]

; endless loop
jmp $

; global message, note that here we use null-termination
MSG_REAL_MODE db 'Started in 16-bit real mode', 0
MSG_PROT_MODE db 'Loaded 32-bit protected mode', 0

; define some macros
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

; this routine print a string in 32-bit protected mode
; string address stored in ebx
print_string_pm:
    push edx
    mov edx, VIDEO_MEMORY       ; edx stores video memory pointer
print_string_pm_loop:
    mov al, [ebx]               ; first byte is ASCII
    mov ah, WHITE_ON_BLACK      ; second byte is description
    cmp al, 0
    je  print_string_pm_done    ; exit if encounter 0
    mov [edx], ax               ; save ax to [edx]
    add ebx, 1                  ; ebx move a byte
    add edx, 2                  ; edx move two bytes
    jmp print_string_pm_loop
print_string_pm_done:
    pop edx
    ret

; GDT, each entry should be 8 bytes, i.e. 64 bits
gdt_start:

gpt_null:       ; mandatory null entry
    dd 0x0      ; 32 0s
    dd 0x0

gdt_code:       ; code segment
    ; base=0x0, limit=0xfffff
    ; 1st flags: (present)1 (previliged)00 (descriptor tye)1 -> 1001b
    ; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
    ; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
    dw 0xffff       ; Limit (bits  0-15)
    dw 0x0          ; Base  (bits  0-15)
    db 0x0          ; Base  (bits 16-23)
    db 10011010b    ; 1st flags, type flags
    db 11001111b    ; 2nd flags, Limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

gdt_data:       ; data segment
    ; base=0x0, limit=0xfffff
    ; 1st flags: (present)1 (previliged)00 (descriptor tye)1 -> 1001b
    ; type flags: (data)0 (conforming)0 (readable)1 (accessed)0 -> 0010b
    ; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
    dw 0xffff       ; Limit (bits  0-15)
    dw 0x0          ; Base  (bits  0-15)
    db 0x0          ; Base  (bits 16-23)
    db 10010010b    ; 1st flags, type flags
    db 11001111b    ; 2nd flags, Limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

gdt_end:        ; let the assembler calculate the size of GDT

gdt_descriptor:
    dw gdt_end - gdt_start - 1      ; 1 byte less than true size
    dd gdt_start                    ; start address of GDT

CODE_SEG equ gdt_code - gdt_start   ; 0x08
DATA_SEG equ gdt_data - gdt_start   ; 0x10

; padding 510 bytes 0, $ means current address and $$ means base address of the current block
; $-$$ is the size of preceding program (excluding $), and 0x510-($-$$) will be the number of 0s
times 510-($-$$) db 0

; the magic number to denote a boot section
dw 0xaa55