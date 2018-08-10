[ORG 0x00] ; Start address
[BITS 16] ; Indicates that following code is set in 16bit

SECTION .text ; Define text Section(Segment)

jmp 0x07C0:START ; copy value 0x07C0 to CS segment reg(initialize seg reg)

START:
	mov ax, 0x07C0
	mov ds, ax
	mov ax, 0xB800
	mov es, ax

;mov ax, 0xB800 ; copy 0xB800 (Start address of video memory) to AX register
;mov ds, ax ; copy ax register value to ds register

	mov si, 0

.SCREENCLEARLOOP:
	mov byte[es:si], 0
	mov byte[es:si+1], 0x0A
	add si,2
	cmp si, 80*25*2
	jl .SCREENCLEARLOOP

	mov si, 0 ; dest string reg
	mov di, 0 ; source string reg

.MESSAGELOOP:
	mov cl, byte[si+MESSAGE1] ; CX reg: Counter for loop or string
	cmp cl, 0 ; CL : Lower 1byte of CX reg
	je .MESSAGEEND ; if CL==0, jump to MESSAGEEND
	mov byte[es:di], cl ; else continue to print string
	add si, 1
	add di, 2
	jmp .MESSAGELOOP

.MESSAGEEND
	jmp $ ; boot loader ends if printing string is finished

MESSAGE1: db 'MINT64 OS Boot Loader START!!', 0 ; this message will be printed



times 510-($-$$) db 0x00 ; from here($-$$) to 510, fill every 1byte by 0x00
db 0x55 
db 0xAA ; set 511, 512 by 0x55, 0xAA to notice that this code is Boot sector 
