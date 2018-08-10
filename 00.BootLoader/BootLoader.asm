[ORG 0x00] ; Start address
[BITS 16] ; Indicates that following code is set in 16bit

SECTION .text ; Define text Section(Segment)

jmp 0x07C0:START ; copy value 0x07C0 to CS segment reg(initialize seg reg)

TOTALSECTORCOUNT: dw 1024 ; size of OS image, maximum 1152 sectors(0x90000byte)

;
; CODE AREA
;

START:
	mov ax, 0x07C0
	mov ds, ax
	mov ax, 0xB800
	mov es, ax

	; create stack: 0x0000:0000~FFFF, 64KB size
	mov ax, 0x0000
	mov ss, ax ; stack segment register
	mov sp, 0xFFFE ; stack pointer
	mov bp, 0xFFFE ; stack base pointer

	mov si, 0 ; initialize si register (string source reg)

.SCREENCLEARLOOP:
	mov byte[es:si], 0
	mov byte[es:si+1], 0x0A
	add si,2
	cmp si, 80*25*2
	jl .SCREENCLEARLOOP

	mov si, 0 ; dest string reg
	mov di, 0 ; source string reg

; print starting message on top of screen
push MESSAGE1 ; put message1 address in stack
push 0 ; y axis of screen
push 0 ; x axis of screen
call PRINTMESSAGE
add sp, 6 ; remove parameter (x, y, message)

; print loading OS image on screen
push IMAGELOADINGMESSAGE ; push message address in stack
push 1 ; y axis
push 0 ; x axis
call PRINTMESSAGE
add sp, 6

;load OS image from disk
;reset first

RESETDISK:
	; call BIOS reset function
	mov ax, 0
	mov dl, 0
	int 0x13 ; interrupt
	jc HANDLEDISKERROR ; jump to error handling function if an error occurs

	; read sector from disk
	; memory address for copying disk (ES:BX) : 0x10000 == 0x1000:0x0000
	mov si, 0x1000
	mov es, si
	mov bx, 0x0000
	mov di, word[TOTALSECTORCOUNT] ; set # of sectors of Os image in di reg

READDATA:
	;CONDITION CHECK: WHETHER EVERY SECTOR IS READ OR NOT
	cmp di, 0
	je READEND ; if DI==0 jump to readend(every sector is read)
	sub di, 0x1 ; else, sub 1 from DI(There are remaining sectors to read)

	; CALL BIOS READ FUNCTION
	mov ah, 0x02 ; BIOS service function #2 (read sector)
	mov al, 0x1 ; # of sector to read == 1 
	mov ch, byte[TRACKNUMBER] ; set track# to read
	mov cl, byte[SECTORNUMBER] ; set sector# to read
	mov dh, byte[HEADNUMBER] ; set head# to read
	mov dl, 0x00 ; set # of drive to read
	int 0x13 ; execute interrupt service
	jc HANDLEDISKERROR ; jump to error handling function if error occurs
	

	; 1 SECTOR IS READ, INCREASE SECTOR
	add si, 0x0020
	mov es, si ; 512 bytes is read, add to ES reg to increase address by 1 sector
	
	;CONDITION CHECK: WHETHER EVERY SECTOR IS READ OR NOT
	mov al, byte[SECTORNUMBER]
	add al, 0x01 ; increase sector # by 1
	mov byte[SECTORNUMBER], al ; set SECTORNUMBER with AL
	cmp al, 19  
	jl READDATA  ; if AL<19, continue to READDATA

	; INVERT HEAD NUMBER
	xor byte[HEADNUMBER], 0x01 ; toggle head number (0 to 1, 1 to 0)
	mov byte[SECTORNUMBER], 0x01 ; set sector # 1

	;CONDITION CHECK: WHETHER EVERY TRACK IS READ
	cmp byte[HEADNUMBER], 0x00
	jne READDATA ; if HEADNUMBER is not 1, track is not completely read: continue to READDATA
	
	; IF HEAD NUMBER IS 0, EVERY TRACK IS READ: INCREASE TRACK # and continue to READDATA
	add byte[TRACKNUMBER], 0X01 ; increase track# 1
	jmp READDATA ; continue to read

READEND:
	push LOADINGCOMPLETEMESSAGE
	push 1
	push 20
	call PRINTMESSAGE
	add sp, 6	
	jmp 0x1000:0x0000 ; EXECUTE LOADED OS IMAGE
;
; FUNCTION CODE AREA
;


HANDLEDISKERROR:
	push DISKERRORMESSAGE
	push 1
	push 20
	call PRINTMESSAGE
	jmp $
	; Just Print Error Message and Do Infinite Loop

PRINTMESSAGE:
	push bp
	mov bp, sp
	push es
	push si
	push di
	push ax
	push cx
	push dx

	mov ax, 0xB800
	mov es, ax ; Set ES register with start address of video memory

	; CALCULATE Y AXIS
	mov ax, word[bp+6] ; put 2nd parameter(y axis) in AX register
	mov si, 160 ; # of byte of 1 line (2*80 col)
	mul si ; ax = ax * si (y axis * (2*80))
	mov di, ax

	;CALCULATE X AXIS
	mov ax, word[bp+4] ; ax = 1st parameter(x axis)
	mov si, 2 ; # of byte of 1 word (2 byte)
	mul si ; ax = ax * si (x axis * 2)
	add di, ax ; di += ax

	mov si, word[bp+8] ; 3rd parameter == string's address

.MESSAGELOOP
	mov cl, byte[si] ; copy 1 character from to cl, si is pointing string
	cmp cl, 0 
	je .MESSAGEEND ; IF CHARACTER == 0, END OF STRING, JUMP TO MESSAGEEND
	mov byte [es:di], cl ; if character != 0, print si
	add si, 1 ; move to next character
	add di, 2 ; 1 word == 1 byte of character + 1 byte of attribution
	jmp .MESSAGELOOP

.MESSAGEEND
	pop dx
	pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret ; clean stack and return

;
; DATA AREA
;

MESSAGE1: db 'MINT64 OS Boot Loader Start!!', 0

DISKERRORMESSAGE: db 'DISK ERROR', 0
IMAGELOADINGMESSAGE: db 'OS Image Loading...', 0
LOADINGCOMPLETEMESSAGE: db 'Loading Complete!!', 0


; VARIABLES FOR READING DISK
SECTORNUMBER: db 0x02
HEADNUMBER: db 0x00
TRACKNUMBER: db 0x00 




times 510-($-$$) db 0x00 ; from here($-$$) to 510, fill every 1byte by 0x00
db 0x55 
db 0xAA ; set 511, 512 by 0x55, 0xAA to notice that this code is Boot sector 
