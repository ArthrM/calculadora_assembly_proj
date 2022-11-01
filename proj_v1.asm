TITLE
.model small
.data
    MSG1 DB 'Primeiro valor: ','$'
    MSG2 DB 'Operacao : ','$'
    MSG3 DB 'Segundo valor: ','$'
    MSG4 DB 10,10,'Resultado: ','$'
    MSG5 DB 10,'!Invalido! - ','$'
.code
main proc
    MOV AX,@DATA
    MOV DS,AX

NUM1:
    LEA DX,MSG1
    MOV AH,09
    INT 21H
    
    MOV AH,01
    INT 21H ; leitura do primeiro numero
    MOV CH,30H
    VALNUM1:
        CMP AL,CH
        JZ GOODNUM1
        INC CH
        CMP CH,3AH
        JNZ VALNUM1

    LEA DX,MSG5
    MOV AH,09
    INT 21H
    JMP NUM1
GOODNUM1:
    SUB AL,30H
    MOV BL,AL
    MOV AH,02
    MOV DL,10
    INT 21H
OPSELECT:
    LEA DX,MSG2
    MOV AH,09
    INT 21H 

    MOV AH,01
    INT 21H ; leitura da operacao

    CMP AL,'+'
    JZ VALIDOP
    CMP AL,'-'
    JZ VALIDOP
    CMP AL,'/'
    JZ VALIDOP
    CMP AL,'*'
    JZ VALIDOP

    LEA DX,MSG5
    MOV AH,09
    INT 21H
    JMP OPSELECT
VALIDOP:
    MOV CL,AL
    MOV AH,02
    MOV DL,10
    INT 21H
NUM2:
    LEA DX,MSG3
    MOV AH,09
    INT 21H

    MOV AH,01
    INT 21H ; leitura do segundo numero
    MOV CH,30H
    VALNUM2:
        CMP AL,CH
        JZ GOODNUM2
        INC CH
        CMP CH,3AH
        JNZ VALNUM2

    LEA DX,MSG5
    MOV AH,09
    INT 21H
    JMP NUM2
GOODNUM2:
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
    JMP RESP
SUBT:
    SUB BL,BH
    MOV BH,BL
    JMP RESP
DIVI:
    
MULT:
    XOR CL,CL
    VOLTAMULT:
        TEST BH,01H
        JE PULAMULT
        ADD CL,BL
        PULAMULT:
            SHL BL,1
            SHR BH,1
            JNZ VOLTAMULT
            MOV BH,CL
            CMP CL,0AH
            JMP RESP
RESP:
    LEA DX,MSG4
    MOV AH,09
    INT 21H
    CMP BH,0
    JGE POS
    NEG BH
    MOV AH,02
    MOV DL,'-'
    INT 21H
    POS:
        XOR AX,AX
        MOV AL,BH
        MOV BH,10D
        DIV BH
        MOV BH,AH
        MOV BL,AL
        MOV DL,BL
        ADD DL,30H
        MOV AH,02
        INT 21H
        MOV DL,BH
        ADD DL,30H
        INT 21H

    MOV AH,4CH
    INT 21H
main endp
END main
