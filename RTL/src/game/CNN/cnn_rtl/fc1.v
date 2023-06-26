module fc1
#(
    parameter DATA_W = 16,
    parameter OUT_POINT = 32,
    parameter OUT_CNT_W = $clog2(OUT_POINT),
    parameter IN_LENGTH = 256,//输入数据量
    parameter FC_W_WIDTH = 16,//权重位宽
    parameter WEIGHTS_NUM = 16*4*4*32,//总权重数
    parameter WEIGHT_ADDR_W = $clog2(WEIGHTS_NUM)
)
(
    input clk,
    input rst_n,

    input   [DATA_W-1:0] data_in,
    input   data_in_valid,
    output  reg fc_ready,
    output  reg [DATA_W*OUT_POINT-1:0] data_out,
    output  reg data_out_valid
);
    reg [WEIGHT_ADDR_W-1:0] fc_w_rd_addr;
    wire [FC_W_WIDTH-1:0] fc_w_rd_data;
    wire [FC_W_WIDTH-1:0] fc_b_rd_data;
    reg [OUT_CNT_W-1:0]outpoint_cnt;//输出节点计数,也作为bias的地址
    reg [DATA_W-1:0] r1_data;//对齐权重延迟一拍
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            r1_data <= 'd0;
        else
            r1_data <= data_in;
    end
    //weights
    fcweights_rom
    #(
        "C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/fc1weights.txt",
        FC_W_WIDTH,
        WEIGHTS_NUM,
        WEIGHT_ADDR_W
    )
    fc1weights_rom_u
    (
        .clk(clk),
        .rom_raddr(fc_w_rd_addr),
        .rom_dout(fc_w_rd_data)
    );
    //bias
    /*fcweights_rom
    #(
        "C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/fc1bias.txt",
        FC_W_WIDTH,
        OUT_POINT,
        OUT_CNT_W
    )
    fc1bias_rom_u
    (
        .clk(clk),
        .rom_raddr(fc_w_rd_addr),
        .rom_dout(fc_b_rd_data)
    );*/
    //输出节点计数
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            outpoint_cnt <= 'd0;
        else begin
            if(outpoint_cnt == (OUT_POINT-1))
                outpoint_cnt <= 'd0;
            else if(fc_w_rd_addr == 'd0 && data_in_valid == 1'b1)//第一个valid才开始加
                outpoint_cnt <= outpoint_cnt + 1'b1;//只要不到31就+1
            else if(fc_w_rd_addr != 'd0)
                outpoint_cnt <= outpoint_cnt + 1'b1;
        end
    end
    reg [OUT_CNT_W-1:0] r1_outpoint_cnt;
    reg [OUT_CNT_W-1:0] r2_outpoint_cnt;//用于sum地址(因为乘和加二级流水线)
    always @(posedge clk or negedge rst_n) begin
        r1_outpoint_cnt <= outpoint_cnt;
        r2_outpoint_cnt <= r1_outpoint_cnt;
    end
    //读rom地址计数
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fc_w_rd_addr <= 'd0;
        else begin
            if((data_in_valid == 1 && fc_w_rd_addr == 'd0) || fc_w_rd_addr != 'd0)//第一个valid才开始加
                fc_w_rd_addr <= fc_w_rd_addr + 1'b1;
            else if(fc_w_rd_addr == (WEIGHTS_NUM))//addr为1~8192同步有效
                fc_w_rd_addr <= 'd0;
        end
    end
    //ready标志
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fc_ready <= 1'b1;
        else begin
            if(data_in_valid == 1'b1)//第一拍强制处理
                fc_ready <= 1'b0;
            else if(data_out_valid)//复位
                fc_ready <= 1'b1;
            else if(fc_ready == 1'b1 && fc_w_rd_addr != 'd0)//握手成功
                fc_ready <= 1'b0;
            else if(outpoint_cnt == (OUT_POINT-1-1))
                fc_ready <= 1'b1;
        end
    end

    reg signed [DATA_W+FC_W_WIDTH-1:0] mul_result;
    reg signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result [OUT_POINT-1:0];//输出32节点
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            mul_result <= 'd0;
        else
            mul_result <= $signed(fc_w_rd_data) * $signed(r1_data);
    end
    //复位打两拍addr
    reg [WEIGHT_ADDR_W-1:0] r1_fc_w_rd_addr;
    reg [WEIGHT_ADDR_W-1:0] r2_fc_w_rd_addr;
    reg [WEIGHT_ADDR_W-1:0] r3_fc_w_rd_addr;
    always @(posedge clk) begin
        r1_fc_w_rd_addr <= fc_w_rd_addr;
        r2_fc_w_rd_addr <= r1_fc_w_rd_addr;
        r3_fc_w_rd_addr <= r2_fc_w_rd_addr;
    end
    integer i;
	always @(posedge clk or negedge rst_n) begin
        if(!rst_n || (fc_w_rd_addr <= 'd1 && r3_fc_w_rd_addr == 'd0) || (fc_w_rd_addr == 'd0 && r3_fc_w_rd_addr == 'd0))//开头置零和最后复位
            for(i=0;i<OUT_POINT;i=i+1) begin
                sum_result [i] <= 'd0;
            end
        else begin
            sum_result[r2_outpoint_cnt] <= sum_result[r2_outpoint_cnt] + mul_result;
        end
	end

    /*wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_0 = sum_result[0];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_1 = sum_result[1];//实际的第一通道
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_2 = sum_result[2];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_3 = sum_result[3];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_4 = sum_result[4];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_5 = sum_result[5];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_6 = sum_result[6];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_7 = sum_result[7];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_8 = sum_result[8];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_9 = sum_result[9];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_10 = sum_result[10];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_11 = sum_result[11];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_12 = sum_result[12];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_13 = sum_result[13];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_14 = sum_result[14];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_15 = sum_result[15];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_16 = sum_result[16];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_17 = sum_result[17];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_18 = sum_result[18];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_19 = sum_result[19];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_20 = sum_result[20];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_21 = sum_result[21];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_22 = sum_result[22];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_23 = sum_result[23];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_24 = sum_result[24];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_25 = sum_result[25];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_26 = sum_result[26];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_27 = sum_result[27];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_28 = sum_result[28];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_29 = sum_result[29];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_30 = sum_result[30];
    wire signed [2*(DATA_W+FC_W_WIDTH)-1:0] sum_result_vis_31 = sum_result[31];
    wire signed [DATA_W-1:0] vis_1_real = sum_result_vis_1 >>> 12;
    wire signed [DATA_W-1:0] vis_0_real = sum_result_vis_0 >>> 12;
    wire signed [DATA_W-1:0] vis_2_real = sum_result_vis_2 >>> 12;
    wire signed [DATA_W-1:0] vis_3_real = sum_result_vis_3 >>> 12;
    wire signed [DATA_W-1:0] vis_4_real = sum_result_vis_4 >>> 12;
    wire signed [DATA_W-1:0] vis_5_real = sum_result_vis_5 >>> 12;
    wire signed [DATA_W-1:0] vis_6_real = sum_result_vis_6 >>> 12;
    wire signed [DATA_W-1:0] vis_7_real = sum_result_vis_7 >>> 12;
    wire signed [DATA_W-1:0] vis_8_real = sum_result_vis_8 >>> 12;
    wire signed [DATA_W-1:0] vis_9_real = sum_result_vis_9 >>> 12;
    wire signed [DATA_W-1:0] vis_10_real = sum_result_vis_10 >>> 12;
    wire signed [DATA_W-1:0] vis_11_real = sum_result_vis_11 >>> 12;
    wire signed [DATA_W-1:0] vis_12_real = sum_result_vis_12 >>> 12;
    wire signed [DATA_W-1:0] vis_13_real = sum_result_vis_13 >>> 12;
    wire signed [DATA_W-1:0] vis_14_real = sum_result_vis_14 >>> 12;
    wire signed [DATA_W-1:0] vis_15_real = sum_result_vis_15 >>> 12;
    wire signed [DATA_W-1:0] vis_16_real = sum_result_vis_16 >>> 12;
    wire signed [DATA_W-1:0] vis_17_real = sum_result_vis_17 >>> 12;
    wire signed [DATA_W-1:0] vis_18_real = sum_result_vis_18 >>> 12;
    wire signed [DATA_W-1:0] vis_19_real = sum_result_vis_19 >>> 12;
    wire signed [DATA_W-1:0] vis_20_real = sum_result_vis_20 >>> 12;
    wire signed [DATA_W-1:0] vis_21_real = sum_result_vis_21 >>> 12;
    wire signed [DATA_W-1:0] vis_22_real = sum_result_vis_22 >>> 12;
    wire signed [DATA_W-1:0] vis_23_real = sum_result_vis_23 >>> 12;
    wire signed [DATA_W-1:0] vis_24_real = sum_result_vis_24 >>> 12;
    wire signed [DATA_W-1:0] vis_25_real = sum_result_vis_25 >>> 12;
    wire signed [DATA_W-1:0] vis_26_real = sum_result_vis_26 >>> 12;
    wire signed [DATA_W-1:0] vis_27_real = sum_result_vis_27 >>> 12;
    wire signed [DATA_W-1:0] vis_28_real = sum_result_vis_28 >>> 12;
    wire signed [DATA_W-1:0] vis_29_real = sum_result_vis_29 >>> 12;
    wire signed [DATA_W-1:0] vis_30_real = sum_result_vis_30 >>> 12;
    wire signed [DATA_W-1:0] vis_31_real = sum_result_vis_31 >>> 12;*/

    always@(posedge clk) begin
        if(r3_fc_w_rd_addr == 'd8191)
            data_out_valid <= 'd1;
        else
            data_out_valid <= 'd0;
        end

    genvar k;
    reg signed [DATA_W-1:0] sum_shift [OUT_POINT-1:0];
    generate
        for(k=0;k<OUT_POINT;k=k+1) begin
            always @(posedge clk) begin
                sum_shift[k] <= sum_result[k] >>> 12;
                //sum_shift[k] <= sum_result[k];
            end
        end
    endgenerate
    genvar j;
    generate
        for(j=0;j<OUT_POINT;j=j+1) begin
            always @(*) begin
                data_out[(j<<4)+:DATA_W] <= (sum_shift[j][DATA_W-1]==1'b0) ? sum_shift[j] : {DATA_W{1'b0}};
            end
        end
    endgenerate
    //debug
    /*wire [15:0] sum_shift_0_debug = sum_shift[0];
    wire [15:0] sum_shift_1_debug = sum_shift[1];
    wire [15:0] sum_shift_2_debug = sum_shift[2];
    wire [15:0] sum_shift_3_debug = sum_shift[3];
    wire [15:0] sum_shift_4_debug = sum_shift[4];
    wire [15:0] sum_shift_5_debug = sum_shift[5];
    wire [15:0] sum_shift_6_debug = sum_shift[6];
    wire [15:0] sum_shift_7_debug = sum_shift[7];
    wire [15:0] sum_shift_8_debug = sum_shift[8];
    wire [15:0] sum_shift_9_debug = sum_shift[9];
    wire [15:0] sum_shift_10_debug = sum_shift[10];
    wire [15:0] sum_shift_11_debug = sum_shift[11];
    wire [15:0] sum_shift_12_debug = sum_shift[12];
    wire [15:0] sum_shift_13_debug = sum_shift[13];
    wire [15:0] sum_shift_14_debug = sum_shift[14];
    wire [15:0] sum_shift_15_debug = sum_shift[15];
    wire [15:0] sum_shift_16_debug = sum_shift[16];
    wire [15:0] sum_shift_17_debug = sum_shift[17];
    wire [15:0] sum_shift_18_debug = sum_shift[18];
    wire [15:0] sum_shift_19_debug = sum_shift[19];
    wire [15:0] sum_shift_20_debug = sum_shift[20];
    wire [15:0] sum_shift_21_debug = sum_shift[21];
    wire [15:0] sum_shift_22_debug = sum_shift[22];
    wire [15:0] sum_shift_23_debug = sum_shift[23];
    wire [15:0] sum_shift_24_debug = sum_shift[24];
    wire [15:0] sum_shift_25_debug = sum_shift[25];
    wire [15:0] sum_shift_26_debug = sum_shift[26];
    wire [15:0] sum_shift_27_debug = sum_shift[27];
    wire [15:0] sum_shift_28_debug = sum_shift[28];
    wire [15:0] sum_shift_29_debug = sum_shift[29];
    wire [15:0] sum_shift_30_debug = sum_shift[30];
    wire [15:0] sum_shift_31_debug = sum_shift[31];*/
endmodule //fc1