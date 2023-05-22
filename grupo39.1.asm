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
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA1     EQU 1       ; linha 1
LINHA4     EQU 8       ; linha 4 
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

;==============================================================================
; main???
;------------------------------------------------------------------------------
PLACE 0

;==============================================================================
; teclado: lê input
;------------------------------------------------------------------------------
teclado:
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; isola os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R1, 0 
    MOVB [R4], R1      ; escreve linha e coluna a zero nos displays

ciclo:
    MOV  R1, LINHA1    ; testar linha 1 

espera_tecla:          ; ciclo espera até uma tecla ser premida
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         
    JZ   proxima_linha ; se nenhuma tecla premida, repete         
    MOV  R7, 0
    MOV  R8, 0
    JMP  converte_linha

proxima_linha:
    SHL  R1, 1           
    MOV  R6, LINHA4
    CMP  R1, R6
    JGT  ciclo
    JMP  espera_tecla

converte_linha:
    SHR  R1, 1
    CMP  R1, 0
    JZ   converte_coluna
    ADD  R7, 1 
    JMP converte_linha

converte_coluna:
    SHR  R0, 1
    CMP  R0, 0
    JZ   converte_tecla
    ADD  R8, 1 
    JMP converte_coluna

converte_tecla:
    SHL  R7, 2
    ADD  R7, R8
    MOVB [R4], R7      ; escreve hexadecimal nos displays
    JMP  ciclo          
