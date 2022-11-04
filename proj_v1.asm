TITLE // Arthur Maluf  22005252 / João Pamponet 22002241 //
.model small
print macro msg         ;Macro para a inicialização e impressão de mensagens
    MOV  AH , 09
    LEA  DX , msg
    INT  21H
endm
.data
    separator        DB 10,'---------------------',10,'$'
    read_msg_value1  DB    '  Primeiro valor: ',      '$'
    read_msg_op      DB    '     Operacao : ',        '$'
    read_msg_value2  DB    '  Segundo  valor: ',      '$'
    result_msg       DB    '   Resultado: ',          '$'
    restart_ask_msg  DB    '  Reiniciar? [y/n] ',     '$'
    div_rest_msg     DB 10,'      Resto:  ',          '$'
    div_invalid      DB    '  Divisor invalido ',     '$'
.code
main proc
 
    MOV   AX ,  @DATA    ;Inicialização do DS
    MOV   DS ,  AX

START:

    call READ            ;Chama o processo de leitura dos valores e da operação

    CMP   CL , '+'       ;Verifica se a operação é a soma
    JNE  NEXT_OP1        ;Pula se não for
    ADD   BH , BL        ;Se for, faz a soma entre os dois valores
    call RESULT          ;Chama o proc para impressão do resultado
    JMP  FINISH

NEXT_OP1:

    CMP   CL , '-'       ;Verifica se a operação é a subtração
    JNE  NEXT_OP2        ;Pula se não for
    SUB   BL , BH        ;Se for, subtrai o segundo valor do primeiro
    MOV   BH , BL        ;Move o resultado para BH (registrador padrão que armazena os resultados)
    call RESULT          ;Chama o proc para impressão do resultado
    JMP  FINISH

NEXT_OP2:   

    CMP   CL , '/'       ;Verifica se a operação é a divisão
    JNE  NEXT_OP3        ;Pula se não for
    CMP   BH , 0
    JNZ  VALID_DIV
    print separator
    print div_invalid
    JMP FINISH

    VALID_DIV:
        call DIVI        ;Chama o proc da divisão
        call RESULT      ;Chama o proc para impressão do resultado
        CMP   BL , 0     ;Verifica se a divisão teve resto
        JE NO_REMAINDER
        call REMAINDER   ;Chama o proc para impressão do resto
        NO_REMAINDER:
            JMP  FINISH

NEXT_OP3:

    CMP   CL , '*'       ;Verifica se a operação é a multiplicação
    JNE  NEXT_OP4        ;Pula se não for
    call MULT            ;Chama o proc da multiplicação
    call RESULT          ;Chama o proc para impressão do resultado
    JMP  FINISH

NEXT_OP4:;Estrutura para possível implementação de mais operações ( sem uso no momento )

FINISH:
    print separator
    print restart_ask_msg
    Y_OR_N:
        MOV  AH , 01         ;Função para leitura de input
        INT  21H           
        CMP  AL , 'y'        ;Valida se a resposta foi 'y'
        JE  VALID_ANSw       ;Pula se sim
        CMP  AL , 'n'        ;Valida se a resposta foi 'n'
        JE  VALID_ANSw       ;Pula se sim
    
        MOV  DL , 08         ;Se chegou até aqui o input foi != 'y'||'n'
        MOV  AH , 02         
        INT  21H             ;Impressão do caractere BS (backspace)
        JMP Y_OR_N           ;Repete a leitura até o input for == 'y'||'n'
        VALID_ANSw:
            CMP  AL , 'y'    ;Se a resposta for 'y', volta para o começo para executar o programa novamente
            JE  START

    MOV  AH , 4CH            ;Se a resposta for 'n', finaliza o programa e em seguida, encerra
    INT  21H
main endp

MULT proc
    XOR  CL , CL         
    MULTI:                       ;; MULTIPLICAÇÃO ;;  BL = Multiplicador / BH = Multiplicando  ;;
        SHR  BH , 1
        JNC BIT_ZERO_MUL           ;    10 (2)  ;   - Shift para a direita no multiplicador, LSB vai para CF, verifica o CF.
        ADD  CL , BL               ; x 101 (5)  ;   - Se CF = 1, multiplicará o multiplicando por 1 ou seja, 
        BIT_ZERO_MUL:              ; ---------  ;    adiciona o próprio multiplicando ao registrador do resultado (CL)
            SHL  BL , 1            ;    10      ;     Se CF = 0, multiplicará o multiplicando por 0, sem necessidade de adição
            CMP  BH , 0            ;   000      ;   - Shift para a esquerda no multiplicando e seguir ao próximo dígito do multiplicador
            JNE MULTI              ;  1000 +    ;   - Repete até que todos os digitos do multiplicador sejam percorridos
            MOV  BH , CL           ; ---------  ;   - Armazena o resultado em BH e retorna
ret                                ;  1010 (10) ;   
MULT endp

DIVI proc
    XOR  CL , CL
    XOR  DX , DX
    MOV  AH , 8
    DIVIS:                     ;;         DIVISÃO         ;;  BL = Dividendo / BH = Divisor / CL = Resto / DL = Quociente  ;;
        XOR  CH , CH             
        XOR  DH , DH             ;   1001 (9) |_10_ (2)  ;   - Shift para a esquerda no dividendo, MSB vai para CF, verifica o CF.
        SHL  BL , 1              ;  -0        0100  (4)  ;   - Insere o valor do CF no LSB de CL por meio do OR lógico após um Shift para esquerda em CL
        JNC BIT_ZERO_DIV         ;  ---                  ;   - Testa se o divisor 'cabe' em CL: 
        MOV  CH , 1              ;   10                  ;    Se sim, subtrai BH de CL e setta DH para 1
        BIT_ZERO_DIV:            ;  -10                  ;    Se não, não subtrai e DH continua 0
            SHL  CL , 1          ;  ----                 ;   - Insere o valor de DH no LSB de DL por meio do OR lógico após um Shift para a esquerda em DL
            OR   CL , CH         ;   000                 ;   - Repete 8 vezes (Percorre todos os bits do registrador BL)
            CMP  CL , BH         ;   - 0                 ;   - Armazena o quociente em BH e o resto em BL
            JL NO_SUB_DIV        ;   ----                ;
            SUB  CL , BH         ;     01                ;
            MOV  DH , 1          ;    - 0                ;
            NO_SUB_DIV:          ;    ----               ;
                SHL  DL , 1      ;      1  (1)           ;
                OR   DL , DH
                DEC  AH
                JNZ DIVIS
    MOV  BH , DL
    MOV  BL , CL
ret
DIVI endp

RESULT proc
    print separator
    print result_msg
    CMP  BH , 0             ;Verifica se o resultado for negativo
    JGE JUMP_NEG_SIGNAL     ;Pula a impressão do '-' se não for negativo
    NEG  BH                 ;Transforma o resultado em positivo
    MOV  AH , 02
    MOV  DL , '-'             
    INT  21H                ;Imprime o sinal de negativo
    MOV  DL , ' '
    INT  21H                ;Imprime um espaço
    JUMP_NEG_SIGNAL:
        CMP  BH , 0AH       ;Verifica se o resultado é maior ou igual a 10
        JGE DOUBLE_DIGITS   ;Pula para a impressão de valores com 2 dígitos
        MOV  DL , BH        ;Move o resultado para DL para impressão
        ADD  DL , 30H       ;Adiciona 30h para transformar o número puro em seu ASCII
        MOV  AH , 02
        INT  21H            ;Imprime o resultado
    ret
        DOUBLE_DIGITS:
        XOR  AX , AX        ;Limpa AX
        MOV  AL , BH        ;Manda o resultado para AL
        MOV  BH , 10D       ;Manda 10 para BH
        DIV  BH             ;Divide o conteúdo de AL por BH
        MOV  BH , AH        ;Armazena o resto da divisão em BH
        MOV  DL , AL        ;Armazena o quociente da divisão em DL para impressão direta          
        ADD  DL , 30H       ;Adiciona 30h para transformar o numero puro em seu ASCII
        MOV  AH , 02          
        INT  21H            ;Imprime o primeiro dígito do resultado
        MOV  DL , BH        ;Move o segundo dígito do resultado para DL para impressão
        ADD  DL , 30H       ;Adiciona 30h para transformar o numero puro em seu ASCII
        INT  21H            ;Imprime o segundo dígito do resultado
ret
RESULT endp

REMAINDER proc
    print div_rest_msg
    MOV  DL , BL           ;Move o resto da divisão para DL para impressão
    ADD  DL , 30H          ;Adiciona 30h para transformar o numero puro em seu ASCII
    MOV  AH , 02
    INT  21H               ;Imprime o valor do resto
ret
REMAINDER endp

READ proc

    MOV  AX , 3              ;Função que limpa a tela do console
    INT  10H
    print separator

    print read_msg_value1
VALUE_1:
    MOV  AH , 01
    INT  21H                 ;Leitura do primeiro numero
    MOV  CH , 30H            ;Move o ASCII do zero para validação repetitiva do input
    VALIDATE_1:
        CMP  AL , CH         ;Verifica se o input é igual a CH
        JZ  VALID_1          ;Se sim, pula
        INC  CH              ;Se não, incrementa CH para testar novamente
        CMP  CH , 3AH        ;Testa todos os numeros em ASCII do zero ao nove, para de testar ao chegar no ASCII 3Ah
        JNE VALIDATE_1

    MOV  DL , 08             ;Se chegou até aqui, o input não foi um número
    MOV  AH , 02
    INT  21H                 ;Impressão do caractere BS (Backspace)
    JMP VALUE_1              ;Repete a leitura até o input for um número

VALID_1:
    SUB  AL , 30H            ;Subtrai 30h para transformar o ASCII do primeiro valor no número puro
    MOV  BL , AL             ;Armazena em BL
    MOV  AH , 02             
    MOV  DL , 10
    INT  21H                 ;Imprime um espaço

    print read_msg_op
OPERATION:
    MOV  AH , 01
    INT  21H                 ;Leitura da operação

    CMP  AL , '+'            ;Valida se o input foi uma das quatro operações válidas
    JZ VALID_OP
    CMP  AL , '-'
    JZ VALID_OP
    CMP  AL , '/'
    JZ VALID_OP
    CMP  AL , '*'
    JZ VALID_OP

    MOV  DL , 08            ;Se chegou até aqui, o input não foi uma operação válida
    MOV  AH , 02
    INT  21H                ;Imprime o caractere BS (Backspace)
    JMP OPERATION           ;Repete a leitura até o input for uma operação válida

VALID_OP:
    MOV  CL , AL            ;Armazena o ASCII da operação em CL
    MOV  AH , 02
    MOV  DL , 10
    INT  21H                ;Imprime um espaço

    print read_msg_value2
VALUE_2:
    MOV  AH , 01
    INT  21H                ;Leitura do segundo numero
    MOV  CH , 30H           ;Move o ASCII do zero para validação repetitiva do input
    VALIDATE_2:
        CMP  AL , CH        ;Verifica se o input é igual a CH
        JZ  VALID_2         ;Se sim, pula
        INC  CH             ;Se não, incrementa CH para testar novamente
        CMP  CH , 3AH       ;Testa todos os numeros do zero ao nove, para de testar ao chegar no ASCII 3Ah
        JNZ VALIDATE_2

    MOV  DL , 08            ;Se chegou até aqui, o input não foi um número
    MOV  AH , 02
    INT  21H                ;Imprime o caractere BS (backspace)
    JMP VALUE_2             ;Repete até o input for um número

VALID_2:
    SUB  AL , 30H           ;Subtrai 30h para transformar o ASCII do segundo valor no número puro
    MOV  BH , AL            ;Armazena em BH

ret
READ endp

END main
