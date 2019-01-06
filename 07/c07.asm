;the user function includes:
;1)getting the data from data_1_section and judging the data
;is 0x0d/0x0a/normal data;
;2)when ready to display on screen, we must get the position of the cursor and set the correct position of the cursor;
;3)one data displayed in video memory occupies two bytes;
;===========================================================
;here we do not need use align, because
;the addr was aligned already when the code
;was read and stored in the memory
;===========================================================
SECTION header vstart=0
	length_of_code dd program_end
	entry_of_code dw start ;0x04
	entry_code_section dd section.code_1.start ;0x06
	num_of_section dw (section_end - section_start)/4 ;0x0a
	section_start:
	code_1_segment dd section.code_1.start
	code_2_segment dd section.code_2.start
	data_1_segment dd section.data_1.start
	data_2_segment dd section.data_2.start
	stack_segment dd section.stack.start
	section_end:
;===========================================================
SECTION code_1 align=16 vstart=0
	put_string:
	mov cl, [bx]
	or cl, cl
	jz .exit
	call put_char
	inc bx
	;here only change the value of ip
	;we konw changing the route of code is
	;to change the value of cs/ip
	jmp put_string
	.exit:
		ret
	put_char:
		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		;here we get the position of cursor
		mov dx, 0x3d4
		mov al, 0x0e
		out dx, al
		mov dx, 0x3d5
		in al, dx
		mov ah, al

		mov dx, 0x3d4
		mov al, 0x0f
		out dx, al
		mov dx, 0x3d5
		in al, dx
		mov bx, ax

		cmp cl, 0x0d
		jnz .put_0a
		mov ax, bx
		mov bl, 0x50
		div bl
		mul bl
		mov bx, ax
		jmp .set_cursor
	.put_0a:
		cmp cl, 0x0a
		jnz .put_other
		add bx, 80
		jmp .roll_screen

	.put_other:
		mov ax, 0xb800
		mov es, ax
		;in the memory, there arm some numbers like 0x07
		;here shl bx, 1 is including the 0x07
		shl bx, 1
		mov [es:bx], cl

		shr bx, 1
		add bx, 1

	.roll_screen:
		cmp bx, 2000
		jl .set_cursor

		mov ax, 0xb800
		;here we move the data in video memory to video memory
		;so ds/es all point to 0xb800
		mov ds, ax
		mov es, ax
		cld

		;0xa0 is the second line and the fist culumn
		;because in the video memory, one data displayed occupies two bytes.
		mov si, 0xa0
		mov di, 0x00
		mov cx, 1920
		rep movsw
		mov bx, 3840
		mov cx, 80
	.cls:
		mov word [es:bx], 0x0720
		add bx, 2
		loop .cls

		mov bx, 1920

	.set_cursor:
		mov dx, 0x3d4
		mov al, 0x0e
		out dx, al
		mov dx, 0x3d5
		mov al, bh
		out dx, al
		mov dx, 0x3d4
		mov al, 0x0f
		out dx, al
		mov dx, 0x3d5
		mov al, bl 
		out dx, al

		pop es 
		pop ds 
		pop dx
		pop cx
		pop bx
		pop ax

		ret
;here ip was set to start, and cs was set to code_1 section
;set ss/sp ds
	start:
		mov ax, [stack_segment]
		mov ss, ax
		mov sp, stack_end
		
		mov ax, [data_1_segment]
		mov ds, ax
		
		;here we want to display msg0
		mov bx, msg0
		call put_string

		;here we want to change the value of cs and ip
		;we make our code go to begin in section code_2 to run
		;the length of code_2_segment is 4bytes
		push word [es:code_2_segment]
		;here begin is the offset from the start of section
		mov ax, begin
		;the length of data pushed is a word
		push ax
		;emulate the return from call process
		retf

	continue:
		mov ax, [es:data_2_segment]
		mov ds, ax
		mov bx, msg1
		call put_string

		jmp $
SECTION code_2 align=16 vstart=0
	begin:
		push word [es:code_1_segment]
		mov ax, continue
		push ax

		retf
SECTION data_1 align=16 vstart=0
    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a
         db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
         db '     xor dx,dx',0x0d,0x0a
         db '     xor ax,ax',0x0d,0x0a
         db '     xor cx,cx',0x0d,0x0a
         db '  @@:',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     add ax,cx',0x0d,0x0a
         db '     adc dx,0',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     cmp cx,1000',0x0d,0x0a
         db '     jle @@',0x0d,0x0a
         db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
         db 0
SECTION data_2 align=16 vstart=0
    msg1 db '  The above contents is written by LeeChung. '
         db '2011-05-06'
         db 0
; the ss is set to start, but sp is set to stack_end
SECTION stack align=16 vstart=0
	resb 256
	stack_end:
;this section only includes program_end
SECTION trail align=16
	program_end:
