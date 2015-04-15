
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
	mov mCar.mwidth,XRADIO
	mov mCar.mheight,YRADIO
	mov mCar.cradio,OUTRADIO
ENDM



DrawCar MACRO mCar

	push eax
	push ebx
	push ecx
	.IF CrashTime == 0
		mov ecx,45
	.ELSE
		mov eax,45
		mov edx,0
		mov ecx,CRASHTIMES
		mul CrashTime
		div ecx
		mov ecx,eax
	.ENDIF
	mov eax,mCar.position.x
	sub eax,ecx
	add eax,GameRect.left
	mov ebx,mCar.position.y
	sub ebx,ecx
	add ebx,GameRect.top
	
	shl ecx,1
	
	INVOKE TransparentBlt,memDC,eax,ebx,ecx,ecx, imgDC,0,0,90,90,00FFFFFFH
	
	pop ecx
	pop ebx
	pop eax
ENDM

SelectAutoCarBmp MACRO autoCar

	mov eax,GameOver
	mov ebx,CollasionNum

	.IF eax && ebx == autoCar.kind
		INVOKE SelectObject,imgDC,BmpCrashCar
	.ELSE
		INVOKE ConvertRadian, autoCar.direction
		.IF	eax >= 360
			mov eax,0
		.ENDIF
		mov edx,0
		mov ebx,20
		div ebx
		mov esi,[BmpAutoCar+eax*TYPE DWORD]
		INVOKE SelectObject,imgDC,esi	
	.ENDIF

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

	mov eax,oldOne.mwidth
	mov newOne.mwidth,eax

	mov eax,oldOne.mheight
	mov newOne.mheight,eax
ENDM





