`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/09 19:56:27
// Design Name: 
// Module Name: MPU6050_PowerOnDelay
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




//mpu6050上电延时模块
module MPU6050PowerOnDelay(
	
	input		clk,
	input		rst,
	
	
	input		PowerOnDelayReq,
	output		PowerOnDelayDone
);

localparam	DelayCycle = 'd5000_0000;


reg[35:0]   cnt;


assign PowerOnDelayDone = (cnt == DelayCycle) ? 1'b1 : 1'b0;

always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		cnt <= 'd0;
	else if(PowerOnDelayReq == 1'b1)
		cnt <= cnt + 1'b1;
	else	
		cnt <= 'd0;

end


endmodule 
