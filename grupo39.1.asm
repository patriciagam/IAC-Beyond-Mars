
teclado:
    MOV  SP, SP_inicial ; inicializa Stack pointer
    MOV  R2, TEC_LIN    ; endereço do periférico das linhas
    MOV  R3, TEC_COL    ; endereço do periférico das colunas
    MOV  R4, DISPLAYS   ; endereço do periférico dos displays
    MOV  R5, MASCARA    ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R1, 0 
    MOVB [R4], R1       ; escreve linha e coluna a zero nos displays

ciclo:
    MOV  R1, LINHA1     ; testar a linha 1 

espera_tecla:           ; neste ciclo espera-se até uma tecla ser premida
    MOVB [R2], R1       ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]       ; ler do periférico de entrada (colunas)
    AND  R0, R5         ; elimina bits para além dos bits 0-3
    CMP  R0, 0          ; há tecla premida?
    JZ   proxima_linha  ; se nenhuma tecla premida, repete
                        ; vai mostrar a linha e a coluna da tecla
    MOV  R7, R0         ; guarda coluna
    MOV  R8, -1         ; inicializar a -1
    CALL converte
    MOV  R0, R8         
    MOV  R8, -1
    MOV  R7, R1         ; guarda linha
    CALL converte
    SHL  R8, 2          ; multiplica linha por 4
    ADD  R8, R0         ; soma linha e coluna
    MOVB [R4], R8       ; escreve hexadecimal nos displays
    JMP  ciclo

proxima_linha:
    SHL  R1, 1              
    MOV  R6, LINHA4
    CMP  R1, R6        
    JGT  ciclo
    JMP  espera_tecla

converte:
    SHR  R7, 1
    ADD  R8, 1
    CMP  R7, 0 
    JNZ  converte
    RET           
    JMP  ciclo          
