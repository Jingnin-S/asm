DATA SEGMENT             
  NUM DB 20H,?,20H DUP(?)
  NUM1 DB 0H
  THE DB 'THE'           
DATA ENDS                
CODE SEGMENT             
  ASSUME CS:CODE,DS:DATA 
START:                   
  MOV AX,DATA           
  MOV DS,AX              
  MOV BX,OFFSET NUM           
  MOV DX,BX              
  MOV AH,0AH            
  INT 21H                
  MOV CH,0
  MOV CL,NUM+1 ;¼ÆÊý      
  ADD BX,2                   
  MOV DX,BX
  DEC CX
  ADD DX,CX            
LOP:                  
  MOV AX,BX
  ADD AX,2
  CMP DX,AX
  JBE OVER
B1:
  MOV AL,[BX]
  CMP AL,THE 
  JNZ L1
  INC BX
  MOV AL,[BX]
  CMP AL,THE+1
  JNZ L2
  INC BX
  MOV AL,[BX]
  CMP AL,THE+2
  JNZ L3
  INC CH
  INC BX
LOOP LOP
L1: INC BX
    JMP B1
L2: JMP B1
L3: JMP B1
OVER:       
  MOV DL,0DH
  MOV AH,02H
  INT 21H 
  MOV DL,0AH
  MOV AH,02H
  INT 21H
  ADD CH,30H
  MOV DL,CH
  MOV AH,02H
  INT 21H
  MOV AH,4CH
  INT 21H
CODE ENDS
END START
 