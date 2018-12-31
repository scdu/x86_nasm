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

	number db 0, 0, 0, 0, 0 
	
	

	times 510 - ($ - $$) db 0	
		db 0x55,0xaa
