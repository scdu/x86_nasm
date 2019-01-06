;firs set addr for ss and sp 
;second set the addr for user code to be stored
;third set the ds and es 
;forth set the lba_start to di and si

;here 0x7c00 is phy addr and its logical addr is 0x7c0
;cs = 0x0
;ip = 0x7c00
;ds = 0x0 but offset is 0x7c00
lba_start equ 100
SECTION loader align=16 vstart=0x7c00
	mov ax, 0
	mov ss, ax
	mov sp, ax
	mov ax, [cs:phy_addr_user_code]
	mov dx, [cs:phy_addr_user_code + 0x02]
	mov bx, 16
	div bx
	;set the value for ds and es
	mov ds, ax
	mov es, ax
	xor di, di
	;here the bits of lba_start are 28
	mov si, lba_start 
	xor bx, bx
	;read the fist lba
	call read_user_code_disk

	;here we need to compute the size of the code
	mov dx, [0x02]
	mov ax, [0x00]
	mov bx, 512
	div bx
	cmp dx, 0
	jnz not_ratio
	dec ax
not_ratio:
	cmp ax, 0
	jz direct

	push ds
	mov cx, ax
read_again:
	mov ax, ds
	;here 0x20 is for logical, phy addr is 0x200 in fact
	add ax, 0x20
	mov ds, ax

	xor bx, bx
	inc si
	call read_user_code_disk
	loop read_again

	pop ds

direct:
	;compute the addr for code section of entry
	mov dx, [0x08]
	mov ax, [0x06]
	call calc_segment_base
	;the logit addr is 16bits
	mov [0x06], ax

	mov cx, [0x0a]
	;this addr is needed to set
	mov bx, 0x0c
realloc:
	mov dx, [bx + 0x02]
	mov ax, [bx]
	call calc_segment_base
	mov [bx], ax
	add bx, 4
	loop realloc

	jmp far [0x04]

read_user_code_disk:
;come in this func, push the regs fist
;this is a habit
;out/in only uses dx and ax
;the bits of the ports are 8, so only use al
	push ax
	push bx
	push cx
	push dx
	;the num of lba needed to read
	mov ax, 1 
	mov dx, 0x1f2
	out dx, al
	;bits 0-7
	inc dx
	mov ax, si
	;the bits of the port is 8
	out dx, al

	;bits 8-15
	inc dx
	mov al, ah
	out dx, al

	;bits 16-23
	inc dx
	mov ax, di
	out dx, al

	;bits 24-27
	inc dx
	mov al, 0xe0
	or al, ah
	out dx, al

	inc dx
	mov al, 0x20
	out dx, al

waits:
	in al, dx
	and al, 0x88
	cmp al, 0x08
	jnz waits

	mov cx, 256
	mov dx, 0x1f0
readw:
	in ax, dx
	;here the ds was already set
	mov [bx], ax
	add bx, 2
	loop readw

	pop dx
	pop cx
	pop bx
	pop ax

	ret
calc_segment_base:
	push dx

	add ax, [cs:phy_addr_user_code]
	add dx, [cs:phy_addr_user_code + 0x02]
	shr ax, 4
	ror dx, 4
	and dx, 0xf000
	or ax, dx

	pop dx

	ret
	
	


;the phy addr for user code 
phy_addr_user_code dd 0x10000

times 510 - ($ - $$) db 0
					 db 0x55,0xaa
