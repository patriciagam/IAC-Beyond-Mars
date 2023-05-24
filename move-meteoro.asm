; *********************************************************************************
; * Descrição: Desenha o asteriode, usando rotinas.
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
COMANDOS			EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU COMANDOS + 02H			; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  	EQU COMANDOS + 42H	; endereço do comando para selecionar uma imagem de fundo

DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periferico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periferico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periferico PIN)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

LINHA       EQU  0      ; linha do boneco (primeira linha do ecrã)
COLUNA	    EQU  0      ; coluna do boneco (primeira coluna do ecrã)

LINHA_TECLA EQU	 2		; linha da tecla que move o boneco

LARGURA		EQU	5		; largura do boneco
COR_PIXEL	EQU	0FF00H	; cor do pixel: vermelho em ARGB 

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H  ; espaço reservado para a pilha 
SP_inicial:				
												
DEF_BONECO:	    ; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL		
    
TECLA: WORD 3

; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0			
inicio:
	MOV  SP, SP_inicial		; inicializa Stack Pointer
                            
	MOV  [APAGA_AVISO], R1  ; apaga o aviso de nenhum cenário selecionado
	MOV  [APAGA_ECRÃ], R1   ; apaga todos os pixels já desenhados
	MOV	R1, 0			    ; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1  ; seleciona o cenário de fundo
     
    MOV  R1, LINHA			; linha do boneco
	MOV  R2, COLUNA			; coluna do boneco
	MOV	R4, DEF_BONECO		; endereço da tabela que define o boneco
	CALL	desenha_boneco	; desenha o boneco

fim:
	JMP  fim                ; termina programa


; *********************************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;		com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
; *********************************************************************************

desenha_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]	; obtém a largura do boneco
	ADD	R4, 2		; endereço da cor do 1º pixel (2 porque a largura é uma word)
	CALL desenha_pixels
	
	; 2ª linha do meteoro
	ADD  R1, 1          ; linha abaixo do boneco
	MOV  R2, R1         ; coluna a frente
	MOV  R5, LARGURA-2  ; largura 
	CALL desenha_linha
	
	; desenha linha do meio
	ADD  R1, 1
	SUB  R2, 4
	MOV  R5, LARGURA-1
	CALL linha_meio

	; 4ª linha do meteoro
	ADD  R1, 1       
	SUB  R2, 4
	MOV  R5, LARGURA-2
	CALL desenha_linha

	; linha final do meteoro 
	ADD  R1, 1   	 		 ; proxima linha
	SUB  R2, 4      	     ; coluna inicial
	MOV  R5, LARGURA      	 ; largura inicial
	MOV	R4, DEF_BONECO
	ADD	R4, 2
	CALL desenha_pixels
	POP	R5
	POP	R4
	POP	R3
	POP	R2

inicio_linha:		
; inicializações
    MOV  R3, TEC_LIN   ; endereço do periferico das linhas
    MOV  R5, TEC_COL   ; endereço do periferico das colunas
    MOV  R7, DISPLAYS  ; endereço do periferico dos displays
    MOV  R8, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; corpo principal do programa
ciclo:
    MOV  R6, 0 
    MOVB [R7], R6      ; escreve linha e coluna a zero nos displays

;espera_tecla:          ; neste ciclo espera-se ate uma tecla ser premida
	;MOV  R6, [TECLA]
    ;MOVB [R3], R6      ; escrever no periferico de saida (linhas)
    ;MOVB R0, [R5]      ; ler do periferico de entrada (colunas)
    ;AND  R0, R8        ; elimina bits para alem dos bits 0-3
    ;CMP  R0, 0         ; ha tecla premida?
    ;JZ   espera_tecla  ; se nenhuma tecla premida, repete

	;MOV R6, [R5]      ; lê o valor das colunas do teclado e armazena em R6
    ;MOVB [R3], R6     ; escreve no periférico de saída (linhas)
    ;AND R6, R8        ; elimina bits além dos bits 0-3
    ;CMP R6, 0         ; há tecla pressionada?
    ;JZ espera_tecla    ; se nenhuma tecla pressionada, repete
    
    
ha_tecla:                 ; neste ciclo espera-se at� NENHUMA tecla estar premida
    MOV  R6, [TECLA]      ; testa a tecla
    MOVB [R3], R1         ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R5]         ; ler do perif�rico de entrada (colunas)
    AND  R0, R8           ; elimina bits para al�m dos bits 0-3
    CMP  R0, R6           ; Se a tecla pressionada não for 4, continua a espera
    JNZ  ha_tecla         ; se ainda houver uma tecla premida, espera at� n�o haver
	MOV  R9, R1
    MOV  [APAGA_ECRÃ], R9 ; apaga todos os pixels já desenhados
 
; Move o meteoro para a próxima linha e coluna na diagonal
move_meteoro:
    SUB R1, 3		       ; linha do boneco
	ADD R2, 1		       ; coluna do boneco   
	MOV	 R4, DEF_BONECO	   ; endereço da tabela que define o boneco
    CALL desenha_boneco
    JMP ciclo              ; Retorna ao início do ciclo principal
	RET
	
desenha_pixels:       	   ; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]	       ; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel  ; escreve cada pixel do boneco
	ADD	R4, 2		       ; endereço da cor do próximo pixel
	ADD  R2, 1             ; próxima coluna
	SUB  R5, 1		       ; menos uma coluna para tratar
	JNZ  desenha_pixels    ; continua até percorrer toda a largura do boneco
	RET

salta_pixel:               ; salta um pixel para desenhar a linha do meio
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

; *********************************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
; *********************************************************************************

escreve_pixel:
	MOV  [DEFINE_LINHA], R1  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2 ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	 ; altera a cor do pixel na linha e coluna selecionadas
	RET

; quando se pressiona a tecla 4 do teclado, o meteoro avança uma linha para baixo

