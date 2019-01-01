jmp near start
mytext db '1 + 2 + 3 + 4 + ......:'

start:
	mov ax, 0x7c0
	mov ds, ax
	mov ax, 0xb800
	mov es, ax
	mov si, mytext
	mov di, 0 
	mov cx, start - mytext
	@show_label:
	xor ax, ax
	mov al, [si]
	inc si
	mov [es:di], al
	inc di
	mov byte [es:di], 0x07
	inc di
	loop @show_label
	;here we caculating the sum of 1 + ....100
	mov si, 1
	xor ax, ax
	@caculate:
	add ax, si 
	inc si 
	cmp  si, 100
	jle @caculate
	
	;for caculating
	mov bx, 0x0
	mov ss, bx 
	mov sp, bx 
	;mov cx, 5
	mov bx, 10
	@digit:
	inc cx
	xor dx, dx
	div bx
	add dl, 0x30
	mov dh, 0x04
	;the num of pushing one is 16bit
	push dx
	cmp ax, 0
	;loop @digit
	jne @digit
	;;for show in dec
	;;the num of loop is important
	;;the num of pushing is 5 so popping si 5
	;mov cx, 5
	@show:
	pop word [es:di]
	add di, 0x02
	loop @show
	jmp near $
	



	;number db 0, 0, 0, 0, 0 
	
	

	times 510 - ($ - $$) db 0	
		db 0x55,0xaa
