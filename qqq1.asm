DATA SEGMENT 
    string  DB ''Hello, world !','$';定义字符率3 date ends
code segment

assume cs:code, ds:date6 start:

mov ax,date ;设置入口参数

mov ds ,ax

MOV dx, offset string
mov ah,09h ;调用09字符串显示功能
int 21h
mov ax,4ch ;返回DOSint 21h
code ends

    end start