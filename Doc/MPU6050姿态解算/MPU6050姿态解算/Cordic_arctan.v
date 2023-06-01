`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ValentineHP
// 
// Create Date: 2023/05/09 22:14:23
// Design Name: 
// Module Name: Cordic_arctan
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cordic_arctan(

    input           clk,
    input           rst_n,

    input           cordic_req,
    output          cordic_ack,

    input signed[15:0]  X,
    input signed[15:0]  Y,

    output[15:0]            amplitude,  //幅度，偏大1.64倍，这里做了近似处理
    output  signed[31:0]    theta    //扩大了2^16
);


`define rot0  32'd2949120       //45度*2^16
`define rot1  32'd1740992       //26.5651度*2^16
`define rot2  32'd919872        //14.0362度*2^16
`define rot3  32'd466944        //7.1250度*2^16
`define rot4  32'd234368        //3.5763度*2^16
`define rot5  32'd117312        //1.7899度*2^16
`define rot6  32'd58688         //0.8952度*2^16
`define rot7  32'd29312         //0.4476度*2^16
`define rot8  32'd14656         //0.2238度*2^16
`define rot9  32'd7360          //0.1119度*2^16
`define rot10 32'd3648          //0.0560度*2^16
`define rot11 32'd1856          //0.0280度*2^16
`define rot12 32'd896           //0.0140度*2^16
`define rot13 32'd448           //0.0070度*2^16
`define rot14 32'd256           //0.0035度*2^16
`define rot15 32'd128           //0.0018度*2^16




reg signed[31:0]    Xn[16:0];
reg signed[31:0]    Yn[16:0];
reg signed[31:0]    Zn[16:0];
reg[31:0]           rot[15:0];
reg                 cal_delay[16:0];


assign cordic_ack = cal_delay[16];
assign theta      = Zn[16];
assign amplitude  = (Xn[16] >>> 1) + (Xn[16] >>> 3) >>> 16;  ////幅度，偏大1.64倍，这里做了近似处理 ,然后缩小了2^16

always@(posedge clk)
begin
    rot[0] <= `rot0;
    rot[1] <= `rot1;
    rot[2] <= `rot2;
    rot[3] <= `rot3;
    rot[4] <= `rot4;
    rot[5] <= `rot5;
    rot[6] <= `rot6;
    rot[7] <= `rot7;
    rot[8] <= `rot8;
    rot[9] <= `rot9;
    rot[10] <= `rot10;
    rot[11] <= `rot11;
    rot[12] <= `rot12;
    rot[13] <= `rot13;
    rot[14] <= `rot14;
    rot[15] <= `rot15;
end

always@(posedge clk or negedge rst_n)
begin
    if( rst_n == 1'b0)
        cal_delay[0] <= 1'b0;
    else
        cal_delay[0] <= cordic_req;
end

genvar j;
generate
    for(j = 1 ;j < 17 ; j = j + 1)
    begin: loop
        always@(posedge clk or negedge rst_n)
        begin
            if( rst_n == 1'b0)
                cal_delay[j] <= 1'b0;
            else
                cal_delay[j] <= cal_delay[j-1];
        end
    end
endgenerate

//将坐标挪到第一和四项限中
always@(posedge clk or negedge rst_n)
begin
    if( rst_n == 1'b0)
    begin
        Xn[0] <= 'd0;
        Yn[0] <= 'd0;
        Zn[0] <= 'd0;
    end
    else if( cordic_req == 1'b1)
    begin
        if( X < $signed(0) && Y < $signed(0))
        begin
            Xn[0] <= -(X << 16);
            Yn[0] <= -(Y << 16);
        end
        else if( X < $signed(0) && Y > $signed(0))
        begin
            Xn[0] <= -(X << 16);
            Yn[0] <= -(Y << 16);
        end
        else
        begin
            Xn[0] <= X << 16;
            Yn[0] <= Y << 16;
        end
        Zn[0] <= 'd0;
    end
    else 
    begin
        Xn[0] <= Xn[0];
        Yn[0] <= Yn[0];
        Zn[0] <= Zn[0];
    end
end


//旋转
genvar i;
generate
    for( i = 1 ;i < 17 ;i = i+1)
    begin: loop2
        always@(posedge clk or negedge rst_n)
        begin
            if( rst_n == 1'b0)
            begin
                Xn[i] <= 'd0;
                Yn[i] <= 'd0;
                Zn[i] <= 'd0;
            end
            else if( cal_delay[i -1] == 1'b1)
            begin
                if( Yn[i-1][31] == 1'b0)
                begin
                    Xn[i] <= Xn[i-1] + (Yn[i-1] >>> (i-1));
                    Yn[i] <= Yn[i-1] - (Xn[i-1] >>> (i-1));
                    Zn[i] <= Zn[i-1] + rot[i-1];
                end
                else
                begin
                    Xn[i] <= Xn[i-1] - (Yn[i-1] >>> (i-1));
                    Yn[i] <= Yn[i-1] + (Xn[i-1] >>> (i-1));
                    Zn[i] <= Zn[i-1] - rot[i-1];
                end
            end
            else
            begin
                Xn[i] <= Xn[i];
                Yn[i] <= Yn[i];
                Zn[i] <= Zn[i];
            end
        end
    end
endgenerate



endmodule
