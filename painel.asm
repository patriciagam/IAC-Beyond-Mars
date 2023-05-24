; *********************************************************************************
; * Descrição: Desenha o asteriode, usando rotinas.
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  	EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

PAINEL_LINHA    EQU  27        ; linha do boneco (primeira linha do ecrã)
PAINEL_COLUNA	EQU  28        ; coluna do boneco (primeira coluna do ecrã)

PAINEL_LARGURA	EQU	15		; largura do boneco

; cores dos pixels em ARGB
VERMELHO	EQU	0FF00H
AMARELO		EQU 0FFF0H
VERDE       EQU 0F0F0H
ROXO		EQU 0F88FH
AZUL		EQU 0F0FFH
ROXIA		EQU 0FF0FH


; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H  ; espaço reservado para a pilha 
SP_inicial:				
												
DEF_PAINEL:	    ; tabela que define o boneco (cor, largura, pixels)
	WORD		PAINEL_LARGURA
	WORD		VERMELHO, ROXO, VERMELHO, ROXO, AMARELO, VERDE, AZUL, ROXIA, VERDE, VERDE, AZUL, ROXO, VERMELHO 
	WORD		ROXO, AMARELO, VERDE, AZUL, ROXIA, VERDE, VERDE, AZUL, ROXO, VERMELHO, ROXO, VERMELHO		

; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0			
inicio:
	MOV  SP, SP_inicial		; inicializa Stack Pointer
                            
	MOV  [APAGA_AVISO], R1		    ; apaga o aviso de nenhum cenário selecionado
	MOV  [APAGA_ECRÃ], R1		    ; apaga todos os pixels já desenhados
	MOV	R1, 0			    ; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1  ; seleciona o cenário de fundo
     
    MOV  R1, PAINEL_LINHA			; linha do boneco
	MOV  R2, PAINEL_COLUNA		; coluna do boneco
	MOV	R4, DEF_PAINEL		; endereço da tabela que define o boneco
	CALL	desenha_painel		; desenha o boneco

fim:
	JMP  fim                 	; termina programa


desenha_painel:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV		R5, [R4]	; obtém a largura do boneco
	MOV 	R5, PAINEL_LARGURA - 4
	ADD		R4, 2		; endereço da cor do 1º pixel (2 porque a largura é uma word)
	MOV		R3, [R4]	 		 ; obtém a cor do próximo pixel do boneco 
	CALL 	linha_meio

	; 2ª linha do painel
	MOV  R1, PAINEL_LINHA + 1       ; linha abaixo do boneco
	MOV  R2, PAINEL_COLUNA - 1      ; coluna a frente
	MOV  R5, PAINEL_LARGURA - 2     ; largura
	MOV	 R6, 11  
	CALL desenha_linha2cores

	; 3ª linha do painel 
	MOV R1, PAINEL_LINHA + 2
	MOV  R2, PAINEL_COLUNA - 2
	MOV  R5, PAINEL_LARGURA
	CALL escreve_pixel
	ADD R2, 1
	ADD R4, 2
	MOV R3, [R4]
	MOV R6, 3
	CALL desenha_linha
	MOV R6, 7
	CALL interiorColorido
	ADD R4, 2
	MOV R3, [R4]
	MOV R6, 3
	CALL desenha_linha
	ADD R4, 2
	MOV R3, [R4]
	CALL escreve_pixel


	; 4ª linha do painel
	MOV  R1, PAINEL_LINHA + 3       ; linha abaixo do boneco
	MOV  R2, PAINEL_COLUNA - 2      ; coluna a frente
	MOV  R5, PAINEL_LARGURA      	; largura 
	CALL escreve_pixel
	ADD R2, 1
	ADD R4, 2
	MOV R3, [R4]
	MOV R6, 3
	CALL desenha_linha
	MOV R6, 7
	CALL interiorColorido
	ADD R4, 2
	MOV R3, [R4]
	MOV R6, 3
	CALL desenha_linha
	ADD R4, 2
	MOV R3, [R4]
	CALL escreve_pixel

	; ultima linha
	MOV  R1, PAINEL_LINHA + 4    	 ; proxima linha
	MOV  R2, PAINEL_COLUNA - 2       ; coluna inicial
	MOV  R5, PAINEL_LARGURA      ; largura inicial
	MOV R6, 13
	CALL desenha_linha2cores
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET
	


desenha_linha2cores:       		 ; desenha os pixels do boneco a partir da tabela
	CALL	escreve_pixel	 ; escreve cada pixel do boneco 
	ADD	 R4, 2		 		 ; endereço da cor do próximo pixel
	MOV	R3, [R4]	 		 ; obtém a cor do próximo pixel do boneco
	ADD  R2, 1               ; próxima coluna
	SUB  R5, 1		 		 ; menos uma coluna para tratar 
	CALL  desenha_linha	
	ADD  R4, 2
	MOV	 R3, [R4]
	CALL  escreve_pixel     ; continua até percorrer toda a largura do objeto
	RET

linha_meio:
	CALL escreve_pixel
	ADD  R2, 1            	 ; próxima coluna
	SUB  R5, 1            	 ; menos uma coluna para desenhar
	CMP  R5, 0               ; verifica se completou a largura
	JNZ  linha_meio		 	 ; continua o loop ate percorrer a largura
	RET

desenha_linha:
	CALL escreve_pixel    	 ; escreve um pixel com a cor definida
	SUB  R6, 1
	SUB  R5, 1
	ADD  R2, 1            	 ; próxima coluna
	CMP  R6, 0            	 ; verifica se já desenhou todas as colunas
	JNZ  desenha_linha   	 ; continua o loop para desenhar a próxima coluna
	RET

interiorColorido:
	ADD R4, 2
	MOV R3, [R4]
	CALL escreve_pixel
	ADD R2, 1
	SUB R6, 1
	CMP R6, 0
	JNZ interiorColorido
	RET

escreve_pixel:
	MOV  [DEFINE_LINHA], R1  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2 ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	 ; altera a cor do pixel na linha e coluna selecionadas
	RET
