TITLE
.model small
.data
    MSG1 DB 'Primeiro valor: ','$'
    MSG2 DB 10,'Operacao : ','$'
    MSG3 DB 10,'Segundo valor: ','$'
    MSG4 DB 10,10,'Resultado: ','$'
.code
main proc
    MOV AX,@DATA
    MOV DS,AX

    LEA DX,MSG1
    MOV AH,09
    INT 21H

    MOV AH,01
    INT 21H ; leitura do primeiro numero
    SUB AL,30H
    MOV BL,AL

    LEA DX,MSG2
    MOV AH,09
    INT 21H 

    MOV AH,01
    INT 21H ; leitura da operação

    MOV CL,AL

    LEA DX,MSG3
    MOV AH,09
    INT 21H

    MOV AH,01
    INT 21H ; leitura do segundo numero

    SUB AL,30H
    MOV BH,AL

    CMP CL,'+'
    JZ SOMA
    CMP CL,'-'
    JZ SUBT
    CMP CL,'/'
    JZ DIVI
    CMP CL,'*'
    JZ MULT

SOMA:
    ADD BH,BL
    CMP BH,0AH
    JGE RESP2
    ADD BH,30H
    JMP RESP
SUBT:
    CMP BL,BH
    JB NEGA
    SUB BL,BH
    ADD BL,30H
    MOV BH,BL
    JMP RESP
    NEGA:
        SUB BH,BL
        LEA DX,MSG4
        MOV AH,09
        INT 21H
        MOV DL,'-'
        MOV AH,02
        INT 21H
        MOV DL,BH
        ADD DL,30H
        INT 21H
        JMP FIM
DIVI:
    
MULT:
    DEC BH
    MOV CH,BL
    MULT2:
        ADD BL,CH
        DEC BH
        JNZ MULT2
    MOV BH,BL
    CMP BH,0AH
    JGE RESP2
    ADD BH,30H
    
RESP:
    LEA DX,MSG4
    MOV AH,09
    INT 21H
    MOV DL,BH
    MOV AH,02
    INT 21H
    JMP FIM
RESP2:
    XOR AX,AX
    MOV AL,BH
    MOV BH,10D
    DIV BH
    MOV BH,AH
    MOV BL,AL
    LEA DX,MSG4
    MOV AH,09
    INT 21H
    MOV DL,BL
    ADD DL,30H
    MOV AH,02
    INT 21H
    MOV DL,BH
    ADD DL,30H
    INT 21H
FIM:
    MOV AH,4CH
    INT 21H
main endp
END main