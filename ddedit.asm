;DavidDOS text editor Written by David Badiei
org 4000h
;Set boot device num
mov byte [bootdev],dl
;Turn cursor off
mov ah,01h
mov cx,2607h
int 10h
;Change bg color
mov ah,06h
xor al,al
xor cx,cx
mov dx,184fh
mov bh,01100000b
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
mov dh,7
mov dl,17
call draw_cursor
drawbox:
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
jle drawbox
mov dh,7
mov dl,17
call draw_cursor
mov si,userPrompt1
call print_string
mov dh,9
mov dl,17
call draw_cursor
mov ah,01h
mov cx,0607h
int 10h
mov cx,0
mov di,userFile
geteditinput:
mov ah,00
int 16h
cmp al,08
je editrmpress
cmp ax,3b00h
je doneprog
cmp al,0dh
je editentpress
inc cx
mov ah,0eh
int 10h
stosb
jmp geteditinput
editrmpress:
cmp cx,0
je geteditinput
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
jmp geteditinput
editentpress:
mov al,0
stosb
mov si,userFile
call makeCaps
mov si,userFile
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
cmp bx,224
jae newfile
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
pusha
mov si,file
mov di,file
add si,di
mov word [lastbyte],si
popa
continueedit:
mov ah,06h
xor al,al
xor cx,cx
mov dx,184fh
mov bh,01100000b
int 10h
xor dx,dx
call draw_cursor
mov ah,09h
mov bh,0
mov cx,80
mov bl,70h
mov al,' '
int 10h
xor dx,dx
call draw_cursor
mov si,titleProg
call print_string
mov si,titleprog2
call print_string
mov si,userFile
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
mov si,options
call print_string
mov dh,1
mov dl,0
call draw_cursor
mov si,file
mov cx,0
mov bx,0
mov byte [cursorx],0
mov byte [cursory],2
mov word [skiplines],cx
call redrawtext
keyview:
mov byte dl,[cursorx]
mov byte dh,[cursory]
call draw_cursor
mov ah,00
int 16h
cmp dl,79
je incy
cmp ah,4bh
je left
cmp ah,4dh
je right
cmp ah,50h
je down
cmp al,0dh
je enter
cmp ah,48h
je up
cmp ax,3b00h
je doneprog
call textentry
jmp keyview
doneprog:
xor dx,dx
call draw_cursor
mov dl,byte [bootdev]
pop ss
jmp 2000h:0000h
bootdev db 0
titleProg db 'DavidDOS text editor', 0
userPrompt1 db 'Enter file name:',0
options db 'F1 - Quit program F2 - Save',0
titleprog2 db ' - ',0
userFile times 11 db 0
fat12str times 11 db 0
lastbyte dw 0
cursorx db 0
cursory db 0
cursorbyte dw 0
tmp dw 0
skiplines dw 0
disk_buffer equ 9000h
file_size dw 0
file equ 9100h
cluster dw 0
fat equ 0ac00h
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
		mov si,userFile
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
	mov si,userFile
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
SectorsPerTrack dw 18     
Sides dw 2
redrawtext:
mov si,file
mov ah,0eh
call cleanblock
pusha
mov dh,2
mov dl,0
call draw_cursor
popa
mov word cx,[skiplines]
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
pusha
mov ah,03h
int 10h
mov [tmp],dx
popa
mov dx,[tmp]
cmp dh,23
je keyview
cmp dl,79
je noprint
int 10h
noprint:
cmp byte [si],0
je keyview
pusha
mov ah,03h
int 10h
mov [tmp],dx
popa
mov dx,[tmp]
cmp dh,23
je keyview
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
left:
cmp byte [cursorx],0
je keyview
dec byte [cursorx]
dec word [cursorbyte]
jmp keyview
right:
pusha
mov ah,03
int 10h
cmp dl,78
je doneeol
popa
mov word ax, [cursorbyte]
mov si,file
add si,ax
inc si
cmp word si,[lastbyte]
je keyview
dec si
cmp byte [si],0ah
je keyview
cmp byte [si],0
je keyview
inc byte [cursorx]
inc word [cursorbyte]
jmp keyview
textentry:
cmp al,8
je backspacekey
cmp ah,53h
je deletepressed
cmp ax,3c00h
je savefile
pusha
mov ah,03
int 10h
cmp dl,78
je eol
popa
call movetextforward
mov si,file
mov word dx, [cursorbyte]
add si,dx
mov byte [si],al
inc byte [cursorx]
inc word [cursorbyte]
inc word [lastbyte]
mov cx,0
call redrawtext
movetextforward:
pusha
mov si,file
add si, word [file_size]
mov di,file
add di,word [cursorbyte]
loopforward:
mov byte al,[si]
mov byte [si+1],al
dec si
cmp si,di
jl doneforward
jmp loopforward
doneforward:
inc word [file_size]
inc word [lastbyte]
popa
ret
eol:
popa
ret
doneeol:
popa
jmp keyview
incy:
mov dl,0
inc dh
mov byte [cursorx],dl
mov byte [cursory],dh
jmp keyview
backspacekey:
cmp byte [cursorx],0
je keyview
cmp word [cursorbyte],0
je keyview
dec byte [cursorx]
dec word [cursorbyte]
mov si,file
add si,word [cursorbyte]
cmp si,word [lastbyte]
je redrawtext
cmp byte [si],0Ah
jle finalcharinline
call movetextbackward
mov word cx,[skiplines]
jmp redrawtext
movetextbackward:
pusha
mov si,file
add si, word [cursorbyte]
add word [lastbyte],file
loopbackward:
mov byte al, [si+1]
mov byte [si],al
inc si
cmp word si, [lastbyte]
jne loopbackward
finishedbackward:
popa
sub word [lastbyte],file
dec word [file_size]
dec word [lastbyte]
ret
finalcharinline:
call movetextbackward
call movetextbackward
jmp redrawtext
deletepressed:
delloop:
cmp byte [cursorx],0
je donegoingleft
dec byte [cursorx]
dec word [cursorbyte]
jmp delloop
donegoingleft:
mov si,file
add si,word [cursorbyte]
inc si
cmp byte [si],0
je donedel
dec si
cmp byte [si],0dh
je finalchar
call movetextbackward
dec word [lastbyte]
jmp donegoingleft
finalchar:
call movetextbackward
call movetextbackward
jmp redrawtext
donedel:
jmp redrawtext
down:
mov word cx,[cursorbyte]
mov si,file
add si,cx
downloop:
inc si
cmp byte [si],0
je redrawtext
dec si
lodsb
inc cx
cmp al,0Ah
jne downloop
mov word [cursorbyte],cx
nowhereout:
cmp byte [cursory],22
je scrollfiledown
inc byte [cursory]
mov byte [cursorx],0
jmp redrawtext
scrollfiledown:
inc word [skiplines]
mov byte [cursorx],0
jmp redrawtext
enter:
call movetextforward
mov word cx,[cursorbyte]
mov di,file
add di,cx
mov byte [di],0dh
call movetextforward
mov word cx,[cursorbyte]
mov di,file
add di,cx
mov byte [di],0ah
jmp down
up:
pusha
mov word cx,[cursorbyte]
mov si,file
add si,cx
cmp si,file
je startoffile
cmp byte al,[si]
cmp al,0ah
je startingonnewline
jmp fullegg
startingonnewline:
cmp si,9101h
je startoffile
cmp byte [si-1],0Ah
je anothernewlinebefore
dec si
dec cx
jmp fullegg
anothernewlinebefore:
cmp byte [si-2],0Ah
jne gotostartofline
dec word [cursorbyte]
jmp displaymove
gotostartofline:
dec si
dec cx
cmp si,file
je startoffile
dec si
dec cx
cmp si,file
je startoffile
jmp loop2
fullegg:
cmp si,file
je startoffile
mov byte al,[si]
cmp al,0Ah
je foundnewline
dec cx
dec si
jmp fullegg
foundnewline:
dec si
dec cx
loop2:
cmp si,file
je startoffile
mov byte al,[si]
cmp al,0Ah
je founddone
dec cx
dec si
jmp loop2
founddone:
inc cx
mov word [cursorbyte],cx
jmp displaymove
startoffile:
mov word [cursorbyte],0
mov byte [cursorx],0
displaymove:
popa
cmp byte [cursory],2
je scrollfileup
dec byte [cursory]
mov byte [cursorx],0
jmp keyview
scrollfileup:
cmp word [skiplines],0
jle keyview
dec word [skiplines]
jmp redrawtext
newfile:
mov di,file
xor al,al
mov cx,24576
rep stosb
mov word [file_size],1
mov bx,file
mov byte [bx],0ah
inc bx
mov word [lastbyte],bx
mov cx,0
mov word [skiplines],0
mov byte [cursorx],0
mov byte [cursory],2
mov word [cursorbyte],0
mov ax,fat12str
mov word cx,[file_size]
mov bx,file
call writefile
mov word [lastbyte],1
jmp continueedit
writefile:
pusha
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,fat
mov bx,si
int 13h
call createfile
popa
mov word [location],bx
mov di,freeclusts
mov cx,128
cleanroutine:
mov word [di],0
add di,2
loop cleanroutine
getclustamount:
mov word cx,[file_size]
mov ax,cx
mov dx,0
mov bx,512
div bx
cmp dx,0
jg addaclust
jmp createentry
addaclust:
inc ax
createentry:
mov word [clustersneeded],ax
mov word bx,[file_size]
cmp bx,0
je finishwrite
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,2
mov al,9
mov si,fat
mov bx,si
int 13h
mov si,fat+3
mov word cx,[clustersneeded]
mov bx,2
mov dx,0
findcluster:
lodsw
and ax,0fffh
jz foundeven
moreodd:
inc bx
dec si
lodsw
shr ax,4
or ax,ax
jz foundodd
moreeven:
inc bx
jmp findcluster
foundeven:
push si
mov si,freeclusts
add si,dx
mov word [si],bx
pop si
dec cx
cmp cx,0
je donefind
inc dx
inc dx
jmp moreodd
foundodd:
push si
mov si,freeclusts
add si,dx
mov word [si],bx
pop si
dec cx
cmp cx,0
je donefind
inc dx
inc dx
jmp moreeven
donefind:
mov cx,0
mov word [count],1
chainloop:
mov word ax,[count]
cmp word ax,[clustersneeded]
je lastcluster
mov di,freeclusts
add di,cx
mov word bx,[di]
mov ax,bx
mov dx,0
mov bx,3
mul bx
mov bx,2
div bx
mov si,fat
add si,ax
mov ax,word [ds:si]
or dx,dx
jz even3
odd3:
and ax,000fh
mov di,freeclusts
add di,cx
mov word bx,[di+2]
shl bx,4
add ax,bx
mov word [ds:si],ax
inc word [count]
add cx,2
jmp chainloop
even3:
and ax,0f000h
mov di,freeclusts
add di,cx
mov word bx,[di+2]
add ax,bx
mov word [ds:si],ax
inc word [count]
add cx,2
jmp chainloop
lastcluster:
mov di,freeclusts
add di,cx
mov word bx,[di]
mov ax,bx
mov dx,0
mov bx,3
mul bx
mov bx,2
div bx
mov si,fat
add si,ax
mov ax, word [ds:si]
or dx,dx
jz evenlast
oddlast:
and ax,000fh
add ax,0ff80h
jmp writefat
evenlast:
and ax,0f000h
add ax,0ff8h
writefat:
mov word [ds:si],ax
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,3
mov al,9
mov si,fat
mov bx,si
int 13h
mov word [location],9100h
mov cx,0
saveloop:
mov di,freeclusts
add di,cx
mov word ax,[di]
cmp ax,0
je writerootentry
pusha
call twelvehts
mov word bx,[location]
mov ah,3
mov al,1
mov dl,byte [bootdev]
int 13h
popa
add word [location],512
inc cx
inc cx
jmp saveloop
writerootentry:
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,fat
mov bx,si
int 13h
mov di,fat
mov si,fat12str
mov bx,0
mov ax,0
findfn4:
mov cx,11
cld
repe cmpsb
je foundfn4
inc bx
add ax,32
mov si,fat12str
mov di,fat
add di,ax
cmp bx,224
jle findfn4
foundfn4:
mov ax,32
mul bx
mov di,fat
add di,ax
mov word ax,[freeclusts]
mov word [di+26],ax
mov word cx,[file_size]
mov word [di+28],cx
mov byte [di+30],0
mov byte [di+31],0
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,fat
mov bx,si
int 13h
finishwrite:
ret
clustersneeded dw 0
freeclusts times 128 dw 0
count dw 0
location dw 0
createfile:
mov di,fat
mov cx,224
findemptyrootentry:
mov byte al,[di]
cmp al,0
je foundempty
cmp al,0e5h
je foundempty
add di,32
loop findemptyrootentry
foundempty:
mov si,fat12str
mov cx,11
rep movsb
sub di,11
mov byte [di+11],0
mov byte [di+12],0
mov byte [di+13],0
mov byte [di+14],0c6h
mov byte [di+15],07eh
mov byte [di+16],0
mov byte [di+17],0
mov byte [di+18],0
mov byte [di+19],0
mov byte [di+20],0
mov byte [di+21],0
mov byte [di+22],0c6h
mov byte [di+23],07eh
mov byte [di+24],0
mov byte [di+25],0
mov byte [di+26],0
mov byte [di+27],0
mov byte [di+28],0
mov byte [di+29],0
mov byte [di+30],0
mov byte [di+31],0
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,fat
mov bx,si
int 13h
ret
savefile:
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,fat
mov bx,si
int 13h
mov di,fat
mov si,fat12str
mov bx,0
mov ax,0
findfn6:
mov cx,11
cld
repe cmpsb
je foundfn6
inc bx
add ax,32
mov si,fat12str
mov di,fat
add di,ax
cmp bx,224
jle findfn6
cmp bx,224
je continuesave
foundfn6:
mov ax,32
mul bx
mov di,fat
add di,ax
mov byte [di],229
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,fat
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
mov si,fat
mov bx,si
int 13h
pop ax
moreCluster:
mov bx,3
mul bx
mov bx,2
div bx
mov si,fat
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
mov si,fat
mov bx,si
int 13h
continuesave:
mov ax,fat12str
mov word cx,[file_size]
push bx
mov bx,9100h
call writefile
pop bx
mov word bx,[skiplines]
jmp redrawtext