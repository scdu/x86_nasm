;for test
;only hello on screen
;cs default value is 0
;ip default value is 0x7c00

mov ax, 0xb800  ;the memory for graphics card to mapped
mov es, ax

;for_displyed:
mov byte [es:0x00], 'h'
mov byte [es:0x01], 0x07
mov byte [es:0x02], 'e'
mov byte [es:0x03], 0x07
mov byte [es:0x04], 'l'
mov byte [es:0x05], 0x07
mov byte [es:0x06], 'l'
mov byte [es:0x07], 0x07
mov byte [es:0x08], 'o'
mov byte [es:0x09], 0x07

mov ax, number 
mov cx, 5
mov bx, 10
mov si, 0

caculate:
	xor dx, dx
	div bx
	mov byte [0x7c00 + number + si], dl
	inc si
	loop caculate

mov si, 0
mov di, 4
mov bx, 0x7c00 + number
display:
	mov al, [bx + di]
	dec di
	add al, 0x30
	mov [cs:0x0a + si], al
	inc si
	mov byte [cs:0x0a + si], 0x04
	inc si
	loop display

number : db 0,0,0,0,0

times 510 - ($ - $$) db 0
		  db 0x55
		  db 0xaa
