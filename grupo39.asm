;==============================================================================
; GRUPO 39
; Inês Paredes (ist1107028)
; Margarida Lourenço (ist1107137)
; Patrícia Gameiro (ist1107245)
;------------------------------------------------------------------------------

; *****************************************************************************
; * Constantes
; **********************************************************************

DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA      EQU 1       ; linha a testar 
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; **********************************************************************
; * Código
; **********************************************************************
PLACE      0
inicio:		
; inicializações
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

ciclo:         
    MOV  R6, LINHA     ;                                                    adicionado do pedaço da aula
    MOVB [R4], R6      ; escreve o valor 1 nos displays

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
    SHR R6, 1          ; roda o valor de R6 para a direita                     adicionado do pedaço da aula
    MOVB [R2], R6      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R6, 0         ; há tecla premida?                                    adicionado do pedaço da aula
    JZ   espera_tecla  ; se nenhuma tecla premida, repete
                       ; vai mostrar a linha e a coluna da tecla
    SHL  R1, 4         ; coloca linha no nibble high
    OR   R1, R0        ; junta coluna (nibble low)
    MOVB [R4], R1      ; escreve linha e coluna nos displays
    
ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    MOV  R1, R6        ; guardar valor de R6
    MOVB [R2], R6      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo         ; repete ciclo

fim:                  ; fim do programa

; Continua apenas a funcionar para uma linha (facated)
