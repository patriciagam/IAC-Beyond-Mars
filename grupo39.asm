;==============================================================================
; GRUPO 39
;------------------------------------------------------------------------------
; Inês Paredes (ist1107028)
; Margarida Lourenço (ist1107137)
; Patrí­cia Gameiro (ist1107245)
;
;==============================================================================
; CONSTANTES
;------------------------------------------------------------------------------
DISPLAYS   EQU 0A000H   ; endereço dos displays (periférico POUT-1)
TEC_LIN    EQU 0C000H   ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H   ; endereço das colunas do teclado (periférico PIN)
LINHA      EQU 01111H   ; linha 1
MASCARA    EQU 0FH      ; para isolar os 4 bits de menor peso

PLACE 1000H

pilha:
	STACK 100H			; espaço reservado para a pilha 
						
SP_inicial:	

DECREMENT0: WORD 0
INCREMENT0: WORD 1
ENERGIA:    WORD 100
;==============================================================================
; main???
;------------------------------------------------------------------------------
PLACE 0

;==============================================================================
; teclado: lê input
;------------------------------------------------------------------------------

teclado:
    MOV  SP, SP_inicial ; inicializa Stack pointer
    MOV  R2, TEC_LIN    ; endereço do periférico das linhas
    MOV  R3, TEC_COL    ; endereço do periférico das colunas
    MOV  R4, DISPLAYS   ; endereço do periférico dos displays
    MOV  R5, MASCARA    ; isola os 4 bits de menor peso
    MOV  R1, [ENERGIA]  ; energia inicial
    CALL atualiza_display
    MOV  R1, LINHA      ; testa a linha 1 

espera_tecla:           ; neste ciclo espera-se até uma tecla ser premida 
    MOVB [R2], R1       ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]       ; ler do periférico de entrada (colunas)
    AND  R0, R5         ; elimina bits para além dos bits 0-3
    CMP  R0, 0          ; verifica se alguma tecla foi premida   
    JZ   proxima_linha  
    

ha_tecla:              ; espera-se até nenhuma tecla estar premida
    PUSH R0
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0
    POP  R0         
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    MOV  R7, R0        ; guarda coluna
    MOV  R8, -1       
    CALL converte
    MOV  R0, R8         
    MOV  R8, -1
    MOV  R7, R1         ; guarda linha
    CALL converte
    SHL  R8, 2          ; multiplica linha por 4
    ADD  R8, R0         ; soma linha e coluna
    AND  R8, R5         ; elimina bits para além dos bits 0-3
    CALL  comandos
    JMP  espera_tecla       

proxima_linha:
    ROL  R1, 1          ; testa a próxima linha
    JMP  espera_tecla

converte:
    SHR  R7, 1
    ADD  R8, 1
    CMP  R7, 0 
    JNZ  converte
    RET    

comandos:
    PUSH R0
    PUSH R1
    MOV  R0, [INCREMENT0]
    CMP  R8, R0
    JZ   incrementa
    MOV  R0, [DECREMENT0]
    CMP  R8, R0
    JZ   decrementa
    POP  R1
    POP  R0
    RET

incrementa:
    MOV  R0, 1
    MOV  R1, [ENERGIA]
    ADD  R1, R0
    MOV  [ENERGIA], R1
    CALL atualiza_display
    POP  R1
    POP  R0
    RET
    
decrementa:
    MOV  R0, -1
    MOV  R1, [ENERGIA]
    ADD  R1, R0
    MOV  [ENERGIA], R1
    CALL atualiza_display
    POP  R1
    POP  R0
    RET

atualiza_display:
    MOV  R9, 1
    MOV  R10, 10        
    PUSH R2
    PUSH R3
    PUSH R5
    MOV  R2, R1
    MOV  R3, R1
    MOV  R1, 0
    MOV  R5, 16             
    CALL converte_decimal
    MOV  [R4], R1       ; escreve no periférico dos displays
    POP R5
    POP R3
    POP R2
    RET

converte_decimal:
    DIV  R2, R10
    MOD  R3, R10
    MUL  R3, R9
    ADD  R1, R3
    MUL  R9, R5
    MOV  R3, R2
    CMP  R2, 0
    JNZ  converte_decimal
    RET