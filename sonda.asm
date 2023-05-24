; *********************************************************************************
; * Descrição: move a sonda pixel a pixel.
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

SONDA_LINHA   EQU 26   ; linha da sonda
SONDA_COLUNA  EQU 32   ; coluna da sonda
COR_PIXEL	EQU	0F6BFH		; cor do pixel: azul em ARGB 

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)
							
     
; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0			
inicio:
	MOV  SP, SP_inicial		; inicializa SP
                            
	MOV  [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0							; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    MOV  R3, COR_PIXEL
    MOV  R1, SONDA_LINHA			; linha do boneco
	MOV  R2, SONDA_COLUNA			; coluna do boneco
	CALL desenha_sonda
	
fim:
	JMP  fim                 ; termina programa


desenha_sonda:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	CALL	move_sonda
	POP     R5
	POP     R2


move_sonda:
	MOV  [APAGA_ECRÃ], R1
	CALL escreve_pixel
	SUB R1, 1
	CMP R1, 0
	JNZ move_sonda

escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET