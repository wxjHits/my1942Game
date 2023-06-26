`include "cnn_defines.v"
module conv1(
    clk                 ,
    rst_n               ,

    cnn_data_in         ,
    cnn_data_in_valid   ,

    cnn_data_out        ,
    cnn_data_out_valid
);
    localparam DATA_IN_W = 1;
    localparam DATA_OUT_W = 16;
    localparam WEIGHT_W = 16;

    input                           clk                 ;
    input                           rst_n               ;
    input   [DATA_IN_W-1:0]         cnn_data_in         ;
    input                           cnn_data_in_valid   ;
    output  [6*DATA_OUT_W-1:0]       cnn_data_out        ;
    output reg                      cnn_data_out_valid  ;

    /*======================= addr ============================*/
    reg [4:0] wr_addr;
    reg [4:0] rd_addr;
    wire [4:0] rd_addr_pre2 = wr_addr +2;
    always@(posedge clk, negedge rst_n)begin
        if(~rst_n)begin
            wr_addr <= 0;
            rd_addr <= 0;
        end
        else if(cnn_data_in_valid == 1'b1)begin
            //========== A ============
            if(wr_addr == 'd27)
                wr_addr <= 5'd0;
            else
                wr_addr <= wr_addr + 1'd1;
            //========== B ============
            if(rd_addr_pre2 > 'd27)
                rd_addr <= rd_addr_pre2 - 5'd28;
            else
                rd_addr <= rd_addr_pre2;
        end
    end
//======================= data ===============================
    wire    [DATA_IN_W-1:0]   window_in[0:5-1];
    wire    [DATA_IN_W-1:0]   window_out[0:5-1];
    assign  window_in[0] = cnn_data_in;
    genvar k;
    generate
    for(k = 1; k < 5; k = k + 1)begin
        assign window_in[k] = window_out[k-1];
    end
    endgenerate


    //======================= Instance ===============================

    generate
    for (k = 0; k < 5; k = k + 1)begin
    linebuffer
    #(
        DATA_IN_W,5,28
    )
    graylinebuffer_U
    (
        .clkw (clk              ),
        .w_en (cnn_data_in_valid),
        .waddr(wr_addr          ),
        .din  (window_in[k]     ),
        .clkr (clk              ),
        .r_en (1'b1             ),
        .raddr(rd_addr          ),
        .dout (window_out[k]    )
    );
    end
    endgenerate
    //======================= window ===============================
    reg signed [7:0] window[5-1:0][5-1:0];
    integer i,j;
    always@(posedge clk, negedge rst_n)begin
        if(~rst_n)begin
            for(i = 0; i < 5; i = i + 1)begin
                for(j = 0; j < 5; j = j + 1)begin
                    window[i][j] <= 0;
                end
            end
        end
        else if(cnn_data_in_valid == 1'b1 )begin
            for(i = 0; i < 5; i = i + 1)begin
                window[i][0] <= window_in[i];
                for(j = 1; j < 5; j = j + 1)begin
                    window[i][j] <= window[i][j-1];
                end
            end
        end
    end
//======================= x_cnt y_cnt ====================
    reg [4:0] x_cnt;
    reg [4:0] y_cnt;

    always@(posedge clk, negedge rst_n)begin
        if(~rst_n)
            x_cnt <= 0;
        else if(x_cnt == 5'd27 && cnn_data_in_valid == 1'b1)
            x_cnt <=0 ;
        else if(cnn_data_in_valid == 1'b1)
            x_cnt <= x_cnt + 1'b1;
    end

    always@(posedge clk, negedge rst_n)begin
        if(~rst_n)
            y_cnt <= 0;
        else if(y_cnt == 5'd27 &&x_cnt == 5'd27 && cnn_data_in_valid == 1'b1)
            y_cnt <= 0;
        else if(cnn_data_in_valid == 1'b1 && x_cnt == 5'd27)
            y_cnt <= y_cnt + 1'b1;
    end
    //======================= weights =======================
    wire c1_w_rd_en;
    wire c1_b_rd_en;
    /*assign  c1_w_rd_en = (cnn_data_in_valid && y_cnt==0)? 1'b1 : 1'b0; */
    assign c1_w_rd_en = 1'b1;
    assign c1_b_rd_en = 1'b1;

    wire    [15:0] rd_c1_w_1_data;
    wire    [15:0] rd_c1_w_2_data;
    wire    [15:0] rd_c1_w_3_data;
    wire    [15:0] rd_c1_w_4_data;
    wire    [15:0] rd_c1_w_5_data;
    wire    [15:0] rd_c1_w_6_data;
    wire    [15:0] rd_c1_b_data;


    reg [4:0] rom_cnt;
    reg [4:0] bias_rom_cnt;
    reg   signed  [15:0]  c1_w_1[4:0][4:0];
    reg   signed  [15:0]  c1_w_2[4:0][4:0];
    reg   signed  [15:0]  c1_w_3[4:0][4:0];
    reg   signed  [15:0]  c1_w_4[4:0][4:0];
    reg   signed  [15:0]  c1_w_5[4:0][4:0];
    reg   signed  [15:0]  c1_w_6[4:0][4:0];

    reg   signed  [15:0]  c1_b[6-1:0];
    /*
    weights_rom#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/kernel1_1.txt") weights_rom_u1(
    .rom_r_en (c1_w_rd_en       ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_1_data   )
    );
    weights_rom#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/kernel1_2.txt") weights_rom_u2(
    .rom_r_en (c1_w_rd_en       ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_2_data   )
    );
    weights_rom#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/kernel1_3.txt") weights_rom_u3(
    .rom_r_en (c1_w_rd_en       ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_3_data   )
    );
    weights_rom#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/kernel1_4.txt") weights_rom_u4(
    .rom_r_en (c1_w_rd_en       ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_4_data   )
    );
    weights_rom#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/kernel1_5.txt") weights_rom_u5(
    .rom_r_en (c1_w_rd_en       ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_5_data   )
    );
    weights_rom#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/kernel1_6.txt") weights_rom_u6(
    .rom_r_en (c1_w_rd_en       ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_6_data   )
    );
    bias_rom#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/weights/bias1.txt") bias_rom_u(
    .rom_r_en (c1_b_rd_en       ),
    .rom_raddr(bias_rom_cnt     ),
    .rom_dout (rd_c1_b_data     )
    );*/

    c1weights_rom#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/kernel1_1.txt") weights_rom_u1(
    .clk      (clk              ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_1_data   )
    );
    c1weights_rom#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/kernel1_2.txt") weights_rom_u2(
    .clk      (clk              ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_2_data   )
    );
    c1weights_rom#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/kernel1_3.txt") weights_rom_u3(
    .clk      (clk              ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_3_data   )
    );
    c1weights_rom#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/kernel1_4.txt") weights_rom_u4(
    .clk      (clk              ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_4_data   )
    );
    c1weights_rom#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/kernel1_5.txt") weights_rom_u5(
    .clk      (clk              ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_5_data   )
    );
    c1weights_rom#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/kernel1_6.txt") weights_rom_u6(
    .clk      (clk              ),
    .rom_raddr(rom_cnt          ),
    .rom_dout (rd_c1_w_6_data   )
    );
    c1bias_rom#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/bias1.txt") bias_rom_u(
    .clk      (clk              ),
    .rom_raddr(bias_rom_cnt     ),
    .rom_dout (rd_c1_b_data     )
    );
    /* 对卷积核权重寄存器赋值 */
    always@(posedge clk, negedge rst_n)begin
        if(~rst_n)
            rom_cnt <= 0;
        else if(rom_cnt == 5'd24 && cnn_data_in_valid == 1'b1)
            rom_cnt <=0 ;
        else if(cnn_data_in_valid == 1'b1)
            rom_cnt <= rom_cnt + 1'b1;
    end
    always@(posedge clk, negedge rst_n)begin
        if(~rst_n)
            bias_rom_cnt <= 0;
        else if(bias_rom_cnt == 5'd5 && cnn_data_in_valid == 1'b1)
            bias_rom_cnt <=0 ;
        else if(cnn_data_in_valid == 1'b1)
            bias_rom_cnt <= bias_rom_cnt + 1'b1;
    end
    reg [4:0] r1_rom_cnt;
    reg [4:0] r1_bias_rom_cnt;
    always @(posedge clk) begin
        r1_rom_cnt <= rom_cnt;
        r1_bias_rom_cnt <= bias_rom_cnt;
    end
    always@(posedge clk)begin//原来是组合逻辑
            c1_w_1[(r1_rom_cnt)/5][(r1_rom_cnt)%5] <= rd_c1_w_1_data;
            c1_w_2[(r1_rom_cnt)/5][(r1_rom_cnt)%5] <= rd_c1_w_2_data;
            c1_w_3[(r1_rom_cnt)/5][(r1_rom_cnt)%5] <= rd_c1_w_3_data;
            c1_w_4[(r1_rom_cnt)/5][(r1_rom_cnt)%5] <= rd_c1_w_4_data;
            c1_w_5[(r1_rom_cnt)/5][(r1_rom_cnt)%5] <= rd_c1_w_5_data;
            c1_w_6[(r1_rom_cnt)/5][(r1_rom_cnt)%5] <= rd_c1_w_6_data;
            c1_b[(r1_bias_rom_cnt)] <= rd_c1_b_data;
    end
    /*wire [15:0] vis_c1_w_1_00 = c1_w_1[0][0];
    wire [15:0] vis_c1_w_1_01 = c1_w_1[0][1];
    wire [15:0] vis_c1_w_1_02 = c1_w_1[0][2];
    wire [15:0] vis_c1_w_1_03 = c1_w_1[0][3];
    wire [15:0] vis_c1_w_1_04 = c1_w_1[0][4];
    wire [15:0] vis_c1_w_1_10 = c1_w_1[1][0];
    wire [15:0] vis_c1_w_1_11 = c1_w_1[1][1];
    wire [15:0] vis_c1_w_1_12 = c1_w_1[1][2];
    wire [15:0] vis_c1_w_1_13 = c1_w_1[1][3];
    wire [15:0] vis_c1_w_1_14 = c1_w_1[1][4];*/

    //======================= mul  =======================
    reg signed[WEIGHT_W-1:0]  window_mul_result_1[4:0][4:0];
    reg signed[WEIGHT_W-1:0]  window_mul_result_2[4:0][4:0];
    reg signed[WEIGHT_W-1:0]  window_mul_result_3[4:0][4:0];
    reg signed[WEIGHT_W-1:0]  window_mul_result_4[4:0][4:0];
    reg signed[WEIGHT_W-1:0]  window_mul_result_5[4:0][4:0];
    reg signed[WEIGHT_W-1:0]  window_mul_result_6[4:0][4:0];


    always@(posedge clk,negedge rst_n)begin
        if(~rst_n)begin
            for(i=0;i<5;i=i+1)begin
                for(j=0;j<5;j=j+1)begin
                        window_mul_result_1[i][j] <= 0;
                        window_mul_result_2[i][j] <= 0;
                        window_mul_result_3[i][j] <= 0;
                        window_mul_result_4[i][j] <= 0;
                        window_mul_result_5[i][j] <= 0;
                        window_mul_result_6[i][j] <= 0;

                end
            end
        end
        else begin
            for(i=0;i<5;i=i+1)begin
                for(j=0;j<5;j=j+1)begin
                        window_mul_result_1[i][j] <= (window[i][j] == 1) ? c1_w_1[i][j] : 'd0;
                        window_mul_result_2[i][j] <= (window[i][j] == 1) ? c1_w_2[i][j] : 'd0;
                        window_mul_result_3[i][j] <= (window[i][j] == 1) ? c1_w_3[i][j] : 'd0;
                        window_mul_result_4[i][j] <= (window[i][j] == 1) ? c1_w_4[i][j] : 'd0;
                        window_mul_result_5[i][j] <= (window[i][j] == 1) ? c1_w_5[i][j] : 'd0;
                        window_mul_result_6[i][j] <= (window[i][j] == 1) ? c1_w_6[i][j] : 'd0;
                end
            end
        end
    end

    wire [WEIGHT_W*26-1:0] window_sum_1;
    wire [WEIGHT_W*26-1:0] window_sum_2;
    wire [WEIGHT_W*26-1:0] window_sum_3;
    wire [WEIGHT_W*26-1:0] window_sum_4;
    wire [WEIGHT_W*26-1:0] window_sum_5;
    wire [WEIGHT_W*26-1:0] window_sum_6;

    wire [WEIGHT_W-1:0] window_sum_out_1;
    wire [WEIGHT_W-1:0] window_sum_out_2;
    wire [WEIGHT_W-1:0] window_sum_out_3;
    wire [WEIGHT_W-1:0] window_sum_out_4;
    wire [WEIGHT_W-1:0] window_sum_out_5;
    wire [WEIGHT_W-1:0] window_sum_out_6;


    assign window_sum_1 ={c1_b[0] , window_mul_result_1[0][0],window_mul_result_1[0][1],window_mul_result_1[0][2],window_mul_result_1[0][3],window_mul_result_1[0][4],
                                    window_mul_result_1[1][0],window_mul_result_1[1][1],window_mul_result_1[1][2],window_mul_result_1[1][3],window_mul_result_1[1][4],
                                    window_mul_result_1[2][0],window_mul_result_1[2][1],window_mul_result_1[2][2],window_mul_result_1[2][3],window_mul_result_1[2][4],
                                    window_mul_result_1[3][0],window_mul_result_1[3][1],window_mul_result_1[3][2],window_mul_result_1[3][3],window_mul_result_1[3][4],
                                    window_mul_result_1[4][0],window_mul_result_1[4][1],window_mul_result_1[4][2],window_mul_result_1[4][3],window_mul_result_1[4][4]};
    assign window_sum_2 ={c1_b[1] , window_mul_result_2[0][0],window_mul_result_2[0][1],window_mul_result_2[0][2],window_mul_result_2[0][3],window_mul_result_2[0][4],
                                    window_mul_result_2[1][0],window_mul_result_2[1][1],window_mul_result_2[1][2],window_mul_result_2[1][3],window_mul_result_2[1][4],
                                    window_mul_result_2[2][0],window_mul_result_2[2][1],window_mul_result_2[2][2],window_mul_result_2[2][3],window_mul_result_2[2][4],
                                    window_mul_result_2[3][0],window_mul_result_2[3][1],window_mul_result_2[3][2],window_mul_result_2[3][3],window_mul_result_2[3][4],
                                    window_mul_result_2[4][0],window_mul_result_2[4][1],window_mul_result_2[4][2],window_mul_result_2[4][3],window_mul_result_2[4][4]};
    assign window_sum_3 ={c1_b[2] , window_mul_result_3[0][0],window_mul_result_3[0][1],window_mul_result_3[0][2],window_mul_result_3[0][3],window_mul_result_3[0][4],
                                    window_mul_result_3[1][0],window_mul_result_3[1][1],window_mul_result_3[1][2],window_mul_result_3[1][3],window_mul_result_3[1][4],
                                    window_mul_result_3[2][0],window_mul_result_3[2][1],window_mul_result_3[2][2],window_mul_result_3[2][3],window_mul_result_3[2][4],
                                    window_mul_result_3[3][0],window_mul_result_3[3][1],window_mul_result_3[3][2],window_mul_result_3[3][3],window_mul_result_3[3][4],
                                    window_mul_result_3[4][0],window_mul_result_3[4][1],window_mul_result_3[4][2],window_mul_result_3[4][3],window_mul_result_3[4][4]};
    assign window_sum_4 ={c1_b[3] , window_mul_result_4[0][0],window_mul_result_4[0][1],window_mul_result_4[0][2],window_mul_result_4[0][3],window_mul_result_4[0][4],
                                    window_mul_result_4[1][0],window_mul_result_4[1][1],window_mul_result_4[1][2],window_mul_result_4[1][3],window_mul_result_4[1][4],
                                    window_mul_result_4[2][0],window_mul_result_4[2][1],window_mul_result_4[2][2],window_mul_result_4[2][3],window_mul_result_4[2][4],
                                    window_mul_result_4[3][0],window_mul_result_4[3][1],window_mul_result_4[3][2],window_mul_result_4[3][3],window_mul_result_4[3][4],
                                    window_mul_result_4[4][0],window_mul_result_4[4][1],window_mul_result_4[4][2],window_mul_result_4[4][3],window_mul_result_4[4][4]};
    assign window_sum_5 ={c1_b[4] , window_mul_result_5[0][0],window_mul_result_5[0][1],window_mul_result_5[0][2],window_mul_result_5[0][3],window_mul_result_5[0][4],
                                    window_mul_result_5[1][0],window_mul_result_5[1][1],window_mul_result_5[1][2],window_mul_result_5[1][3],window_mul_result_5[1][4],
                                    window_mul_result_5[2][0],window_mul_result_5[2][1],window_mul_result_5[2][2],window_mul_result_5[2][3],window_mul_result_5[2][4],
                                    window_mul_result_5[3][0],window_mul_result_5[3][1],window_mul_result_5[3][2],window_mul_result_5[3][3],window_mul_result_5[3][4],
                                    window_mul_result_5[4][0],window_mul_result_5[4][1],window_mul_result_5[4][2],window_mul_result_5[4][3],window_mul_result_5[4][4]};
    assign window_sum_6 ={c1_b[5] , window_mul_result_6[0][0],window_mul_result_6[0][1],window_mul_result_6[0][2],window_mul_result_6[0][3],window_mul_result_6[0][4],
                                    window_mul_result_6[1][0],window_mul_result_6[1][1],window_mul_result_6[1][2],window_mul_result_6[1][3],window_mul_result_6[1][4],
                                    window_mul_result_6[2][0],window_mul_result_6[2][1],window_mul_result_6[2][2],window_mul_result_6[2][3],window_mul_result_6[2][4],
                                    window_mul_result_6[3][0],window_mul_result_6[3][1],window_mul_result_6[3][2],window_mul_result_6[3][3],window_mul_result_6[3][4],
                                    window_mul_result_6[4][0],window_mul_result_6[4][1],window_mul_result_6[4][2],window_mul_result_6[4][3],window_mul_result_6[4][4]};

    add_tree_conv1 add_tree_conv1_u1(
        .clk              (clk              ),
        .add_tree_data_in (window_sum_1     ),
        .add_tree_data_out(window_sum_out_1 )
    );
    add_tree_conv1 add_tree_conv1_u2(
        .clk              (clk              ),
        .add_tree_data_in (window_sum_2     ),
        .add_tree_data_out(window_sum_out_2 )
    );
    add_tree_conv1 add_tree_conv1_u3(
        .clk              (clk              ),
        .add_tree_data_in (window_sum_3     ),
        .add_tree_data_out(window_sum_out_3 )
    );
    add_tree_conv1 add_tree_conv1_u4(
        .clk              (clk              ),
        .add_tree_data_in (window_sum_4     ),
        .add_tree_data_out(window_sum_out_4 )
    );
    add_tree_conv1 add_tree_conv1_u5(
        .clk              (clk              ),
        .add_tree_data_in (window_sum_5     ),
        .add_tree_data_out(window_sum_out_5 )
    );
    add_tree_conv1 add_tree_conv1_u6(
        .clk              (clk              ),
        .add_tree_data_in (window_sum_6     ),
        .add_tree_data_out(window_sum_out_6 )
    );

    assign cnn_data_out = {
    /*window_sum_out_6,
    window_sum_out_5,
    window_sum_out_4,
    window_sum_out_3,
    window_sum_out_2,
    window_sum_out_1*/
    (window_sum_out_6[WEIGHT_W-1]==0)? window_sum_out_6:{WEIGHT_W{1'b0}},
    (window_sum_out_5[WEIGHT_W-1]==0)? window_sum_out_5:{WEIGHT_W{1'b0}},
    (window_sum_out_4[WEIGHT_W-1]==0)? window_sum_out_4:{WEIGHT_W{1'b0}},
    (window_sum_out_3[WEIGHT_W-1]==0)? window_sum_out_3:{WEIGHT_W{1'b0}},
    (window_sum_out_2[WEIGHT_W-1]==0)? window_sum_out_2:{WEIGHT_W{1'b0}},
    (window_sum_out_1[WEIGHT_W-1]==0)? window_sum_out_1:{WEIGHT_W{1'b0}}
    };

    wire data_out_valid_o = (x_cnt>=4&&y_cnt>=4)?1'b1:1'b0;
    reg delay_data_out_valid_o;
    reg delay1_data_out_valid_o;
    reg delay2_data_out_valid_o;
    reg delay3_data_out_valid_o;
    reg delay4_data_out_valid_o;
    always@(posedge clk)begin
        delay_data_out_valid_o <=data_out_valid_o;
        delay1_data_out_valid_o <=delay_data_out_valid_o;
        delay2_data_out_valid_o <=delay1_data_out_valid_o;
        delay3_data_out_valid_o <=delay2_data_out_valid_o;
        delay4_data_out_valid_o <=delay3_data_out_valid_o;
        cnn_data_out_valid <= delay4_data_out_valid_o;
    end
endmodule

