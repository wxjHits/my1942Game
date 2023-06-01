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



//mpu6050初始化
module MPU6050Init(

	input			    clk,
	input			    rst,
	
	input			    InitReq,			//初始化请求
	
	
	input			    WriteDone,			//一个数据写完
	
	output		        InitDone,			//初始化完成
	output reg[15:0]	InitData			//初始化数据

);

localparam	PWR_MGMT_1   =   8'h6B;
localparam	SMPLRT_DIV   =   8'h19;//sample rate.  Fsample= 1Khz/(<this value>+1) = 1000Hz	
localparam	MPU_CONFIG   =   8'h1A;//内部低通  acc:44hz	gyro:42hz
localparam  GYRO_CONFIG  =   8'h1B;// gyro scale  ：+-2000°/s
localparam	ACCEL_CONFIG =   8'h1C;// Accel scale ：+-8g (65536/16=4096 LSB/g) 

reg[5:0] Index;

assign InitDone = (Index == 'd4 && WriteDone == 1'b1) ? 1'b1 : 1'b0;






always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		Index <= 'd0;
	else if(InitReq == 1'b1)
		if(WriteDone == 1'b1)
			Index <= Index + 1'b1;
		else
			Index <= Index;
	else
		Index <= Index;
end


always@(*)
begin
	case(Index)
	'd0:InitData <= {PWR_MGMT_1,8'h00};
	'd1:InitData <= {SMPLRT_DIV,8'h29};
	'd2:InitData <= {MPU_CONFIG,8'h03};
	'd3:InitData <= {GYRO_CONFIG,8'h18};
	'd4:InitData <= {ACCEL_CONFIG,8'h10};
	default:InitData <= {PWR_MGMT_1,8'h80};
	endcase
end

endmodule 