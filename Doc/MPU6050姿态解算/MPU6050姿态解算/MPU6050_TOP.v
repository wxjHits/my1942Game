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


module MPU6050_TOP(

    input                       clk,
    input                       rst_n,

 
    input                       mpu6050_req,
    output                      mpu6050_ack,

    
    output   signed [15:0]      GYROXo,
    output   signed [15:0]      GYROYo,
    output   signed [15:0]      GYROZo,

    output   signed [15:0]      ACCELXo,
    output   signed [15:0]      ACCELYo,
    output   signed [15:0]      ACCELZo,


    output                      IICSCL,             /*IIC 时钟输出*/
    inout                       IICSDA             /*IIC 数据线*/ 
);



localparam      S_IDLE          =   'd0;
localparam      S_READ_GYRO     =   'd1;
localparam      S_READ_ACCEL    =   'd2;  
localparam      S_ACK           =   'd3;

reg[3:0]    state , next_state;
	
//读取角速度
wire		ReadGYROReq;
wire[15:0]	GYROX;
wire[15:0]	GYROY;
wire[15:0]	GYROZ;
wire	    GYRODone;

//读取加速度
wire		ReadACCELReq;
wire[15:0]	ACCELX;
wire[15:0]	ACCELY;
wire[15:0]	ACCELZ;
wire		ACCELDone;	


assign      mpu6050_ack = (state == S_ACK) ? 1'b1 : 1'b0;

assign      GYROXo      = GYROX;
assign      GYROYo      = GYROY;
assign      GYROZo      = GYROZ;

assign      ACCELXo     =   ACCELX;
assign      ACCELYo     =   ACCELY;
assign      ACCELZo     =   ACCELZ;



assign      ReadGYROReq = ( state == S_READ_GYRO) ? 1'b1 : 1'b0;
assign      ReadACCELReq = ( state == S_READ_ACCEL) ? 1'b1 : 1'b0;

always@(posedge clk or negedge rst_n) begin
    if( rst_n == 1'b0)
        state <= S_IDLE;
    else
        state <= next_state;
end

always@(*)begin
    case(state)
    S_IDLE:
        if( mpu6050_req == 1'b1 )
            next_state <= S_READ_GYRO;
        else
            next_state <= S_IDLE;
    S_READ_GYRO:
        if( GYRODone == 1'b1)
            next_state <= S_READ_ACCEL;
        else
            next_state <= S_READ_GYRO;
    S_READ_ACCEL:
        if( ACCELDone == 1'b1)
            next_state <= S_ACK;
        else
            next_state <= S_READ_ACCEL;
    S_ACK:
        next_state <= S_IDLE;
    default: next_state <= S_IDLE;
    endcase
end



// always@(posedge clk or negedge rst_n)
// begin
//     if(rst_n == 1'b0) begin
//         GYROXo <= 'd0;
//         GYROYo <= 'd0;
//         GYROZo <= 'd0;
//     end
//     else if( GYRODone == 1'b1) begin
//         GYROXo <=   GYROX;
//         GYROYo <=   GYROY;
//         GYROZo <=   GYROZ;
//     end
//     else begin
//         GYROXo <=   GYROXo;
//         GYROYo <=   GYROYo;
//         GYROZo <=   GYROZo;
//     end
// end

// always@(posedge clk or negedge rst_n)
// begin
//     if(rst_n == 1'b0) begin
//         ACCELXo <= 'd0;
//         ACCELYo <= 'd0;
//         ACCELZo <= 'd0;
//     end
//     else if( GYRODone == 1'b1) begin
//         ACCELXo <=   ACCELX;
//         ACCELYo <=   ACCELY;
//         ACCELZo <=   ACCELZ;
//     end
//     else begin
//         ACCELXo <=   ACCELXo;
//         ACCELYo <=   ACCELYo;
//         ACCELZo <=   ACCELZo;
//     end
// end

MPU6050_Read    MPU6050_Read_HP(
	
	.clk                        (       clk         ),
	.rst                        (       rst_n       ),

	.SCL                        (       IICSCL      ),
	.SDA                        (       IICSDA      ),
	
	
	//读取角速度
	.ReadGYROReq                (       ReadGYROReq ),
	.GYROX                      (       GYROX       ),
	.GYROY                      (       GYROY       ),
	.GYROZ                      (       GYROZ       ),
	.GYRODone                   (       GYRODone    ),
	
	//读取加速度
	.ReadACCELReq               (       ReadACCELReq),
	.ACCELX                     (       ACCELX      ),
	.ACCELY                     (       ACCELY      ),
	.ACCELZ                     (       ACCELZ      ),
	.ACCELDone                  (       ACCELDone   )	
);


endmodule
