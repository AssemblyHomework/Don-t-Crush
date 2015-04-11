
Init MACRO mCar,mx,my,mdirection,mkind
	mov mCar.position.x,mx
	mov mCar.position.y,my
	FLD mdirection
	FSTP mCar.direction
	mov mCar.state,0
	mov mCar.inway,0	;;0FFFFFFFFH表示在里道
	mov mCar.speed,SPEED
	FLD fcircle
	FSTP mCar.circle
	mov mCar.kind,mkind
	mov mCar.area,RADIO
	mov mCar.cradio,OUTRADIO
ENDM

CarRect MACRO mCar, mrect
	push eax
	push ebx
	mov eax,mCar.position.x
	sub eax,RADIO/2
	add eax,GameRect.left
	mov mrect.left,eax
	add eax,RADIO
	mov mrect.right,eax

	mov ebx,mCar.position.y
	sub ebx,RADIO/2
	add ebx,GameRect.top
	mov mrect.top,eax
	add eax,RADIO
	mov mrect.left,eax

	
	pop ebx
	pop eax

ENDM

DrawCar MACRO mCar
	push eax
	push ebx
	mov eax,mCar.position.x
	sub eax,RADIO/2
	add eax,GameRect.left
	mov ebx,mCar.position.y
	sub ebx,RADIO/2
	add ebx,GameRect.top

	INVOKE BitBlt,memDC,eax,ebx,mainCar.area,mainCar.area,imgDC,0,0,SRCCOPY
	pop ebx
	pop eax
ENDM
;return eax
Random MACRO	range
	push ecx
	INVOKE nrandom,range
	pop ecx
ENDM

Change MACRO target, Num, kind
	push eax
	push ebx
	mov eax,Num
	mov ebx,kind
	.IF ebx == 1
	    and eax,000000FFH
	.ELSEIF ebx == 2
	    and eax,0000FF00h
	    shr eax,8
	.ELSE
		and eax,0FF0000h
		shr eax,16
	.ENDIF

	.IF eax > POSIBILITY
		mov target,0
	.ELSE
		mov target,1
	.ENDIF
	pop ebx
	pop eax
ENDM

CopyCar MACRO newOne, oldOne
	mov eax,oldOne.position.x
	mov newOne.position.x,eax
	mov eax,oldOne.position.y
	mov newOne.position.y,eax

	FLD oldOne.direction
	FSTP newOne.direction

	mov eax,oldOne.state
	mov newOne.state,eax

	mov eax,oldOne.inway
	mov newOne.inway,eax

	mov eax,oldOne.speed
	mov newOne.speed,eax

	FLD oldOne.circle
	FSTP newOne.circle

	mov eax,oldOne.kind
	mov newOne.kind,eax

	mov eax,oldOne.area
	mov newOne.area,eax

ENDM

