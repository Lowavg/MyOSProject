[ORG 0x00]
[BITS 16]

SECTION .text

;
;Code area
;

	mov ax, 0x1000 ; Starting address of protected mode's entry point
	mov ds, ax
	mov es, ax

	cli ; No interrupt
	lgdt [GDTR] ; Load GDT Table

;
; Entering protected mode
; No Paging, No cache, Internal FPU, No Align check
;

	mov eax, 0x4000003B ; setting cr0 control register
	mov cr0, eax

	jmp dword 0x08: (PROTECTEDMODE - $$ + 0x10000)

;
;Entering Protected mode
;
[BITS 32]
PROTECTEDMODE:
	mov ax, 0x10 ; save protected mode kernel's data segment descriptor in AX register
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax ; set segment selectors

	; Define stack  as size of 64KB in 0x00000000 ~ 0x0000FFFF

	mov ss, ax 
	mov esp, 0xFFFE
	mov ebp, 0xFFFE ; stack grows to 0x0000

	push (SWITCHSUCCESSMESSAGE - $$ + 0x10000)
	push 2
	push 0 ; Parameters : x coord, y coord, message
	call PRINTMESSAGE ; call function
	add esp, 12 ; remove parameters

	jmp $ ; infinite loop (work done)

;
;Function Code area
;

PRINTMESSAGE:
	push ebp
	mov ebp, esp
	push esi
	push edi
	push eax
	push ecx
	push edx

	mov eax, dword[ebp+12] ; parameter #2 : Y coordinate
	mov esi, 160 ; # of bytes of 1 line (2 byte * 80 characters)
	mul esi ; Y coord * 2
	mov edi, eax ; mov result to edi

	mov eax, dword[ebp+8] ; parameter #1 : X coordinate
	mov esi, 2 ; size of 1 character
	mul esi ; X coord * 2
	add edi, eax

	mov esi, dword[ebp+16] ; parameter #3 : message to print

.MESSAGELOOP:
	mov cl, byte[esi] ; copy 1 byte from ESI(message) to CL
	cmp cl, 0
	je .MESSAGEEND ; if CL is 0 (message is over), jump to Message end

	mov byte[edi+0xB8000], cl ; 0xB8000 : Video memory address
	add esi, 1 ; move to next character
	add edi, 2 ; move to next position of video memory : 1byte is character, 1byte is attribute

	jmp .MESSAGELOOP ; Loop

.MESSAGEEND:
	pop edx
	pop ecx
	pop eax
	pop edi
	pop esi
	pop ebp
	ret ; clean stack and return

;
;Data code area
;


;Align following datas in 8 byte
align 8, db 0

; Align GDTR's end in 8 byte
dw 0x0000
; Define GDTR data structure
GDTR:
	dw GDTEND - GDT - 1 ; Following GDT Table's size
	dd (GDT - $$ + 0x10000) ; Following GDT Table's Starting address

; Define GDT Table
GDT:

;Null Descriptor, must initialize by 0
	NULLDescriptor:
		dw 0x0000
		dw 0x0000
		db 0x00
		db 0x00
		db 0x00
		db 0x00

; Code Segment Descriptor for protected mode kernel
	CODEDESCRIPTOR: ; total 64 bits, 8 bit each
		dw 0xFFFF ; Limit [15:0] : 1111 1111 1111 1111
		dw 0x0000 ; Base [15:0] 
		db 0x00 ; Base [23:16]
		db 0x9A ; P=1, DPL=0, S=Code Segment, Type=Execute/Read : 1[P]00[DPL]1[S] 1010[Type]
		db 0xCF ; G=1, D=1, L=0, Limit[19:16] : 1[G]1[D]0[L]0[AVL] 1111[Limit]
		db 0x00 ; Base [31:24]

	; Base address is : 0x00[31:24]0x00[23:16]0x0000[15:0] : 0000 0000 0000 0000 0000 0000 0000 0000 (32bit: 0~4GB)
	; Limit is : 0xF[19:16]0xFFFF[15:0] : 1111 1111 1111 1111 1111 (20bit: 0~1MB)

; Data Segment Descriptor
	DATADESCRIPTOR:
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x92
		db 0xCF
		db 0x00
GDTEND:

	; P: Present, Indicates whether this descriptor is available
	; DPL: Descriptor Privilege Level, 0(high) ~ 3(low)
	; S: Type of descriptor, 1 means Segment descriptor, 0 means System descriptor
	; Type: Code / Data segment
	; G: Granularity, Weight to be multiplied to segment size field(1: multiply 4KB to segment size, 0: do nothing)
	; D(D/B): Default Operation Size (1: 32Bit segment, 0: 16Bit segment)
	; L: Used by IA-32e mode (1: 64bit code segment, 0: 32bit code segment)
	; AVL: Available, OS uses this field  


SWITCHSUCCESSMESSAGE: db 'Successfully Switched To Protected mode!!', 0

times 512 - ($-$$) db 0x00 ; Fill rest space with 0
