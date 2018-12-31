jmp near start
mytext db 'm',0x07,'y',0x07,'t',0x07,'e',0x07,'s',0x07,'t',0x07,':', 0x04

start:
	mov ax, 0x7c0
	mov ds, ax
	mov ax, 0xb800
	mov es, ax
	mov si, mytext
	mov di, 0 
	mov cx, (start - mytext)/2
	cld
	rep movsw
	;for caculating
	mov ax, 0x0
	mov ss, ax 
	mov sp, ax 
	mov cx, 5
	mov ax, number
	xor si, si
	mov bx, 10
	@digit:
	xor dx, dx
	div bx
	add dl, 0x30
	mov dh, 0x04
	;the num of pushing one is 16bit
	push dx
	inc si
	loop @digit
	;for show in dec
	;the num of loop is important
	;the num of pushing is 5 so popping si 5
	mov cx, 5
	@show:
	pop word [es:di]
	add di, 0x02
	loop @show
	jmp near $
	



	number db 0, 0, 0, 0, 0 
	
	

	times 510 - ($ - $$) db 0	
		db 0x55,0xaa
