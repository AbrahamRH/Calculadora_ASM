; Autor: Ramírez Hernández Abraham
; Fecha de termino: 01/02/21
; Descripción: Este programa realiza operaciones aritmeéticas básicas tales como
;              La suma, resta, división y multiplicación de números enteros.
;              Es programa recibe los valores a operar por el teclado y se muestran los resultados y opciones 
;              en pantalla por un menú.
; Versión del ensamblador: Turbo Assembler version 4.1
; Comandos de ensamblado y enlazado: 
;    TASM.EXE CALCULADORA
;    TLINK.EXE CALCULADORA
;

Page 60, 132
Title Calculadora
.286
; ===========MACROS=========== 
CasteoACadena macro num, cadena
    ;Obtenemos posición del cursor
    mov ah, 03h
    mov bh, 00
    int 10h
    xor ax, ax
    mov al, dl
    ; la posición la guardamos en las variables renglon y columna
    mov columna, ax
    mov al, dh
    mov renglon, ax
    mov dx, offset cadena
    push num ; Numéro a castear
    push dx ; AsciiMas
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

continue macro cad
    MoverCursor 15, 22
    ImprimirCadena cad
    mov ah, 08h
    int 21h
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

;Macro para obtener un caracter
getChar macro var, charDir
    mov dx, offset var
    mov ah, 0ah
    int 21h ; Leemos el caracter de la pantalla
    mov si, dx
    mov al, [si+2] ; Obtenemos el caracter y lo guardamos en al
    mov bx, offset charDir
    mov [bx], al   ; Guardamos el caracter en la direccion de la variable
endm

;Macro para castear de cadena a numero
getNum macro var, num
    mov ah, 0ah
    mov dx, offset var
    int 21h
    mov di, offset num
    push dx ; cadRec
    push di ; numero
    call castNum
endm

IngresaNum macro banner, prompt, var, num
    mov ax, 00
    mov num, ax
    ImprimirCadena banner
    ImprimirCadena prompt
    getNum var, num ; Guardamos el numero
endm

IniciaPantalla macro ren, col
    call clrscr
    call setFondo
    call setCuadro
    mov ren, 5
    mov col, 8
    MoverCursor ren, col
endm
; ============================
.model small 
.stack 64
.data
    x dw 00 ;  Numero 1 a recibir
    y dw 00 ;  Numero 2 a recibir
    z dw 00 ; Resultado
    temp dw 00
    opcion db 00

    ; Variables utilizadas para el casteo a numero
    numCad db 6,0,'       '  ; Variable para recibir los numeros a operar
    ;  Se permite una mantisa de 2^16 unicamente 
    caracteres db 00 ; Es el número de caracteres introducidos
    potencia db 00


    bienvenida db 'Bienvenido a la calculadora de enteros / Mantisa maxima es de 65536 ','$' 
    bannerOp db 'Que operacion desea realizar? (indique con el caracter S,R,M,D) ','$' 
    opciones db 'Suma - S,  Resta - R, Multiplicacion - M, Division - D','$'
    prompt db '-> ','$'

    bannerOp2 db 'Desea realizar otra operacion?   Si - 1','$'
    opciones2 db '(Si no desea otra operacion introduzca otro caracter)','$'

    strcontinue db 'Presione una tecla para continuar...','$'
    strSuma db 'Se realizara la suma','$'
    strResta db 'Se realizara la resta','$'
    strMulti db 'Se realizara la multiplicacion','$'
    strDivi db 'Se realizara la division','$'
    strDefault db 'Opcion no reconocida','$'
    strResultado db 'El resultado es:      ','$'
    strResiduo db 'El residuo es:      ','$'
    strDesborde db 'Hubo un desbordamiento, la mantisa es de 65,535 ','$'
    strDesbordeRes db 'Hubo un desbordamiento, la mantisa es de 32,768 ','$'
    strSigno db '-     ','$'
    ingresarNum db 'Ingresa un numero a operar ','$'


    opRealizar db 2,0,' ','$'
    renglon dw 5
    columna dw 8 ; Variables usadas para ubicar el cursor

    AsciiMas dw 00
    diez equ 10

    ;Caracteres para imprimir el cuadro
    esquina db '+','$'
    vertical db '|','$'
    horizontal db '-','$'
    estaDibujado db 00 ; Variable que nos sirve para identificar si se dibujo
    
.code
Principal proc
    assume 
    mov ax, @data
    mov ds, ax
    mov es, ax

Inicio: 
    pusha
    IniciaPantalla renglon, columna
    ; Imprimimos el menu de opciones
    ImprimeMenu bienvenida, bannerOp, opciones, renglon, columna
    ImprimirCadena prompt
    getChar opRealizar, opcion ; Obtenemos la opcion por el teclado
    IniciaPantalla renglon, columna
    MoverCursor renglon, columna
    inc renglon
Suma:
    cmp opcion, 'S'
    jne intermedioSuma
    ;Obtenemos los dos números
    ImprimirCadena strSuma
    MoverCursor renglon, columna
    IngresaNum ingresarNum, prompt, numCad, x ;  Guardamos el num en X
    inc renglon
    MoverCursor renglon, columna
    jmp mitadSuma
    intermedioSuma: 
        jmp resta
    mitadSuma:
    IngresaNum ingresarNum, prompt, numCad, y ;  Guardamos el num en y
    inc renglon
    MoverCursor renglon, columna
    ImprimirCadena strResultado
    mov ax, x 
    add ax, y
    jc desSuma ; Se verifica que no exista un desborde
    mov z, ax
    CasteoACadena z, AsciiMas
    continue strcontinue
    jmp otraOp    
    desSuma: ;Si hay un desborde se avisa y se pregunta si se quiere otra operación
    imprimirCadena strDesborde
    continue strcontinue
    jmp otraOp    
Resta: 
    cmp opcion, 'R'
    jne intermedioResta
    ImprimirCadena strResta
    MoverCursor renglon, columna
    IngresaNum ingresarNum, prompt, numCad, x ;  Guardamos el num en X
    inc renglon
    MoverCursor renglon, columna
    jmp mitadResta
    intermedioResta:
        jmp multiplicacion
    mitadResta:
    IngresaNum ingresarNum, prompt, numCad, y ;  Guardamos el num en y
    inc renglon
    MoverCursor renglon, columna
    ImprimirCadena strResultado
    mov ax, x 
    sub ax, y
    jns positivo
    ;Hacemos el complemento a 2 si el resultado es negativo
    not ax
    add ax, 1
    cmp ax, 8000h
    ja desResta ; verificamos si no hay desborde despues del complemento a 2
    pusha
    ImprimirCadena strSigno
    popa
    positivo: ;Si es positivo saltamos
    cmp ax, 8000h
    ja desResta ; verificamos si no hay desborde
    mov z, ax
    CasteoACadena z, AsciiMas
    continue strcontinue
    jmp otraOp    
    desResta: ;Si hay un desborde se avisa y se pregunta si se quiere otra operación
    imprimirCadena strDesbordeRes
    continue strcontinue
    jmp otraOp    
multiplicacion: 
    cmp opcion, 'M'
    jne intermedioMulti
    imprimircadena strMulti
    MoverCursor renglon, columna
    IngresaNum ingresarNum, prompt, numCad, x ;  Guardamos el num en X
    inc renglon
    MoverCursor renglon, columna
    jmp mitadMulti
    intermedioMulti:
        jmp division
    mitadMulti:
    IngresaNum ingresarNum, prompt, numCad, y ;  Guardamos el num en y
    inc renglon
    MoverCursor renglon, columna
    ImprimirCadena strResultado
    mov ax, x 
    mul y
    jo desMulti
    mov z, ax
    CasteoACadena z, AsciiMas
    continue strcontinue
    jmp otraOp    
    desMulti: ;Si hay un desborde se avisa y se pregunta si se quiere otra operación
    imprimirCadena strDesborde
    continue strcontinue
    jmp otraOp    
division:
    cmp opcion, 'D'
    jne intermedioDiv
    imprimircadena strDivi
    MoverCursor renglon, columna
    IngresaNum ingresarNum, prompt, numCad, x ;  Guardamos el num en X
    inc renglon
    MoverCursor renglon, columna
    cmp temp, 1 ; Bandera para saber si hubo un desbordamiento
    je desDiv ; Saltamos si hay un desborde que se verifica si se paso la mantisa de 2^15
    jmp mitadDiv
    intermedioDiv:
        jmp default
    desDiv: ;Si hay un desborde se avisa y se pregunta si se quiere otra operación
        imprimirCadena strDesbordeRes
        continue strcontinue
        jmp otraOp    
    mitadDiv:
    IngresaNum ingresarNum, prompt, numCad, y ;  Guardamos el num en d
    inc renglon
    MoverCursor renglon, columna
    ImprimirCadena strResultado
    mov dx, 00h
    mov ax, x 
    mov bx, y; División con mantisa 2^15
    div bx
    mov z, ax ; Cociente
    mov x, dx ; Residuo
    CasteoACadena z, AsciiMas
    inc renglon
    mov columna, 8
    MoverCursor renglon, columna
    ImprimirCadena strResiduo
    CasteoACadena x, AsciiMas
    continue strcontinue
    jmp otraOp   
default:
    imprimircadena strdefault
    continue strcontinue
OtraOp:
    IniciaPantalla renglon, columna
    inc renglon
    MoverCursor renglon, columna
    inc renglon
    ImprimirCadena bannerOp2
    MoverCursor renglon, columna
    inc renglon
    ImprimirCadena opciones2
    MoverCursor renglon, columna
    inc renglon
    ImprimirCadena prompt
    getChar opRealizar, opcion
    popa
    xor opcion, 030h
    cmp opcion,1
    jne Fin 
    jmp Inicio
Fin:
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

setFondo proc
    ; Cambiamos el color 
    mov ah, 06h
    mov al, 00h
    mov bh, 2fh ; Fondo verde con letras blancas
    mov cx, 00h
    mov dx, 2080h ; Filas y columnas
    int 10h
    ret
setFondo endp

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
    mov bx, diez
    mov cx, 5
    casteo:
        mov dx, 0h
        div bx
        mov temp, cx
        mov [si], ax ; Más significativo 
        xor dl, 030h ; Obtenemos el digito
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

castNum proc
    mov bp, sp
    add bp, 04
    mov si, [bp] ; Dir CadRec
    mov di, [bp-2]
    inc si
    mov temp, 0
    mov bl, [si]
    mov caracteres, bl
    mov potencia, bl
    xor cx, cx
    mov bx, diez
    castNumero:
        inc si
        dec potencia
        xor ax, ax
        mov al, [si]
        xor al, 030h
        mov cl, potencia
        obtenerPotencia: ; Obtiene la potencia de 10^n para posicionar el digito
            cmp cl, 0
            je continuar
            mul bx
            loop obtenerPotencia
        continuar:
        add [di], ax
        cmp dx, 0
        jz sigue
        mov temp, 1; Usamos una bandera para ver cuando sobrepasa la mantisa
        sigue:
        mov cl, caracteres
        dec caracteres
        loop castNumero
    ret 4
castNum endp

setCuadro proc
    mov renglon, 3
    mov columna, 4
    mov estaDibujado, 0
    lineaHorizontal: ; Imprimimos las lineas horizontales del recuadro
        mov cx,  73
        filas:
            MoverCursor renglon, columna
            inc columna
            ImprimirCadena horizontal
            loop filas
    inc estaDibujado ; En la primera vuelta estaDibujado = 1
    cmp estaDibujado, 1
    jne lineaVertical ; Si no es 1 (segunda vuelta) nos mantenemos en la misma columna
    sub columna, 73
    lineaVertical: ; Imprimimos las lineas verticales
        mov cx, 20
        columnas:
            MoverCursor renglon, columna
            cmp estaDibujado, 1 ; Si es la segunda vuelta, nos movemos arriba
            je haciaAbajo
            dec renglon
            jmp sigueImpresion
            haciaAbajo:
            inc renglon
            sigueImpresion:
            imprimircadena vertical
            loop columnas
    cmp estaDibujado, 1
    je lineaHorizontal ;Dibujamos la linea horizontal inferior
    ret
setCuadro endp

end Principal