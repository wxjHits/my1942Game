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





module MPU6050ReadACCEL(

	input		clk,
	input 	    rst,
	
	
	input		ReadReq,

	
	input			    WriteDone,			//一个数据写完
	input[7:0]		    ReadData,			//读到的数据
	output reg[15:0]	ACCELData,			//accle数据
	
	
	output[15:0]	ACCELX,
	output[15:0]	ACCELY,
	output[15:0]	ACCELZ,
	output		    ReadDone

);


localparam	ACCEL_XOUT_H	=  8'h3b;
localparam	ACCEL_XOUT_L	=  8'h3c;	
localparam	ACCEL_YOUT_H	=  8'h3d;
localparam	ACCEL_YOUT_L	=  8'h3e;
localparam	ACCEL_ZOUT_H	=  8'h3f;
localparam	ACCEL_ZOUT_L	=  8'h40;



reg[5:0] Index;


reg[15:0]	ACCELXReg;
reg[15:0]	ACCELYReg;	
reg[15:0]	ACCELZReg;

assign ReadDone = (Index == 'd5 && WriteDone == 1'b1) ? 1'b1 : 1'b0;

assign ACCELX = ACCELXReg;
assign ACCELY = ACCELYReg;
assign ACCELZ = ACCELZReg;


always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
	begin
		ACCELXReg <= 'd0;
		ACCELYReg <= 'd0;
		ACCELZReg <= 'd0;
	end
	else if(Index == 'd0 && WriteDone == 1'b1)
		ACCELXReg <= {ReadData,ACCELXReg[7:0]};
	else if(Index == 'd1 && WriteDone == 1'b1)
		ACCELXReg <= {ACCELXReg[15:8],ReadData};
		
	else if(Index == 'd2 && WriteDone == 1'b1)
		ACCELYReg <= {ReadData,ACCELYReg[7:0]};
	else if(Index == 'd3 && WriteDone == 1'b1)
		ACCELYReg <= {ACCELYReg[15:8],ReadData};
		
	else if(Index == 'd4 && WriteDone == 1'b1)
		ACCELZReg <= {ReadData,ACCELZReg[7:0]};
	else if(Index == 'd5 && WriteDone == 1'b1)
		ACCELZReg <= {ACCELZReg[15:8],ReadData};
	else begin
		ACCELXReg <= ACCELXReg;
		ACCELYReg <= ACCELYReg;
		ACCELZReg <= ACCELZReg;
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
	'd0:ACCELData <= {ACCEL_XOUT_H,8'h00};
	'd1:ACCELData <= {ACCEL_XOUT_L,8'h00};
	'd2:ACCELData <= {ACCEL_YOUT_H,8'h00};
	'd3:ACCELData <= {ACCEL_YOUT_L,8'h00};
	'd4:ACCELData <= {ACCEL_ZOUT_H,8'h00};
	'd5:ACCELData <= {ACCEL_ZOUT_L,8'h00};
	default:ACCELData <= {ACCEL_ZOUT_L,8'h00};
	endcase
end


endmodule 