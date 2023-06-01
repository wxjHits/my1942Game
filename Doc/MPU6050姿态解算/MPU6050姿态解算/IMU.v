`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/14 17:08:27
// Design Name: 
// Module Name: IMU
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


module IMU(
    input                       clk,
    input                       rst_n,

    input                       imu_req,
    output                      imu_ack,

    output signed[31:0]         roll,
    output signed[31:0]         pitch,
    output signed[31:0]         yaw,


    output                      IICSCL,             /*IIC 时钟输出*/
    inout                       IICSDA             /*IIC 数据线*/ 
);


localparam      S_IDLE          =   'd0;
localparam      S_READ_MPU6050  =   'd1;
localparam      S_Cordic        =   'd2;
localparam      S_Cordic2       =   'd3;
localparam      S_FILTER        =   'd4;
localparam      S_ACK           =   'd5;

reg[3:0]    state , next_state;

wire    mpu6050_req;
wire    mpu6050_ack;



wire signed[15:0]   GYROXo;
wire signed[15:0]   GYROYo;
wire signed[15:0]   GYROZo;
wire signed[15:0]   ACCELXo;
wire signed[15:0]   ACCELYo;
wire signed[15:0]   ACCELZo;




wire signed[31:0]   acc_roll;
wire signed[31:0]   acc_pitch;

reg signed[31:0]   gyro_roll;
reg signed[31:0]   gyro_pitch;
reg signed[31:0]   gyro_yaw;

wire    cordic_req;
wire    cordic_ack;

wire    cordic2_req;
wire    cordic2_ack;

wire signed[31:0]   theta;
wire signed[31:0]   theta2;
wire signed[15:0]   amplitude;

wire    fir_filter_req;
wire    fir_filter_ack;




assign   mpu6050_req = (state == S_READ_MPU6050) ? 1'b1 : 1'b0;
assign   cordic_req = (state == S_Cordic) ? 1'b1 : 1'b0;
assign   cordic2_req = (state == S_Cordic2) ? 1'b1 : 1'b0;
assign   fir_filter_req = (state == S_FILTER) ? 1'b1 : 1'b0;

assign   imu_ack = (state == S_ACK) ? 1'b1 : 1'b0;
assign   roll    = acc_roll;
assign   pitch   = acc_pitch;   
assign   yaw     = gyro_yaw;

always@(posedge clk or negedge rst_n) begin
    if( rst_n == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state; 
end

always@(*) begin
    case(state)
    S_IDLE:
        if( imu_req == 1'b1)
            next_state <= S_READ_MPU6050;
        else
            next_state <= S_IDLE;
    S_READ_MPU6050:
        if( mpu6050_ack == 1'b1 )
            next_state <= S_Cordic;
        else
            next_state <= S_READ_MPU6050;
    S_Cordic:
        if( cordic_ack == 1'b1)
            next_state <= S_Cordic2;
        else
            next_state <= S_Cordic;
    S_Cordic2:
        if( cordic2_ack == 1'b1)
            next_state <= S_FILTER;
        else
            next_state <= S_Cordic2;
    S_FILTER:
        if( fir_filter_ack == 1'b1)
            next_state <= S_ACK;
        else
            next_state <= S_FILTER;
    S_ACK:
        next_state <= S_IDLE;
    default:     next_state <= S_IDLE;
    endcase
end


always@(posedge clk or negedge rst_n)
begin
    if( rst_n == 1'b0) begin
        gyro_roll   <= 'd0;
        gyro_pitch  <= 'd0;
        gyro_yaw    <= 'd0;
    end
    else if( mpu6050_ack == 1'b1) begin
        gyro_roll   <= gyro_roll  + GYROXo;
        gyro_pitch  <= gyro_pitch + GYROYo;
        gyro_yaw    <= gyro_yaw   + GYROZo;
    end
    else begin
        gyro_roll   <= gyro_roll;
        gyro_pitch  <= gyro_pitch;
        gyro_yaw    <= gyro_yaw;
    end
end

MPU6050_TOP MPU6050_TOP_HP(

    .clk                        (           clk         ),
    .rst_n                      (           rst_n       ),

 
    .mpu6050_req                (           mpu6050_req ),
    .mpu6050_ack                (           mpu6050_ack ),

    

    .GYROXo                     (           GYROXo      ),
    .GYROYo                     (           GYROYo      ),    
    .GYROZo                     (           GYROZo      ),

    .ACCELXo                    (           ACCELXo     ),
    .ACCELYo                    (           ACCELYo     ),
    .ACCELZo                    (           ACCELZo     ),


    .IICSCL                     (           IICSCL      ),             /*IIC 时钟输出*/
    .IICSDA                     (           IICSDA      )/*IIC 数据线*/ 
);



Cordic_arctan   Cordic_arctan_HP(

    .clk                        (           clk         ),
    .rst_n                      (           rst_n       ),


    .cordic_req                 (           cordic_req  ),
    .cordic_ack                 (           cordic_ack  ),

    .X                          (           ACCELZo     ),
    .Y                          (           ACCELYo     ),

    .amplitude                  (           amplitude   ),  //幅度，偏大1.64倍，这里做了近似处理
    .theta                      (           theta       )  //扩大了2^16
);

Cordic_arctan   Cordic_arctan_HP2(

    .clk                        (           clk         ),
    .rst_n                      (           rst_n       ),


    .cordic_req                 (           cordic2_req  ),
    .cordic_ack                 (           cordic2_ack  ),

    .X                          (           amplitude   ),
    .Y                          (           ACCELXo     ),

    .amplitude                  (                       ),  //幅度，偏大1.64倍，这里做了近似处理
    .theta                      (           theta2      )  //扩大了2^16
);



FIR_Filter FIR_Filter_HP(

    .clk                        (           clk             ),
    .rst_n                      (           rst_n           ),

    .fir_filter_req             (           fir_filter_req  ),
    .fir_filter_ack             (           fir_filter_ack  ),

    .filter_data_in             (           theta           ),
    .filter_data_out            (           acc_roll        )
);


FIR_Filter FIR_Filter_HP2(

    .clk                        (           clk             ),
    .rst_n                      (           rst_n           ),

    .fir_filter_req             (           fir_filter_req  ),
    .fir_filter_ack             (                           ),

    .filter_data_in             (           theta2           ),
    .filter_data_out            (           acc_pitch        )
);
endmodule
