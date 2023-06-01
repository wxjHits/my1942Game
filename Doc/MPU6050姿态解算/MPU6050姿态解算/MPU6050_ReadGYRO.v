

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ValentineHP
// 
// Create Date: 2023/05/09 19:41:57
// Design Name: 
// Module Name: MPU6050_TOP
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


module MPU6050ReadGYRO(
	
	input		clk,
	input 	rst,
	
	
	input		ReadReq,
	
	
	input			WriteDone,			//一个数据读完
	input[7:0]		ReadData,			//读到的数据
	output reg[15:0]	GYROData,			//gyro数据
	
	
	output[15:0]	GYROX,
	output[15:0]	GYROY,
	output[15:0]	GYROZ,
	output		ReadDone

);

	
localparam	GYRO_XOUT_H	= 8'h43;
localparam	GYRO_XOUT_L	= 8'h44;	
localparam	GYRO_YOUT_H	= 8'h45;
localparam	GYRO_YOUT_L	= 8'h46;
localparam	GYRO_ZOUT_H	= 8'h47;
localparam	GYRO_ZOUT_L	= 8'h48;



reg[5:0] Index;


reg[15:0]	GYROXReg;
reg[15:0]	GYROYReg;	
reg[15:0]	GYROZReg;

assign ReadDone = (Index == 'd5 && WriteDone == 1'b1) ? 1'b1 : 1'b0;

assign GYROX = GYROXReg;
assign GYROY = GYROYReg;
assign GYROZ = GYROZReg;


always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
	begin
		GYROXReg <= 'd0;
		GYROYReg <= 'd0;
		GYROZReg <= 'd0;
	end
	else if(Index == 'd0 && WriteDone == 1'b1)
		GYROXReg <= {ReadData,GYROXReg[7:0]};
	else if(Index == 'd1 && WriteDone == 1'b1)
		GYROXReg <= {GYROXReg[15:8],ReadData};
		
	else if(Index == 'd2 && WriteDone == 1'b1)
		GYROYReg <= {ReadData,GYROYReg[7:0]};
	else if(Index == 'd3 && WriteDone == 1'b1)
		GYROYReg <= {GYROYReg[15:8],ReadData};
		
	else if(Index == 'd4 && WriteDone == 1'b1)
		GYROZReg <= {ReadData,GYROZReg[7:0]};
	else if(Index == 'd5 && WriteDone == 1'b1)
		GYROZReg <= {GYROZReg[15:8],ReadData};
	else begin
		GYROXReg <= GYROXReg;
		GYROYReg <= GYROYReg;
		GYROZReg <= GYROZReg;
	end
	
end


always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		Index <= 'd0;
	else if(ReadReq == 1'b1)
		if(WriteDone == 1'b1 && Index < 'd5)
			Index <= Index + 1'b1;
		else if(WriteDone == 1'b1)
			Index <= 'd0;
		else
			Index <= Index;
	else
		Index <= 'd0;
end

always@(*)
begin
	case(Index)
	'd0:GYROData <= {GYRO_XOUT_H,8'h00};
	'd1:GYROData <= {GYRO_XOUT_L,8'h00};
	'd2:GYROData <= {GYRO_YOUT_H,8'h00};
	'd3:GYROData <= {GYRO_YOUT_L,8'h00};
	'd4:GYROData <= {GYRO_ZOUT_H,8'h00};
	'd5:GYROData <= {GYRO_ZOUT_L,8'h00};
	default:GYROData <= {GYRO_ZOUT_L,8'h00};
	endcase
end


endmodule 