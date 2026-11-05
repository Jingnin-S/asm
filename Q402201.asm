DATA SEGMENT
    TIMES 10 DB 0 ; 分配一个大小为10字节的数组
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODA,DS:DATA
START:

ORG 100h    ; 程序的起始地址

MOV SI, 0    ; SI 寄存器用于数组索引
MOV CX, 10   ; 输入最多10个数字

; 初始化数组
MOV DI, 0    ; DI 寄存器用于数组元素的偏移地址
MOV BX, 10   ; 数组的大小

; 输入循环
INPUT_LOOP:
    MOV AH, 1    ; 调用 DOS 的功能 1，等待用户输入
    INT 21h      ; 调用 DOS中断

    ; 检查是否回车（ASCII码为13）
    CMP AL, 13
    JE EXIT_INPUT

    ; 将输入的字符转换为数字
    SUB AL, 48   ; ASCII 数字字符转换为整数

    ; 存储数字到数组
    MOV [BX+DI], AL

    INC DI       ; 增加数组偏移地址
    LOOP INPUT_LOOP  ; 继续输入直到 CX 变为 0

EXIT_INPUT:

; 处理数组中的数字为BCD格式
MOV SI, 0   ; 重新初始化 SI 为数组的起始索引
MOV CX, 10  ; 重新初始化 CX 为数组的大小

BCD_LOOP:
    ; 从数组中加载数
    MOV AL, [BX+SI]

    ; 将数字转换为BCD格式
    AAM

    ; 转换后的BCD格式数字存储到数组中
    MOV [BX+SI], AL

    INC SI       ; 增加数组索引
    LOOP BCD_LOOP

; 输出BCD格式的十六进制数到显示屏
MOV SI, 0   ; 重新初始化 SI 为数组的起始索引
MOV CX, 10  ; 重新初始化 CX 为数组的大小

OUTPUT_LOOP:
    ; 从数组中加载BCD格式的数字
    MOV AL, [BX+SI]

    ; 将BCD格式的数字转换为十六进制字符
    ADD AL, 30h

    ; 输出字符
    MOV AH, 2    ; 调用DOS的功能2，输出字符
    INT 21h      ; 调用DOS中断

    INC SI       ; 增加数组索引
    LOOP OUTPUT_LOOP

; 程序结束
MOV AH, 4Ch  ; 调用DOS的功能4Ch，程序结束
INT 21h

RET

; 数据段


; 程序结束
INT 20h
