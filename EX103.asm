DATA SEGMENT
    LIST DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH ;共阴极数码管，无小数点的数字
    LST DB 0BFH,86H,0DBH,0CFH,0E6H,0EDH,0FDH,87H,0FFH,0EFH;带小数点的数字
DATA ENDS
;本实验中，用8255的A口（288H）连接位码，用8255的B口（289H）连接段码，用8255的C口（28AH）连接8个小灯
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:MOV AX,DATA
           MOV DS,AX
;8255初始化
           MOV AL,10000000B
           MOV DX,28BH
           OUT DX,AL
;用280H来表示IN0，用281H来表示IN1，用282H来表示IN2
LIN0:AND AX,0000H
         MOV DX,280H
         OUT DX,AL
         NOP
         NOP
         NOP
         NOP
         IN AL,DX

         MOV DX,28AH
         OUT DX,AL;输出到8个小灯上显示
         CALL DELAY

         MOV BX,5
         MUL BL
         MOV BL,255
         DIV BL
         MOV CH,AL;商送到CH中存储（用于输出个位）
         MOV CL,AH;余数送到CL中存储（用于输出十分位）

         MOV AL,00000001B;输出个位到数码管上
         MOV DX,288H
         OUT DX,AL
         MOV BX,0
         ADD BL,CH
         MOV AL,LST[BX]
         MOV DX,289H
         OUT DX,AL
         CALL DELAY
         MOV AX,0
         OUT DX,AL

         MOV AL,BL
         ADD AL,30H
         MOV DL,AL;在屏幕上打印出来
         MOV AH,02H
         INT 21H

         MOV DL,46             ;输出小数点，显示在屏幕上
         MOV AH,02H
         INT 21H

         MOV AL,00000010B;输出十分位到数码管上
         MOV DX,288H
         OUT DX,AL
         MOV AL,CL
         MOV BX,10
         MUL BL
         MOV BL,255
         DIV BL
         MOV BX,0
         ADD BL,AL
         MOV AL,LIST[BX]
         MOV DX,289H
         OUT DX,AL
         CALL DELAY
         MOV AX,0
         OUT DX,AL

         MOV AL,BL
         ADD AL,30H
         MOV DL,AL;在屏幕上打印出来
         MOV AH,02H
         INT 21H

         MOV DL,32                      ;输出空格
         MOV AH,02H
         INT 21H

LIN1:AND AX,0000H
         MOV DX,281H
         OUT DX,AL
         NOP
         NOP
         NOP
         NOP
         IN AL,DX

         MOV BX,5
         MUL BL
         MOV BL,255
         DIV BL
         MOV CH,AL;商送到CH中存储（用于输出个位）
         MOV CL,AH;余数送到CL中存储（用于输出十分位）

         MOV AL,00001000B;输出个位到数码管上
         MOV DX,288H
         OUT DX,AL
         MOV BX,0
         ADD BL,CH
         MOV AL,LST[BX]
         MOV DX,289H
         OUT DX,AL
         CALL DELAY
         MOV AX,0
         OUT DX,AL

         MOV AL,BL
         ADD AL,30H
         MOV DL,AL;在屏幕上打印出来
         MOV AH,02H
         INT 21H

         MOV DL,46             ;输出小数点，显示在屏幕上
         MOV AH,02H
         INT 21H

         MOV AL,00010000B;输出十分位到数码管上
         MOV DX,288H
         OUT DX,AL
         MOV AL,CL
         MOV BX,10
         MUL BL
         MOV BL,255
         DIV BL
         MOV BX,0
         ADD BL,AL
         MOV AL,LIST[BX]
         MOV DX,289H
         OUT DX,AL
         CALL DELAY
         MOV AX,0
         OUT DX,AL

         MOV AL,BL
         ADD AL,30H
         MOV DL,AL;在屏幕上打印出来
         MOV AH,02H
         INT 21H

         MOV DL,32                      ;输出空格
         MOV AH,02H
         INT 21H

LIN2:AND AX,0000H
         MOV DX,282H
         OUT DX,AL
         NOP
         NOP
         NOP
         NOP
         IN AL,DX

         MOV BX,5
         MUL BL
         MOV BL,255
         DIV BL
         MOV CH,AL;商送到CH中存储（用于输出个位）
         MOV CL,AH;余数送到CL中存储（用于输出十分位）

         MOV AL,01000000B;输出个位到数码管上
         MOV DX,288H
         OUT DX,AL
         MOV BX,0
         ADD BL,CH
         MOV AL,LST[BX]
         MOV DX,289H
         OUT DX,AL
         CALL DELAY
         MOV AX,0
         OUT DX,AL

         MOV AL,BL
         ADD AL,30H
         MOV DL,AL;在屏幕上打印出来
         MOV AH,02H
         INT 21H

         MOV DL,46             ;输出小数点，显示在屏幕上
         MOV AH,02H
         INT 21H

         MOV AL,10000000B;输出十分位到数码管上
         MOV DX,288H
         OUT DX,AL
         MOV AL,CL
         MOV BX,10
         MUL BL
         MOV BL,255
         DIV BL
         MOV BX,0
         ADD BL,AL
         MOV AL,LIST[BX]
         MOV DX,289H
         OUT DX,AL
         CALL DELAY
         MOV AX,0
         OUT DX,AL

         MOV AL,BL
         ADD AL,30H
         MOV DL,AL;在屏幕上打印出来
         MOV AH,02H
         INT 21H

         MOV DL,0DH                      ;输出空格
         MOV AH,02H
         INT 21H
         JMP LIN0

DELAY PROC           ;延时程序
PUSH AX
PUSH CX
MOV CX,0100H
T1:MOV AX,0005H
T2:DEC AX
JNZ T2
LOOP T1
POP CX
POP AX                                                                                                                                   
RET
DELAY ENDP

CODE ENDS
  END START
