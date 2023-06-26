`timescale 1ns / 1ps

module serializer_10_to_1(
    input           serial_clk_5x,      // 输入串行数据时钟
    input   [9:0]   paralell_data,      // 输入并行数据
	input reset,
    output 			serial_data_p,      // 输出串行差分数据P
    output 			serial_data_n       // 输出串行差分数据N
    );

//reg define
reg   [2:0]  bit_cnt = 0;
reg   [4:0]  datain_rise_shift = 0;
reg   [4:0]  datain_fall_shift = 0;

//wire define
wire  [4:0]  datain_rise;
wire  [4:0]  datain_fall;

//*****************************************************
//**                    main code
//*****************************************************

//上升沿发送Bit[8]/Bit[6]/Bit[4]/Bit[2]/Bit[0]
assign  datain_rise = {paralell_data[8],paralell_data[6],paralell_data[4],
                        paralell_data[2],paralell_data[0]};

//下降沿发送Bit[9]/Bit[7]/Bit[5]/Bit[3]/Bit[1]
assign  datain_fall = {paralell_data[9],paralell_data[7],paralell_data[5],
                        paralell_data[3],paralell_data[1]};

//位计数器赋值
always @(posedge serial_clk_5x) begin
    if(bit_cnt == 3'd4)
        bit_cnt <= 1'b0;
    else
        bit_cnt <= bit_cnt + 1'b1;
end

//移位赋值，发送并行数据的每一位
always @(posedge serial_clk_5x) begin
    if(bit_cnt == 3'd4) begin
        datain_rise_shift <= datain_rise;
        datain_fall_shift <= datain_fall;
    end
    else begin
        datain_rise_shift <= datain_rise_shift[4:1];
        datain_fall_shift <= datain_fall_shift[4:1];
    end
end
//安路2倍频输出原语
PH1_LOGIC_ODDR u_LOGIC_ODDR_p(
    .d0    (datain_rise_shift[0]),
    .d1    (datain_fall_shift[0]),
    .rst(reset),
    .clk    (serial_clk_5x),
    .q     (serial_data_p)
);
PH1_LOGIC_ODDR u_LOGIC_ODDR_n(
    .d0    (datain_rise_shift[0]),
    .d1    (datain_fall_shift[0]),
    .rst(reset),
    .clk    (serial_clk_5x),
    .q     (serial_data_n)
);


endmodule
