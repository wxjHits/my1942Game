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



module MPU6050_Read(
	
	input			clk,
	input			rst,
	
	output			SCL,
	inout			SDA,
	
	
	//读取角速度
	input			ReadGYROReq,
	output[15:0]	GYROX,
	output[15:0]	GYROY,
	output[15:0]	GYROZ,
	output		    GYRODone,
	
	//读取加速度
	input			ReadACCELReq,
	output[15:0]	ACCELX,
	output[15:0]	ACCELY,
	output[15:0]	ACCELZ,
	output		    ACCELDone	
);


localparam	S_PowerOnDelay  =   7'b00000_01;	//上电延时
localparam	S_IDLE	        =	7'b00000_10;
localparam	S_Init	        =	7'b00001_00;
localparam	S_ReadGYRO      =	7'b00010_00;
localparam	S_ReadACCEL     =	7'b00100_00;
localparam	S_MPURESET		=	7'b01000_00;
localparam	S_PowerOnDelay2 =   7'b10000_00;	//复位延时



reg[6:0]	state,next_state;


wire Done;
reg PowerOnDelayReq;
wire PowerOnDelayDone;



reg	 MpuResetReq;
wire MpuResetDone;


reg InitReq;

wire		InitDone;
wire[15:0]	InitData;
wire[7:0]	IICRead;

reg GYROReq;
wire[15:0]	GYROData;

reg ACCELReq;
wire[15:0]	ACCELData;


assign	MpuResetDone = Done;
always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		state <= S_PowerOnDelay;
	else
		state <= next_state;
end


always@(*)
begin
	case(state)
	S_PowerOnDelay:
		if(PowerOnDelayDone == 1'b1)
			next_state <= S_MPURESET;
		else
			next_state <= S_PowerOnDelay;
	S_MPURESET:
		if( MpuResetDone == 1'b1)
			next_state <= S_PowerOnDelay2;
		else
			next_state <= S_MPURESET;
	S_PowerOnDelay2:
		if( PowerOnDelayDone == 1'b1)
			next_state <= S_Init;
		else
			next_state <= S_PowerOnDelay2;
	S_Init:
		if(InitDone == 1'b1)
			next_state <= S_IDLE;
		else
			next_state <= S_Init;
	S_IDLE:
		if(ReadGYROReq == 1'b1)
			next_state <= S_ReadGYRO;
		else if(ReadACCELReq == 1'b1)
			next_state <= S_ReadACCEL;
		else
			next_state <= S_IDLE;
	S_ReadGYRO:
		if(GYRODone == 1'b1)
			next_state <= S_IDLE;
		else
			next_state <= S_ReadGYRO;
	S_ReadACCEL:
		if(ACCELDone == 1'b1)
			next_state <= S_IDLE;
		else
			next_state <= S_ReadACCEL;
	default:
		next_state <= S_PowerOnDelay;
	endcase
end





always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		PowerOnDelayReq <= 1'b0;
	else if(state == S_PowerOnDelay || state == S_PowerOnDelay2)
		PowerOnDelayReq <= 1'b1;
	else
		PowerOnDelayReq <= 1'b0;
end
//上电延时
MPU6050PowerOnDelay MPU6050PowerOnDelay_HP(
	
	.clk				(clk),
	.rst				(rst),
	
	
	.PowerOnDelayReq		(PowerOnDelayReq),
	.PowerOnDelayDone		(PowerOnDelayDone)
	
);


always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		MpuResetReq  <= 1'b0;
	else if(state == S_MPURESET)
		MpuResetReq <= 1'b1;
	else
		MpuResetReq <= 1'b0;
end


always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		InitReq  <= 1'b0;
	else if(state == S_Init)
		InitReq <= 1'b1;
	else
		InitReq <= 1'b0;
end

//初始化
MPU6050Init   MPU6050Init_HP(

	.clk			(clk),
	.rst			(rst),
	
	.InitReq		(InitReq),			//初始化请求
	
	
	.WriteDone		(Done),			//一个数据写完
	
	.InitDone		(InitDone),
	.InitData		(InitData)			//初始化数据

);




always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		GYROReq <= 1'b0;
	else if(state == S_ReadGYRO)
		GYROReq <= 1'b1;
	else
		GYROReq <= 1'b0;

end



MPU6050ReadGYRO  MPU6050ReadGYRO_HP(
	
	.clk		(clk),
	.rst		(rst),
	
	
	.ReadReq	(GYROReq),
	
	
	.WriteDone	(Done),		//一个数据写完
	.ReadData	(IICRead),			//读到的数据
	.GYROData	(GYROData),			//gyro数据
	
	
	.GYROX	(GYROX),
	.GYROY	(GYROY),
	.GYROZ	(GYROZ),
	.ReadDone	(GYRODone)

);



always@(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		ACCELReq <= 1'b0;
	else if(state == S_ReadACCEL)
		ACCELReq <= 1'b1;
	else
		ACCELReq <= 1'b0;

end

MPU6050ReadACCEL MPU6050ReadACCEL_HP
(
	.clk		(clk),
	.rst		(rst),
	
	
	.ReadReq	(ACCELReq),

	
	.WriteDone	(Done),			    //一个数据写完
	.ReadData	(IICRead),			//读到的数据
	.ACCELData	(ACCELData),		//accle数据
	
	
	.ACCELX	(ACCELX),
	.ACCELY	(ACCELY),
	.ACCELZ	(ACCELZ),
	.ReadDone	(ACCELDone)

);

wire[15:0]	I_R_W_Data;
wire		I_Start;



assign I_R_W_Data = (state == S_Init) ? InitData : (state == S_ReadGYRO) ? GYROData : 
					(state == S_ReadACCEL) ? ACCELData : 
					(state == S_MPURESET ) ? {8'h6B,8'h80} : 'd0;

assign I_R_W_SET = (state == S_Init || state == S_MPURESET) ? 1'b1 : 1'b0;
assign I_Start = (InitReq == 1'b1 || ACCELReq == 1'b1 || GYROReq == 1'b1 || MpuResetReq == 1'b1) ? 1'b1 : 1'b0;

I2C_Master I2C_Master_HP(
	.I_Clk_in		(clk),
	.I_Rst_n		(rst),
	.O_SCL			(SCL),
	.IO_SDA			(SDA),
	//control_sig
	.I_Start		(I_Start),   //开始信号
	.O_Done		(Done),    //数据输出有效
	.I_R_W_SET		(I_R_W_SET), //读写使能 读为0，写为1
	.I_Slave_Addr	(7'h68),//从机地址
	.I_R_W_Data		(I_R_W_Data),//I_R_W_Data[15:8]->reg_addr,I_R_W_Data[7:0]->W_data,
	.O_Data	(IICRead),  //读出的数据
	.O_Error()	  //读出错误
 );

endmodule 