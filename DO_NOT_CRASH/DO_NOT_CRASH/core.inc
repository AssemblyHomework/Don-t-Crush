
;================================
;��������

PAI TEXTEQU <3.1415926>
TWOPAI TEXTEQU <6.2831852>
FZERO TEXTEQU <0.0>
RIGHTX = 840
RIGHTY = 327
LEFTX =  310
LEFTY = 327
RADIO = 28       ;���ӽ���ΪԲ��ʱ��ֱ��
INRADIO = 176    ;�ڳ���ת��İ뾶
OUTRADIO = 233   ;�⳵��ת��İ뾶
STARTX = 554	  ;������
GAP = 10		  ;�����϶
BOARD = 50	  ;�����Ŀ���

OUPY = 94
IUPY = 151
ODOWNY = 561
IDOWNY = 504
CIRCLE TEXTEQU <0.0375>
SPEED TEXTEQU <8>
SLOWCIRCLE TEXTEQU <0.01875>
SLOWSPEED TEXTEQU <4>
;================================
;�ṹ�嶨��

POS STRUCT
 x dd 0
 y dd 0
POS ENDS

CAR STRUCT
 position POS <>
 direction real4 0.0 ; [0,��)�ȣ�����2��)��{PAI,TWOPAI}, 0 ��ʾֱ�������˶�����Ϊ�޷�׼ȷ��ʾ��
 state     dd   0  ; 0 ��ʾ����ֱ�ߣ�1��ʾ���������2��ʾ����ֱ�ߣ�3��ʾ�������
 inway dd 0		    ; 1 ��ʾ���������ܵ���0FFFFFFFFH��ʾ�����
 speed dd SPEED	    ; ������ֱ��ʱÿ��ʱ�����ܵ�����
 circle real4 CIRCLE   ; ���������ʱÿ��ʱ����ת�ĽǶȣ���������
 kind dd 1         ; ���ӵ����1��ʾ�˿��Ƶĳ���2-4��ʾ�Զ����Ƶĳ�
 area dd RADIO        ; ���ӵ����ؿ��ȣ�Ϊ�����ײ�������Ӷ�����ΪԲ��
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

	