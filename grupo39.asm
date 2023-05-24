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
DISPLAYS      EQU 0A000H   ; endereço dos displays (periférico POUT-1)
TEC_LIN       EQU 0C000H   ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL       EQU 0E000H   ; endereço das colunas do teclado (periférico PIN)
TEC_LINHA     EQU 01111H   ; linha 1
MASCARA       EQU 0FH      ; para isolar os 4 bits de menor peso
 
; MediaCenter
COMANDOS      EQU 6000H	         ; endereço de base dos comandos do MediaCenter
DEFINE_LINHA  EQU COMANDOS + 0AH ; endereço do comando para definir a linha
DEFINE_COLUNA EQU COMANDOS + 0CH ; endereço do comando para definir a coluna
DEFINE_PIXEL  EQU COMANDOS + 12H ; endereço do comando para escrever um pixel
APAGA_AVISO   EQU COMANDOS + 40H ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	  EQU COMANDOS + 02H ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_FUNDO  EQU COMANDOS + 42H	; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM	  EQU COMANDOS + 5AH ; endereço do comando para tocar um som

; Ecrã
ECRA_ALTURA   EQU  32            ; número de linhas do ecrã 
ECRA_LARGURA  EQU  64            ; número de colunas do ecrã 

; Asteróide
AST_LARGURA	  EQU  5		     ; largura do asteroide
AST_LINHA     EQU  0             ; linha do asteróide (primeira linha do ecrã)
AST_COLUNA	  EQU  0             ; coluna do asteróide (primeira coluna do ecrã)
LILAS	      EQU  0FA7EH		 ; cor do asteróide

; Sonda
AZUL          EQU  0F6BFH		 ; cor da sonda

;==============================================================================
PLACE 1000H

pilha:
	STACK 100H			         ; espaço reservado para a pilha 
						
SP_inicial:	

;==============================================================================
; VARIÁVEIS
;------------------------------------------------------------------------------

; Comandos
DECREMENT0:   WORD 00H
INCREMENT0:   WORD 01H
ASTEROIDE:    WORD 0AH
SONDA:        WORD 0BH

ENERGIA:      WORD 100

; Sonda
SONDA_LINHA:  WORD 26
SONDA_COLUNA: WORD 32

; Asteróide
DEF_ASTEROIDE:	                 ; tabela que define o asteróide
	WORD		AST_LARGURA
	WORD		LILAS, 0, LILAS, 0, LILAS

;==============================================================================
; início do jogo
;------------------------------------------------------------------------------
PLACE 0

jogo:
    MOV  SP, SP_inicial          ; inicializa Stack pointer
    MOV  [APAGA_AVISO], R1	
    MOV  [APAGA_ECRÃ], R1	
	MOV	 R1, 0			         ; cenário de fundo número 0
    MOV  [SELECIONA_FUNDO], R1	 ; seleciona o cenário de fundo
    MOV  R1, AST_LINHA			 ; linha do asteróide
	MOV  R2, AST_COLUNA			 ; coluna do asteróide
	MOV	 R4, DEF_ASTEROIDE	     ; endereço da tabela que define o asteroide
	CALL desenha_asteroide

;==============================================================================
; teclado: lê input
;------------------------------------------------------------------------------

teclado:
    MOV  R1, [ENERGIA]  ; energia inicial
    MOV  R2, TEC_LIN    ; endereço do periférico das linhas
    MOV  R3, TEC_COL    ; endereço do periférico das colunas
    MOV  R4, DISPLAYS   ; endereço do periférico dos displays
    MOV  R5, MASCARA    ; isola os 4 bits de menor peso
    CALL atualiza_display
    MOV  R1, TEC_LINHA  ; testa a linha 1 

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
    MOV  R0, [SONDA]
    CMP  R8, R0
    JZ   sonda
    MOV  R0, [ASTEROIDE]
    CMP  R8, R0
    JZ   move_asteroide
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

;==============================================================================
; sonda
;------------------------------------------------------------------------------
sonda:
    PUSH R1
    PUSH R2

;==============================================================================
; asteróide
;------------------------------------------------------------------------------
desenha_asteroide:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]	             ; obtém a largura do asteroide
	ADD	R4, 2		             ; endereço da cor do 1º pixel
	CALL desenha_pixels
	                        
    ; 2ª linha do meteoro
	MOV  R1, AST_LINHA + 1           ; linha abaixo do asteróide
	MOV  R2, AST_COLUNA + 1          ; coluna a frente
	MOV  R5, AST_LARGURA - 2         ; largura 
	CALL desenha_linha
	
	; desenha linha do meio
	MOV R1, AST_LINHA + 2
	MOV  R2, AST_COLUNA
	MOV  R5, AST_LARGURA - 1
	CALL linha_meio

	; 3ª linha do meteoro
	MOV  R1, AST_LINHA + 3       ; linha abaixo do asteróide
	MOV  R2, AST_COLUNA + 1      ; coluna a frente
	MOV  R5, AST_LARGURA - 2     ; largura 
	CALL desenha_linha

	; linha final do meteoro 
	MOV  R1, AST_LINHA + 4    	 ; proxima linha
	MOV  R2, AST_COLUNA       	 ; coluna inicial
	MOV  R5, AST_LARGURA      	 ; largura inicial
	MOV	R4, DEF_ASTEROIDE
	ADD	R4, 2
	CALL desenha_pixels
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET

move_asteroide:
    SUB R1, 3		             ; linha do boneco
	ADD R2, 1		             ; coluna do boneco   
	MOV	 R4, DEF_ASTEROIDE	     ; endereço da tabela que define o boneco
    CALL desenha_asteroide
	POP  R1
    POP  R0
    RET
	
desenha_pixels:       		 ; desenha os pixels do asteróide a partir da tabela
	MOV	R3, [R4]	         ; obtém a cor do próximo pixel do asteróide
	CALL	escreve_pixel	 ; escreve cada pixel do asteróide
	ADD	R4, 2		         ; endereço da cor do próximo pixel 
	ADD  R2, 1               ; próxima coluna
	SUB  R5, 1		         ; menos uma coluna para tratar
	JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	RET

salta_pixel:                 ; salta um pixel para desenhar a linha do meio
	ADD R2, 1

linha_meio:
	CALL escreve_pixel
	ADD  R2, 1            	 ; próxima coluna
	SUB  R5, 1            	 ; menos uma coluna para desenhar
	CMP  R5, 2            	 ; verifica se a ultima coluna preencida foi a segunda
	JZ   salta_pixel	     ; avança um pixel
	CMP  R5, 0               ; verifica se completou a largura
	JNZ  linha_meio		     ; continua o loop ate percorrer a largura
	RET

desenha_linha:
	CALL escreve_pixel    	 ; escreve um pixel com a cor definida
	ADD  R2, 1            	 ; próxima coluna
	SUB  R5, 1            	 ; menos uma coluna para desenhar
	CMP  R5, 0            	 ; verifica se já desenhou todas as colunas
	JNZ  desenha_linha   	 ; continua o loop para desenhar a próxima coluna
	RET

;==============================================================================
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel 
;------------------------------------------------------------------------------

escreve_pixel:
	MOV  [DEFINE_LINHA], R1  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2 ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	 ; altera a cor do pixel selecionado
	RET