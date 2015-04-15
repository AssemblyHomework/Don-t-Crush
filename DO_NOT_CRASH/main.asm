TITLE main.asm      
.386      
.model flat,stdcall      
option casemap:none    

INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
INCLUDELIB gdi32.lib
INCLUDELIB masm32.lib
INCLUDELIB comctl32.lib
INCLUDELIB winmm.lib
INCLUDELIB msimg32.lib

INCLUDE msimg32.inc
INCLUDE masm32.inc
INCLUDE windows.inc
INCLUDE user32.inc
INCLUDE kernel32.inc
INCLUDE gdi32.inc
INCLUDE comctl32.inc
INCLUDE winmm.inc 

INCLUDE rscr.inc ;资源
INCLUDE core.inc
INCLUDE main.inc  ;MACRO定义


;函数包含
WinMain PROTO hInst:HINSTANCE,hPrevInstance:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
ErrorHandler PROTO
InitRect PROTO
resetGame PROTO
PaintProc PROTO hWid:DWORD
ShowScore PROTO target:DWORD
InitAniChange PROTO mCar:PTR CAR,mdisR:PTR DWORD
AniMoveOn PROTO mCar:PTR CAR, ticks:DWORD, mdisR:DWORD
JudgeChange PROTO
PlayMp3File PROTO hWin:DWORD,NameOfFile:DWORD
PlayMp3StartFile PROTO hWin:DWORD,NameOfFile:DWORD
PlayMp3CrashFile PROTO hWin:DWORD,NameOfFile:DWORD
LoadRecordFile PROTO
StoreRecordFile PROTO
TimerProc PROTO
ShowBest PROTO
CheckGood PROTO


;常量宏定义

INTERVAL equ 10
STOPTICK equ 90
CHANGETICK equ 50
GOODTICK equ 30
POSIBILITY TEXTEQU <077H>
changeoffset = 0
carID = 164
DO_NOT_SHARE EQU 0 
GOODDISTANCE EQU 160
STARTTIMES = 50
CRASHTIMES = 100
.data
StartTime dd 0
CrashTime dd 0 

StartFlag dd 0 

GoodTicks dd 0
GoodFlag dd 0
Best dd 0
NewBest dd 0
hFile HANDLE INVALID_HANDLE_VALUE
PlayFlag dd 0
MusicFileName BYTE "..\DO_NOT_CRASH\resource\Music\bgm.mp3",0
StartName BYTE "..\DO_NOT_CRASH\resource\Music\start.wav",0
CrashName BYTE "..\DO_NOT_CRASH\resource\Music\Crash.mp3",0

Mp3Device   BYTE "MPEGVideo",0
Mp3StartDevice   BYTE "MPEGVideo",0
Mp3CrashDevice   BYTE "MPEGVideo",0

RecordFileName BYTE "best.txt",0

Mp3DeviceID dd 0
Mp3TurnDeviceID dd 0
Mp3ScoreDeviceID dd 0
Mp3StartDeviceID dd 0
Mp3DepartDeviceID dd 0
Mp3CrashDeviceID dd 0

disR1 dd 0
disR2 dd 0
disR3 dd 0

stopticks dd 0
changeticks1 dd 0
changeticks2 dd 0
changeticks3 dd 0

oldscore dd 0
oldx dd 0
oldx1 dd 0
oldx2 dd 0
oldx3 dd 0
GameOver dd 0			;1表示游戏结束
CollasionNum dd 1		;撞车的车序号
Stop dd 0				;1表示暂停
BgColor dd 00EFF8FAh ;00bbggrr
TextBgColor dd 00EE0000h 
ClassName dd "wc",0
WndWidth dd 1168
WndHeight dd 675
WndRect RECT <>
WindowName dd "DNC",0
ClientOffX dd 0
ClientWidth dd 1147
ClientOffY dd 0
ClientHeight dd 612
GameRect RECT <>
NumberOffX dd 498
NumberWidth dd 150
NumberOffY dd 285
NumberHeight dd 70
NumberRect RECT <>

BestOffX0 dd 489
BestWidth0 dd 100
BestOffY0 dd 355
BestHeight0 dd 70

BestOffX dd 589
BestWidth dd 70
BestOffY dd 355
BestHeight dd 70

GoodOffX dd 489
GoodWidth dd 150
GoodOffY dd 285
GoodHeight dd 70

BestRect RECT <>
BestRect0 RECT <>
GoodRect RECT <>

AllCarRect RECT <>
;菜单有关数据
hMenu dd ?
MenuNewG BYTE "NEW",0
MenuPlayM BYTE "PLAY MUSIC",0
MenuStopM BYTE "STOP MUSIC",0
MenuAbout BYTE "ABOUT",0
MenuHelpP BYTE "HELP",0
MenuFile BYTE "File",0
MenuOther BYTE "Other",0
;得分
ScoreText BYTE 3 DUP (?),0
BestText BYTE 3 DUP (?),0
BestText0 BYTE "best:",0
;Good
GoodText BYTE "GOOD+1",0
;字体名
FontName BYTE "abc",0
FontName1 BYTE "sabc",0
;消息窗口内容
MsgTitle BYTE 0
Author BYTE "I,YOU,HE",0
GameOverText BYTE "Game Over, press ENTER to restart",0
Help BYTE "SPACE:change way",0
.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
bgBrush dd ?
textBgBrush dd ?
WndOffX dd ?
WndOffY dd ?
hWnd dd ?
hDC dd ?
memDC dd ?
imgDC dd ?
imgMDC dd ?
hBitmap dd ?
;位图句柄
BmpRunway dd ?
BmpMainCar dd 18 DUP (?)

BmpAutoCar dd 18 DUP (?)
BmpCrashCar dd ?
BmpMaskCar dd ?
;字体
textFont HFONT ?
bestFont HFONT ?
;判断是否改变自动控制小车车道
Change1 dd ?
Change2 dd ?
Change3 dd ?
;判断是否正在分开
Depart  dd ?
;判断是否正在改变车道
AniChange1 dd ? 
AniChange2 dd ?
AniChange3 dd ?
.code
start:
	INVOKE GetTickCount
	INVOKE nseed,eax

	INVOKE GetModuleHandle,0
	mov hInstance,eax

	INVOKE GetCommandLine
	mov CommandLine,eax

	INVOKE WinMain,hInstance,0,CommandLine,SW_SHOWDEFAULT
	INVOKE ExitProcess,eax
;====================================================================
WinMain PROC hInst:HINSTANCE,hPrevInstance:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wndclass:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL dwStyle:DWORD
	LOCAL scrWidth:DWORD
	LOCAL scrHeight:DWORD

	;初始化窗口类
	mov wndclass.cbSize,sizeof WNDCLASSEX
	mov wndclass.style, CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
	mov wndclass.lpfnWndProc,OFFSET WndProc
	mov wndclass.cbClsExtra,0
	mov wndclass.cbWndExtra,0
	mov eax,hInst
	mov wndclass.hInstance,eax
	INVOKE CreateSolidBrush,BgColor
	mov bgBrush,eax
	INVOKE CreateSolidBrush,TextBgColor
	mov textBgBrush,eax
	mov wndclass.hbrBackground,eax
	mov wndclass.lpszMenuName,0
	mov wndclass.lpszClassName,OFFSET ClassName
	INVOKE LoadIcon,hInstance,SnakeIcon
	mov wndclass.hIcon,eax
	INVOKE LoadCursor,0,IDC_ARROW
	mov wndclass.hCursor,eax
	mov wndclass.hIconSm,0
	;初始化字体
	INVOKE CreateFont, 50,
                    30,
                    0,
                    0,
                    FW_EXTRABOLD,
                    TRUE,
                    FALSE,
                    FALSE,
                    DEFAULT_CHARSET,
                    OUT_TT_PRECIS,
                    CLIP_DEFAULT_PRECIS,
                    CLEARTYPE_QUALITY,
                    DEFAULT_PITCH or FF_DONTCARE,
                    OFFSET FontName
    mov textFont, eax
    INVOKE CreateFont, 30,
                    20,
                    0,
                    0,
                    FW_EXTRABOLD,
                    TRUE,
                    FALSE,
                    FALSE,
                    DEFAULT_CHARSET,
                    OUT_TT_PRECIS,
                    CLIP_DEFAULT_PRECIS,
                    CLEARTYPE_QUALITY,
                    DEFAULT_PITCH or FF_DONTCARE,
                    OFFSET FontName1
	mov bestFont,eax
	;计算窗口位置，使窗口位于屏幕中央
	mov dwStyle,WS_OVERLAPPEDWINDOW
	mov eax,WS_SIZEBOX
	not eax
	and dwStyle,eax
	INVOKE GetSystemMetrics,SM_CXSCREEN
	mov scrWidth,eax
	INVOKE GetSystemMetrics,SM_CYSCREEN
	mov scrHeight,eax
	mov ebx,2
	mov edx,0
	mov eax,scrWidth
	sub eax,WndWidth
	div ebx
	mov WndOffX,eax
	mov eax,scrHeight
	sub eax,WndHeight
	div ebx
	mov WndOffY,eax

	INVOKE RegisterClassEx,ADDR wndclass
	INVOKE CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,ADDR ClassName,
					ADDR WindowName,
					dwStyle,
					WndOffX,WndOffY,WndWidth,WndHeight,
					0,0,
					hInst,0
	.IF eax == 0
		call ErrorHandler
		jmp Exit_Program
	.ENDIF
	mov hWnd,eax						;保存窗口句柄
	;载入图片
	INVOKE LoadBitmap, hInstance, BMP_RUNWAY
	mov BmpRunway, eax
	INVOKE LoadBitmap, hInstance, BMP_CRASHCAR
	mov BmpCrashCar, eax
	WHILE changeoffset LT 72
		INVOKE LoadBitmap,hInstance,carID
		mov BmpMainCar+changeoffset,eax
		changeoffset = changeoffset+4
		carID = carID+1
	ENDM
	
	changeoffset = 0
	carID = 182
	WHILE changeoffset LT 72
		INVOKE LoadBitmap,hInstance,carID
		mov BmpAutoCar+changeoffset,eax
		changeoffset = changeoffset+4
		carID = carID+1
	ENDM
	
	;载入最好记录文件
	INVOKE LoadRecordFile
	;初始化rect
	INVOKE InitRect
	;初始化游戏
	INVOKE resetGame					;设置好游戏初始时的状态
	INVOKE InvalidateRect,hWnd,NULL,FALSE

	INVOKE ShowWindow,hWnd,SW_SHOWNORMAL
	INVOKE UpdateWindow,hWnd

	
	INVOKE SetTimer,hWnd,1,INTERVAL,NULL
;开始消息循环
MessageLoop:
	INVOKE GetMessage,ADDR msg,0,0,0
	cmp eax,0
	je Exit_Program
	INVOKE TranslateMessage,ADDR msg
	INVOKE DispatchMessage,ADDR msg
	jmp MessageLoop

	INVOKE KillTimer,hWnd,1

Exit_Program:
	INVOKE ExitProcess,0
WinMain ENDP

ErrorHandler PROC
.data
	ErrorTitle BYTE "ERROR",0
	pErrorMsg DWORD ?
	msgId DWORD ?
.code
	INVOKE GetLastError
	mov msgId,eax

	INVOKE FormatMessage,FORMAT_MESSAGE_ALLOCATE_BUFFER+\
				FORMAT_MESSAGE_FROM_SYSTEM,NULL,msgId,NULL,
				ADDR pErrorMsg,NULL,NULL
	INVOKE MessageBox,NULL,pErrorMsg,ADDR ErrorTitle,MB_ICONERROR+MB_OK

	INVOKE LocalFree,pErrorMsg
	ret
ErrorHandler ENDP

InitRect PROC
	;游戏
	mov eax,ClientOffX
	mov GameRect.left,eax
	add eax,ClientWidth
	mov GameRect.right,eax
	mov eax,ClientOffY
	mov GameRect.top,eax
	add eax,ClientHeight
	mov GameRect.bottom,eax
	;得分
	mov eax,NumberOffX
	mov NumberRect.left,eax
	add eax,NumberWidth
	mov NumberRect.right,eax
	mov eax,NumberOffY
	mov NumberRect.top,eax
	add eax,NumberHeight
	mov NumberRect.bottom,eax
	;最高纪录
	mov eax,BestOffX
	mov BestRect.left,eax
	add eax,BestWidth
	mov BestRect.right,eax
	mov eax,BestOffY
	mov BestRect.top,eax
	add eax,BestHeight
	mov BestRect.bottom,eax

	mov eax,BestOffX0
	mov BestRect0.left,eax
	add eax,BestWidth0
	mov BestRect0.right,eax
	mov eax,BestOffY0
	mov BestRect0.top,eax
	add eax,BestHeight0
	mov BestRect0.bottom,eax
	;Good
	mov eax,GoodOffX
	mov GoodRect.left,eax
	add eax,GoodWidth
	mov GoodRect.right,eax
	mov eax,GoodOffY
	mov GoodRect.top,eax
	add eax,GoodHeight
	mov GoodRect.bottom,eax
	;主窗口
	mov WndRect.left,0
	mov eax,WndWidth
	mov WndRect.right,eax
	mov WndRect.top,0
	mov eax,WndHeight
	mov WndRect.bottom,eax

	ret
InitRect ENDP

WndProc PROC hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL hPopMenu:DWORD
	LOCAL ps:PAINTSTRUCT
	.IF uMsg == WM_CREATE
		INVOKE CreateMenu
		mov hMenu,eax
		.IF eax
			INVOKE CreatePopupMenu
			mov hPopMenu,eax
			INVOKE AppendMenu,hPopMenu,NULL,MENU_NEWGAME,ADDR MenuNewG
			INVOKE AppendMenu,hPopMenu,NULL,MENU_PLAYMUSIC,ADDR MenuPlayM
			INVOKE AppendMenu,hPopMenu,NULL,MENU_STOPMUSIC,ADDR MenuStopM
			INVOKE AppendMenu,hMenu,MF_POPUP,hPopMenu,ADDR MenuFile
			INVOKE CreatePopupMenu
			mov hPopMenu,eax
			INVOKE AppendMenu,hPopMenu,NULL,MENU_HELPINFO,ADDR MenuHelpP
			INVOKE AppendMenu,hPopMenu,NULL,MENU_ABOUTAUTHOR,ADDR MenuAbout
			INVOKE AppendMenu,hMenu,MF_POPUP,hPopMenu,ADDR MenuOther
		.ENDIF
		INVOKE SetMenu,hWin,hMenu
		jmp WndProcExit
	.ELSEIF uMsg == WM_TIMER
		INVOKE TimerProc
		jmp WndProcExit
	.ELSEIF uMsg == WM_PAINT
		INVOKE BeginPaint,hWin,ADDR ps
		mov hDC,eax
		INVOKE PaintProc,hWin
		INVOKE EndPaint,hWin,ADDR ps
		jmp WndProcExit
	.ELSEIF uMsg == WM_KEYDOWN
		mov eax, wParam		
		.IF eax == VK_ESCAPE
			invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.ELSEIF eax == VK_SPACE			
			.IF !Stop && !GameOver
				INVOKE CheckGood

				INVOKE ChangeWay,ADDR mainCar
			
				

				INVOKE InvalidateRect,hWin,NULL,FALSE
			.ENDIF
		.ELSEIF eax == VK_TAB
			mov ebx,Stop
			not ebx
			mov Stop,ebx
		.ELSEIF eax == VK_RETURN
			INVOKE resetGame
			INVOKE InvalidateRect,hWnd,NULL,FALSE
		.ENDIF
		jmp WndProcExit
	.ELSEIF uMsg == WM_CLOSE
		INVOKE StoreRecordFile
		INVOKE PostQuitMessage,0
		jmp WndProcExit
	.ELSEIF uMsg == WM_DESTROY
		INVOKE StoreRecordFile
		INVOKE PostQuitMessage,0
		jmp WndProcExit
	.ELSEIF uMsg == WM_COMMAND
		.IF wParam == MENU_NEWGAME
			INVOKE resetGame
			INVOKE InvalidateRect,hWnd,NULL,FALSE
		.ELSEIF wParam == MENU_ABOUTAUTHOR
			INVOKE MessageBox,0,ADDR Author, ADDR MsgTitle, MB_OK
		.ELSEIF wParam == MENU_HELPINFO
			INVOKE MessageBox,0,ADDR Help, ADDR MsgTitle,MB_OK
		.ELSEIF wParam == MENU_PLAYMUSIC
			.IF PlayFlag == 0
				mov PlayFlag,1  
				invoke PlayMp3File,hWin,ADDR MusicFileName
			.ENDIF
		.ELSEIF wParam == MENU_STOPMUSIC
			.IF PlayFlag == 1
				invoke mciSendCommand,Mp3DeviceID,MCI_CLOSE,0,0
				mov PlayFlag,0
			.ENDIF
		.ENDIF
		jmp WndProcExit
	.ELSE 
		INVOKE DefWindowProc,hWin,uMsg,wParam,lParam
		jmp WndProcExit
	.ENDIF

WndProcExit:
	ret
WndProc ENDP

PaintProc PROC hWid:DWORD
	LOCAL hOld:DWORD
	
	INVOKE CreateCompatibleDC,hDC
	mov memDC,eax
	INVOKE CreateCompatibleDC,hDC
	mov imgDC,eax
	INVOKE CreateCompatibleDC,hDC
	mov imgMDC,eax
	INVOKE CreateCompatibleBitmap,hDC,WndWidth,WndHeight
	mov hBitmap,eax
	INVOKE SelectObject, memDC,hBitmap
	mov hOld, eax
	INVOKE FillRect, memDC, ADDR WndRect, bgBrush

	;画跑道
	INVOKE SelectObject,imgDC,BmpRunway
	INVOKE BitBlt,memDC,ClientOffX,ClientOffY,ClientWidth,ClientHeight,imgDC,0,0,SRCCOPY

	;画得分
;	INVOKE FillRect,memDC,ADDR NumberRect, textBgBrush
	INVOKE SetBkMode,memDC,TRANSPARENT
	INVOKE SetTextColor,memDC,00EFF8FAh
	INVOKE SelectObject,memDC,textFont
	INVOKE DrawText,memDC,ADDR ScoreText,-1,ADDR NumberRect,DT_VCENTER
	INVOKE SelectObject,memDC,bestFont
	INVOKE DrawText,memDC,ADDR BestText0,-1,ADDR BestRect0,DT_VCENTER
	INVOKE DrawText,memDC,ADDR BestText,-1,ADDR BestRect,DT_VCENTER
	.IF GoodFlag == 1
		mov eax,GOODDISTANCE
		mov edx,0
		mov ebx,GOODTICK
		mul GoodTicks
		div ebx
		mov ebx,GoodOffY
		sub ebx,eax
		mov GoodRect.top,ebx

		INVOKE DrawText,memDC,ADDR GoodText,-1,ADDR GoodRect,DT_VCENTER
	.ENDIF

	;画人控制小车
	
	mov eax,GameOver
	.IF !eax
		INVOKE ConvertRadian, mainCar.direction
		mov edx,0
		mov ebx,20
		div ebx
		mov esi,[BmpMainCar+eax*TYPE DWORD]
		INVOKE SelectObject,imgDC,esi		
	.ELSE
		INVOKE SelectObject,imgDC,BmpCrashCar
	.ENDIF
	
	DrawCar mainCar
	
	;画自动控制小车

	SelectAutoCarBmp autoCar1

	DrawCar autoCar1

	SelectAutoCarBmp autoCar2

	DrawCar autoCar2

	SelectAutoCarBmp autoCar3

	DrawCar autoCar3
	
	INVOKE BitBlt,hDC,0,0,WndWidth,WndHeight,memDC,0,0,SRCCOPY
	INVOKE SelectObject,hDC,hOld
	INVOKE DeleteDC,memDC
	INVOKE DeleteDC,imgDC
	INVOKE DeleteDC,imgMDC
	INVOKE DeleteObject,hBitmap
	ret
PaintProc ENDP

resetGame PROC
	
	Init mainCar,STARTX+40,ODOWNY,mZero,0
	
	Init autoCar3,STARTX-XRADIO,ODOWNY,mTwoPai,3
	Init autoCar2,STARTX-XRADIO*2-20,ODOWNY,mTwoPai,2
	Init autoCar1,STARTX-XRADIO*3-40,ODOWNY,mTwoPai,1

	
	mov score,0
	mov GameOver,0
	mov Stop,0
	mov Change1,0
	mov Change2,0
	mov Change3,0
	mov Depart,0
	mov AniChange1,0
	mov AniChange2,0
	mov AniChange3,0
	mov stopticks,0

	mov eax,NewBest
	mov Best,eax
	mov GoodFlag,0
	mov GoodTicks,0

	mov StartTime,STARTTIMES
	mov CrashTime,0

	mov StartFlag,1
	ret
resetGame ENDP

ShowScore PROC,
	target:DWORD
	mov ebx,10
	mov eax,target
	mov edx,0

	div ebx
	or edx,30h
	mov ScoreText+2,dl
	xor edx,edx

	div ebx
	.IF edx != 0
		or edx,30h
	.ELSE
		mov edx,20h
	.ENDIF
	mov ScoreText+1,dl
	xor edx,edx

	div ebx
	.IF edx != 0
		or edx,30h
	.ELSE
		mov edx,20h
	.ENDIF
	mov ScoreText,dl
	xor edx,edx

	ret
ShowScore ENDP

ShowBest PROC
	mov eax,Best
	mov edx,0

	div ebx
	or edx,30h
	mov BestText+2,dl
	xor edx,edx

	div ebx
	.IF edx != 0
		or edx,30h
	.ELSE
		mov edx,20h
	.ENDIF
	mov BestText+1,dl
	xor edx,edx

	div ebx
	.IF edx != 0
		or edx,30h
	.ELSE
		mov edx,20h
	.ENDIF
	mov BestText,dl
	xor edx,edx

	ret
ShowBest ENDP

JudgeChange PROC
LOCAL randomNum:DWORD
	mov ebx,score
	Random 0FFFFFFH
	mov randomNum,eax
	.IF ebx < 5
		Change Change1, randomNum,1
		mov ecx,Change1
		mov Change2,ecx
		mov Change3,ecx
	.ELSEIF ebx >= 5 && ebx < 15
		Change Change1, randomNum,1
		Change Change2, randomNum,2
		mov ecx,Change2
		mov Change3,ecx

		mov edx, Change1
		mov esi, Change2
 		mov edi, Change3
		mov eax,randomNum
 	.ELSEIF ebx >= 15
		
		Change Change1, randomNum,1
		Change Change2, randomNum,2
		Change Change3, randomNum,3
		
	.ENDIF
	
	ret
JudgeChange ENDP

InitAniChange PROC,
	mCar:PTR CAR,
	mdisR:PTR DWORD
	
	mov esi,mCar
	assume esi:PTR CAR

	.IF [esi].inway
		mov eax,OUTRADIO
	.ELSE
		mov eax,INRADIO
	.ENDIF

	sub eax,[esi].cradio
	mov edi,mdisR
	mov [edi],eax

	assume esi:nothing
	ret
InitAniChange ENDP

AniMoveOn PROC,
	mCar:PTR CAR,
	ticks:DWORD,
	mdisR:DWORD
LOCAL mchangeticks:DWORD

	mov eax,ticks
	mov esi,mCar

	assume esi:PTR CAR	

	.IF eax != CHANGETICK
		
		mov mchangeticks,CHANGETICK
		
		mov eax,mdisR
		imul ticks
		CWD
		idiv mchangeticks
		.IF [esi].inway
			add eax,INRADIO
		.ELSE 
			add eax,OUTRADIO
		.ENDIF
		mov [esi].cradio,eax
	.ELSE
		.IF [esi].inway
			mov [esi].cradio,OUTRADIO
		.ELSE
			mov [esi].cradio,INRADIO
		.ENDIF
		not [esi].inway
	.ENDIF

	assume esi:nothing
	ret
AniMoveOn ENDP

;播放音乐函数
PlayMp3File PROC hWin:DWORD,NameOfFile:DWORD
LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS
	mov eax,hWin        
	mov mciPlayParms.dwCallback,eax
	mov eax,OFFSET Mp3Device
	mov mciOpenParms.lpstrDeviceType,eax
	mov eax,NameOfFile
	mov mciOpenParms.lpstrElementName,eax
	INVOKE mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
	mov eax,mciOpenParms.wDeviceID
	mov Mp3DeviceID,eax
	invoke mciSendCommand,Mp3DeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParms
	ret  
PlayMp3File ENDP

PlayMp3StartFile PROC hWin:DWORD,NameOfFile:DWORD
	LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS
	mov eax,hWin        
	mov mciPlayParms.dwCallback,eax
	mov eax,OFFSET Mp3StartDevice
	mov mciOpenParms.lpstrDeviceType,eax
	mov eax,NameOfFile
	mov mciOpenParms.lpstrElementName,eax
	INVOKE mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
	mov eax,mciOpenParms.wDeviceID
	mov Mp3StartDeviceID,eax
	invoke mciSendCommand,Mp3StartDeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParms
	ret  
PlayMp3StartFile ENDP

PlayMp3CrashFile PROC hWin:DWORD,NameOfFile:DWORD
	LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS
	mov eax,hWin        
	mov mciPlayParms.dwCallback,eax
	mov eax,OFFSET Mp3CrashDevice
	mov mciOpenParms.lpstrDeviceType,eax
	mov eax,NameOfFile
	mov mciOpenParms.lpstrElementName,eax
	INVOKE mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
	mov eax,mciOpenParms.wDeviceID
	mov Mp3CrashDeviceID,eax
	invoke mciSendCommand,Mp3CrashDeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParms
	ret  
PlayMp3CrashFile ENDP

LoadRecordFile PROC
	LOCAL reallen:DWORD
	
	INVOKE CreateFile,
		ADDR RecordFileName,
		GENERIC_READ,
		DO_NOT_SHARE,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		0

	.IF eax != INVALID_HANDLE_VALUE
		mov hFile, eax
		INVOKE ReadFile,
			hFile,
			ADDR Best,
			TYPE Best,
			ADDR reallen,
			0
		mov eax,Best
		mov NewBest,eax
		INVOKE CloseHandle, hFile
		mov hFile, INVALID_HANDLE_VALUE
	.ELSE
		mov Best,0
		mov NewBest,0
	.ENDIF

	ret
LoadRecordFile ENDP

StoreRecordFile PROC
	LOCAL reallen:DWORD

	.IF hFile != INVALID_HANDLE_VALUE
		INVOKE CloseHandle, hFile
		mov hFile, INVALID_HANDLE_VALUE
	.ENDIF
	mov eax,Best
	.IF eax < NewBest

		mov eax,NewBest
		INVOKE CreateFile,
			ADDR RecordFileName,
			GENERIC_WRITE,
			DO_NOT_SHARE,
			NULL,
			CREATE_ALWAYS,
			FILE_ATTRIBUTE_NORMAL,
			0

		.IF eax != INVALID_HANDLE_VALUE
			mov hFile, eax
			INVOKE WriteFile,
				hFile,
				ADDR NewBest,
				TYPE NewBest,
				ADDR reallen,
				0
			INVOKE CloseHandle, hFile
			mov hFile, INVALID_HANDLE_VALUE
		.ENDIF
	.ENDIF
	ret
StoreRecordFile ENDP

TimerProc PROC

		.IF StartFlag == 1
			.IF StartTime != 0
			  invoke mciSendCommand,Mp3StartDeviceID,MCI_CLOSE,0,0
			.ENDIF
			invoke PlayMp3StartFile,hWnd,ADDR StartName
			mov StartFlag, 0
		.ENDIF
		.IF StartTime > 0
		dec StartTime
			.IF StartTime == 0
				invoke mciSendCommand,Mp3StartDeviceID,MCI_CLOSE,0,0
				mov StartFlag,0
			.ENDIF
		.ENDIF

		

		.IF !GameOver && !Stop
			
			;恢复速度
			.IF stopticks >= STOPTICK
				mov autoCar2.speed,SPEED
				FLD fcircle
				FSTP autoCar2.circle

				mov autoCar3.speed,SPEED
				FLD fcircle
				FSTP autoCar3.circle

				mov Depart,0
				mov stopticks,0
			.ELSEIF Depart != 0
				inc stopticks
			.ENDIF
			;结束动画
			.IF changeticks1 >= CHANGETICK
				mov AniChange1,0
				mov changeticks1,0
			.ELSEIF AniChange1 != 0
				inc changeticks1
			.ENDIF

			.IF changeticks2 >= CHANGETICK
				mov AniChange2,0
				mov changeticks2,0
			.ELSEIF AniChange2 != 0
				inc changeticks2
			.ENDIF

			.IF changeticks3 >= CHANGETICK
				mov AniChange3,0
				mov changeticks3,0
			.ELSEIF AniChange3 != 0
				inc changeticks3
			.ENDIF
			;保留运动前一次的x坐标
			mov eax,mainCar.position.x
			mov oldx,eax
			mov eax,autoCar1.position.x
			mov oldx1,eax
			mov eax,autoCar2.position.x
			mov oldx2,eax
			mov eax,autoCar3.position.x
			mov oldx3,eax
			;改变运动半径达到渐变效果
		
			.IF AniChange1 == 1
				INVOKE AniMoveOn, ADDR autoCar1,changeticks1,disR1
			.ENDIF

			.IF AniChange2 == 1
				INVOKE AniMoveOn, ADDR autoCar2,changeticks2,disR2
			.ENDIF

			.IF AniChange3 == 1
				INVOKE AniMoveOn, ADDR autoCar3,changeticks3,disR3
			.ENDIF
			
			;运动
			INVOKE MoveOn, ADDR mainCar
			
			INVOKE MoveOn, ADDR autoCar1
			
			INVOKE MoveOn, ADDR autoCar2
			
			INVOKE MoveOn, ADDR autoCar3
			

			
			;检查分数
			mov ecx, score
			mov oldscore,ecx
			mov ebx, mainCar.position.x
			mov eax, oldx
			.IF eax < STARTX && ebx >= STARTX
				inc score
				mov eax,score
				.IF eax > Best
					mov NewBest,eax
				.ENDIF
				INVOKE JudgeChange
			.ELSEIF eax > STARTX && ebx <= STARTX
				inc score
				mov eax,score
				.IF eax > Best
 					mov NewBest,eax
				.ENDIF
				INVOKE JudgeChange
			.ENDIF

			INVOKE ShowScore, score
			INVOKE ShowBest
			;检测是否进入动画
		
			mov ebx, autoCar1.position.x
			mov eax, oldx1
			.IF eax > LEFTX && ebx <= LEFTX
				.IF Change1 == 1
					INVOKE InitAniChange,ADDR autoCar1,ADDR disR1
					mov eax, disR1
					mov AniChange1,1
					mov changeticks1,0
				.ENDIF
			.ELSEIF eax < RIGHTX  && ebx >= RIGHTX
				.IF Change1 == 1
					INVOKE InitAniChange,ADDR autoCar1,ADDR disR1
					
					mov AniChange1,1
					mov changeticks1,0
				.ENDIF
			.ENDIF

			mov ebx, autoCar2.position.x
			mov eax, oldx2
			.IF eax > LEFTX && ebx <= LEFTX
				.IF Change2 == 1
					INVOKE InitAniChange,ADDR autoCar2,ADDR disR2
					mov AniChange2,1
					mov changeticks2,0
				.ENDIF
			.ELSEIF eax < RIGHTX  && ebx >= RIGHTX
				.IF Change2 == 1
					INVOKE InitAniChange,ADDR autoCar2,ADDR disR2
					mov AniChange2,1
					mov changeticks2,0
				.ENDIF
			.ENDIF

			mov ebx, autoCar3.position.x
			mov eax, oldx3
			.IF eax > LEFTX && ebx <= LEFTX
				.IF Change3 == 1
					INVOKE InitAniChange,ADDR autoCar3,ADDR disR3
					mov AniChange3,1
					mov changeticks3,0
				.ENDIF
			.ELSEIF eax < RIGHTX  && ebx >= RIGHTX
				.IF Change3 == 1
					INVOKE InitAniChange,ADDR autoCar3,ADDR disR3
					mov AniChange3,1
					mov changeticks3,0
				.ENDIF
			.ENDIF
					
			;检查是否要减速分开
			.IF oldscore == 4 && score == 5
					mov autoCar2.speed,SLOWSPEED
					FLD slowCircle
					FSTP autoCar2.circle

					mov autoCar3.speed,SLOWSPEED
					FLD slowCircle
					FSTP autoCar3.circle

					mov Depart,1
			.ELSEIF oldscore == 14 && score == 15

					mov autoCar3.speed,SLOWSPEED
					FLD slowCircle
					FSTP autoCar3.circle

					mov Depart,1
			.ENDIF

			

			;检测碰撞
			INVOKE CheckCollasion, ADDR mainCar,ADDR autoCar3
			.IF eax
				mov GameOver,0FFFFFFFFh
				mov Stop,0FFFFFFFFh
				mov CollasionNum,3
				invoke PlayMp3CrashFile,hWnd,ADDR CrashName
				mov CrashTime,CRASHTIMES
;				INVOKE MessageBox,0,ADDR GameOverText, ADDR MsgTitle, MB_OK
			.ELSE
				INVOKE CheckCollasion, ADDR mainCar,ADDR autoCar2
				.IF eax
					mov GameOver,0FFFFFFFFh
					mov Stop,0FFFFFFFFh
					mov CollasionNum,2
					invoke PlayMp3CrashFile,hWnd,ADDR CrashName
					mov CrashTime,CRASHTIMES
;					INVOKE MessageBox,0,ADDR GameOverText, ADDR MsgTitle, MB_OK
				.ELSE
					INVOKE CheckCollasion, ADDR mainCar,ADDR autoCar1
					.IF eax
						mov GameOver,0FFFFFFFFh
						mov Stop,0FFFFFFFFh
						mov CollasionNum,1
						invoke PlayMp3CrashFile,hWnd,ADDR CrashName
						mov CrashTime,CRASHTIMES
;						INVOKE MessageBox,0,ADDR GameOverText, ADDR MsgTitle, MB_OK
					.ELSE
						mov eax, GoodFlag
						.IF eax == 1 
							.IF GoodTicks == 0
								inc score
								mov eax,score
								.IF eax > Best
									mov NewBest,eax
								.ENDIF
							.ENDIF
							.IF GoodTicks < GOODTICK
								inc GoodTicks
		
							.ELSE
								mov GoodFlag,0
								mov GoodTicks,0
							.ENDIF
						.ENDIF
					.ENDIF			
				.ENDIF
			.ENDIF
			
			INVOKE InvalidateRect,hWnd,NULL,FALSE
		.ELSEIF GameOver && CrashTime > 0
			dec CrashTime
		.ELSEIF GameOver && CrashTime <= 0
			.IF CrashTime == 0
				invoke mciSendCommand,Mp3CrashDeviceID,MCI_CLOSE,0,0
			.ENDIF
			not GameOver
			INVOKE MessageBox,0,ADDR GameOverText, ADDR MsgTitle, MB_OK		
		.ENDIF
	ret
TimerProc ENDP

CheckGood PROC
	mov eax,mainCar.position.x
	mov ebx,eax
	mov ecx,eax
	sub eax,autoCar1.position.x
	jge checkAbs1
	neg eax
checkAbs1:	
	sub ebx,autoCar2.position.x
	jge checkAbs2
	neg ebx
checkAbs2:
	sub ecx,autoCar3.position.x
	jge checkAbs3
	neg ecx 
checkAbs3:
	.IF eax < 100 || ebx < 100 || ecx < 100
		mov GoodFlag,1
		mov GoodTicks,0
	.ENDIF

	ret
CheckGood ENDP
END start