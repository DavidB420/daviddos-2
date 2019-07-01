;DavidDOS 2.0 kernel Made by David Badiei
org 0000h

mov ax, 2000h
mov ds, ax
mov es, ax
mov ss, ax    
mov sp, 0

pusha
mov ah,0eh
mov al,07h
int 10h
mov al,08h
int 10h
mov al,20h
int 10h
mov al,08h
int 10h
popa
;check drive num
mov byte [bootdev],dl

mov si,text_string
call print_string

mov si,text_string1
call print_string

jmp shellsub

start:

cmp bp,1
je afterprog

mov cx,0

mov si,newline
call print_string

mov ah,0eh
mov al,'>'
int 10h

mov di,buffer
call getinput

mov si,buffer
mov di,cmd_help
call strcmp
jc helpsub

mov si,buffer
mov di,cmd_clear
call strcmp
jc clearsub

mov si,buffer
mov di,cmd_restart
call strcmp
jc restartsub

mov si,buffer
mov di,cmd_calc
call strcmp
jc calcsub

mov si,buffer
mov di,cmd_echo
call strcmp
jc echosub

mov si,buffer
mov di,cmd_ascii
call strcmp
jc asciisub

mov si,buffer
mov di,cmd_guess
call strcmp
jc guesssub

mov si,buffer
mov di,cmd_shell
call strcmp
jc shellsub

mov si,buffer
mov di,cmd_sd
call strcmp
jc sdsub

mov si,buffer
mov di,cmd_time
call strcmp
jc timesub

mov si,buffer
mov di,cmd_dir
call strcmp
jc dirsub

mov si,buffer
mov di,cmd_del
call strcmp
jc delsub

mov si,buffer
mov di,cmd_ren
call strcmp
jc rensub

mov si,buffer
mov di,cmd_cat
call strcmp
jc catsub

mov si,buffer
mov di,cmd_load
call strcmp
jc loadsub

mov si,buffer
mov di,cmd_edit
call strcmp
jc editsub

mov si,invalid
call print_string

mov si,buffer
call print_string

jmp start

hlt

text_string db 'DavidDOS 2.0 Copyright (C) 2019 David Badiei', 0x0D, 0x0A, 0
text_string1 db '===============================================================================', 0
text_string2 db 'DavidDOS - Internal Commands', 0x0D, 0x0A, 'help - Brings this list', 0x0D, 0x0A, 'cls - Clear the screen', 0x0D, 0x0A, 'restart - Restarts the system', 0xD, 0xA, 'calc - A simple calculator', 0x0D, 0x0A, 'echo - Repeat an argument', 0x0D, 0x0A, 'ascii - Displays all ASCII characters', 0x0D, 0x0A, 'guess - A simple number guessing game', 0x0D, 0x0A, 'shell - Graphical Shell', 0x0D, 0x0A, 'sd - Shuts down the system', 0x0D, 0x0A, 'timed - Get time and date', 0x0D, 0x0A, 'Disk related services - dir, del, ren, cat, load, edit', 0
buffer times 64 db 0
newline db	0x0D, 0x0A, 0
invalid db 'Illegal Command!: ', 0
cmd_help db 'help', 0
cmd_clear db 'cls', 0
cmd_restart db 'restart', 0
cmd_calc db 'calc', 0
cmd_echo db 'echo', 0
cmd_ascii db 'ascii', 0
cmd_guess db 'guess', 0
cmd_shell db 'shell', 0
cmd_sd db 'sd', 0
cmd_time db 'timed', 0
cmd_dir db 'dir', 0
cmd_del db 'del', 0
cmd_ren db 'ren', 0
cmd_cat db 'cat', 0
cmd_load db 'load', 0
cmd_edit db 'edit', 0
print_string:			
	mov ah, 0eh				
	loop:
	lodsb					
	test al,al				
	jz done				
	int	10h				
	jmp loop				
	done:
		ret
getinput:
	mov ah,0
	int 16h
	cmp al,08h
	je delchar
	cmp al,0dh
	je entpress
	cmp al,3fh
	je getinput
	mov ah,0eh
	int 10h
	stosb
	inc cx
	jmp getinput
	delchar:
		cmp cx,0
		je getinput
		mov ah,0eh
		mov al,08h
		int 10h
		mov al,20h
		int 10h
		mov al,08h
		int 10h
		sub cx,1
		dec di
	    mov byte [di], 0
		jmp getinput
	entpress:
	   mov al,0
	   stosb
	   mov ah,0eh
	   mov al,0dh
	   int 10h
	   mov al,0ah
	   int 10h
	   ret
strcmp:
	loop1:
		mov al,[si]
		mov bl,[di]
		cmp al,bl
		jne notequal
		cmp al,0
		je done1
		add di,1
		add si,1
		jmp loop1
	notequal:
		clc
		ret
	done1:
		stc
		ret
helpsub:
	mov si,text_string2
	call print_string
	jmp start
clearsub:
	pusha
	mov ah, 00h
	mov al, 03h  
	int 10h
	popa
	mov si,text_string
	call print_string
	mov si,text_string1
	call print_string
    jmp start

restartsub:
	jmp 0xffff:0000h

calcsub:
	mov si,calc1
	call print_string
	mov di,num1
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov si,newline
	call print_string
	mov si,calc2
	call print_string
	mov di,num2
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov si,newline
	call print_string
	mov si,calc3
	call print_string
	mov dx,[num1]
	sub dx,30h
	mov bx,[num2]
    add dx,bx
	mov [num3],dx
	mov si,num3
	mov ah,0eh
	lodsb
	cmp al,':'
	jge calcnumoverflow
	int 10h
    lodsb
	sub al,30h
	cmp al,':'
	jge tenormore
	calcline:
	int 10h
	mov dx,0
	jmp start
	tenormore:
		mov al,08h
		int 10h
		mov al,20h
		int 10h
		mov al,08h
		int 10h
		mov si,num3
		mov ah,0eh
		lodsb
		add al,1
		cmp al,':'
		jge calcnumoverflow
		int 10h
		lodsb
		sub al,30h
		sub al,10
		int 10h
		mov cx,0
		mov dx,[num3]
		jmp start
	calcnumoverflow:
		mov si,calc4
		call print_string
		jmp start
	calc1 db 'Enter first number: ', 0
	calc2 db 'Enter second number: ', 0
	calc3 db 'Answer: ', 0
	calc4 db 'Number Overflow!', 0 
	num1 times 2 db 0
	num2 times 2 db 0
	num3 db 0
	
echosub:
	mov ax,0
	mov dx,0
	mov cx,0
	mov si,echo1
	call print_string
	mov di,echobuffer
	getinputecho:
	mov ah,0
	int 16h
	cmp al,08h
	je delcharecho
	cmp al,0dh
	je entpressecho
	cmp cx,27h
	je getinputecho
	mov ah,0eh
	int 10h
	stosb
	inc cx
	jmp getinputecho
	delcharecho:
		cmp cx,0
		je getinputecho
		mov ah,0eh
		mov al,08h
		int 10h
		mov al,20h
		int 10h
		mov al,08h
		int 10h
		sub cx,1
		dec di
	    mov byte [di], 0
		jmp getinputecho
	entpressecho:
	    mov al,0
	    stosb
	    mov ah,0eh
	    mov al,0dh
	    int 10h
	    mov al,0ah
	    int 10h
		mov si,echo2
		call print_string
		mov si,newline
		call print_string
		mov ah,0h
		int 16h
		mov bl,al
		mov ah,0eh
		int 10h
		mov si,newline
		call print_string
		cmp bl,'1'
		je onesub
		cmp bl,'2'
		je fivesub
		cmp bl,'3'
		je tensub
		cmp bl,'4'
		je twentyfivesub
		cmp bl,'5'
		je fiftysub
		cmp bl,'6'
		je hundredsub
		mov si,echo3
		call print_string
		jmp start
		onesub:
			mov si,echobuffer
			call print_string
			jmp start
		fivesub:
			mov bx,5
			jmp outsub
		tensub:
			mov bx,10
			jmp outsub
		twentyfivesub:
			mov bx,25
			jmp outsub
		fiftysub:
			mov bx,50
			jmp outsub
		hundredsub:
			mov bx,75
			jmp outsub
		outsub:
			mov cx,0
			loop5:
				inc cx
				mov si,echobuffer
				call print_string
				cmp cx,bx
				je oof
				mov si,newline
				call print_string
				jmp loop5
			oof:
				jmp start
			echo1 db 'Enter argument: ', 0
			echo2 db 'How many times do you wanna loop the argument?', 0x0D, 0x0A, '1.Once', 0x0D,0x0A, '2.Five times', 0x0D, 0x0A, '3.Ten times', 0x0D, 0x0A, '4.Twenty five times', 0x0D, 0x0A, '5.Fifty times', 0x0D, 0x0A, '6.Hundred times', 0
			echo3 db 'Invalid option :-(', 0
			echobuffer times 40 db 0
			timesbuffer times 2 db 0
asciisub:
	mov si,asciiprompt
	call print_string
	mov cx,256
	mov al,0
	mov ah,0eh
	asciiloop:
		int 10h
		add al,1
		sub cx,1
		jnz asciiloop
	mov cx,0
	mov ax,0
	jmp start
	asciiprompt db 'Here are all the ASCII characters: ', 0

 guesssub:
	mov ah,00h
	int 1ah
	mov ax,dx
	xor dx,dx
	mov cx,10
	div cx
	add dl,30h
	mov al,dl
	mov di,randNum
	stosb
	mov cx,0fh
	mov dx,4240h
	mov ah,86h
	int 15h
	mov ah,00h
	int 1ah
	mov ax,dx
	xor dx,dx
	mov cx,10
	div cx
	add dl,30h
	mov al,dl
	stosb
	mov si,intro
	call print_string
	;Fix problem when it outputs random crap
	push cx
	mov cx,23
	fixthing:
	mov ah,0eh
	mov al,08h
	int 10h
	mov al,20h
	int 10h
	mov al,08h
	int 10h
	loop fixthing
	pop cx
	guessloop:
	mov si,askUser
	call print_string
	mov di,num
	mov ah,00h
	int 016h
	stosb
	cmp al,1bh
	je exit
	mov ah,0eh
	int 10h
	mov ah,00h
	int 016h
	stosb
	cmp al,1bh
	je exit
	mov ah,0eh
	int 10h
	mov si,newline
	call print_string
	mov si,num
	mov di,randNum
	mov al,[si]
	mov bl,[di]
	cmp al,bl
	jg lessthan
	cmp al,bl
	jl greatthan
	cmp al,bl
	je equalthan
	jmp guessloop
	exit:
	jmp start
	lessthan:
		mov si,less
		call print_string
		jmp guessloop
	greatthan:
		mov si,great
		call print_string
		jmp guessloop
	equalthan:
		mov si,num
		mov di,randNum
		mov al,[si+1]
		mov bl,[di+1]
		cmp al,bl
		jg lessthan
		cmp al,bl
		jl greatthan
		cmp al,bl
		je gameEnd
		jmp guessloop
	gameEnd:
		mov si,gameEndstr
		call print_string
		jmp start
	intro db 'Welcome to Guess the Number!', 0x0D, 0x0A, 'Please enter a number between 1 and 99', 0x0D, 0x0A, 'Additonal commands: del', 0
	askUser db 'Enter Number: ', 0
	less db 'Oops the number is less than that one. Try another', 0x0D, 0x0A, 0
	great db 'Oops the number is greater than that one. Try another', 0x0D, 0x0A, 0
	gameEndstr db 'Congratulations! You got the number!', 0
	num times 2 db 0
	randNum times 2 db 0

shellsub:
	mov ah,01h
	mov cx,2607h
	int 10h
	mov bp,1
	;fill bg
	mov ah,06h
	xor al,al
	xor cx,cx
	mov dx,184fh
	mov bh,1fh
	int 10h
	call draw_cursor
	;gray bar on top
	xor dx,dx
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,80
	mov bl,70h
	mov al,' '
	int 10h
	mov si,text_string
	call print_string
	xor dx,dx
	call draw_cursor
	mov si,text_string
	call print_string
	;gray bar on bottom
	mov dl,0
	mov dh,24
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,80
	mov bl,70h
	mov al,' '
	int 10h
	;red box in middle
	mov dl,5
	mov dh,1
	call draw_cursor
	boxloop1:
	inc dh
	cmp dh,23
	je afterwrite
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,70
	mov bl,4fh
	mov al,' '
	int 10h
	jmp boxloop1
	afterwrite:
		mov dl,5
		mov dh,3-1
		call draw_cursor
		mov si,selectText
		call print_string
	;Add programs to list
	mov dl,5
	mov dh,3
	call draw_cursor
	call addtext
	mov dh,3
	;Add selections
	movehiglight:
	mov dl,5
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,70
	mov bl,0xf0
	mov al,' '
	int 10h
	call addtext
	mov dl,5
	mov dh,3
	call draw_cursor
	jmp keys
	app1 db 'restart - Restarts the system', 0
	app2 db 'calc - A simple calculator', 0
	app3 db 'echo - Repeat an argument', 0
	app4 db 'ascii - Displays all ASCII characters', 0
	app5 db 'guess - A simple number guessing game', 0
	app6 db 'exit - Return to command line', 0
	app7 db 'sd - Shuts down the system', 0
	app8 db 'timed - Get time and date', 0
	app9 db 'load - Load external executable', 0
	app10 db 'fileman - Graphical file manager', 0
	app11 db 'ddedit - Text Editor', 0
	;move cursor with arrow keys and loop shell
	keys:
	mov ah,00h
	int 16h
	cmp ah,48h
	je uparrow
	cmp ah,50h
	je downarrow
	cmp al,1bh
	je clearsub
	cmp al,0dh
	je entersub
	jmp shellsub
	addtext:
		mov si,app1
		call print_string
		inc dh
		call draw_cursor
		mov si,app2
		call print_string
		inc dh
		call draw_cursor
		mov si,app3
		call print_string
		inc dh
		call draw_cursor
		mov si,app4
		call print_string
		inc dh
		call draw_cursor
		mov si,app5
		call print_string
		inc dh
		call draw_cursor
		mov si,app6
		call print_string
		inc dh
		call draw_cursor
		mov si,app7
		call print_string
		inc dh
		call draw_cursor
		mov si,app8
		call print_string
		inc dh
		call draw_cursor
		mov si,app9
		call print_string
		inc dh
		call draw_cursor
		mov si,app10
		call print_string
		inc dh
		call draw_cursor
		mov si,app11
		call print_string
		ret
	draw_cursor:
		mov bh,0
		mov ah,2
		int 10h
		ret
	redraw_list:
		mov ch,dh
		mov cl,dl
		call draw_cursor
		mov dh,3
		mov dl,5
		call draw_cursor
		call addtext
		mov dh,ch
		mov dl,cl
		call draw_cursor
		ret
	uparrow:
		cmp dh,3
		je keys
		dec dh
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,0xf0
		mov al,' '
		int 10h
		add dh,1
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,4fh
		mov al,' '
		int 10h
		sub dh,1
		call draw_cursor
		call redraw_list
		jmp keys

	downarrow:
		cmp dh,13
		je keys
		inc dh
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,0xf0
		mov al,' '
		int 10h
		sub dh,1
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,4fh
		mov al,' '
		int 10h
		add dh,1
		call draw_cursor
		call redraw_list
		jmp keys
	entersub:
		pusha
		mov ah, 00h
		mov al, 03h  
		int 10h
		popa
		cmp dh,3
		je restartsub
		cmp dh,4
		je calcsub
		cmp dh,5
		je echosub
		cmp dh,6
		je asciisub
		cmp dh,7
		je guesssub
		cmp dh,8
		je gotocmd
		cmp dh,9
		je sdsub
		cmp dh,10
		je timesub
		cmp dh,11
		je loadsub
		cmp dh,12
		je executefileman
		cmp dh,13
		je editsub
	gotocmd:
		call clearallreg
		continuecrap:
		mov bp,0
		mov si,text_string
		call print_string
		mov si,text_string1
		call print_string
		jmp start
	afterprog:
		mov si,pressKey
		call print_string
		mov ah,00h
		int 16h
		jmp shellsub
	selectText db 'Please select a program below:', 0
	pressKey db 0Dh, 0Ah, 'Press any key to continue...', 0
sdsub:
	mov ax,5300h
	mov bx, 0
	int 15h
	mov ax,5301h
	mov bx,0
	int 15h
	mov ax, 530Eh		
	mov bx, 0			
	mov cx, 0102h
	int 15h
	mov ax, 5307h		
	mov cx, 0003h		
	mov bx, 0001h		
	int 15h
	mov si,apmError
	call print_string
	hlt
	jmp start
	apmError db 'It is now safe to turn off your computer.', 0

timesub:
	;Time section
	mov si,timeStr
	call print_string
	mov ah,02h
	int 1ah
	mov al,ch
	call bcdtoint
	mov ch,al
	mov al,cl
	call bcdtoint
	mov cl, al
	mov al, dh			
	call bcdtoint
	mov dh, al
	mov ah,0eh
	xor ax,ax
	mov al,ch
	call outputnum
	mov ah,0eh
	mov al,":"
	int 10h
	mov ah,0eh
	xor ax,ax
	mov al,cl
	call outputnum
	mov ah,0eh
	mov al,":"
	int 10h
	mov ah,0eh
	xor ax,ax
	mov al,dh
	call outputnum
	;Date section
	mov si,dateStr
	call print_string
	mov ah,04
	int 1ah
	mov al,dl
	call bcdtoint
	mov dl,al
	mov al,dh
	call bcdtoint
	mov dh,al
	mov al,ch
	call bcdtoint
	mov ch,al
	mov al,cl
	call bcdtoint
	mov cl,al
	mov al,dl
	call outputnum
	mov ah,0eh
	mov al,'/'
	int 10h
	mov al,dh
	call outputnum
	mov ah,0eh
	mov al,'/'
	int 10h
	mov al,ch
	call outputnum
	mov al,cl
	call outputnum
	jmp start
	bcdtoint:
		push cx
		push ax
		and al, 11110000b
		shr al,4
		mov cl,10
		mul cl
		pop cx
		and cl,00001111b
		add al,cl
		pop cx
		ret
	outputnum:		
		mov ah,0
		mov bl,10
		div bl
		mov bh,ah
		mov ah,0eh
		add al,'0'
		int 10h
		mov al,bh
		add al,'0'
		int 10h
		ret
	timeStr db 'Time: ', 0
	dateStr db 0x0D, 0x0A, 'Date: ', 0
dirsub:
	;Fix bug where instead of it outputting data from the disk it outputs crap after running a del command
	call clearallreg
	mov ch,0
	mov cl,2
	mov dh,1
	mov ah,2
	mov al,14
	mov dl,byte [bootdev]
	mov si,disk_buffer
	mov bx,si
	clc
	int 13h
	mov bx,0x2000
	mov es,bx
	mov si,disk_buffer
	mov di,filelist_tmp
	mov ah,0eh
	mov cx,0
	readroot:
	lodsb
	cmp al,229
	je skipfn
	cmp al,0fh
	je skipfn
	cmp al,0
	je exitdir
	int 10h
	inc cx
	inc dx
	cmp cx,11
	je donereadfn
	jmp readroot
	exitdir:
	jmp start
	filelist_tmp times 512 db 0
	disk_buffer equ 2000h
	donereadfn:
	add si,21
	push ax
	mov ax,0e20h
	int 10h
	int 10h
	int 10h
	pop ax
	mov cx,0
	jmp readroot
	skipfn:
	add si,31
	jmp readroot
	error1:
	mov bl,80h
	mov byte [bootdev],bl
	mov ch,0
	mov cl,2
	mov dh,1
	mov ah,2
	mov al,14
	mov dl,byte [bootdev]
	mov si,disk_buffer
	mov bx,si
	clc
	int 13h
	ret
delsub:
	pusha
	mov si,userDel
	call print_string
	mov di,fileTodelete
	mov cx,0
	getdelinput:
	mov ah,00
	int 16h
	cmp al,08
	je delrmpress
	cmp al,0dh
	je delentpress
	inc cx
	mov ah,0eh
	int 10h
	stosb
	jmp getdelinput
	jmp start
	delrmpress:
	cmp cx,0
	je getdelinput
	mov ah,0eh
	mov al,08h
	int 10h
	mov al,20h
	int 10h
	mov al,08h
	int 10h
	sub cx,1
	dec di
	mov byte [di], 0
	jmp getdelinput
	delentpress:
	mov al,0
	stosb
	mov ah,0eh
	mov al,0dh
	int 10h
    mov al,0ah
	int 10h
	mov si,fileTodelete
	call makeCaps
	mov si,fileTodelete
	call makeFAT12
	mov ch,0
	mov cl,2
	mov dh,1
	mov dl,byte [bootdev]
	mov ah,2
	mov al,14
	mov si,disk_buffer
	mov bx,si
	int 13h
	mov di,disk_buffer
	mov si,fat12str
	mov bx,0
	mov ax,0
	rmrootdir:
	mov cx,11
	cld
	repe cmpsb
	je foundit
	inc bx
	add ax,32
	mov si,fat12str
	mov di,disk_buffer
	add di,ax
	cmp bx,224
	jle rmrootdir
	cmp bx,224
	je start
	foundit:
	push si
	mov si,fat12str
	call print_string
	pop si
	cmp bx,0
	je subtract
	mov ax,32
	mul bx
	mov di,disk_buffer
	add di,ax
	jmp finishdel
	subtract:
	mov di,disk_buffer
	finishdel:
	mov byte [di],229
	mov ch,0
	mov cl,2
	mov dh,1
	mov dl,byte [bootdev]
	mov ah,3
	mov al,14
	mov si,disk_buffer
	mov bx,si
	int 13h
	mov ax, word [es:di+26]
	mov word [tmp],ax
	push ax
	mov ch,0
	mov cl,2
	mov dh,0
	mov dl,byte [bootdev]
	mov ah,2
	mov al,9
	mov si,disk_buffer
	mov bx,si
	int 13h
	pop ax
	moreCluster:
	mov bx,3
	mul bx
	mov bx,2
	div bx
	mov si,disk_buffer
	add si,ax
	mov ax, word [si]
	test dx,dx
	jz even
	odd:
	push ax
	and ax,0x000F
	mov word [si],ax
	pop ax
	shr ax,4
	jmp calcclustcount
	even:
	push ax
	and ax,0xF000
	mov word [si],ax
	pop ax
	and ax,0x0fff
	calcclustcount:
	mov word [tmp],ax
	cmp ax,0ff8h
	jae donefat
	jmp moreCluster
	donefat:
	mov ch,0
	mov cl,2
	mov dh,0
	mov dl,byte [bootdev]
	mov ah,3
	mov al,9
	mov si,disk_buffer
	mov bx,si
	int 13h
	donedel:
	popa
	jmp start
	userDel db 'Enter filename: ', 0
	fileTodelete times 11 db 0
	fat12str times 11 db 0
	filename dw 0
	tmp dw 0
	getStringlength:
	mov si,fileTodelete
	mov dl,0
	loopstrlength:
	cmp byte [si],0
	jne inccounter
	cmp byte [si],0
	je donestrlength
	jmp loopstrlength
	inccounter:
	inc dl
	inc si
	jmp loopstrlength
	donestrlength:
	ret
	makeCaps:
		cmp byte [si],0
		je donemakincaps
		cmp byte [si],61h
		jb notatoz
		cmp byte [si],7ah
		ja notatoz
		sub byte [si],20h
		jb makeCaps
		jmp makeCaps
		notatoz:
		inc si
		jmp makeCaps
		donemakincaps:
		ret
	makeFAT12:
		call getStringlength
		mov si,fileTodelete
		mov di,fat12str
		mov cx,0
		mov dh,0
		mov bx,di
		copytonewstr:
		lodsb
		cmp al,'.'
		je extfound
		stosb
		inc cx
		jmp copytonewstr
		extfound:
		cmp cx,8
		je addext
		addspaces:
		mov byte [di],' '
		inc di
		inc cx
		cmp cx,8
		jl addspaces
		addext:
		lodsb
		stosb
		lodsb
		stosb
		lodsb
		stosb
		mov al,0
		stosb
		ret

clearallreg:
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
	xor si,si
	xor di,di
	ret

rensub:
    pusha
	mov si,ques1ren
	call print_string
	mov di,fileToren
	mov cx,0
	getreninput:
	mov ah,0
	int 16h
	cmp al,08
	je renrmsub
	cmp al,0dh
	je renentsub
	stosb
	inc cx
	mov ah,0eh
	int 10h
	jmp getreninput
	renrmsub:
	cmp cx,0
	je getreninput
	mov ah,0eh
	mov al,08h
	int 10h
	mov al,20h
	int 10h
	mov al,08h
	int 10h
	dec cx
	dec di
	mov byte [di], 0
	jmp getreninput
	renentsub:
	mov ah,0eh
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	mov si,fileToren
	call makeCaps
	mov bp,0
	call makerenFAT12
	mov si,ques2ren
	call print_string
	mov di,filen
	mov cx,0
	getreninput1:
	mov ah,0
	int 16h
	cmp al,08
	je renrmsub1
	cmp al,0dh
	je renentsub1
	stosb
	inc cx
	mov ah,0eh
	int 10h
	jmp getreninput1
	renrmsub1:
	cmp cx,0
	je getreninput1
	mov ah,0eh
	mov al,08h
	int 10h
	mov al,20h
	int 10h
	mov al,08h
	int 10h
	dec cx
	dec di
	mov byte [di], 0
	jmp getreninput1
	renentsub1:
	mov ah,0eh
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	mov si,filen
	call makeCaps
	mov bp,1
	call makerenFAT12
	mov si,fat12str1
	call print_string
	mov ch,0
	mov cl,2
	mov dh,1
	mov dl,byte [bootdev]
	mov ah,2
	mov al,14
	mov si,disk_buffer
	mov bx,si
	int 13h
	mov di,disk_buffer
	mov si,fat12str
	mov bx,0
	mov ax,0
	findfn:
	mov cx,11
	cld
	repe cmpsb
	je foundfn
	inc bx
	add ax,32
	mov si,fat12str
	mov di,disk_buffer
	add di,ax
	cmp bx,224
	jle findfn
	foundfn:
	mov ax,32
	mul bx
	mov di,disk_buffer
	add di,ax
	mov bx,ax
	mov cx,11
	mov si,fat12str1
	replacefn:
	mov dh, byte [si]
	mov byte [di], dh
	inc si
	inc di
	loop replacefn
	mov ch,0
	mov cl,2
	mov dh,1
	mov dl,byte [bootdev]
	mov ah,3
	mov al,14
	mov si,disk_buffer
	mov bx,si
	int 13h
	popa
	jmp start
	ques1ren db 'Enter file name of file you want to rename: ', 0
	ques2ren db 'Enter your new file name: ', 0
	fileToren times 11 db 0
	filen times 11 db 0
	fat12str1 times 11 db 0
	getStringrenlength:
	mov si,fileToren
	mov dl,0
	loopstrrenlength:
	cmp byte [si],0
	jne increncounter
	cmp byte [si],0
	je donestrlength
	jmp loopstrrenlength
	increncounter:
	inc dl
	inc si
	jmp loopstrlength
	makerenFAT12:
		call getStringrenlength
		cmp bp,0
		je ogfn
		cmp bp,1
		je nfn
		ogfn:
		mov si,fileToren
		mov di,fat12str
		jmp continuefat12
		nfn:
		mov si,filen
		mov di,fat12str1
		continuefat12:
		mov cx,0
		mov dh,0
		mov bx,di
		copyrentonewstr:
		lodsb
		cmp al,'.'
		je extrenfound
		stosb
		inc cx
		jmp copyrentonewstr
		extrenfound:
		cmp cx,8
		je addrenext
		addrenspaces:
		mov byte [di],' '
		inc di
		inc cx
		cmp cx,8
		jl addrenspaces
		addrenext:
		lodsb
		stosb
		lodsb
		stosb
		lodsb
		stosb
		mov al,0
		stosb
		ret
catsub:
	mov si,catques1
	call print_string
	mov di,fileToren
	mov cx,0
	getcatinput:
	mov ah,0
	int 16h
	cmp al,08
	je catrmsub
	cmp al,0dh
	je catentsub
	stosb
	inc cx
	mov ah,0eh
	int 10h
	jmp getcatinput
	catrmsub:
	cmp cx,0
	je getcatinput
	mov ah,0eh
	mov al,08h
	int 10h
	mov al,20h
	int 10h
	mov al,08h
	int 10h
	dec cx
	dec di
	mov byte [di], 0
	jmp getcatinput
	catentsub:
	mov ah,0eh
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	mov si,fileToren
	call makeCaps
	mov bp,0
	call makerenFAT12
	mov ch,0
	mov cl,2
	mov dh,1
	mov dl,byte [bootdev]
	mov ah,2
	mov al,14
	mov si,disk_buffer
	mov bx,si
	int 13h
	mov di,disk_buffer
	mov si,fat12str
	mov bx,0
	mov ax,0
	findfn1:
	mov cx,11
	cld
	repe cmpsb
	je foundfn1
	inc bx
	add ax,32
	mov si,fat12str
	mov di,disk_buffer
	add di,ax
	cmp bx,224
	jle findfn1
	foundfn1:
	mov ax,32
	mul bx
	mov di,disk_buffer
	add di,ax
	mov ax,word [di+1Ah]
	mov word [cluster],ax
	push ax
	mov ch,0
	mov cl,2
	mov dh,0
	mov dl,byte [bootdev]
	mov ah,2
	mov al,9
	mov si,fat
	mov bx,si
	int 13h
	pop ax
	push ax
	mov di,file
	mov bx,di
	call twelvehts
	mov ax,0201h
	int 13h
	mov bp,0
	pop ax
	loadnextclust:
	mov cx,ax
	mov dx,ax
	shr dx,1
	add cx,dx
	mov bx,fat
	add bx,cx
	mov dx,word[bx]
	test ax,1
	jnz odd1
	even1:
	and dx,0fffh
	jmp end
	odd1:
	shr dx,4
	end:
	mov ax,dx
	mov word [cluster],dx
	call twelvehts
	add bp,512
	mov si,file
	add si,bp
	mov bx,si
	mov ax,0201h
	int 13h
	mov dx,word [cluster]
	mov ax,dx
	cmp dx,0ff0h
	jb loadnextclust
	mov si,file
	call print_string
	jmp start
	catques1 db 'Enter file name: ', 0
	file equ 4000h
	fat equ 0ac00h
	cluster dw 0
	pointer dw 0
twelvehts:
add ax,31
push bx
push ax
mov bx,ax
mov dx,0
div word [SectorsPerTrack]
add dl,01h
mov cl,dl
mov ax,bx
mov dx,0
div word [SectorsPerTrack]
mov dx,0
div word [Sides]
mov dh,dl
mov ch,al
pop ax
pop bx
mov dl,byte [bootdev]
ret
bootdev db 0
SectorsPerTrack dw 18     
Sides dw 2    

loadsub:
push bp
mov si,catques1
call print_string
mov di,fileTodelete
mov cx,0
getloadinput:
mov ah,0
int 16h
cmp al,08
je loadrmsub
cmp al,0dh
je loadentsub
stosb
inc cx
mov ah,0eh
int 10h
jmp getloadinput
loadrmsub:
cmp cx,0
je getcatinput
mov ah,0eh
mov al,08h
int 10h
mov al,20h
int 10h
mov al,08h
int 10h
dec cx
dec di
mov byte [di], 0
jmp getloadinput
loadentsub:
mov ah,0eh
mov al,0dh
int 10h
mov al,0ah
int 10h
mov si,fileTodelete
call makeCaps
call makeFAT12
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov si,fat12str
mov di,disk_buffer
mov bx,0
mov ax,0
findfn2:
mov cx,11
cld
repe cmpsb
je foundfn2
inc bx
add ax,32
mov si,fat12str
mov di,disk_buffer
add di,ax
cmp bx,224
jle findfn2
cmp bx,224
jae filenotfound
foundfn2:
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
mov ax,word [di+1Ah]
mov word [cluster],ax
push ax
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,2
mov al,9
mov si,fat
mov bx,si
int 13h
pop ax
push ax
mov di,file
mov bx,di
call twelvehts
mov ax,0201h
int 13h
mov bp,0
pop ax
loadnextclust1:
mov cx,ax
mov dx,ax
shr dx,1
add cx,dx
mov bx,fat
add bx,cx
mov dx,word[bx]
test ax,1
jnz odd2
even2:
and dx,0fffh
jmp end1
odd2:
shr dx,4
end1:
mov ax,dx
mov word [cluster],dx
call twelvehts
add bp,512
mov si,file
add si,bp
mov bx,si
mov ax,0201h
int 13h
mov dx,word [cluster]
mov ax,dx
cmp dx,0ff0h
jb loadnextclust1
mov dl,byte [bootdev]
push ds
push es
push ss
call 4000h
pop ds
pop es
pop ss
pop bp
jmp start
executefileman:
push bp
mov ch,0
mov cl,2
mov dl,byte [bootdev]
mov dh,1
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
clc
int 13h
mov si,fileman
mov di,disk_buffer
mov bx,0
mov ax,0
findfn3:
mov cx,11
cld
repe cmpsb
je foundfn3
inc bx
add ax,32
mov si,fileman
mov di,disk_buffer
add di,ax
cmp bx,224
jle findfn3
cmp bx,225
jge filenotfound
foundfn3:
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
mov ax,word [di+1Ah]
push ax
mov ch,0
mov cl,2
mov dl,byte [bootdev]
mov dh,0
mov ah,2
mov al,9
mov si,fat
mov bx,si
clc
int 13h
pop ax
push ax
mov di,file
mov bx,di
call twelvehts
mov ax,0201h
int 13h
mov bp,0
pop ax
loadnextclust2:
mov cx,ax
mov dx,ax
shr dx,1
add cx,dx
mov bx,fat
add bx,cx
mov dx,word[bx]
test ax,1
jnz odd3
even3:
and dx,0fffh
jmp end2
odd3:
shr dx,4
end2:
mov ax,dx
mov word [cluster],dx
call twelvehts
add bp,512
mov si,file
add si,bp
mov bx,si
mov ax,0201h
int 13h
mov dx,word [cluster]
mov ax,dx
cmp dx,0ff0h
jb loadnextclust2
mov dl,byte [bootdev]
push ss
call 4000h
mov byte [bootdev],dl
pop bp
jmp shellsub
fileman db 'FILEMAN COM',0
filenotfound:
mov ah,01h
mov cx,2607h
int 10h
mov dh,8
mov dl,20
call draw_cursor
makewin:
mov ah,09h
mov al,' '
mov bh,0
mov bl,4fh
mov cx,40
int 10h
inc dh
call draw_cursor
cmp dh,14
jle makewin
mov dh,10
mov dl,28
call draw_cursor
mov si,error
call print_string
mov dh,12
mov dl,35
call draw_cursor
mov ah,09h
mov al,' '
mov bh,0
mov bl,70h
mov cx,6
int 10h
mov dh,12
mov dl,37
call draw_cursor
mov si,ok
call print_string
mov ah,00
int 16h
mov dh,23
mov dl,0
call draw_cursor
jmp start
error db 'Error: File not found!', 0
ok db 'OK', 0
SecsPerTrack dw 18
backup db 'FILEMAN COM',0
editsub:
push bp
mov ch,0
mov cl,2
mov dl,byte [bootdev]
mov dh,1
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
clc
int 13h
mov si,editor
mov di,disk_buffer
mov bx,0
mov ax,0
findfn4:
mov cx,11
cld
repe cmpsb
je foundfn3
inc bx
add ax,32
mov si,editor
mov di,disk_buffer
add di,ax
cmp bx,224
jle findfn4
cmp bx,225
jge filenotfound
foundfn4:
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
mov ax,word [di+1Ah]
push ax
mov ch,0
mov cl,2
mov dl,byte [bootdev]
mov dh,0
mov ah,2
mov al,9
mov si,fat
mov bx,si
clc
int 13h
pop ax
push ax
mov di,file
mov bx,di
call twelvehts
mov ax,0201h
int 13h
mov bp,0
pop ax
loadnextclust3:
mov cx,ax
mov dx,ax
shr dx,1
add cx,dx
mov bx,fat
add bx,cx
mov dx,word[bx]
test ax,1
jnz odd4
even4:
and dx,0fffh
jmp end4
odd4:
shr dx,4
end4:
mov ax,dx
mov word [cluster],dx
call twelvehts
add bp,512
mov si,file
add si,bp
mov bx,si
mov ax,0201h
int 13h
mov dx,word [cluster]
mov ax,dx
cmp dx,0ff0h
jb loadnextclust2
mov dl,byte [bootdev]
push ss
call 4000h
mov byte [bootdev],dl
pop bp
jmp shellsub
jmp start
editor db 'DDEDIT  COM',0