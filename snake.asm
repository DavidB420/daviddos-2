;Snake game for DavidDOS By David Badiei
org 4000h
;Change Video mode to VGA 320x200
mov ah,0
mov al,13h
int 10h
;Set background
mov ax,0A000h
mov es,ax
mov cx,0xffff
loopbg:
mov bx,cx
mov byte [es:bx],0x0a
loop loopbg
;Spawn player
mov byte [playerColor],4
call spawnplayer
;Show Score
call printscore
;Spawn fruit
mov byte [fruitColor],0ch
call spawnfruit
;Wait for keypress
userInput:
mov ah,1
int 16h
jz keepgoin
mov ah,0
int 16h
jmp updateplayer
keepgoin:
mov ah,byte [lastmove]
updateplayer:
pusha
call printscore
popa
cmp ah,4bh
je left
cmp ah,4dh
je right
cmp ah,50h
je down
cmp al,1bh
je doneprog
cmp ah,48h
jne keepgoin
up:
mov byte [playerColor],0x0a
call spawnplayer
sub word [y1],4
sub word [y2],4
mov byte [playerColor],0x04
call spawnplayer
mov byte [lastmove],48h
jmp upcheck
down:
mov byte [playerColor],0x0a
call spawnplayer
add word [y1],4
add word [y2],4
mov byte [playerColor],0x04
call spawnplayer
mov byte [lastmove],50h
jmp downcheck
left:
mov byte [playerColor],0x0a
call spawnplayer
sub word [x1],4
sub word [x2],4
mov byte [playerColor],0x04
call spawnplayer
mov byte [lastmove],4bh
jmp leftcheck
right:
mov byte [playerColor],0x0a
call spawnplayer
add word [x1],4
add word [x2],4
mov byte [playerColor],0x04
call spawnplayer
mov byte [lastmove],4dh
jmp rightcheck
moveplayer:
mov cx,1
mov dx,86A0h
mov ah,86h
int 15h
jmp userInput
;Return Video mode back to text mode
doneprog:
mov ah,0
mov al,3
int 10h
ret

x1 dw 160
y1 dw 100

x2 dw 165
y2 dw 105

scoreStr db 'Score:',0
lastmove db 0x4d
playerColor db 0
score db 0
fruitColor db 0
twoplusone dw 0
fruitx dw 0
fruity dw 0

spawnplayer:
mov dx,[y1]
loopsqr1:
mov cx,[x1]
loopsqr2:
mov ah,0ch
mov al,byte [playerColor]
int 10h
inc cx
cmp cx,[x2]
jle loopsqr2
inc dx
cmp dx,[y2]
jle loopsqr1
ret

printscore:
mov dx,0
mov ah,02h
int 10h
mov si,scoreStr
call print_string
xor ah,ah
mov al,byte [score]
call inttostr
ret

print_string:
mov ah,0eh
loopprint:
lodsb
test al,al
jz doneprint
mov bl,6
int 10h
jmp loopprint
doneprint:
ret

spawnfruit:
call seedrand
mov ax,0
mov bx,197
call getrand
mov dx,cx
mov cx,50
mov word [fruity],dx
mov word [fruitx],cx
inc word [fruitx]
loopfruit1:
mov ah,0ch
mov al,byte [fruitColor]
int 10h
inc cx
cmp cx,word [fruitx]
jle loopfruit1
sub word [fruitx],2
mov cx,word [fruitx]
add word [fruitx],3
inc dx
loopfruit2:
mov ah,0ch
mov al,byte [fruitColor]
int 10h
inc cx
cmp cx,word [fruitx]
jle loopfruit2
sub word [fruitx],3
mov cx,word [fruitx]
add word [fruitx],3
inc dx
loopfruit3:
mov ah,0ch
mov al,byte [fruitColor]
int 10h
inc cx
cmp cx,word [fruitx]
jle loopfruit3
sub word [fruitx],2
mov cx,word [fruitx]
inc word [fruitx]
inc dx
loopfruit4:
mov ah,0ch
mov al,byte [fruitColor]
int 10h
inc cx
cmp cx,word [fruitx]
jle loopfruit4
sub word [fruitx],2
ret

clearfruit:
mov ax,0A000h
mov es,ax
xor di,di
xor si,si
mov cx,0
loopclear:
lodsb
cmp al,0ch
je foundit
continueit:
inc cx
cmp cx,0xffff
je doneclear
jmp loopclear
doneclear:
ret
foundit:
dec si
mov al,0ah
stosb
jmp continueit

upcheck:
push cx
mov cx,word [x2]
mov word [twoplusone],cx
inc word [twoplusone]
pop cx
mov cx,word [x1]
mov dx,word [y1]
dec dx
uploop:
mov ah,0dh
int 10h
cmp al,0ch
je hitfruit
inc cx
cmp cx,word [twoplusone]
je moveplayer
jmp uploop

downcheck:
push cx
mov cx,word [x2]
mov word [twoplusone],cx
inc word [twoplusone]
pop cx
mov cx,word [x1]
mov dx,word [y2]
inc dx
downloop:
mov ah,0dh
int 10h
cmp al,0ch
je hitfruit
inc cx
cmp cx,word [twoplusone]
je moveplayer
jmp downloop

leftcheck:
push cx
mov cx,word [y2]
mov word [twoplusone],cx
inc word [twoplusone]
pop cx
mov cx,word [x1]
mov dx,word [y1]
dec cx
leftloop:
mov ah,0dh
int 10h
cmp al,0ch
je hitfruit
inc dx
cmp dx,word [twoplusone]
je moveplayer
jmp leftloop

rightcheck:
push cx
mov cx,word [y2]
mov word [twoplusone],cx
inc word [twoplusone]
pop cx
mov cx,word [x2]
mov dx,word [y1]
inc cx
rightloop:
mov ah,0dh
int 10h
cmp al,0ch
je hitfruit
inc dx
cmp dx,word [twoplusone]
je moveplayer
jmp rightloop

inttostr:
pusha
mov cx,0
mov bx,10
pushit:
xor dx,dx
div bx
inc cx
push dx
test ax,ax
jnz pushit
popit:
pop dx
add dl,30h
pusha
mov al,dl
mov ah,0eh
mov bl,6
int 10h
popa
inc di
dec cx
jnz popit
popa
ret

hitfruit:
call clearfruit
inc byte [score]
call printscore
jmp moveplayer

seedrand:
push bx
push ax
mov bx,0
mov al,02h
out 70h,al
in al,71h
mov bl,al
mov word [randseed],bx
pop ax
pop bx
ret
randseed dw 0

getrand:
push dx
push bx
push ax
sub bx,ax
call genrand
mov dx,bx
add dx,1
mul dx
mov cx,dx
pop ax
pop bx
pop dx
add cx,ax
ret

genrand:
push dx
push bx
mov ax, word [randseed]
mov dx,7383h
mul dx
mov word [randseed],ax
pop bx
pop dx
ret
