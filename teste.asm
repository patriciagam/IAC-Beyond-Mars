;==============================================================================
; GRUPO 39
;------------------------------------------------------------------------------
; Inês Paredes (ist1107028)
; Margarida Lourenço (ist1107137)
; Patrícia Gameiro (ist1107245)
;
;==============================================================================
; CONSTANTES
;------------------------------------------------------------------------------
DISPLAYS   EQU 0A000H   ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H   ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H   ; endereço das colunas do teclado (periférico PIN)
LINHA      EQU 01111H   ; linha 1
MASCARA    EQU 0FH      ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

PLACE 1000H

pilha:
	STACK 100H			; espaço reservado para a pilha 
						
SP_inicial:	

DECREMENTA: WORD 0
INCREMENTA: WORD 1
ENERGIA:    WORD 15
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
    MOV  R5, MASCARA    ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R1, [ENERGIA]  ; energia inicial
    MOVB [R4], R1       ; escreve linha e coluna a zero nos displays
    MOV  R1, LINHA      ; testar a linha 1 

espera_tecla:           ; neste ciclo espera-se até uma tecla ser premida 
    MOVB [R2], R1       ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]       ; ler do periférico de entrada (colunas)
    AND  R0, R5         ; elimina bits para além dos bits 0-3
    CMP  R0, 0          ; há tecla premida?    
    JZ   proxima_linha  ; testar a próxima linha
    MOV  R7, R0         ; guarda coluna
    MOV  R8, -1         ; inicializar a -1
    CALL converte
    MOV  R0, R8         
    MOV  R8, -1
    MOV  R7, R1         ; guarda linha
    CALL converte
    SHL  R8, 2          ; multiplica linha por 4
    ADD  R8, R0         ; soma linha e coluna
    AND  R8, R5         ; elimina bits para além dos bits 0-3
    JMP  comandos

proxima_linha:
    ROL  R1, 1          ; testar a próxima linha
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
    MOV  R0, [INCREMENTA]
    CMP  R8, R0
    JZ   incrementa
    MOV  R0, [DECREMENTA]
    CMP  R8, R0
    JZ   decrementa
    POP  R1
    POP  R0
    JMP  espera_tecla

incrementa:
    MOV  R0, 1
    MOV  R1, [ENERGIA]
    ADD  R1, R0
    MOV  [R4], R1
    POP  R1
    POP  R0
    JMP  espera_tecla

decrementa:
    MOV  R0, -1
    MOV  R1, [ENERGIA]
    ADD  R1, R0
    MOV  [R4], R1
    POP  R1
    POP  R0
    JMP  espera_tecla
