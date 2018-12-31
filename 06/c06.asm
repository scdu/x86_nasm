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
	mov cx, 5
	mov ax, number
	xor si, si
	mov bx, 10
	cwd
	@digit:
	xor dx, dx
	div bx
	add dl, 0x30
	mov [number + si], dl
	inc si
	loop @digit
	;for show in dec
	mov cx, 5
	;here si must dec,but di
	;here si = 5, di = e
	dec si
	@show:
	xor ax, ax
	mov al, [number + si]
	mov [es:di], al
	inc di
	mov byte [es:di], 0x04 
	inc di
	dec si
	jns @show
	jmp near $
	



	number db 0, 0, 0, 0, 0 
	
	

	times 510 - ($ - $$) db 0	
		db 0x55,0xaa
