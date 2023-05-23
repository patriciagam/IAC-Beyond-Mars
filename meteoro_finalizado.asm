; *********************************************************************************
; * Descrição: Este programa ilustra o desenho de um boneco do ecrã, usando rotinas.
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

LINHA       EQU  1        ; linha do boneco (a meio do ecrã))
COLUNA		EQU  1        ; coluna do boneco (a meio do ecrã)

LARGURA		EQU	5			; largura do boneco
COR_PIXEL	EQU	0FF00H		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

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
							
DEF_BONECO:				; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL		; # # #   as cores podem ser diferentes de pixel para pixel
     

; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0			
inicio:
	MOV  SP, SP_inicial		; inicializa SP
                            
	MOV  [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0							; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
     
    MOV  R1, LINHA			; linha do boneco
	MOV  R2, COLUNA			; coluna do boneco
	MOV	R4, DEF_BONECO		; endereço da tabela que define o boneco
	CALL	desenha_boneco	; desenha o boneco

fim:
	JMP  fim                 ; termina programa


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************


desenha_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			 ; obtém a largura do boneco
	ADD	R4, 2				 ; endereço da cor do 1º pixel (2 porque a largura é uma word)
	CALL desenha_pixels
	; 2ª linha do meteoro
	MOV  R1, LINHA + 1       ; linha abaixo do boneco
	MOV  R2, COLUNA + 1      ; coluna a frente
	MOV  R5, LARGURA - 2     ; largura 
	CALL desenha_linha
	
	; desenha linha do meio
	MOV R1, LINHA + 2
	MOV  R2, COLUNA
	MOV  R5, LARGURA - 1
	CALL linha_meio

	; 2ª linha do meteoro
	MOV  R1, LINHA + 3       ; linha abaixo do boneco
	MOV  R2, COLUNA + 1      ; coluna a frente
	MOV  R5, LARGURA - 2     ; largura 
	CALL desenha_linha

	; desenha linha final do meteoro 
	MOV  R1, LINHA + 4    	 ; proxima linha
	MOV  R2, COLUNA       	 ; coluna inicial
	MOV  R5, LARGURA      	 ; largura inicial
	MOV	R4, DEF_BONECO
	ADD	R4, 2

	; desenha a ultima linha do meteoro
	CALL desenha_pixels
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET
	
desenha_pixels:       		 ; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			 ; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel	 ; escreve cada pixel do boneco
	ADD	R4, 2				 ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R5, 1				 ; menos uma coluna para tratar
    JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	RET


salta_pixel:
	ADD R2, 1

linha_meio:
	CALL escreve_pixel
	ADD  R2, 1            	 ; próxima coluna
	SUB  R5, 1            	 ; menos uma coluna para desenhar
	CMP  R5, 2            	 ; verifica se já desenhou todas as colunas
	JZ   salta_pixel
	CMP  R5, 0               ; verifica se completou a largura
	JNZ  linha_meio
	RET

desenha_linha:
	CALL escreve_pixel    	 ; escreve um pixel com a cor definida
	ADD  R2, 1            	 ; próxima coluna
	SUB  R5, 1            	 ; menos uma coluna para desenhar
	CMP  R5, 0            	 ; verifica se já desenhou todas as colunas
	JNZ  desenha_linha   	 ; continua o loop para desenhar a próxima coluna
	RET

; linha central 


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2 ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	 ; altera a cor do pixel na linha e coluna selecionadas
	RET
