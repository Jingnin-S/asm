;硬件连接：先将译码器的Y1端口和和8255的片选信号相连接8255 
;控制寄存器端口地址 28BH
;A 口的地址 288H
;B 口的地址 289H
;C 口的地址 28AH
;L7、L6、L5（红黄绿） 作为南北路口的交通灯与 PC7、PC6、PC5 相连，
;L2、L1、L0 （红黄绿）作为东西路口的交通灯与 PC2、PC1、PC0 相连。
;PA0-PA7 八个口作为输出连接八段数码管的段选输入，PB0-PB7 八个口作为输出连接八段数码管的位选输入

;8*8点阵连接方式：
;双色点阵/行选 接 I/O 地址译码/Y0(280H---287H)
;双色点阵/红选 接 I/O 地址译码/Y3(298H---29FH)
;双色点阵/绿选 接 I/O 地址译码/Y2(290H---297H)
;双色点阵/总线(D7---D0) 接 总线/JP14(D7---D0)
;双色点阵/WR 接 总线/IOW
;双色点阵工作于“总线”模式（JCS4 跳线短接总线边）。
;行选的地址 280H
;红选的地址 298H
;绿选的地址 290H
DATA SEGMENT
    LIST DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
    PORTA EQU 288H
    PORTB EQU 289H
    PORTC EQU 28AH
    CONTROL EQU 28BH
    
    LINE EQU 280H
    RED EQU 298H
    GREEN EQU 290H
DATA ENDS

STACKS SEGMENT STACK
    DB 100 DUP(?)
STACKS ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA,SS:STACKS
START:
    MOV AX,DATA
    MOV DS,AX
    
    MOV DX,CONTROL
    MOV AL,10000000B;A口B口C口均为方式0输出
    OUT DX,AL

    ;假定南北向先亮红灯30s，东西向先亮绿灯27s+黄灯3s。两个路口的亮灯顺序都是红灯30s+绿灯27s+黄灯3s，然后循环往复

RESTART:
S11:MOV DX,PORTC
    MOV AL,10000001B; 设置AL寄存器的值为二进制的10000000，表示A口B口C口均为方式0输出
    OUT DX,AL ;南北亮红灯，东西亮绿灯
    
    ;8*8点阵的右边代表南北向，左半边代表东西向
        ;点阵进度调整
    MOV DX,LINE; 将点阵的控制端口地址加载到DX寄存器
    MOV AL,11111111B ; 设置AL寄存器的值为二进制的11111111，表示点阵全部点亮
    OUT DX,AL; 将AL寄存器的值输出到点阵的控制端口
    MOV DX,RED; 将红色灯的控制端口地址加载到DX寄存器
    MOV AL,11111111B; 设置AL寄存器的值为二进制的11111111，表示红色灯全部点亮
    OUT DX,AL ; 将AL寄存器的值输出到红色灯的控制端口
    
    MOV CX,27 ; 循环27次，延时27秒
    MOV AL,4FH  ; 设置AL寄存器的值为十进制的79，用于数码管显示倒计时
    MOV DX,PORTA ; 将数码管A的控制端口地址加载到DX寄存器
    OUT DX,AL  ; 将AL寄存器的值输出到数码管A的控制端口
    MOV AL,00100010B   ; 设置AL寄存器的值为二进制的00100010，用于数码管B的显示
    MOV DX,PORTB ; 将数码管B的控制端口地址加载到DX寄存器
    OUT DX,AL ;将两组数码管的十位设置为3，开始倒计时

S1: MOV DX,PORTC
    MOV AL,10000001B; 设置AL寄存器的值为二进制的10000001，表示南北亮红灯，东西亮绿灯
    CALL DELAY_1S ;延时1s
    CMP CX,3 ;判断红灯是否大于6S，若大于6S，则需要检测是否有行人按下按钮2
    JB NO1
    MOV DX,0FFFFH ; 将DX寄存器的值设置为0xFFFF，用于检测键盘输入
    MOV AH,06H; 设置AH寄存器的值为06H，表示调用键盘输入功能
    INT 21H;进入06号功能，检测键盘是否有按键按下。
    ;若按键为2，则代表行人按下，直接跳到绿灯
    CMP AL,50 ; 判断是否有按键按下，若按键为2，则代表行人按下，直接跳到绿灯
    JNZ NO1
    JMP S33
NO1:
    CMP CX,18
    JNZ FLAG11 ;判断是不是已经倒计时了10S，若倒计时了10S，将十位数从3切换到2;并将点阵进度减小一些
    MOV DX,PORTA
    MOV AL,5BH
    OUT DX,AL
    
        ;点阵进度调整
    MOV DX,LINE
    MOV AL,11111000B ; 设置AL寄存器的值为二进制的11111000，用于点阵的显示
    OUT DX,AL
    MOV DX,RED
    MOV AL,11111111B ; 设置AL寄存器的值为二进制的11111111，用于红色灯的显示
    OUT DX,AL  ; 将AL寄存器的值输出到红色灯的控制端口
FLAG11:CMP CX,8 ;判断是不是已经倒计时了20s，若倒计时了20s，将十位数从2切换到1；并将点阵进度减小一些
    JNZ FLAG12
    MOV DX,PORTA
    MOV AL,06H ; 设置AL寄存器的值为06H，用于数码管A的显示
    OUT DX,AL
    
    ;点阵进度调整
    MOV DX,LINE
    MOV AL,10000000B ; 将点阵的控制端口地址加载到DX寄存器
    OUT DX,AL
    MOV DX,RED
    MOV AL,11111111B
    OUT DX,AL
FLAG12:LOOP S1
    
    MOV AL,10000010B;27S后东西路口亮黄灯，南北路口仍然为红灯
    MOV DX,PORTC ; 将交叉路口的控制端口地址加载到DX寄存器
    OUT DX,AL ; 将AL寄存器的值输出到交叉路口的控制端口
    
    MOV CX,3;黄灯闪烁3s，每间隔1s闪烁一次
S2: 
    CALL DELAY_1S ; 调用延时函数，延时1秒
    CMP CX,3;判断是不是过了1s，过了1s后黄灯取反
    JNZ FLAG21
    MOV DX,PORTC ; 将交叉路口的控制端口地址加载到DX寄存器
    MOV AL,10000000B ; 设置AL寄存器的值为二进制的10000000，表示黄灯取反
    OUT DX,AL ; 将AL寄存器的值输出到交叉路口的控制端口
FLAG21:CMP CX,2;判断是不是过了2s，过了2s后黄灯取反s
    JNZ FLAG22
    MOV DX,PORTC
    MOV AL,10000010B; 设置AL寄存器的值为二进制的10000010，表示黄灯取反
    OUT DX,AL
    
        ;点阵进度调整
    MOV DX,LINE
    MOV AL,00000000B; 设置AL寄存器的值为二进制的00000000，用于点阵的显示
    OUT DX,AL
    MOV DX,RED
    MOV AL,00000000B ; 设置AL寄存器的值为二进制的00000000，用于红色灯的显示
    OUT DX,AL
    
FLAG22:LOOP S2

S33:MOV DX,PORTC; 将交叉路口的控制端口地址加载到DX寄存器
    MOV AL,00100100B;又过了3S，南北路口亮绿灯，东西路口亮红灯
    OUT DX,AL
    
        ;点阵进度调整
    MOV DX,LINE
    MOV AL,11111111B; 设置AL寄存器的值为二进制的11111111，用于点阵的显示
    OUT DX,AL
    MOV DX,GREEN; 将绿色灯的控制端口地址加载到DX寄存器
    MOV AL,11111111B; 设置AL寄存器的值为二进制的11111111，用于绿色灯的显示
    OUT DX,AL; 将AL寄存器的值输出到绿色灯的控制端口
    
    MOV CX,27
    MOV AL,4FH ;十位数重新变为3
    MOV DX,PORTA
    OUT DX,AL
    
S3:MOV DX,PORTC
    MOV AL,00100100B; 设置AL寄存器的值为二进制的00100100，表示南北路口亮绿灯，东西路口亮红灯
    CALL DELAY_1S
    CMP CX,3 ;判断红灯是否大于6S，若大于6S，则需要检测是否有行人按下按钮2
    JB NO2
    MOV DX,0FFFFH ; 将DX寄存器的值设置为0xFFFF，用于检测键盘输入
    MOV AH,06H ; 设置AH寄存器的值为06H，表示调用键盘输入功能
    INT 21H;进入06号功能，检测键盘是否有按键按下。
    ;若按键为2，则代表行人按下，直接跳到绿灯
    CMP AL,50
    JNZ NO2
    JMP S11
NO2:
    CMP CX,18 ; 判断是不是已经倒计时了10秒，若倒计时了10秒，将十位数从2切换到1；并将点阵进度减小一些
    JNZ FLAG31
    MOV DX,PORTA
    MOV AL,5BH ;十位数变为2
    OUT DX,AL
    
        ;点阵进度调整
    MOV DX,LINE
    MOV AL,11111000B
    OUT DX,AL
    MOV DX,GREEN
    MOV AL,11111111B
    OUT DX,AL
FLAG31:CMP CX,8
    JNZ FLAG32
    MOV DX,PORTA
    MOV AL,06H ;十位数变为1
    OUT DX,AL
    
        ;点阵进度调整
    MOV DX,LINE
    MOV AL,10000000B
    OUT DX,AL
    MOV DX,GREEN
    MOV AL,11111111B
   
    OUT DX,AL
FLAG32: LOOP S3

    MOV DX,PORTC   
    MOV AL,01000100B;又过了27S后，南北路口亮黄灯，东西路口亮红灯
    OUT DX,AL
    
    MOV CX,3
S4: CALL DELAY_1S
    CMP CX,3;判断是不是过了1s，过了1s后黄灯取反
    JNZ FLAG41
    MOV DX,PORTC
    MOV AL,10000000B;
    OUT DX,AL
FLAG41:CMP CX,2;判断是不是过了2s，过了2s后黄灯取反s
    JNZ FLAG42
    MOV DX,PORTC
    MOV AL,10000010B
    OUT DX,AL
    
        ;点阵进度调整
    MOV DX,LINE
    MOV AL,00000000B
    OUT DX,AL
    MOV DX,GREEN
    MOV AL,00000000B
    OUT DX,AL
FLAG42:LOOP S4
    JMP RESTART
    
    MOV AH,4CH
    INT 21H    

DELAY_1S PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX
    MOV DX,0FFFFH
    MOV AH,06H
    INT 21H;进入06号功能，检测键盘是否有按键按下。
    ;若按键为1，则代表有紧急情况，所有的灯均为红灯亮起，倒计时停止
    CMP AL,49
    JNZ CONTINUE
    CALL EMERGENCY
    POP AX
    POP BX
    POP CX
    POP DX
    OUT DX,AL
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX
CONTINUE:
    MOV CX,4000
T1: MOV BX,3000
T2: DEC BX
    JNZ T2
    LOOP T1
    POP AX
    POP BX
    POP CX
    POP DX
    RET
DELAY_1S ENDP

EMERGENCY PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX

    MOV DX,PORTC
    MOV AL,10000100B;全部亮红灯
    OUT DX,AL
CIRCLE:
    MOV DX,0FFFFH ;紧急情况中的循环不断判断是否有按键0，有按键0则紧急情况解除，回到源程序
    MOV AH,06H
    INT 21H
    CMP AL,48
    JNZ CIRCLE
    
    POP AX
    POP BX
    POP CX
    POP DX
    RET
EMERGENCY ENDP
    CODE ENDS
    END START
