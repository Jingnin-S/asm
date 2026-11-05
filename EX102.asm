
;计数器0:分频1000，CLK0接1MHZ，GATE0接5V，OUT0接CLK1
;计数器1:分频1000，CLK1接OUT0，GATE1接5V，OUT1接CLK2
;计数器2:计数器，CLK2接OUT1，GATE2接K7开关
;8255A口位码，B口段码，C口接收开关电平
DATAS SEGMENT
P82540 EQU 280H         ;定义端口
P82541 EQU 281H
P82542 EQU 282H
P8254S EQU 283H
P8255A EQU 288H
P8255B EQU 289H
P8255C EQU 28AH
P8255S EQU 28BH
SM_TAB DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H   ;定义数码管0~F
PC_ASC DB 30H,31H,32H,33H,34H,35H,36H,37H,38H,39H                           ;ASC码0~9
S_STR  DB 'TIME TOO LONG,Please restart the program','$'                    ;定义显示字符串
L_STR  DB 'Cumulating Time:','$'
H_STR  DB 0DH,0AH,'$'
V_STR  DB 'Current velocity is :','$'
D_STR  DB 'M/s','$'
F_STR  DB 'Too Fast!','$'
SPEED  DB 0                   ;速度缓存
SPEED1 DB 0
SPEED2 DB 0
BUFFER DB 100                 ;时间缓存
K_FLAG DB 0
TIME   DB 0                   ;当前计时
TIME1  DB 0
TIME2  DB 0
NUM DW 0                      ;减一计时器数
DATAS ENDS
 
STACKS SEGMENT
 X DB 100 DUP(?)
STACKS ENDS
 
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    CALL PINIT
MAINLP:                       ;扫描K7端口，有无高电平，没有继续扫描
    MOV DX,P8255C
    IN AL,DX
    AND AL,01H
    CMP AL,1
    JZ JISHU
    JMP MAINLP
JISHU:                        ;若有高电平，则置标志位，刷新缓存位
    MOV K_FLAG,1
    MOV SI,0
    MOV SPEED,0
    MOV TIME,0
    MOV NUM,0
LP:                           ;进入计数循环，调用dos显示、数码管显示
    CALL TIMER    
    CALL SM_PRINT
    CALL DOS_PRINT    
    MOV DX,P8255C
    IN AL,DX
    AND AL,01H               ;检测开关端口，若发现变低则退出计数循环
    CMP AL,1
    JZ LP
    CALL SPEED_PRINT
    MOV K_FLAG,0
    JMP MAINLP
    MOV AH,4CH
    INT 21H
 
;功能：P8254、P8255初始化
PINIT PROC
    MOV DX,P8255S
    MOV AL,81H
    OUT DX,AL
    
    MOV DX,P8254S
    MOV AL,36H
    OUT DX,AL
    MOV DX,P82540
    MOV AX,1000
    OUT DX,AL
    MOV AL,AH
    OUT DX,AL
    
    MOV DX,P8254S
    MOV AL,76H
    OUT DX,AL
    MOV DX,P82541
    MOV AX,1000
    OUT DX,AL
    MOV AL,AH
    OUT DX,AL
    
    MOV DX,P8254S
    MOV AL,0B2H
    OUT DX,AL
    MOV DX,P82542
    MOV AX,0
    OUT DX,AL
    MOV AL,AH
    OUT DX,AL
    RET
PINIT ENDP
 
;功能：速度计算，显示一次计时的速度
SPEED_PRINT PROC
    PUSH AX
    PUSH BX
    PUSH DX
    MOV AL,100
    MOV BL,TIME
    MOV AH,0
    DIV BL
    MOV SPEED,AL
    CMP SPEED,50
    JG EXE
    CALL V_PRINT
    MOV AH,0
    MOV BL,10
    DIV BL
    MOV SPEED1,AH
    MOV AH,0
    DIV BL
    MOV SPEED2,AH
    MOV AH,0
    MOV AL,SPEED2
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H
    MOV AL,SPEED1
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H
    CALL D_PRINT
    CALL H_PRINT
    JMP EXT5
EXE:
    CALL F_PRINT
    MOV AL,0FFH 
    MOV DX,P8255A 
    OUT DX,AL
    MOV AL,71H
    MOV DX,P8255B
    OUT DX,AX
EXT5:
    POP AX
    POP BX
    POP DX
    RET
SPEED_PRINT ENDP
 
;功能：数码管显示
SM_PRINT PROC
    PUSH AX
    PUSH BX
    PUSH DX
    CMP K_FLAG,0 ;状态判断，执行条件：FLAG=1、时间有更新（BUFFER）、计数时间小于16
    JZ EXT3
    MOV AL,TIME
    CMP AL,BUFFER
    JZ EXT3
    MOV AL,TIME
    CMP AL,16
    JZ EXT3
    MOV AL,TIME
    MOV AH,0
    MOV SI,AX
    MOV AL,01H 
    MOV DX,P8255A 
    OUT DX,AL
    MOV AL,SM_TAB[SI]
    MOV DX,P8255B
    OUT DX,AX
    INC SI
EXT3:
    POP DX
    POP BX
    POP AX
    RET
SM_PRINT ENDP
 
;功能：时间刷新器
TIMER PROC
    PUSH AX
    PUSH BX
    PUSH DX
    CMP K_FLAG,1    ;状态判断，为1持续刷新TIME
    JZ TI
T0: 
    JMP DEND
TI:
   MOV AL,10000000B
   MOV DX,P8254S
   OUT DX,AL
   MOV DX,P82542
   IN  AL,DX
   MOV AH,AL
   IN  AL,DX
   XCHG AH,AL 
   MOV NUM,AX
   MOV BX,0
   SUB BX,AX
   MOV TIME,BL
DEND:
   POP DX
   POP BX 
   POP AX 
   RET
TIMER ENDP
 
;功能：DOS窗口显示，TIME处理为个位、十位
DOS_PRINT PROC
    PUSH AX
    PUSH BX
    PUSH DX
    CMP K_FLAG,0
    JZ EXT1
    MOV AL,TIME
    CMP AL,BUFFER
    JZ EXT1
    MOV AL,TIME
    CMP AL,16
    JZ EXT
    CALL L_PRINT
    MOV AL,TIME     ;将新的时间压入BUFFER
    MOV BUFFER,AL
    MOV AH,0
    MOV BL,10
    DIV BL          ;将时间分别处理为十位、个位送入TIME2、TIME1
    MOV TIME1,AH
    MOV AH,0
    DIV BL
    MOV TIME2,AH
    MOV AH,0
    MOV AL,TIME2
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H
    MOV AL,TIME1
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H
    CALL H_PRINT
    JMP EXT1
EXT:
    CALL S_PRINT
    MOV AH,4CH
    INT 21H
EXT1:
    POP DX
    POP BX
    POP AX
    RET
DOS_PRINT ENDP
 
;功能：字符串输出
H_PRINT PROC
    PUSH DX
    PUSH AX
    PUSH DS
    MOV AX,SEG H_STR
    MOV DS,AX
    MOV DX,OFFSET H_STR
    MOV AH,09H
    INT 21H
    POP DS
    POP AX
    POP DX
    RET
H_PRINT ENDP
 
L_PRINT PROC
    PUSH DX
    PUSH AX
    PUSH DS
    MOV AX,SEG L_STR
    MOV DS,AX
    MOV DX,OFFSET L_STR
    MOV AH,09H
    INT 21H
    POP DS
    POP AX
    POP DX
    RET
L_PRINT ENDP
 
F_PRINT PROC
    PUSH DX
    PUSH AX
    PUSH DS
    MOV AX,SEG F_STR
    MOV DS,AX
    MOV DX,OFFSET F_STR
    MOV AH,09H
    INT 21H
    POP DS
    POP AX
    POP DX
    RET
F_PRINT ENDP
 
S_PRINT PROC
    PUSH DX
    PUSH AX
    PUSH DS
    MOV AX,SEG S_STR
    MOV DS,AX
    MOV DX,OFFSET S_STR
    MOV AH,09H
    INT 21H
    CALL H_PRINT
    POP DS
    POP AX
    POP DX
    RET
S_PRINT ENDP
 
D_PRINT PROC
    PUSH DX
    PUSH AX
    PUSH DS
    MOV AX,SEG D_STR
    MOV DS,AX
    MOV DX,OFFSET D_STR
    MOV AH,09H
    INT 21H
    POP DS
    POP AX
    POP DX
    RET
D_PRINT ENDP
 
V_PRINT PROC
    PUSH DX
    PUSH AX
    PUSH DS
    MOV AX,SEG V_STR
    MOV DS,AX
    MOV DX,OFFSET V_STR
    MOV AH,09H
    INT 21H
    POP DS
    POP AX
    POP DX
    RET
V_PRINT ENDP
 
CODES ENDS
END START