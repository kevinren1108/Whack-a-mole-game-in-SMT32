; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014

;;; Directives
            PRESERVE8
            THUMB       

        		 
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value

;The offboard DIP Switch will be on port A bits 0 thru 3
;PORT A GPIO - Base Addr: 0x40010800
GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOA_CRH	EQU		0x40010804	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOA_IDR	EQU		0x40010808	; (0x08) Port Input Data Register
GPIOA_ODR	EQU		0x4001080C	; (0x0C) Port Output Data Register
GPIOA_BSRR	EQU		0x40010810	; (0x10) Port Bit Set/Reset Register
GPIOA_BRR	EQU		0x40010814	; (0x14) Port Bit Reset Register
GPIOA_LCKR	EQU		0x40010818	; (0x18) Port Configuration Lock Register

;PORT B GPIO - Base Addr: 0x40010C00
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOB_CRH	EQU		0x40010C04	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOB_IDR	EQU		0x40010C08	; (0x08) Port Input Data Register
GPIOB_ODR	EQU		0x40010C0C	; (0x0C) Port Output Data Register
GPIOB_BSRR	EQU		0x40010C10	; (0x10) Port Bit Set/Reset Register
GPIOB_BRR	EQU		0x40010C14	; (0x14) Port Bit Reset Register
GPIOB_LCKR	EQU		0x40010C18	; (0x18) Port Configuration Lock Register

;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOC_CRH	EQU		0x40011004	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOC_IDR	EQU		0x40011008	; (0x08) Port Input Data Register
GPIOC_ODR	EQU		0x4001100C	; (0x0C) Port Output Data Register
GPIOC_BSRR	EQU		0x40011010	; (0x10) Port Bit Set/Reset Register
GPIOC_BRR	EQU		0x40011014	; (0x14) Port Bit Reset Register
GPIOC_LCKR	EQU		0x40011018	; (0x18) Port Configuration Lock Register

;Registers for configuring and enabling the clocks
;RCC Registers - Base Addr: 0x40021000
RCC_CR		EQU		0x40021000	; Clock Control Register
RCC_CFGR	EQU		0x40021004	; Clock Configuration Register
RCC_CIR		EQU		0x40021008	; Clock Interrupt Register
RCC_APB2RSTR	EQU	0x4002100C	; APB2 Peripheral Reset Register
RCC_APB1RSTR	EQU	0x40021010	; APB1 Peripheral Reset Register
RCC_AHBENR	EQU		0x40021014	; AHB Peripheral Clock Enable Register

RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register  -- Used

RCC_APB1ENR	EQU		0x4002101C	; APB1 Peripheral Clock Enable Register
RCC_BDCR	EQU		0x40021020	; Backup Domain Control Register
RCC_CSR		EQU		0x40021024	; Control/Status Register
RCC_CFGR2	EQU		0x4002102C	; Clock Configuration Register 2

STACK_POINTER EQU 0x20001000
; Times for delay routines
        
DELAYTIME	EQU		1600000		; (200 ms/24MHz PLL)
halfDELAYTIME EQU    800000
quatDELAYTIME EQU    400000


; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY

Reset_Handler		PROC

	BL GPIO_ClockInit
	BL GPIO_init
	LDR R3, =DELAYTIME
	ldr r6, = STACK_POINTER
	b UC2
	ENDP

;This routine will enable the clock for the Ports that you need	
	ALIGN
GPIO_ClockInit PROC

	; Students to write.  Registers   .. RCC_APB2ENR
	; ENEL 384 Pushbuttons: SW2(Red): PB8, SW3(Black): PB9, SW4(Blue): PC12 *****NEW for 2015**** SW5(Green): PA5
	; ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12
	ldr r0,=RCC_APB2ENR
	ldr r1,[r0] ;load value store in address r0 to r1
	orr r1,#0x1c 
	str r1,[r0] ;save value in r1 to address r0
	BX LR
	ENDP
		
;This routine enables the GPIO for the LED's.  By default the I/O lines are input so we only need to configure for ouptut.
	ALIGN
GPIO_init  PROC
	
	; ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12
	ldr r0,=0x40010804 ; 0x40010804 (0x04) Port Configuration Register for Px15 -> Px8
	ldr r1,=0x44433334
	str r1,[r0]
	ldr r4,=0x40010800 ; port A GPIO (0x00) Port Configuration Register for Px7 -> Px0
	ldr r1,[r4]
	and r1,#0xfffffff0
	orr r1,#4
	str r1,[r4]
	ldr r0,=0x4001080C ; 0x4001080C (0x0C) Port A Output Data Register
	ldr r1,[r0]
	eor r1,#0x1e00 ;1111000000000
	str r1,[r0] ;turn off all leds
	
	
    BX LR
	ENDP

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;The game enter a start up status. A LED pattern will indicating that no
;;;game is in progress and the game is waiting for a player to start by press any
;;;of the four switch
;;;Require:
;;;	N/A
;;;Promise:
;;;	Keep indicate the led pattern until any switch was pressed
;;;Note:
;;;	The first two line is used to reset game condition in any case the game restart 
;;; after one round

	ALIGN
UC2 PROC; 4 leds cycling back and forth at 1Hz
	ldr r10,=400000 ; reset variable delay counter's maxium use for variable delay time
	bl offLed ; Turn off any led 

	mov r8, #0
;;;;;;;;;;;;;;;;;;LED1
	bl led1Light ; turn on led 1
	bl testKeyPress ; test if any switch was pressed
	bl delay ; delay 
	bl offLed ; turn off all led
;;;;;;;;;;;;;;;;;;LED2
	bl led2Light
	bl testKeyPress	
	bl delay
	bl offLed	
;;;;;;;;;;;;;;;;;;LED3
	bl led3Light
	bl testKeyPress
	bl delay
	bl offLed
;;;;;;;;;;;;;;;;;;LED4
	bl led4Light	
	bl testKeyPress
	bl delay
	bl offLed
;;;;;;;;;;;;;;;;;;LED3
	bl led3Light
	bl testKeyPress
	bl delay
	bl offLed
;;;;;;;;;;;;;;;;;;LED2
	bl led2Light
	bl testKeyPress
	bl delay
	b UC2 ; go back to UC2 if no switch was pressed and the led patten will keep go back and forth by order 1-2-3-4-3-2-1-2-3-4-3-2-1
	ENDP	
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A special led patten to indicate any status change
;;; Promiss:
;;; 	N/A
;;;	Require:
;;;		N/A
;;; Note:
;;; 	special used for status change from UC2 to UC3
	ALIGN
ledStatusPatten PROC; 4 leds cycling back and forth at 1Hz
;;;;;;;;;;;;;;;;;;LED1
	bl offLed
	bl led1Light 
	bl quatDelay
	bl offLed
;;;;;;;;;;;;;;;;;;LED2
	bl led2Light 
	bl quatDelay
	bl offLed
;;;;;;;;;;;;;;;;;;LED3
	bl led3Light
	bl quatDelay
	bl offLed
;;;;;;;;;;;;;;;;;;LED4
	bl led4Light 	
	bl quatDelay
	bl offLed
;;;;;;;;;;;;;;;;;;LED3
	bl led3Light 
	bl quatDelay
	bl offLed
;;;;;;;;;;;;;;;;;;LED2
	bl led2Light
	bl quatDelay
	bl offLed
;;;;;;;;;;;;;;;;;;AllLed
	bl allLedOn
	bl quatDelay
	bl offLed
	bl quatDelay
	bl allLedOn
	bl quatDelay
	bl offLed
	bl quatDelay
	bl allLedOn
	bl quatDelay
	bl offLed
	bl quatDelay
	B UC3
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine for turn on led 1
;;; Require:
;;;		R0: ptr to GPIOA_ODR
;;;		R1: right value that just turn on led 1
;;; Promise:
;;;		Reset timing delay counter to zero and turn on led 1
	ALIGN
led1Light PROC
	mov r4,#0
	ldr r0,=0x4001080C
	ldr r1,=0x0000bc00
	str r1,[r0] 
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine for turn on led 2
;;; Require:
;;;		R0: ptr to GPIOA_ODR
;;;		R1: right value that just turn on led 2
;;; Promise:
;;;		Reset timing delay counter to zero and turn on led 2		
	ALIGN
led2Light PROC
	mov r4,#0
	ldr r0,=0x4001080C
	ldr r1,=0x00001a01
	str r1,[r0] 
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine for turn on led 3
;;; Require:
;;;		R0: ptr to GPIOA_ODR
;;;		R1: right value that just turn on led 3
;;; Promise:
;;;		Reset timing delay counter to zero and turn on led 3		
	ALIGN
led3Light PROC
	mov r4,#0
	ldr r0,=0x4001080C
	ldr r1,=0x00001601
	str r1,[r0] 
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine for turn on led 4
;;; Require:
;;;		R0: ptr to GPIOA_ODR
;;;		R1: right value that just turn on led 4
;;; Promise:
;;;		Reset timing delay counter to zero and turn on led 4		
	ALIGN
led4Light PROC
	mov r4,#0
	ldr r0,=0x4001080C
	ldr r1,=0x00000E01
	str r1,[r0] 
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine for turn on all led 
;;; Require:
;;;		R0: ptr to GPIOA_ODR
;;;		R1: right value that turn on all led 
;;; Promise:
;;;		N/A	
	ALIGN
allLedOn PROC
	PUSH {r0,r1,r2,r3,r4,r5,r6}
	ldr r0,=0x4001080C
	mov r1,#0x00000001
	str r1,[r0] 
	POP {r0,r1,r2,r3,r4,r5,r6}
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine for turn off all led 
;;; Require:
;;;		R0: ptr to GPIOA_ODR
;;;		R1: right value that turn off all led 
;;; Promise:
;;;		N/A		
	ALIGN
offLed PROC
	mov r4,#0
	ldr r0,=0x4001080C
	orr r1,#0x1e00
	str r1,[r0]
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test if any of the 4 switch was pressed, if any one of the switch was press jump to UC3
;;; Require:
;;;		N/A 
;;; Promise:
;;;		N/A	
	ALIGN
testKeyPress PROC
	ldr r0,=0x40010C08
	ldr r1,[r0] ;test if sw1 press
	lsr r1,#8 
	and r1,#1
	cmp r1,#1
	bne UC2ToUC3
		
	ldr r0,=0x40010C08
	ldr r1,[r0] ;test if sw2 press
	lsr r1,#9
	and r1,#1
	cmp r1,#1
	bne UC2ToUC3

	ldr r0,=0x40011008
	ldr r1,[r0] ;test if sw3 press
	lsr r1,#12
	and r1,#1
	cmp r1,#1
	bne UC2ToUC3
	
	ldr r0,=0x40010808
	ldr r1,[r0] ;test if sw4 press
	lsr r1,#5
	and r1,#1
	cmp r1,#1
	bne UC2ToUC3
	bx lr
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine that counting from 0 to 1600000 that same as sleep() in c
;;; Require:
;;;		N/A 
;;; Promise:
;;;		Not change any register before and after the subroutine called
;;; Note:
;;;		Have to place this subroutine here to avoid the literal pool too distance
	ALIGN
delay PROC
	push {r0, r1, r2, r3, r4}
	ldr r3,=1600000
delayLoop
	add r4, #1
	cmp r3, r4
	bne delayLoop
	pop {r0, r1, r2, r3, r4} 
	BX LR
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine that counting from 0 to 400000 that same as sleep() in c
;;; Require:
;;;		N/A 
;;; Promise:
;;;		Not change any register before and after the subroutine called
;;; Note:
;;;		Have to place this subroutine here to avoid the literal pool too distance
	ALIGN
quatDelay PROC
	push {r0, r1, r2, r3, r4}
	ldr r3,=400000 
quatDelayLoop
	add r4, #1
	cmp r3, r4
	bne quatDelayLoop
	pop {r0, r1, r2, r3, r4}
	BX LR
	ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine that counting from 0 to the value in r10 that same as sleep() in c
;;; Require:
;;;		r10 is the value that greater enough for human reaction 
;;; Promise:
;;;		Not change any register before and after the subroutine called
;;; Note:
;;;		Have to place this subroutine here to avoid the literal pool too distance		
	ALIGN
variableDelay PROC
	push {r0, r1, r2, r3, r4}
variableDelayLoop
	add r4, #1
	cmp r10, r4
	bne variableDelayLoop
	pop {r0, r1, r2, r3, r4}
	BX LR
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A jumper that connect UC2 to UC3 because there is a led patten should be perform 
;;; in between UC2 and UC3
;;; Require:
;;;		N/A
;;; Promise:
;;;		change value in register r12 to 4, this value is used to make sure the random 
;;;		never repeate 	
	ALIGN
UC2ToUC3 PROC
	bl ledStatusPatten
	mov r12, #0x4
	ENDP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Use case 3, initial all condition for a normal game play round
;;; Require:
;;;		N/A
;;; Promise:
;;;		turn off all led in case. call random function to generate a random number
;;;		and based on the number that generated to turn on the corresponding led
;;; Note:
;;;		R9 is using for variableDelay function, the value in r9 will countrol how
;;;		the variale delay working
	ALIGN
UC3 PROC
	ldr r9,= 15000
	sub r10,r10, r9
	bl offLed
	bl quatDelay
	bl random; 
	bl gameStart
	bl offLed
	bl quatDelay
	bl random; 
	bl gameStart
	bl offLed
	bl quatDelay
	bl random; 
	bl gameStart
	bl offLed
	bl quatDelay
	bl random; 
	bl gameStart
	bl offLed
	bl quatDelay
	bl random; 
	bl gameStart
	ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; based on the number random, turn on led
;;; Require:
;;;		r5 has a value between 0 to 3
;;; Promise:
;;;		keep track the number of round plays, when it reach to 15(successed game),
;;;		jump to final success use case(UC4)
	ALIGN
gameStart PROC
	cmp r8, #15
	beq endSuccess
	cmp r5, #0x0
	beq led0
	cmp r5, #0x1
	beq led1
	cmp r5, #0x2
	beq led2
	cmp r5, #0x3
	beq led3
	bx lr
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutine led0 to led 3 is using to turn on led and then try find in any 
;;; switch is pressed
;;; Require:
;;;		N/A
;;; Promise:
;;;		N/A
	ALIGN
led0 PROC
	bl led1Light 	
	b catchSwitch
	ENDP

	ALIGN
led1 PROC
	bl led2Light 
	b catchSwitch
	ENDP
		
	ALIGN
led2 PROC
	bl led3Light 
	b catchSwitch
	ENDP

	ALIGN
led3 PROC
	bl led4Light 
	b catchSwitch
	ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pick the value from the current stack pointer(r6) and find the remainder from this value
;;; devided by 4, check if this value is same as the previse random value, if no, finish random.
;;; Otherwise, random again. Finally move the ptr to next address by adding the random value to
;;; the address and store the random value to r5.
;;; Require:
;;;		r6 is pointing to the initial value of the stack pointer.
;;; Promise:
;;;		r5 will save a random value.
	ALIGN
random PROC
	push {r0, r1, r2, r3, r4}
	mov r0, r6
	ldr R1, [r0]
	and r1, r1, #0x000000ff
	mov r2, #0x4
	udiv r3, r1, r2; r3 = r1 / r2
	mls r5, r3, r2, r1 ; r5 = r1 - (r2 * r3), remainder
	add r6, r6, #1
	cmp r5, r12
	beq random
	mov r12, r5
	pop {r0, r1, r2, r3, r4}
	bx lr
	ENDP	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; check if any switch was pressed 
;;; Require:
;;;		N/A
;;; Promise:
;;;		if no swithch has been pressed, jump to end eailure(UC5), if any switch
;;;		was pressed, save the corrsponding number to r11.
	ALIGN
catchSwitch PROC
	bl variableDelay
	LDR R3, = 10
	add r4, r4, #1
	cmp r3, r4
	beq endFailure	
	ldr r0,=0x40010C08 ;test if sw1 press
	ldr r1,[r0] 
	lsr r1,#8 
	and r1,#1
	cmp r1,#1
	bne onePress
	ldr r0,=0x40010C08 ;test if sw2 press
	ldr r1,[r0] 
	lsr r1,#9
	and r1,#1
	cmp r1,#1
	bne twoPress
	ldr r0,=0x40011008 ;test if sw3 press
	ldr r1,[r0] 
	lsr r1,#12
	and r1,#1
	cmp r1,#1
	bne threePress
	ldr r0,=0x40010808 ;test if sw4 press
	ldr r1,[r0] 
	lsr r1,#5
	and r1,#1
	cmp r1,#1
	bne fourPress
	b catchSwitch
onePress
	mov r11, #0
	b checkResult
twoPress
	mov r11, #1
	b checkResult
threePress
	mov r11, #2
	b checkResult
fourPress
	mov r11, #3
	b checkResult
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; check if the switch has been pressed is corrsponding as the led order.
;;; Require:
;;;		r5 is the No of led is on
;;;		r11 is the No of swithc is pressed
;;; Promise:
;;;		jump to add score if press correct, or jump to fail if press is incorrect
	ALIGN
checkResult PROC
	cmp r5,r11
	beq addScore
	bne endFailure
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; add one score
;;; Require:
;;;		N/A
;;; Promise:
;;;		N/A
	ALIGN
addScore PROC
	add r8, r8, #1
	b UC3
	ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; show led patten indcate game fail and display score
;;; Require:
;;;		N/A
;;; Promise:
;;;		N/A
	ALIGN
endFailure PROC
	bl offLed
	bl quatDelay
	bl allLedOn
	bl quatDelay
	bl offLed
	bl quatDelay
	bl allLedOn
	bl quatDelay
	bl offLed
	bl displayScore
	ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; show led patten indcate game success and display score
;;; Require:
;;;		N/A
;;; Promise:
;;;		N/A		
	ALIGN
endSuccess PROC
	bl offLed
	bl allLedOn
	bl delay
	bl delay
	bl delay
	bl delay
	b UC2
	ENDP	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; display score
;;; Require:
;;;		r8 is the value of score 
;;; Promise:
;;;		N/A
	ALIGN
displayScore PROC
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8}
	ldr r3,=6400000
	ldr r0,=0x4001080C
	ldr r1,[r0]
	cmp r8, #0
	beq score0
	cmp r8, #1
	beq score1
	cmp r8, #2
	beq score2
	cmp r8, #3
	beq score3
	cmp r8, #4
	beq score4
	cmp r8, #5
	beq score5
	cmp r8, #6
	beq score6
	cmp r8, #7
	beq score7
	cmp r8, #8
	beq score8
	cmp r8, #9
	beq score9
	cmp r8, #10
	beq score10
	cmp r8, #11
	beq score11
	cmp r8, #12
	beq score12
	cmp r8, #13
	beq score13
	cmp r8, #14
	beq score14
score0
	ldr r2,=zero
	b turnOnLed
score1
	ldr r2,=one
	b turnOnLed
score2
	ldr r2,=two
	b turnOnLed
score3
	ldr r2,=three
	b turnOnLed
score4
	ldr r2,=four
	b turnOnLed
score5
	ldr r2,=five
	b turnOnLed
score6
	ldr r2,=six
	b turnOnLed
score7
	ldr r2,=seven
	b turnOnLed
score8
	ldr r2,=eight
	b turnOnLed
score9
	ldr r2,=nine
	b turnOnLed
score10
	ldr r2,=ten
	b turnOnLed
score11
	ldr r2,=eleven
	b turnOnLed
score12
	ldr r2,=twelve
	b turnOnLed
score13
	ldr r2,=thirteen
	b turnOnLed
score14
	ldr r2,=fourteen
	b turnOnLed
turnOnLed
	add r4,r4,#1
	and r1,r1,r2
	str r1,[r0] 
	cmp r3, r4
 	bne turnOnLed
	mov r8, #0
	b UC2
	ENDP
		
zero		EQU 0xFFFFFFFF
one 		EQU 0xFFFFEFFF
two 		EQU 0xFFFFF7FF
three 		EQU 0xFFFFE7FF
four 		EQU 0xFFFFFBFF
five 		EQU 0xFFFFEBFF
six  		EQU	0xFFFFF3FF
seven 		EQU 0xFFFFE3FF
eight 		EQU 0xFFFFFDFF
nine		EQU 0xFFFFEDFF
ten			EQU 0xFFFFF5FF
eleven		EQU 0xFFFFE5FF
twelve 		EQU 0xFFFFF9FF
thirteen	EQU 0xFFFFE9FF
fourteen	EQU 0xFFFFF1FF
	
	ALIGN
	END
		