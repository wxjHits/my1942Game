module fc2
#(
    parameter DATA_W = 16,
    parameter OUT_POINT = 4,
    parameter OUT_CNT_W = $clog2(OUT_POINT),
    parameter IN_LENGTH = 32,//输入数据量
    parameter FC_W_WIDTH = 16,//权重位宽
    parameter WEIGHTS_NUM = 4*32,//总权重数
    parameter WEIGHT_ADDR_W = $clog2(WEIGHTS_NUM)
)
(
    input clk,
    input rst_n,

    input   [DATA_W*IN_LENGTH-1:0] data_in,
    input   data_in_valid,
    //output  reg [DATA_W*OUT_POINT-1:0] data_out,
    output  reg data_out_valid,
    output  reg [3:0] one_hot
);
    localparam IN_ADDR_W = $clog2(IN_LENGTH);
    reg [DATA_W*OUT_POINT-1:0] data_out;
    reg [DATA_W-1:0] data_in_spilt [IN_LENGTH-1:0];
    //debug
    wire [DATA_W*IN_LENGTH-1:0] in_debug = {data_in[31:0],data_in[DATA_W*IN_LENGTH-1:32]};
    genvar i;
    generate
        for(i=0;i<IN_LENGTH;i=i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n)
                    data_in_spilt[i] <= 'd0;
                else begin
                    if(data_in_valid)
                        data_in_spilt[i] <= in_debug[(i<<4)+:16];
                    else
                        data_in_spilt[i] <= data_in_spilt[i];
                end
            end
        end
    endgenerate

    //数据控制
    reg [WEIGHT_ADDR_W-1:0] fc2_w_addr;
    reg [WEIGHT_ADDR_W-1:0] r1_fc2_w_addr;
    reg [WEIGHT_ADDR_W-1:0] r2_fc2_w_addr;
    reg [IN_ADDR_W-1:0] fc2_data_addr;
    reg [DATA_W-1:0] fc2_data;
    wire [FC_W_WIDTH-1:0] fc2_w_data;
    reg start_flag;//开始计算
    always @(posedge clk) begin
        r1_fc2_w_addr <= fc2_w_addr;
        r2_fc2_w_addr <= r1_fc2_w_addr;
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            start_flag <= 'd0;
        else begin
            if(data_in_valid)
                start_flag <= 'd1;
            else if(r2_fc2_w_addr == WEIGHTS_NUM-1)
                start_flag <= 'd0;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fc2_w_addr <= 'd0;
        end
        else begin
            if(fc2_w_addr == WEIGHTS_NUM-1)
                fc2_w_addr <= 'd0;
            else if(start_flag && r2_fc2_w_addr != 'd127 && r1_fc2_w_addr != 'd127)
                fc2_w_addr <= fc2_w_addr + 'd1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fc2_data_addr <= 'd0;
        end
        else begin
            if(fc2_data_addr == IN_LENGTH-1)
                fc2_data_addr <= 'd0;
            else if(start_flag && r2_fc2_w_addr != 'd127 && r1_fc2_w_addr != 'd127)
                fc2_data_addr <= fc2_data_addr + 'd1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fc2_data <= 'd0;
        end
        else begin
            if(start_flag)
                fc2_data <= data_in_spilt[fc2_data_addr];
            else if(data_out_valid)//复位
                fc2_data <= 'd0;
        end
    end
    fcweights_rom
    #(
        "C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/fc2weights.txt",
        FC_W_WIDTH,
        WEIGHTS_NUM,
        WEIGHT_ADDR_W
    )
    fc1weights_rom_u
    (
        .clk(clk),
        .rom_raddr(fc2_w_addr),
        .rom_dout(fc2_w_data)
    );

    //数据运算
    reg [OUT_CNT_W-1:0] channel;
    reg signed [DATA_W+FC_W_WIDTH-1:0] r_sum_channel0;
    reg signed [DATA_W+FC_W_WIDTH-1:0] r_sum_channel1;
    reg signed [DATA_W+FC_W_WIDTH-1:0] r_sum_channel2;
    reg signed [DATA_W+FC_W_WIDTH-1:0] r_sum_channel3;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            channel <= 'd0;
        else begin
            if(fc2_w_addr == 'd33 || fc2_w_addr == 'd65 || fc2_w_addr == 'd97)
                channel <= channel + 'd1;
            else if(data_out_valid)//复位
                channel <= 'd0;
        end
    end
    //reg signed [DATA_W+FC_W_WIDTH-1:0] sum_result [OUT_POINT-1:0];
    reg signed [DATA_W+FC_W_WIDTH-1:0] mul_result;
    always @(posedge clk) begin
            mul_result <= $signed(fc2_data) * $signed(fc2_w_data);
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n || data_out_valid) begin
            r_sum_channel0 <= 'd0;
            r_sum_channel1 <= 'd0;
            r_sum_channel2 <= 'd0;
            r_sum_channel3 <= 'd0;
        end
        else begin
            if(start_flag) begin
            case(channel)
                'd0:begin
                    r_sum_channel0 <= r_sum_channel0 + mul_result;
                end
                'd1:begin
                    r_sum_channel1 <= r_sum_channel1 + mul_result;
                end
                'd2:begin
                    r_sum_channel2 <= r_sum_channel2 + mul_result;
                end
                'd3:begin
                    r_sum_channel3 <= r_sum_channel3 + mul_result;
                end
            endcase
            end
        end
    end
    reg pre_data_out_valid;
    reg pre1_data_out_valid;//抓取正确的四通道
    always @(posedge clk) begin
        data_out_valid <= pre_data_out_valid;
        pre_data_out_valid <= pre1_data_out_valid;
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            pre1_data_out_valid <= 'd0;
        else begin
            if(r2_fc2_w_addr == WEIGHTS_NUM-1)
                pre1_data_out_valid <= 'd1;
            else if(pre1_data_out_valid == 'd1)
                pre1_data_out_valid <= 'd0;
        end
    end

    wire signed [DATA_W-1:0] r_sum_channel0_shift = r_sum_channel0 >>>12;
    wire signed [DATA_W-1:0] r_sum_channel1_shift = r_sum_channel1 >>>12;
    wire signed [DATA_W-1:0] r_sum_channel2_shift = r_sum_channel2 >>>12;
    wire signed [DATA_W-1:0] r_sum_channel3_shift = r_sum_channel3 >>>12;
    //对齐数据、valid
    reg [DATA_W*OUT_POINT-1:0] r_data_out;
    always @(posedge clk) data_out <= r_data_out;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            r_data_out <= 'd0;
        else if(pre1_data_out_valid)
            r_data_out <= {r_sum_channel3_shift,r_sum_channel2_shift,r_sum_channel1_shift,r_sum_channel0_shift};
    end
    //one_hot
    reg [3:0] pre_one_hot;
    reg signed [DATA_W-1:0] big_0_1;
    reg signed [DATA_W-1:0] big_2_3;
    function [0:0] COMPARE;
        input [DATA_W-1:0] a;
        input [DATA_W-1:0] b;
        begin
            if(a[DATA_W-1] == b[DATA_W-1]) begin
                if(a > b)
                    COMPARE = 1;//a>b
                else
                    COMPARE = 0;
            end
            else if(a[DATA_W-1] == 1'b1 && b[DATA_W-1] == 1'b0)
                COMPARE = 0;
            else if(a[DATA_W-1] == 1'b0 && b[DATA_W-1] == 1'b1)
                COMPARE = 1;
        end
    endfunction
        function [0:0] COMPARE1;
        input [DATA_W-1:0] a;
        input [DATA_W-1:0] b;
        begin
            if(a[DATA_W-1] == b[DATA_W-1]) begin
                if(a > b)
                    COMPARE1 = 1;//a>b
                else
                    COMPARE1 = 0;
            end
            else if(a[DATA_W-1] == 1'b1 && b[DATA_W-1] == 1'b0)
                COMPARE1 = 0;
            else if(a[DATA_W-1] == 1'b0 && b[DATA_W-1] == 1'b1)
                COMPARE1 = 1;
        end
    endfunction
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            pre_one_hot <= 'd0;
        else if(pre1_data_out_valid) begin
            if(COMPARE(r_sum_channel0_shift,r_sum_channel1_shift)) begin
                pre_one_hot[1:0] <= 2'b01;//ch0大
                big_0_1 <= r_sum_channel0_shift;
            end
            else begin
                pre_one_hot[1:0] <= 2'b10;
                big_0_1 <= r_sum_channel1_shift;
            end
            if(COMPARE(r_sum_channel2_shift,r_sum_channel3_shift)) begin
                pre_one_hot[3:2] <= 2'b01;
                big_2_3 <= r_sum_channel2_shift;
            end
            else begin
                pre_one_hot[3:2] <= 2'b10;
                big_2_3 <= r_sum_channel3_shift;
            end
        end
    end
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            one_hot <= 'd0;
        else begin
            if(COMPARE1(big_0_1,big_2_3))
                one_hot <= {2'b00,pre_one_hot[1:0]};
            else
                one_hot <= {pre_one_hot[3:2],2'b00};
        end
    end
    //debug
    /*wire [15:0] data_in_spilt_0_debug  = data_in_spilt[0 ];
    wire [15:0] data_in_spilt_1_debug  = data_in_spilt[1 ];
    wire [15:0] data_in_spilt_2_debug  = data_in_spilt[2 ];
    wire [15:0] data_in_spilt_3_debug  = data_in_spilt[3 ];
    wire [15:0] data_in_spilt_4_debug  = data_in_spilt[4 ];
    wire [15:0] data_in_spilt_5_debug  = data_in_spilt[5 ];
    wire [15:0] data_in_spilt_6_debug  = data_in_spilt[6 ];
    wire [15:0] data_in_spilt_7_debug  = data_in_spilt[7 ];
    wire [15:0] data_in_spilt_8_debug  = data_in_spilt[8 ];
    wire [15:0] data_in_spilt_9_debug  = data_in_spilt[9 ];
    wire [15:0] data_in_spilt_10_debug = data_in_spilt[10];
    wire [15:0] data_in_spilt_11_debug = data_in_spilt[11];
    wire [15:0] data_in_spilt_12_debug = data_in_spilt[12];
    wire [15:0] data_in_spilt_13_debug = data_in_spilt[13];
    wire [15:0] data_in_spilt_14_debug = data_in_spilt[14];
    wire [15:0] data_in_spilt_15_debug = data_in_spilt[15];
    wire [15:0] data_in_spilt_16_debug = data_in_spilt[16];
    wire [15:0] data_in_spilt_17_debug = data_in_spilt[17];
    wire [15:0] data_in_spilt_18_debug = data_in_spilt[18];
    wire [15:0] data_in_spilt_19_debug = data_in_spilt[19];
    wire [15:0] data_in_spilt_20_debug = data_in_spilt[20];
    wire [15:0] data_in_spilt_21_debug = data_in_spilt[21];
    wire [15:0] data_in_spilt_22_debug = data_in_spilt[22];
    wire [15:0] data_in_spilt_23_debug = data_in_spilt[23];
    wire [15:0] data_in_spilt_24_debug = data_in_spilt[24];
    wire [15:0] data_in_spilt_25_debug = data_in_spilt[25];
    wire [15:0] data_in_spilt_26_debug = data_in_spilt[26];
    wire [15:0] data_in_spilt_27_debug = data_in_spilt[27];
    wire [15:0] data_in_spilt_28_debug = data_in_spilt[28];
    wire [15:0] data_in_spilt_29_debug = data_in_spilt[29];
    wire [15:0] data_in_spilt_30_debug = data_in_spilt[30];
    wire [15:0] data_in_spilt_31_debug = data_in_spilt[31];*/

endmodule //fc2