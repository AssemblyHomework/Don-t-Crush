
;================================
;常量定义

PAI TEXTEQU <3.1415926>
TWOPAI TEXTEQU <6.2831852>
FZERO TEXTEQU <0.0>
RIGHTX = 840
RIGHTY = 327
LEFTX =  310
LEFTY = 327
RADIO = 28       ;车子近似为圆形时的直径
INRADIO = 176    ;内车道转弯的半径
OUTRADIO = 233   ;外车道转弯的半径
STARTX = 554	  ;出发点
GAP = 10		  ;轨道缝隙
BOARD = 50	  ;车道的宽度

OUPY = 94
IUPY = 151
ODOWNY = 561
IDOWNY = 504
CIRCLE TEXTEQU <0.0375>
SPEED TEXTEQU <8>
SLOWCIRCLE TEXTEQU <0.01875>
SLOWSPEED TEXTEQU <4>
;================================
;结构体定义

POS STRUCT
 x dd 0
 y dd 0
POS ENDS

CAR STRUCT
 position POS <>
 direction real4 0.0 ; [0,Π)∪（Π，2Π)∪{PAI,TWOPAI}, 0 表示直线向右运动，因为无法准确表示Π
 state     dd   0  ; 0 表示在下直线，1表示在右弯道，2表示在上直线，3表示在左弯道
 inway dd 0		    ; 1 表示车子在内跑道，0FFFFFFFFH表示在里道
 speed dd SPEED	    ; 车子在直线时每个时间间隔跑的像素
 circle real4 CIRCLE   ; 车子在弯道时每个时间间隔转的角度（弧度数）
 kind dd 1         ; 车子的类别，1表示人控制的车，2-4表示自动控制的车
 area dd RADIO        ; 车子的像素宽度，为简便碰撞，将车子都近似为圆形
 cradio dd INRADIO
CAR ENDS

 ;=================================
 .data
 EXTERNDEF mainCar:CAR,
	autoCar1:CAR,
	autoCar2:CAR,
	autoCar3:CAR,
	leftCPonit:POS,
	rightCPoint:POS,
	mPai:real4,
	mTwoPai:real4,
	mZero:real4,
	score:DWORD,
	fcircle:real4,
	slowCircle:DWORD
.code
	ChangeWay PROTO,
			     mCar:PTR CAR
	CalculateFloat PROTO,
				radian:real4,
				mulInt:DWORD,
				mulNum:real4
	
	MoveOn PROTO,
				mCar:PTR CAR
	CheckCollasion PROTO,
				CarA:PTR CAR,
				CarB:PTR CAR
	GetSqua PROTO
	ConvertRadian	PROTO,
				cradian:real4

	