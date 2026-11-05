DATA SEGMENT
    VARM1 DB 10H     ; VARM1 是一个字节型变量
    VARB  DB 0H      ; VARB 是用于存储左移次数的字节型变量
    VARW  DB 0H      ; VARW 是用于存储左移后结果的字节型变量
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE
START:
    MOV BL, 0       ; 初始化 BL 为 0
    MOV AX, VARM1   ; 将 VARM1 中的值加载到 AX

    ; 循环左移操作，直到最高位为 1

    JS DONE         ; 如果结果是负数，跳转到 DONE
LOOP_LEFT_SHIFT:
    INC BL          ; 左移次数加 1
    SHL AX, 1       ; 左移一位

    JMP LOOP_LEFT_SHIFT  ; 继续循环左移

DONE:
    MOV VARB, BL    ; 存储左移次数到 VARB
    MOV VARW, AL    ; 存储左移后的结果到 VARW
    INT 20H         ; 退出程序
CODE ENDS
END START
