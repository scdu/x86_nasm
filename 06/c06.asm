jmp near start
mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,':', 0x04
number db 0, 0, 0, 0, 0 

start:
	mov ax, 0x7c0
	mov ds, ax ;set a section started from 0x7c0,and ip = 0x0

	mov ax, 0xb800
	mov es, ax

	cld
	mov si, mytext ;here the values of si/di/cx changes autoly
	mov di, 0 
	mov cx, ( number - mytext )/2; why here can use / directly
							   ; cx not only enflects loop but also enflects movsb and movsw
	rep movsw


	mov ax, number
	mov cx, 10
	mov bx, ax
	mov si, 5 
caculate:
	xor dx, dx
	div cx 
	mov	[bx], dl
	add bx, 1
	dec si
	jns caculate

	mov cx, 10
;	mov si, 0
	mov si, 10
	mov bx, ax
	mov cx, 5
caculate:
	xor dx, dx
	div si 
	mov	[bx], dl
	add bx, 1
	loop caculate

	mov bx, number
	mov si, 4
display:
	mov al, [bx + si]
	add al, 0x30
	mov ah, 0x04
	mov [es: di], ax
	add di, 2
	dec si
	jns display
	
	

	times 510 - ($ - $$) db 0	
		db 0x55,0xaa
