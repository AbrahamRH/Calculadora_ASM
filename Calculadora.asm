Page 60, 132
Title Calculadora
.286
; ===========MACROS=========== 
CasteoACadena macro num, cadena
    mov dx, offset cadena
    push num ; Numéro a castear
    push dx ; Mas
    call castCadena
endm

ImprimirCadena macro cadena
    mov ax, offset cadena
    push ax
    call imprimeCad
endm

MoverCursor macro ren, col
    push ren ; Renglon
    push col ; Columna
    call Cursor
endm

;Macro encargada de imprimir el menu con las opciones de las operaciones 
ImprimeMenu macro cad1, cad2, cad3, ren, col
    MoverCursor ren, col
    inc ren
    ImprimirCadena cad1
    MoverCursor ren, col
    inc ren
    ImprimirCadena cad2
    MoverCursor ren, col
    ImprimirCadena cad3
    inc ren
    MoverCursor ren, col
endm

getChar macro var, charDir
    mov dx, offset var
    mov ah, 0ah
    int 21h
    mov si, dx
    mov al, [si+2]
    mov bx, offset charDir
    mov [bx], al  
endm
; ============================
.model small 
.stack 64
.data
    x dw 00
    y dw 00
    z dw 02
    temp dw 00
    opcion db 00

    bienvenida db 'Bienvenido a la calculadora de enteros / Mantisa maxima es de 65536 ','$' 
    bannerOp db 'Que operacion desea realizar? (indique con el caracter S,R,M,D) ','$' 
    opciones db 'Suma - S,  Resta - R, Multiplicacion - M, Division - D','$'
    prompt db '-> ','$'

    strSuma db 'Se realizara la suma','$'
    strResta db 'Se realizara la resta','$'
    strMulti db 'Se realizara la multiplicacion','$'
    strDivi db 'Se realizara la division','$'
    strDefault db 'Opcion no reconocida','$'

    opRealizar db 2,0,' ','$'
    renglon dw 5
    columna dw 8 ; Variables usadas para ubicar el cursor

    AsciiMas dw 00
    diez equ 10
.code
Principal proc
    assume 
    mov ax, @data
    mov ds, ax
    mov es, ax
    pusha

Inicio: 
    call clrscr
    ImprimeMenu bienvenida, bannerOp, opciones, renglon, columna ; Imprimimos el menu de opciones
    ImprimirCadena prompt
    getChar opRealizar, opcion
    call clrscr
    MoverCursor renglon, columna
Suma:
    cmp opcion, 'S'
    jne resta
    ImprimirCadena strSuma
    
Resta: 
    cmp opcion, 'R'
    jne multiplicacion
    ImprimirCadena strResta

multiplicacion: 
    cmp opcion, 'M'
    jne division
    imprimircadena strMulti

division:
    cmp opcion, 'D'
    jne default
    imprimircadena strDivi

default:
    imprimircadena strdefault



    popa
    mov ah, 04ch
    mov al,0 
    int 21h
Principal endp

clrscr proc
    mov ah,0fh;		limpia pantalla
    int 10h
    mov ah,0
    INT 10h
    ret
clrscr endp

Cursor proc
	mov bp,sp
	add bp,4
	mov dh,[bp]; renglon
	mov dl,[bp-2]; columna
	mov ah,02h  
	mov bh,00 
	int 10h ; ubicamos
	ret 4
Cursor endp

imprimeCad proc
	mov bp,sp
	add bp,02	
	mov dx,[bp] ; obteniendo la dir de la cadena a imprimir
	mov ah,09h
	int 21h
	ret 2
imprimeCad endp

imprimeCar proc
    mov bp, sp
    add bp, 02
    xor ax, ax
    mov al, [bp] ; Caracter a imprimir
    mov ah, 09h
    mov bh, 00
    mov cx, 1
    int 10h
    ret 2
imprimeCar endp

castCadena proc
    mov bp, sp
    add bp, 04
    mov ax, [bp]   ; Numero a castear
    mov si, [bp-2] ; Mas
    mov bl, diez
    mov cx, 4
    casteo:
        div bl
        mov temp, cx
        mov [si], al ; Más significativo 
        xor ah, 030h
        xor dx, dx
        mov dl, ah
        push dx 
        call imprimeCar
        dec columna
        ;Ubicamos el cursor
        push renglon ; renglon
        push columna ; columna
        call Cursor
        mov cx, temp
        mov ax, [si]
    loop casteo
    ret 4
castCadena endp

end Principal