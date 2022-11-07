TITLE // Arthur Maluf  22005252 / João Pamponet 22002241 //
.model small
print macro msg         ;Macro para a inicialização e impressão de mensagens
    MOV  AH , 09
    LEA  DX , msg
    INT  21H
endm
.stack 100h
.data
    intro            DB 10,'                 C A L C U L A D O R A    X 8 6  A S S E M B L Y',                   '$'
    separator        DB 10,'________________________________________________________________________________',10,'$'
    read_msg_value1  DB    '                              Primeiro valor > ',                                    '$'
    read_msg_op      DB 10,'                                  Operacao > ',                                      '$'
    read_msg_value2  DB 10,'                              Segundo  valor > ',                                    '$'
    result_msg       DB    '                                Resultado: ',                                        '$'
    restart_ask_msg  DB 10,'     [SPACE] PARA REINICIAR                      QUALQUER TECLA PARA SAIR '      ,10,'$'
    div_rest_msg     DB 10,'                                 Resto :  ',                                         '$'
    div_invalid      DB    '                             > Divisor invalido <',                                  '$'
.code
main proc
 
    MOV   AX ,  @DATA   ;Inicialização do DS
    MOV   DS ,  AX
   
START:

    MOV  AH , 00        ;Função da INT 10H para settar modo de exibição de vídeo
    MOV  AL , 03        ;Modo de vídeo 80x25, 16 cores, 8 páginas
    INT  10H            

    MOV  AH , 01        ;Função da INT 10H para settar o formato do cursor
    MOV  CX , 2000h     ;Valor para ocultar o cursor
    INT  10H            

    MOV  AH , 09H       ;Função da INT 10H para escrever caracteres e atribuir cores à posição escrita
    MOV  AL , ' '       ;Escrevemos um espaço em branco pois queremos apenas mudar a cor da posição
    MOV  CX , 2000D     ;Número exato de posições na tela com o modo de vídeo 80x25 = 2000D = 7D0H
    MOV  BX , 070H      ;Atribuição da cor 0CH nos caracteres e da cor 00H no background
    INT  10H            
    call READ           ;Chama o processo de leitura dos valores e da operação

    CMP  CL , '+'       ;Verifica se a operação é a soma
     JNE NEXT_OP1       ;Pula se não for
    ADD  BH , BL        ;Se for, faz a soma entre os dois valores
    call RESULT         ;Chama o proc para impressão do resultado
    JMP  FINISH

 NEXT_OP1:

    CMP  CL , '-'       ;Verifica se a operação é a subtração
     JNE NEXT_OP2       ;Pula se não for
    SUB  BL , BH        ;Se for, subtrai o segundo valor do primeiro
    MOV  BH , BL        ;Move o resultado para BH (registrador padrão que armazena os resultados)
    call RESULT         ;Chama o proc para impressão do resultado
    JMP  FINISH

 NEXT_OP2:   

    CMP  CL , '/'       ;Verifica se a operação é a divisão
     JNE NEXT_OP3      ;Pula se não for
    CMP  BH , 0
     JNZ VALID_DIV
    print separator
    print div_invalid
    JMP  FINISH

    VALID_DIV:
        call DIVI           ;Chama o proc da divisão
        call RESULT         ;Chama o proc para impressão do resultado
        CMP  BL , 0         ;Verifica se a divisão teve resto
         JE  NO_REMAINDER
        call REMAINDER      ;Chama o proc para impressão do resto
        NO_REMAINDER:
        JMP  FINISH

 NEXT_OP3:

    CMP  CL , '*'        ;Verifica se a operação é a multiplicação
     JNE NEXT_OP4        ;Pula se não for
    call MULT            ;Chama o proc da multiplicação
    call RESULT          ;Chama o proc para impressão do resultado
    JMP  FINISH

 NEXT_OP4: ;Estrutura para possível implementação de mais operações ( sem uso no momento )

FINISH:
    print separator
    MOV  AH , 09H            ;Função da INT 10H para escrever caracteres e atribuir cores à posição escrita
    MOV  AL , ' '            ;Escrevemos um espaço em branco pois queremos apenas mudar a cor da posição
    MOV  CX , 240D      
    MOV  BX , 0F0H           ;Atribuição da cor 00H nos caracteres e da cor 0FH no background
    INT  10H                 ;Interrupção
    print restart_ask_msg
        MOV  AH , 07         ;Função para leitura de input sem echo
        INT  21H           
            CMP  AL , ' '    ;Se a resposta for um espaço, volta para o começo para executar o programa novamente
             JNE ANSW_N
            JMP START
 ANSW_N:
    MOV  AH , 4CH            ;Se a resposta não for um espaço, finaliza o programa e em seguida, encerra
    INT  21H
main endp

READ proc

    print intro
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
         JZ  VALID_2        ;Se sim, pula
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

MULT proc
    XOR  CL , CL         
    MULTI:                       ; MULTIPLICAÇÃO ;  BL = Multiplicador / BH = Multiplicando  ;
        SHR  BH , 1
         JNC BIT_ZERO_MUL         ;    10 (2)   ;   - Shift para a direita no multiplicador, LSB vai para CF, verifica o CF.
        ADD  CL , BL              ; x 101 (5)   ;   - Se CF = 1, multiplicará o multiplicando por 1 ou seja, 
        BIT_ZERO_MUL:             ; ---------   ;    adiciona o próprio multiplicando ao registrador do resultado (CL)
            SHL  BL , 1           ;    10       ;     Se CF = 0, multiplicará o multiplicando por 0, sem necessidade de adição
            CMP  BH , 0           ;   000       ;   - Shift para a esquerda no multiplicando e seguir ao próximo dígito do multiplicador
             JNE MULTI            ;  1000 +     ;   - Repete até que todos os digitos do multiplicador sejam percorridos
            MOV  BH , CL          ; ---------   ;
ret                               ;  1010 (10)  ;     BH = Resultado ;;
MULT endp

DIVI proc
    XOR  CL , CL
    XOR  DX , DX
    MOV  CH , BL                 ;        DIVISÃO        ;   CH = Dividendo / BH = Divisor  
    MOV  AH , 8                 
    DIVIS:                       ;   1001 (9) |_10_ (2)  ;   - ROL no CX, MSB do Dividendo (CH) vai para CL
        ROL  CX , 1              ;  -0        0100  (4)  ;   - Verifica se o divisor 'cabe' em CL:
        CMP  CL , BH             ;  ----                 ;    Se sim, subtrai BH de CL e coloca 1 no MSB de DH (MOV DH,80H)
         JL  NO_SUB_DIV          ;    10                 ;    Se não, não subtrai e DH fica 0
        SUB  CL , BH             ;   -10                 ;   - ROL em DX, MSB de DH vai para o Quociente (DL)
        MOV  DH , 80H            ;   ----                ;
        NO_SUB_DIV:              ;     00                ;   - Repete 8 vezes (percorre todos os bits do registrador CH
            ROL  DX , 1          ;    - 0                ;
            DEC  AH              ;    ----               ;
             JNZ DIVIS           ;      01               ;
    MOV  BH , DL                 ;     - 0               ;
    MOV  BL , CL                 ;     ----              ;
ret                              ;       1 (1)           ;    BL = Resto / BH = Quociente  ;
DIVI endp

RESULT proc
    print separator
    print result_msg
    CMP  BH , 0             ;Verifica se o resultado for negativo
     JGE JUMP_NEG_SIGNAL    ;Pula a impressão do '-' se não for negativo
    NEG  BH                 ;Transforma o resultado em positivo
    MOV  AH , 02
    MOV  DL , '-'             
    INT  21H                ;Imprime o sinal de negativo
    MOV  DL , ' '
    INT  21H                ;Imprime um espaço
    JUMP_NEG_SIGNAL:
        CMP  BH , 0AH       ;Verifica se o resultado é maior ou igual a 10
         JGE DOUBLE_DIGITS  ;Pula para a impressão de valores com 2 dígitos
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



END main
