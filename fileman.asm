;DavidDOS graphical file manager By David Badiei
org 4000h
mov byte [bootdev],dl
start:
;Turn cursor off
mov ah,01h
mov cx,2607h
int 10h
;Fill bg
mov ah,06h
xor al,al
xor cx,cx
mov dx,184fh
mov bh,2fh
int 10h
;make top bar
xor dx,dx
call draw_cursor
mov ah,09h
mov bh,0
mov cx,80
mov bl,70h
mov al,' '
int 10h
mov si,titleProg
call print_string
xor dx,dx
call draw_cursor
mov si,titleProg
call print_string
;make bottom bar
mov dh,24
mov dl,0
call draw_cursor
mov ah,09h
mov bh,0
mov cx,80
mov bl,70h
mov al,' '
int 10h
mov dh,24
mov dl,0
call draw_cursor
mov si,bottomProg
call print_string
;Make middle box
mov dh,7
mov dl,17
call draw_cursor
drawbox:
mov ah,09h
mov bh,0
mov cx,40
mov bl,4fh
mov al,' '
int 10h
inc dh
call draw_cursor
cmp dh,11
jle drawbox
mov dh,7
mov dl,17
call draw_cursor
mov si,titleBox
call print_string
;Output intial options
mov dh,8
mov dl,17
call draw_cursor
call drawlist
;Bar code
mov dh,8
mov dl,17
call draw_cursor
call drawbar
mov si,option1
call print_string
;Get user input
userInput:
mov ah,00
int 16h
cmp ax,3b00h
je doneprog
cmp ah,48h
je uparrow
cmp ah,50h
je downarrow
cmp al,0dh
je enter
jmp userInput
uparrow:
cmp dh,8
je userInput
dec dh
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,0xf0
mov al,' '
int 10h
add dh,1
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,4fh
mov al,' '
int 10h
sub dh,1
call draw_cursor
push dx
mov dh,8
mov dl,17
call draw_cursor
pop dx
mov ch,dh
mov cl,dl
call draw_cursor
mov dh,8
mov dl,17
call draw_cursor
call drawlist
mov dh,ch
mov dl,cl
call draw_cursor
jmp userInput
downarrow:
cmp dh,11
je userInput
inc dh
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,0xf0
mov al,' '
int 10h
sub dh,1
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,4fh
mov al,' '
int 10h
add dh,1
call draw_cursor
mov ch,dh
mov cl,dl
mov dh,8
mov dl,17
call draw_cursor
call drawlist
mov dh,ch
mov dl,cl
call draw_cursor
jmp userInput
drawbar:
mov ah,09h
mov bh,0
mov cx,40
mov bl,70h
mov al,' '
int 10h
ret
drawlist:
mov si,option1
call print_string
inc dh
call draw_cursor
mov si,option2
call print_string
inc dh
call draw_cursor
mov si,option3
call print_string
inc dh
call draw_cursor
mov si,option4
call print_string
ret
enter:
cmp dh,8
je listfiles
cmp dh,9
je deletefile
cmp dh,10
je renamefile
cmp dh,11
je viewfile
jmp doneprog
doneprog:
xor dx,dx
call draw_cursor
mov dl,byte [bootdev]
pop ss
jmp 2000h:0000h
titleProg db 'DavidDOS File manager', 0
bottomProg db 'F1 - exit file manager', 0
titleBox db 'Please select an option:', 0
option1 db 'List files', 0
option2 db 'Delete file          ', 0
option3 db 'Rename file', 0
option4 db 'View file contents',0
disk_buffer equ 9000h
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
draw_cursor:
		mov bh,0
		mov ah,2
		int 10h
		ret
listfiles:
xor dx,dx
call draw_cursor
mov si,files
call print_string
mov dh,24
mov dl,0
call draw_cursor
mov ah,09h
mov bh,0
mov cx,80
mov bl,4fh
mov al,' '
int 10h
mov dh,24
mov dl,0
call draw_cursor
mov si,spacer
call print_string
mov dh,1
mov dl,0
drawlistbox:
call draw_cursor
mov ah,09h
mov bh,0
mov cx,80
mov bl,4fh
mov al,' '
int 10h
inc dh
cmp dh,23
jle drawlistbox
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov dh,1
mov dl,0
call draw_cursor
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
cmp cx,11
je donereadfn
jmp readroot
exitdir:
mov ah,00
int 16h
jmp start
files db 'Files:                ', 0
spacer db '                      ', 0
skipfn:
add si,31
jmp readroot
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

deletefile:
xor dx,dx
call draw_cursor
mov si,option2
call print_string
mov dh,24
mov dl,0
call draw_cursor
mov si,spacer
call print_string
mov dh,7
mov dl,17
drawbox1:
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,4fh
mov al,' '
int 10h
inc dh
call draw_cursor
cmp dh,11
jle drawbox1
mov dh,7
mov dl,17
call draw_cursor
mov si,userPrompt1
call print_string
mov dh,9
mov dl,17
call draw_cursor
mov ah,1
mov cx,0607h
int 10h
mov di,userDel
mov cx,0
getdelinput:
mov ah,00
int 16h
cmp al,08
je delrmpress
cmp ax,3b00h
je doneprog
cmp al,0dh
je delentpress
inc cx
mov ah,0eh
int 10h
stosb
jmp getdelinput
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
mov si,userDel
call makeCaps
mov si,userDel
call makeFAT12
pusha
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
userPrompt1 db 'Enter file name:',0
userDel times 11 db 0
fat12str times 11 db 0
tmp dw 0
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
		mov si,userDel
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
getStringlength:
	mov si,userDel
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
renamefile:
xor dx,dx
call draw_cursor
mov si,rename
call print_string
mov dh,24
mov dl,0
call draw_cursor
mov si,spacer
call print_string
mov dh,7
mov dl,17
call draw_cursor
drawbox11:
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,4fh
mov al,' '
int 10h
inc dh
call draw_cursor
cmp dh,11
jle drawbox11
mov dh,7
mov dl,17
call draw_cursor
mov si,userPrompt2
call print_string
mov dh,9
mov dl,17
call draw_cursor
mov ah,1
mov cx,0607h
int 10h
mov cx,0
mov di,userDel
getreninput1:
mov ah,00
int 16h
cmp al,08
je renrmpress
cmp ax,3b00h
je doneprog
cmp al,0dh
je renentpress
inc cx
mov ah,0eh
int 10h
stosb
jmp getreninput1
renrmpress:
cmp cx,0
je getreninput1
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
jmp getreninput1
renentpress:
mov si,userDel
call makeCaps
mov si,userDel
call makeFAT12
mov dh,7
mov dl,17
call draw_cursor
drawbox21:
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,4fh
mov al,' '
int 10h
inc dh
call draw_cursor
cmp dh,11
jle drawbox21
mov dh,7
mov dl,17
call draw_cursor
mov si,userPrompt3
call print_string
mov dh,9
mov dl,17
call draw_cursor
mov ah,1
mov cx,0607h
int 10h
mov di,userRen
mov cx,0
getreninput2:
mov ah,00
int 16h
cmp al,08
je renrmpress1
cmp ax,3b00h
je doneprog
cmp al,0dh
je renentpress1
inc cx
mov ah,0eh
int 10h
stosb
jmp getreninput2
renrmpress1:
cmp cx,0
je getreninput1
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
jmp getreninput1
renentpress1:
mov si,userRen
call makeCaps
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
jmp start
rename db 'Rename file          ', 0
userPrompt2 db 'Enter old file name:', 0
userPrompt3 db 'Enter new file name:', 0
userRen times 11 db 0
fat12str1 times 11 db 0
makerenFAT12:
		call getrenStringlength
		mov si,userRen
		mov di,fat12str1
		mov cx,0
		mov dh,0
		mov bx,di
		copytonewstr1:
		lodsb
		cmp al,'.'
		je extfound1
		stosb
		inc cx
		jmp copytonewstr1
		extfound1:
		cmp cx,8
		je addext1
		addspaces1:
		mov byte [di],' '
		inc di
		inc cx
		cmp cx,8
		jl addspaces1
		addext1:
		lodsb
		stosb
		lodsb
		stosb
		lodsb
		stosb
		mov al,0
		stosb
		ret
getrenStringlength:
	mov si,userRen
	mov dl,0
	loopstrlength1:
	cmp byte [si],0
	jne inccounter1
	cmp byte [si],0
	je donestrlength1
	jmp loopstrlength1
	inccounter1:
	inc dl
	inc si
	jmp loopstrlength
	donestrlength1:
	ret
viewfile:
xor dx,dx
call draw_cursor
mov si,viewer
call print_string
mov si,spacer
call print_string
mov dh,24
mov dl,0
call draw_cursor
mov si,spacer
call print_string
mov dh,7
mov dl,17
call draw_cursor
drawbox3:
call draw_cursor
mov ah,09h
mov bh,0
mov cx,40
mov bl,4fh
mov al,' '
int 10h
inc dh
call draw_cursor
cmp dh,11
jle drawbox3
mov dh,7
mov dl,17
call draw_cursor
mov si,userPrompt1
call print_string
mov dh,9
mov dl,17
call draw_cursor
mov ah,1
mov cx,0607h
int 10h
mov cx,0
mov di,userDel
getviewinput:
mov ah,00
int 16h
cmp al,08
je viewrmpress
cmp ax,3b00h
je doneprog
cmp al,0dh
je viewentpress
inc cx
mov ah,0eh
int 10h
stosb
jmp getviewinput
viewrmpress:
cmp cx,0
je getviewinput
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
jmp getviewinput
viewentpress:
mov si,userDel
call makeCaps
mov si,userDel
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
push ax
mov ax,word [di+1ch]
mov word[file_size],ax
pop ax
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
jmp fileviewer
viewer db 'Viewer', 0
instructions db 'Use arrow keys to move up and down and F1 to return to main menu', 0
file_size dw 0
file equ 9100h
cluster dw 0
fat equ 0ac00h
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
fileviewer:
mov ah,01h
mov cx,2607h
int 10h
mov ah,06h
xor al,al
xor cx,cx
mov dx,184fh
mov bh,00110000b
int 10h
xor dx,dx
call draw_cursor
xor dx,dx
call draw_cursor
mov ah,09h
mov bh,0
mov cx,80
mov bl,70h
mov al,' '
int 10h
mov si,viewer
call print_string
xor dx,dx
call draw_cursor
mov si,viewer
call print_string
mov dh,24
mov dl,0
call draw_cursor
mov ah,09h
mov bh,0
mov cx,80
mov bl,70h
mov al,' '
int 10h
mov dh,24
mov dl,0
call draw_cursor
mov si,instructions
call print_string
mov dh,2
mov dl,0
call draw_cursor
mov si,file
mov cx,0
mov bx,0
mov word [skiplines],cx
jmp redrawtext
exitviewloop:
mov word [skiplines],0
mov cx,0
mov si,file
mov bx,0
keyview:
mov ah,00
int 16h
cmp ah,48h
je uparrowview
cmp ah,50h
je downarrowview
cmp ax,3b00h
je start
jmp keyview
uparrowview:
cmp word [skiplines],0		
jle keyview
mov bx,0
dec word [skiplines]		
mov word cx,[skiplines]
jmp redrawtext
downarrowview:
cmp bx,0
jne keyview
inc word [skiplines]
mov word cx,[skiplines]
jmp redrawtext
skiplines dw 0
redrawtext:
mov si,file
mov ah,0eh
call cleanblock
pusha
mov dh,2
mov dl,0
call draw_cursor
popa
redraw:
cmp cx,0
je loopy
dec cx
redrawfuck:
lodsb
cmp al,10
jne redrawfuck
jmp redraw
loopy:
lodsb
cmp al,10
jne skipreturn
pusha
mov ah,03h
int 10h
mov dl,0
call draw_cursor
popa
skipreturn:
int 10h
cmp byte [si], 0
je finished
pusha
mov ah,03h
int 10h
cmp dh,23
je keyview
popa
jmp loopy
cleanblock:
pusha
mov dh,2
mov dl,0
call draw_cursor
cleanloop:
mov ah,0eh
mov al,' '
int 10h
mov ah,3
int 10h
cmp dh,23
je doneclean
jmp cleanloop
doneclean:
popa
ret
finished:
mov bx,1
jmp keyview