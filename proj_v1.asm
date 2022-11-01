TITLE // Arthur Maluf  22005252 / João Pamponet 2200---- //
.model small
print macro X         ;macro para a inicialização e impressão de mensagens
    mov ah,09
    lea dx,X
    int 21h
endm
.data
    separator DB 10,'---------------------',10,'$'
    value1_read_msg DB '  Primeiro valor: ','$'
    op_read_msg DB '     Operacao : ','$'
    value2_read_msg DB '  Segundo  valor: ','$'
    result_msg DB '   Resultado:  ','$'
    restart_ask_msg DB '  Reiniciar? [y/n] ','$'
.code
main proc
    MOV AX,@DATA       ;inicialização do .data
    MOV DS,AX
START:

    call READ          ;chama o processo de leitura dos valores e da operação [linha 119]

    CMP CL,'+'         ;verifica se a operação é a soma
    JNE NOT_SUM        ;pula se não for
    ADD BH,BL          ;se for, faz a soma entre os dois valores
    call RESP          ;chama o proc para impressão do resultado [linha 90]
    JMP ENCERRA
NOT_SUM:
    CMP CL,'-'         ;verifica se a operação é a subtração
    JNE NOT_SUBT       ;pula se não for
    SUB BL,BH          ;se for, subtrai o segundo valor do primeiro
    MOV BH,BL          ;move a resposta para BH (registrador padrão que armazena a resposta)
    call RESP          ;chama o proc para impressão do resultado [linha 90]
    JMP ENCERRA
NOT_SUBT:             
    CMP CL,'/'         ;verifica se a operação é a divisão
    JNE NOT_DIVI       ;pula se não for
    call DIVI          ;chama o proc da divisão [linha 84]
    call RESP          ;chama o proc para impressão do resultado [linha 90]
    JMP ENCERRA
NOT_DIVI:
    CMP CL,'*'         ;verifica se a operação é a multiplicação (se chegou até aqui tem que ser)
    JNE NOT_MULTI      ;pula se não for (se chegou até aqui É PRA SER)
    call MULT          ;chama o proc da multiplicação [linha 70]
    call RESP          ;chama o proc para impressão do resultado [linha 90]
    JMP ENCERRA
NOT_MULTI:
;o código nunca deve chegar aqui dado que a validação de input funcione. (funciona(confia))
ENCERRA:
    print restart_ask_msg 
Y_OR_N:
    MOV AH,01         ;função para leitura de input
    INT 21H           
    CMP AL,'y'        ;valida se a resposta foi 'y'
    JE VALID_ANS      ;pula se sim
    CMP AL,'n'        ;valida se a resposta foi 'n'
    JE VALID_ANS      ;pula se sim
    
    MOV DL,08         ;se chegou até aqui o input foi != 'y'||'n'
    MOV AH,02         
    INT 21H           ;impressão do caractere BS (backspace)
    JMP Y_OR_N        ;repete a leitura até o input for == 'y'||'n'
VALID_ANS:
    CMP AL,'y'        ;se a resposta for 'y', volta para o começo para executar o programa novamente
    JE START

    MOV AH,4CH        ;se a resposta for 'n', finaliza o programa e em seguida, encerra
    INT 21H

MULT proc             ; "It just works." -Steve Jobs
    XOR CL,CL         
    VOLTAMULT:
        SHR BH,1
        JNC PULAMULT
        ADD CL,BL
        PULAMULT:
            SHL BL,1
            JNZ VOLTAMULT
            MOV BH,CL
            CMP CL,0AH
ret
MULT endp

DIVI proc            ; nope


ret
DIVI endp

RESP proc
    print separator
    print result_msg
    CMP BH,0               ;verifica se o resultado for negativo
    JGE no_signal_needed   ;pula a impressão do '-' se não for negativo
    NEG BH                 ;transforma o resultado em positivo
    MOV AH,02
    MOV DL,'-'             
    INT 21H                ;imprime o sinal de negativo
    MOV DL,' '
    INT 21H                ;imprime um espaço
    no_signal_needed:
        XOR AX,AX          ;limpa AX
        MOV AL,BH          ;manda a resposta para AL
        MOV BH,10D         ;manda 10 para BH
        DIV BH             ;divide o conteúdo de AL por BH
        MOV BH,AH          ;armazena o resto da divisão em BH
        MOV DL,AL          ;armazena o quociente da divisão em DL para impressão          
        ADD DL,30H         ;adiciona 30h para transformar o numero puro em seu ASCII
        MOV AH,02          
        INT 21H            ;imprime o primeiro dígito do resultado
        MOV DL,BH          ;move o segundo dígito do resultado para DL para impressão
        ADD DL,30H         ;adiciona 30h para transformar o numero puro em seu ASCII
        INT 21H            ;imprime o segundo dígito do resultado
        print separator
ret
RESP endp

READ proc
    MOV AX,3              ;função que limpa a tela do console
    INT 10H
    print separator
    print value1_read_msg
VALUE_1:
    MOV AH,01
    INT 21H               ;leitura do primeiro numero
    MOV CH,30H            ;move o ASCII do zero para validação repetitiva do input
    VALIDATE_1:
        CMP AL,CH         ;verifica se o input é igual a CH
        JZ VALID_1        ;se sim, pula
        INC CH            ;se não, incrementa CH para testar novamente
        CMP CH,3AH        ;testa todos os numeros do zero ao nove, para de testar ao chegar no ASCII 3Ah
        JNE VALIDATE_1
    MOV DL,08             ;se chegou até aqui, o input não foi um número
    MOV AH,02
    INT 21H               ;impressão do caractere BS (backspace)
    JMP VALUE_1           ;repete a leitura até o input for um número
VALID_1:
    SUB AL,30H            ;subtrai 30h para transformar o ASCII do primeiro valor no número puro
    MOV BL,AL             ;armazena em BL
    MOV AH,02             
    MOV DL,10
    INT 21H               ;imprime um espaço

    print op_read_msg
OPERATION:
    MOV AH,01
    INT 21H               ;leitura da operação

    CMP AL,'+'            ;valida se o input foi uma das quatro operações válidas
    JZ VALID_OP
    CMP AL,'-'
    JZ VALID_OP
    CMP AL,'/'
    JZ VALID_OP
    CMP AL,'*'
    JZ VALID_OP

    MOV DL,08            ;se chegou até aqui, o input não foi uma operação válida
    MOV AH,02
    INT 21H              ;imprime o caractere BS (backspace)
    JMP OPERATION        ;repete a leitura até o input for uma operação válida
VALID_OP:
    MOV CL,AL            ;armazena o ASCII da operação em CL
    MOV AH,02
    MOV DL,10
    INT 21H              ;imprime um espaço

    print value2_read_msg
VALUE_2:
    MOV AH,01
    INT 21H              ;leitura do segundo numero
    MOV CH,30H           ;move o ASCII do zero para validação repetitiva do input
    VALIDATE_2:
        CMP AL,CH        ;verifica se o input é igual a CH
        JZ VALID_2       ;se sim, pula
        INC CH           ;se não, incrementa CH para testar novamente
        CMP CH,3AH       ;testa todos os numeros do zero ao nove, para de testar ao chegar no ASCII 3Ah
        JNZ VALIDATE_2

    MOV DL,08            ;se chegou até aqui, o input não foi um número
    MOV AH,02
    INT 21H              ;imprime o caractere BS (backspace)
    JMP VALUE_2          ;repete até o input for um número
VALID_2:
    SUB AL,30H           ;subtrai 30h para transformar o ASCII do segundo valor no número puro
    MOV BH,AL            ;armazena em BH
ret
READ endp

main endp
END main
