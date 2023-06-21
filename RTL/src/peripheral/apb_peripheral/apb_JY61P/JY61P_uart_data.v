/*
    APB总线
    JY61P串口数据的接收
*/
module JY61P_uart_data(
    input   wire                clk             ,
    input   wire                rstn            ,
    input   wire                jy61p_uart_rx   ,//port
    // output  wire           jy61p_uart_tx,
    output  wire signed [15:0]  Roll    ,
    output  wire signed [15:0]  Pitch   ,
    output  wire signed [15:0]  Yaw      
);

/*存储角度数据的信号声明*/
reg [7:0] Roll_L    ;
reg [7:0] Roll_H    ;
reg [7:0] Pitch_L   ;
reg [7:0] Pitch_H   ;
reg [7:0] Yaw_L     ;
reg [7:0] Yaw_H     ;

assign Roll  = {Roll_H,Roll_L   };
assign Pitch = {Pitch_H,Pitch_L };
assign Yaw   = {Yaw_H,Yaw_L     };

// ila_0 your_instance_name (
//     .clk(clk), // input wire clk    
//     .probe0(Roll), // input wire [15:0]  probe0  
//     .probe1(Pitch), // input wire [15:0]  probe1 
//     .probe2(Yaw) // input wire [15:0]  probe2
// );

/*uart接收模块的例化*/
wire        uart_rx_done;
wire [7:0]  uart_rx_data;

uart_recv u_uart_recv(
    .clk        (clk            ),
    .rstn       (rstn           ),
    .uart_rxd   (jy61p_uart_rx  ),
    .uart_done  (uart_rx_done   ),
    .uart_data  (uart_rx_data   ) 
);

wire        uart_rx_done_p  ;
reg         uart_rx_done_r0 ;
reg         uart_rx_done_r1 ;
always@(posedge clk)begin
    if(~rstn)begin
        uart_rx_done_r0<=0;
        uart_rx_done_r1<=0;
    end
    else begin
        uart_rx_done_r0<=uart_rx_done;
        uart_rx_done_r1<=uart_rx_done_r0;
    end
end
assign uart_rx_done_p = uart_rx_done_r0 & (~uart_rx_done_r1);

/***状态机，检测接收6个角度数据***/
reg [3:0] state ;
always@(posedge clk)begin
    if(~rstn)begin
        state<=0;
    end
    else begin
        case(state)
            0:begin //IDLE 检测0x55
                if(uart_rx_done_p && uart_rx_data==8'h55)
                    state<=1;
                else
                    state<=0;
            end
            1:begin//检测0x53
                if(uart_rx_done_p)begin
                    if(uart_rx_data==8'h53)
                        state<=2;
                    else
                        state<=0;
                end
                else
                    state<=1;
            end

            2:begin//Roll_L
                if(uart_rx_done_p)begin
                    Roll_L<=uart_rx_data;
                    state<=3;
                end
                else
                    state<=2;
            end

            3:begin//Roll_H
                if(uart_rx_done_p)begin
                    Roll_H<=uart_rx_data;
                    state<=4;
                end
                else
                    state<=3;
            end

            4:begin//Pitch_L
                if(uart_rx_done_p)begin
                    Pitch_L<=uart_rx_data;
                    state<=5;
                end
                else
                    state<=4;
            end

            5:begin//Pitch_H
                if(uart_rx_done_p)begin
                    Pitch_H<=uart_rx_data;
                    state<=6;
                end
                else
                    state<=5;
            end

            6:begin//Yaw_L
                if(uart_rx_done_p)begin
                    Yaw_L<=uart_rx_data;
                    state<=7;
                end
                else
                    state<=6;
            end

            7:begin//Yaw_H
                if(uart_rx_done_p)begin
                    Yaw_H<=uart_rx_data;
                    state<=8;
                end
                else
                    state<=7;
            end

            8:begin//
                if(uart_rx_done_p)
                    state<=9;
                else
                    state<=8;
            end
            9:begin//
                if(uart_rx_done_p)
                    state<=10;
                else
                    state<=9;
            end
            10:begin//
                if(uart_rx_done_p)
                    state<=0;
                else
                    state<=10;
            end
        endcase
    end
end

endmodule 