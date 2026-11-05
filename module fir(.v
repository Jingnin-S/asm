module JIANBOQI(
    input   clk,    //输入时钟  频率为2KHZ
    input   rst,    //复位信号   
    input   signed[11:0]  Xin,  //输入数据,频率为2KHZ
    output  signed[28:0] Yout   //输出数据
);

//将各个寄存器清零
reg signed [11:0] Xin_reg[15:0];
reg [ 3:0] i;
always @(posedge clk or negedge rst)
    if(!rst) begin
       for(i=0;i<15;i=i+1)
            Xin_reg[i] <= 12'd0;
    end
    else begin
        for(i=0;i<15;i=i+1)
            Xin_reg[i+1] <= Xin_reg[i];
        Xin_reg[0] <= Xin;
    end

//将对称系数的输入数据相加，同时将对应的滤波器系数送入乘法器
//为了进一步提高运算速度，零外增加了一级寄存器
reg signed [12:0] Add_reg[7:0];   //长度为滤波器长度的一半 因为是两个系数相加，所以位宽增加了一位
reg [3:0]  j;
always @(posedge clk or negedge rst)
    if(!rst) begin
        for(j=0;j<8;j=j+1)
            Add_reg[j] <= 12'd0;  
    end
    else begin
        for(j=0;j<8;j=j+1)
            Add_reg[j] <= {Xin_reg[j][11],Xin_reg[j]} + {Xin_reg[15-j][11],Xin_reg[15-j]};
    end
    
//得出结果，简便起见就直接用✖，不用乘法器IP核了 不过实际过程中推荐使用IP核
//fir8阶滤波器
reg signed[24:0] Mout[7:0];
reg [ 3:0] k;
wire signed[11:0] coe[7:0];

assign coe[0] = 12'h000;
assign coe[1] = 12'hffd;
assign coe[2] = 12'h00f;
assign coe[3] = 12'h02e;
assign coe[4] = 12'hf8b;
assign coe[5] = 12'hef9;
assign coe[6] = 12'h24e;
assign coe[7] = 12'h7ff;

always @(posedge clk or negedge rst)
    if(!rst) begin
        for(k=0;k<8;k=k+1)
            Mout[k] <= 12'd0;  
    end
    else begin
        for(k=0;k<8;k=k+1)
            Mout[k] <= Add_reg[k] * coe[k];
    end

//将滤波器系数与输入数据的乘法结果累加，并输出滤波后的结果
//与串行结构不同，此处在一个时钟周期内直接将所有乘法器结果相加
reg signed [28:0] sum;
reg signed [28:0] yout;
reg [ 3:0] L;
always @(posedge clk or negedge rst)
    if(!rst) begin
        sum <= 29'd0;
        yout <= 29'd0;
    end
    else begin
        yout <= sum;
        sum = 29'd0;
        for(L=0;L<8;L=L+1)
            sum = sum + Mout[L];
    end
assign Yout = yout;
endmodule 
