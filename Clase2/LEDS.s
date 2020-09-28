SYSCTL_RCGCGPIO_R	EQU 0x400FE608 ; INICIO DEL RELOJ
GPIO_PORTF_AMSEL_R	EQU 0x40025528 ; ELIMINA EL ANALOGO DEL PUERTO F
GPIO_PORTF_PCTL_R	EQU 0x4002552C ; CONFIGURACION GPIO
GPIO_PORTF_DIR_R	EQU 0x40025400 ; DIRECCION DEL REGISTRO
GPIO_PORTF_AFSEL_R	EQU 0x40025420 ; ELIMINA CUALQUIER OTRA SE�AL DEL PUERTO
GPIO_PORTF_DEN_R	EQU 0x4002551C ; PUERTOS DIGITALES
PF2					EQU 0x40025010 ; HABILITACION DEL PUERTO F2
CONSTANTE			EQU 2000000

	AREA codigo, CODE, READONLY, ALIGN=2
	THUMB ; ES ELQUE DEFINE EL USO DE LAS INSTRUCCIONES
	
	EXPORT Start ;DECLARACION DE Start COMO GLOBAL
		
Start ;PUNTO DE ENTRADA A PARTIR DEL STARTUP
;PASO 1: ACTIVACION DEL RELOJ PARA PUERTO F
	LDR R1, =SYSCTL_RCGCGPIO_R
	LDR R0, [R1]
	ORR R0, R0,#0x20
	STR R0, [R1]
	NOP
	NOP
;PASO 2: DESBLOQUEO DE PINES. EN ESTE CASO LOS PINES ESTAN LIBRES
;EN ESTE PROGRAMA NO HAY PINES QUE NECESITEN DESBLOQUEO
;PASO 3: DESHABILITAR FUNCION ANALOGICA
	LDR R1, =GPIO_PORTF_AMSEL_R
	LDR R0, [R1]
	BIC R0, R0,#0x04
	STR R0, [R1]
;PASO 4; CONFIGURACION DEL GPIO, PCTL=0
	LDR R1, =GPIO_PORTF_PCTL_R
	LDR R0, [R1]
	BIC R0, R0,#0x00000F00
	STR R0, [R1]
;PASO 5: ESPECIFICAR LA DIRECCION
	LDR R1, =GPIO_PORTF_DIR_R
	LDR R0, [R1]
	ORR R0, R0,#0x04
	STR R0, [R1]
;PASO 6: LIMPIAR LOS BITS EN FUNCION ALTERNATIVA
	LDR R1, =GPIO_PORTF_AFSEL_R
	LDR R0, [R1]
	BIC R0, R0,#0x04
	STR R0, [R1]
;PASO 7: HABILITAR EL PUERTO DIGITAL
	LDR R1, =GPIO_PORTF_DEN_R
	LDR R0, [R1]
	BIC R0, R0,#0x04
	STR R0, [R1]
	
	B Loop
	
PAUSA ;RETARDO DE 1s
	ADD R0, #1
	NOP
	NOP
	NOP
	NOP
	CMP R0, R1
	BNE PAUSA
	BX LR ;BIFURCACION, DETERMINA EL ESTADO DEL PROCESADOR
	
Loop ;CICLO PARA ENCENDER Y APAGAR EL LED 
;CARGAR EN R0 EL CONTENIDO DE LA DIRECCION DE MEMORIA A LA QUE 
;APUNTA R1 (PF2)
	LDR R1, =PF2
	LDR R0, [R1]
	;LED NEGADO
	EOR R0, R0, #0x04 ; XOR
	STR R0, [R1]
	;REINICIAMOS LA PAUSA
	LDR R0, =0
	LDR R1, =CONSTANTE
	BL PAUSA
	;REPETICION
	B Loop
	
	ALIGN 
	END
