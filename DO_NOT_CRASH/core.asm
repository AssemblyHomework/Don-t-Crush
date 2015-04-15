.386
.model flat,stdcall
option casemap:none

INCLUDE masm32.inc
INCLUDE core.inc

.data
mainCar CAR <>
autoCar1 CAR <>
autoCar2 CAR <>
autoCar3 CAR <>
leftCPoint POS <LEFTX,LEFTY>
rightCPoint POS <RIGHTX,RIGHTY>
inRadio dd INRADIO
outRadio dd OUTRADIO
mPai real4 PAI
mTwoPai real4 TWOPAI
mZero real4 FZERO
precision real4 10000.0
fcircle real4 CIRCLE
score DWORD 0
slowCircle DWORD SLOWCIRCLE
.code
;-----------------------------
;改变小车轨道
;receive:mCar 指向小车结构体的指针
;没有返回
ChangeWay PROC mCar:PTR CAR
	
	mov edi,mCar
	assume edi:ptr CAR
	mov eax,[edi].kind

		mov ebx,[edi].state
		mov eax,[edi].position.y
		.IF ebx == 0    ;在下直线
			mov edx,[edi].inway
			.IF edx
				mov [edi].position.y,ODOWNY
				mov [edi].cradio,OUTRADIO
			.ELSE
				mov [edi].position.y,IDOWNY
				mov [edi].cradio,INRADIO
			.ENDIF
			
		.ELSEIF ebx == 2     ;在上直线
			mov edx,[edi].inway
			.IF edx
				mov [edi].position.y,OUPY
				mov [edi].cradio,OUTRADIO
			.ELSE
				mov [edi].position.y,IUPY
				mov [edi].cradio,INRADIO
			.ENDIF
			
		.ELSE     ;在右弯道或左弯道
			mov edx,[edi].inway
			
			push eax
			push ebx
			INVOKE CalculateFloat, [edi].direction, GAP+BOARD,precision
			.IF edx
				add eax, [edi].position.x
				mov [edi].position.x,eax
				add ebx, [edi].position.y
				mov [edi].position.y,ebx
				mov [edi].cradio,OUTRADIO
			.ELSE
				mov ecx,[edi].position.x
				sub ecx,eax
				mov [edi].position.x,ecx
				mov ecx,[edi].position.y
				sub ecx,ebx
				mov [edi].position.y,ecx
				mov [edi].cradio,INRADIO
			.ENDIF
			pop ebx
			pop eax
		.ENDIF
	mov eax,[edi].inway
	not eax
	mov [edi].inway,eax
	assume edi:nothing


	ret
ChangeWay ENDP

;----------------------------------------------
;计算sin和cos与一个系数的乘积
;reveive: 弧度值（浮点数），乘系数
;return: eax中返回与sin乘的结果，ebx中返回与cos乘的结果
CalculateFloat PROC,
	radian:real4,
	mulInt:DWORD,
	 mulNum:real4
LOCAL mulsin:SDWORD
LOCAL mulcos:SDWORD

	FINIT
	FLD radian
	FSINCOS

	FMUL mulNum
	FIMUL mulInt
	FDIV mulNum
	FISTP mulcos

	FMUL mulNum
	FIMUL mulInt
	FDIV mulNum
	FISTP mulsin

	mov eax,mulsin
	mov ebx,mulcos
	ret
CalculateFloat ENDP

MoveOn PROC,
	mCar:PTR CAR
	mov edi,mCar
	assume edi:ptr CAR
	mov eax,[edi].kind
	.IF eax == 0    ;人控制的小车
		mov ebx,[edi].state
		mov eax,[edi].position.x
		.IF ebx == 0    ;在下直线
			add eax,[edi].speed
			.IF eax >= rightCPoint.x
				mov eax, rightCPoint.x
				mov [edi].state,1 
			.ENDIF
			mov [edi].position.x,eax
		.ELSEIF ebx == 2     ;在上直线
			sub eax,[edi].speed
			.IF eax <= leftCPoint.x
				mov eax, leftCPoint.x
				mov [edi].state,3 
			.ENDIF
			mov [edi].position.x,eax
		.ELSEIF ebx == 1     ;在右弯道		
			push eax
			push ebx

			FLD [edi].direction
			FADD [edi].circle
			FSTP [edi].direction
			FLD [edi].direction
			FCOMP mPai
			fnstsw ax
			sahf
			jnb L1
			INVOKE CalculateFloat,[edi].direction, [edi].cradio,precision		     
 			add eax, rightCPoint.x
			mov [edi].position.x,eax
			add ebx, rightCPoint.y
			mov [edi].position.y,ebx
			jmp L2
		L1:	
			mov eax,rightCPoint.x
			mov [edi].position.x,eax
			mov ebx,[edi].inway
			.IF ebx
				mov [edi].position.y,IUPY
			.ELSE
				mov [edi].position.y,OUPY
			.ENDIF
			mov [edi].state,2
			FLD mPai
			FSTP [edi].direction
		L2:	pop ebx
			pop eax

		.ELSE         ;在左弯道		
			push eax
			push ebx
			FLD [edi].direction
			FADD [edi].circle
			FSTP [edi].direction
			FLD [edi].direction
			FCOMP mTwoPai
			fnstsw ax
			sahf
			jnb LL1		
			INVOKE CalculateFloat, [edi].direction, [edi].cradio,precision		    
			add eax, leftCPoint.x
			mov [edi].position.x,eax
			add ebx, leftCPoint.y
			mov [edi].position.y,ebx
			jmp LL2
		LL1:	
			mov eax,leftCPoint.x
			mov [edi].position.x,eax
			mov ebx,[edi].inway
			.IF ebx
				mov [edi].position.y,IDOWNY
			.ELSE
				mov [edi].position.y,ODOWNY
			.ENDIF
			
			mov [edi].state,0
			FLD mZero
			FSTP [edi].direction
		LL2:	
			pop ebx
			pop eax

			
		.ENDIF
	;电脑控制的小车
	.ELSE
		mov ebx,[edi].state
		mov eax,[edi].position.x
		.IF ebx == 0    ;在下直线
			sub eax,[edi].speed
			.IF eax <= leftCPoint.x
				mov eax, leftCPoint.x
				mov [edi].state,3 
			.ENDIF
			mov [edi].position.x,eax
		.ELSEIF ebx == 2     ;在上直线
			add eax,[edi].speed
			.IF eax >= rightCPoint.x
				mov eax, rightCPoint.x
				mov [edi].state,1 
			.ENDIF
			mov [edi].position.x,eax
		.ELSEIF ebx == 1     ;在右弯道		
			push eax
			push ebx
			FLD [edi].direction
			FSUB [edi].circle
			FSTP [edi].direction
			FLD [edi].direction
			FCOMP mZero
			fnstsw ax
			sahf
			jna AL1

			INVOKE CalculateFloat,[edi].direction, [edi].cradio,precision

			add eax, rightCPoint.x
			mov [edi].position.x,eax
			add ebx, rightCPoint.y
			mov [edi].position.y,ebx
			jmp AL2
		AL1:	

			mov eax,rightCPoint.x
			mov [edi].position.x,eax
			mov ebx,[edi].inway
			.IF ebx
				mov [edi].position.y,IDOWNY
			.ELSE
				mov [edi].position.y,ODOWNY
			.ENDIF
			
			mov [edi].state,0
			FLD mTwoPai
			FSTP [edi].direction
		AL2:	pop ebx
			pop eax

		.ELSE         ;在左弯道
					
			push eax
			push ebx
			FLD [edi].direction
			FSUB [edi].circle
			FSTP [edi].direction
			FLD [edi].direction
			FCOMP mPai
			fnstsw ax
			sahf
			jna ALL1
			
			INVOKE CalculateFloat, [edi].direction, [edi].cradio,precision

			add eax, leftCPoint.x
			mov [edi].position.x,eax
			add ebx, leftCPoint.y
			mov [edi].position.y,ebx
			jmp ALL2
		ALL1:	
			mov eax,leftCPoint.x
			mov [edi].position.x,eax
			mov ebx,[edi].inway
			.IF ebx
				mov [edi].position.y,IUPY
			.ELSE
				mov [edi].position.y,OUPY
			.ENDIF
			
			mov [edi].state,2
			FLD mPai
			FSTP [edi].direction
		ALL2:	
			pop ebx
			pop eax
		.ENDIF
	.ENDIF
	assume edi:nothing
	ret
MoveOn ENDP

CheckCollasion PROC,
	CarA:PTR CAR,
	CarB:PTR CAR

	mov edi,CarA
	mov esi,CarB
	assume edi:ptr CAR
	assume esi:ptr CAR

	mov eax,[edi].position.x
	sub eax,[esi].position.x
	jge subAbs1
	neg eax

subAbs1:	
	
	mov ebx,[edi].position.y
	sub ebx,[esi].position.y
	jge subAbs2
	neg ebx

subAbs2:	
	.IF eax < XRADIO && ebx < YRADIO
		mov eax,1
	.ELSE
		mov eax,0
	.ENDIF
	
EXITCHECK:
	assume edi:nothing
	assume esi:nothing
	
	ret
CheckCollasion ENDP
;----------------
;return square of eax
;receive:eax
;return:eax
GetSqua PROC
	mov ebx,eax
	mov edx,0
	imul ebx

	ret
GetSqua ENDP
;---------------------------------
;将弧度数转换为角度数
;receive:弧度
;return:eax
ConvertRadian	PROC,
	cradian:real4
LOCAL cAngle:DWORD

	mov cAngle,360
	FLD cradian
	FIMUL cAngle
	FDIV mTwoPai
	FISTTP cAngle
	mov eax,cAngle

	ret
ConvertRadian ENDP

END