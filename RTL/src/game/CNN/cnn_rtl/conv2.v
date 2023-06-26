
module conv2(
        input           clk,
        input           rst_n,

        input   [16*6-1:0] data_in,
        input                data_in_valid,

        output   [15:0] data_out,//这里不严谨，还没改
        output      reg         c2_ready,
        output      reg          data_out_valid,
        output      reg [4:0] out_channel_cnt
    );


genvar m,n,k,l,a,b;
 //================== ADDR =======================
reg [3:0] wr_addr;
reg [3:0] rd_addr;
wire [3:0] rd_addr_pre2 = wr_addr + 2;
always@(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        wr_addr <= 0;
        rd_addr <= 0;
    end
    else if(  data_in_valid == 1'b1 )begin
        if(wr_addr == 'd11)
            wr_addr <= 0;
        else
            wr_addr <=  wr_addr + 1'd1;

        if(rd_addr_pre2 > 'd11)
            rd_addr <= rd_addr_pre2 - 4'd12;
        else
            rd_addr <=rd_addr_pre2;

    end

end
 //================== DATA ========================
    wire [16*6-1:0] window_in[0:4];
    wire [16*6-1:0] window_out[0:4];

    assign window_in[0] = data_in;

    generate
        for(k=1;k<5;k=k+1)begin
            assign window_in[k] = window_out[k-1];
        end
    endgenerate
    reg delay_c2_ready;
    always@(posedge clk ) delay_c2_ready<=c2_ready;
    generate
        for(k=0;k<5;k=k+1)begin
    linebuffer
    #(
        96,4,12
    )
    conv2linebuffer_U
    (
        .clkw (clk              ),
        .w_en (data_in_valid),
        .waddr(wr_addr          ),
        .din  (window_in[k]     ),
        .clkr (clk              ),
        .r_en (delay_c2_ready   ),
        .raddr(rd_addr          ),
        .dout (window_out[k]    )
    );

end
endgenerate

 //===================== data window(6 channel) ============
    reg [96-1:0] window[4:0][4:0];
    wire [16*25-1:0] window_2d [6-1:0];//按照channel划分
    wire [16*25-1:0] window_2d_single;
    wire [16-1:0] window_single[4:0][4:0];//单通道window
    reg [3:0] window_2d_addr;
    generate
        for(l=0;l<6;l=l+1) begin
            assign window_2d[l] = { window[0][0][(l*16)+:16],window[0][1][(l*16)+:16],window[0][2][(l*16)+:16],window[0][3][(l*16)+:16],window[0][4][(l*16)+:16],
                                    window[1][0][(l*16)+:16],window[1][1][(l*16)+:16],window[1][2][(l*16)+:16],window[1][3][(l*16)+:16],window[1][4][(l*16)+:16],
                                    window[2][0][(l*16)+:16],window[2][1][(l*16)+:16],window[2][2][(l*16)+:16],window[2][3][(l*16)+:16],window[2][4][(l*16)+:16],
                                    window[3][0][(l*16)+:16],window[3][1][(l*16)+:16],window[3][2][(l*16)+:16],window[3][3][(l*16)+:16],window[3][4][(l*16)+:16],
                                    window[4][0][(l*16)+:16],window[4][1][(l*16)+:16],window[4][2][(l*16)+:16],window[4][3][(l*16)+:16],window[4][4][(l*16)+:16]};
        end
    endgenerate
    generate
        for(a=0;a<5;a=a+1) begin
            for(b=0;b<5;b=b+1) begin
                assign window_single[a][b] = window_2d_single[((a*5+b)*16)+:16];
            end
        end
    endgenerate
    integer i,j;
    always@(posedge clk,negedge rst_n)begin
        if(~rst_n)begin
            for(i=0;i<5;i=i+1)begin
                for(j=0;j<5;j=j+1)begin
                    window[i][j] <= 0;
                end
            end
        end
        else if(data_in_valid) begin
            for(i=0;i<5;i=i+1)begin
                window[i][0] <= window_in[i];
                for(j=1;j<5;j=j+1)begin
                    window[i][j] <= window[i][j-1];
                end
            end
        end
    end
//reg [4:0] out_channel_cnt;
reg [4:0] in_channel_cnt;

 //============================X_CNT =================================
reg [4:0]   x_cnt;
reg [4:0]   y_cnt;
reg [4:0]   x_cnt_delay;
reg [2:0]   x01cnt;
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        x_cnt <= 0;
    else if(y_cnt == 12 && x_cnt == 'd1 && out_channel_cnt == 'd15)
        x_cnt <= 0;
    else if(y_cnt == 12 && x_cnt == 'd1 && x01cnt == 'd2)
        x_cnt <= 0;
    else if(y_cnt == 12 && x_cnt == 'd0 && out_channel_cnt==15 && in_channel_cnt == 6)
        x_cnt <=x_cnt +1'b1;
    else if(data_in_valid && x_cnt == 'd11 )
        x_cnt <= 0;
    else if(data_in_valid)
        x_cnt <=x_cnt +1'b1;
end
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        y_cnt <= 0;
    else if( x_cnt == 'd1 && y_cnt == 'd12 && x01cnt == 'd2)
        y_cnt <= 0;
    else if(data_in_valid && x_cnt == 'd11 )
        y_cnt <=y_cnt +1'b1;
end
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        x_cnt_delay <= 0;
    else begin
        x_cnt_delay <= x_cnt;
    end
end
//归零
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        x01cnt <= 0;
    else begin
        if(y_cnt == 'd12 && x_cnt == 'd1 && x_cnt_delay == 'd0)
        x01cnt <= x01cnt + 'd1;
        else if(x01cnt == 'd2)
        x01cnt <= 'd0;
    end
end
 //======================== IN_CHANNEL_CNT============================

always@(posedge clk or negedge rst_n)begin
    if(~rst_n)
        in_channel_cnt<=0;
    else if(x01cnt == 'd2)
        in_channel_cnt<=0;
    else if(x_cnt>0 && x_cnt<3 && y_cnt >4 && y_cnt!=12)
        in_channel_cnt<=0;
    else if(in_channel_cnt==6)
        in_channel_cnt<=0;
    else if(x_cnt>=5 && y_cnt>=4 )
        in_channel_cnt<=in_channel_cnt+1;
    else if(x_cnt == 'd0 && y_cnt>4 )
        in_channel_cnt<=in_channel_cnt+1;
    else if(x_cnt == 'd1 && y_cnt =='d12)
        in_channel_cnt<=in_channel_cnt+1;
end

    assign window_2d_single = window_2d[in_channel_cnt];
 //======================== OUT_CHANNEL_CNT============================
always@(posedge clk or negedge rst_n)begin
    if(~rst_n)
        out_channel_cnt<=0;
    else if(x_cnt>0 && x_cnt<3 && y_cnt >4 && y_cnt!=12)
        out_channel_cnt<=0;
    else if(out_channel_cnt==15 && in_channel_cnt == 6)
        out_channel_cnt<=0;
    else if(x_cnt>=5 && y_cnt>=4 && in_channel_cnt == 6)
        out_channel_cnt<=out_channel_cnt+1;
    else if(x_cnt == 'd0 && y_cnt>4 && in_channel_cnt == 6)
        out_channel_cnt<=out_channel_cnt+1;
    else if(x_cnt == 'd1 && y_cnt == 'd12 && in_channel_cnt == 6)
        out_channel_cnt<=out_channel_cnt+1;
    else if(x01cnt == 'd2)
        out_channel_cnt<='d0;
end

 //======================== ROM_ADDR============================
reg [8:0] c2_w_rd_addr;
always@(posedge clk or negedge rst_n)begin
    if(~rst_n)
        c2_w_rd_addr<=0;
    else if(in_channel_cnt == 'd5)
        c2_w_rd_addr<=c2_w_rd_addr;
    else if(x_cnt>0 && x_cnt<3 && y_cnt >4 && y_cnt!=12)
        c2_w_rd_addr<=0;
    else if(c2_w_rd_addr == 'd95)//************************tmd有大问题
        c2_w_rd_addr<=0;
    else if((x_cnt>=4 && y_cnt>=4) || (y_cnt >=5 && y_cnt != 12 && x_cnt == 0)) //实际上x_cnt=0时需要计算上一行最后一个window
        c2_w_rd_addr<=c2_w_rd_addr+1;
    else if(x01cnt == 'd2)
        c2_w_rd_addr<=0;
    else if(y_cnt == 'd12)
        c2_w_rd_addr<=c2_w_rd_addr+1;
end
always@(posedge clk or negedge rst_n)begin
    if(~rst_n)
        window_2d_addr<=0;
    else if(x_cnt>0 && x_cnt<3 && y_cnt >4 && y_cnt!=12)
        window_2d_addr<=0;
    else if(window_2d_addr == 'd11)
        window_2d_addr<=0;
    else if(x_cnt>=4 && y_cnt>=4 )
        window_2d_addr<=window_2d_addr+1;
    else if(x_cnt == 'd0 && y_cnt>4 )
        window_2d_addr<=window_2d_addr+1;
end
 //========================= C2_READY =================================

always@(posedge clk or negedge rst_n)begin
    if(~rst_n)
        c2_ready <= 1'b1;
    else if(x01cnt == 'd2)
        c2_ready <= 1'b1;
    else if(y_cnt == 'd12 )
        c2_ready <= 1'b0;
    else if(out_channel_cnt==15 && in_channel_cnt == 4)
        c2_ready <= 1'b0;
    else if(out_channel_cnt==15 && in_channel_cnt == 3)
        c2_ready <= 1'b1;
    else if(x_cnt==3&&y_cnt==4)
        c2_ready <= 1'b0;
    else if(x_cnt ==3 && y_cnt>4)
        c2_ready <= 1'b0;
    else if(x_cnt>0 && x_cnt < 3 && y_cnt>4 )
        c2_ready <= 1'b1;
end

//==================== param ====================

wire [25*16-1:0] c2_w_rd_data;
//8bit,25个权重,共12*16=192个
c2weights_rom
//#("C:/Users/WS/Desktop/cam_hdmi/conv1_proj/RTL/conv_multi_6/txtfiles/kernel2.txt")
#("C:/Users/hp/Desktop/my1942Game/RTL/src/game/CNN/weights/kernel2.txt")
c2weights_rom_row0(
    .clk(clk),
    .rom_raddr(c2_w_rd_addr),
    .rom_dout(c2_w_rd_data)
);
wire [15:0]    c2_w_row0_data[4:0];
wire [15:0]    c2_w_row1_data[4:0];
wire [15:0]    c2_w_row2_data[4:0];
wire [15:0]    c2_w_row3_data[4:0];
wire [15:0]    c2_w_row4_data[4:0];
generate
    for(k=0;k<5;k=k+1)begin
        assign c2_w_row0_data[k] = c2_w_rd_data[(k*16+0)  +:16];
        assign c2_w_row1_data[k] = c2_w_rd_data[(k*16+80) +:16];
        assign c2_w_row2_data[k] = c2_w_rd_data[(k*16+160)+:16];
        assign c2_w_row3_data[k] = c2_w_rd_data[(k*16+240)+:16];
        assign c2_w_row4_data[k] = c2_w_rd_data[(k*16+320)+:16];
    end
endgenerate
//=============================== MUL================================
reg signed [31:0] in_channel_mul_result[0:4][0:4];
reg signed [34:0] in_channel_sum_result;
reg signed [34:0] in_channel_sum_result_single;
//============c1_w *4096 | c2_w * 256 ===
wire [15:0] in_channel_sum_result_s;
always@(posedge clk)begin
    for(j=0;j<5;j=j+1)begin
        //每个通道的输入乘以对应权重得到单通道window*weights
        in_channel_mul_result[0][j]<= $signed( window_single[4][4-j]) * $signed(c2_w_row0_data[j]);
        in_channel_mul_result[1][j]<= $signed( window_single[3][4-j]) * $signed(c2_w_row1_data[j]);
        in_channel_mul_result[2][j]<= $signed( window_single[2][4-j]) * $signed(c2_w_row2_data[j]);
        in_channel_mul_result[3][j]<= $signed( window_single[1][4-j]) * $signed(c2_w_row3_data[j]);
        in_channel_mul_result[4][j]<= $signed( window_single[0][4-j]) * $signed(c2_w_row4_data[j]);
    end
end
//单通道window*weights相加，形成6个单通道输出
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        in_channel_sum_result ='d0;
    else begin
        in_channel_sum_result_single <= in_channel_mul_result[0][0]+in_channel_mul_result[0][1]+in_channel_mul_result[0][2]+in_channel_mul_result[0][3]+in_channel_mul_result[0][4]+
                                        in_channel_mul_result[1][0]+in_channel_mul_result[1][1]+in_channel_mul_result[1][2]+in_channel_mul_result[1][3]+in_channel_mul_result[1][4]+
                                        in_channel_mul_result[2][0]+in_channel_mul_result[2][1]+in_channel_mul_result[2][2]+in_channel_mul_result[2][3]+in_channel_mul_result[2][4]+
                                        in_channel_mul_result[3][0]+in_channel_mul_result[3][1]+in_channel_mul_result[3][2]+in_channel_mul_result[3][3]+in_channel_mul_result[3][4]+
                                        in_channel_mul_result[4][0]+in_channel_mul_result[4][1]+in_channel_mul_result[4][2]+in_channel_mul_result[4][3]+in_channel_mul_result[4][4];
        if(in_channel_cnt == 'd0)
            in_channel_sum_result <= 'd0;
        else if(y_cnt < 4)
            in_channel_sum_result <= 'd0;
        /*else if(x_cnt>0 && x_cnt<3 && y_cnt >4 && y_cnt!=12)
            in_channel_sum_result <= 'd0;*/
        else if(x_cnt<=5 && y_cnt<=4 && in_channel_cnt==0)
            in_channel_sum_result <= 'd0;
        else begin
            in_channel_sum_result <=in_channel_mul_result[0][0]+in_channel_mul_result[0][1]+in_channel_mul_result[0][2]+in_channel_mul_result[0][3]+in_channel_mul_result[0][4]+
                                    in_channel_mul_result[1][0]+in_channel_mul_result[1][1]+in_channel_mul_result[1][2]+in_channel_mul_result[1][3]+in_channel_mul_result[1][4]+
                                    in_channel_mul_result[2][0]+in_channel_mul_result[2][1]+in_channel_mul_result[2][2]+in_channel_mul_result[2][3]+in_channel_mul_result[2][4]+
                                    in_channel_mul_result[3][0]+in_channel_mul_result[3][1]+in_channel_mul_result[3][2]+in_channel_mul_result[3][3]+in_channel_mul_result[3][4]+
                                    in_channel_mul_result[4][0]+in_channel_mul_result[4][1]+in_channel_mul_result[4][2]+in_channel_mul_result[4][3]+in_channel_mul_result[4][4]+
                                    in_channel_sum_result;
        end
    end
end

    /*wire [15:0] window_vis_00 = window[0][0];
    wire [15:0] window_vis_01 = window[0][1];
    wire [15:0] window_vis_02 = window[0][2];
    wire [15:0] window_vis_03 = window[0][3];
    wire [15:0] window_vis_04 = window[0][4];
    wire [15:0] window_vis_10 = window[1][0];
    wire [15:0] window_vis_11 = window[1][1];
    wire [15:0] window_vis_12 = window[1][2];
    wire [15:0] window_vis_13 = window[1][3];
    wire [15:0] window_vis_14 = window[1][4];
    wire [15:0] window_vis_20 = window[2][0];
    wire [15:0] window_vis_21 = window[2][1];
    wire [15:0] window_vis_22 = window[2][2];
    wire [15:0] window_vis_23 = window[2][3];
    wire [15:0] window_vis_24 = window[2][4];
    wire [15:0] window_vis_30 = window[3][0];
    wire [15:0] window_vis_31 = window[3][1];
    wire [15:0] window_vis_32 = window[3][2];
    wire [15:0] window_vis_33 = window[3][3];
    wire [15:0] window_vis_34 = window[3][4];
    wire [15:0] window_vis_40 = window[4][0];
    wire [15:0] window_vis_41 = window[4][1];
    wire [15:0] window_vis_42 = window[4][2];
    wire [15:0] window_vis_43 = window[4][3];
    wire [15:0] window_vis_44 = window[4][4];

    wire [31:0] mul_vis_00 = in_channel_mul_result[0][0];
    wire [31:0] mul_vis_01 = in_channel_mul_result[0][1];
    wire [31:0] mul_vis_02 = in_channel_mul_result[0][2];
    wire [31:0] mul_vis_03 = in_channel_mul_result[0][3];
    wire [31:0] mul_vis_04 = in_channel_mul_result[0][4];
    wire [31:0] mul_vis_10 = in_channel_mul_result[1][0];
    wire [31:0] mul_vis_11 = in_channel_mul_result[1][1];
    wire [31:0] mul_vis_12 = in_channel_mul_result[1][2];
    wire [31:0] mul_vis_13 = in_channel_mul_result[1][3];
    wire [31:0] mul_vis_14 = in_channel_mul_result[1][4];
    wire [31:0] mul_vis_20 = in_channel_mul_result[2][0];
    wire [31:0] mul_vis_21 = in_channel_mul_result[2][1];
    wire [31:0] mul_vis_22 = in_channel_mul_result[2][2];
    wire [31:0] mul_vis_23 = in_channel_mul_result[2][3];
    wire [31:0] mul_vis_24 = in_channel_mul_result[2][4];
    wire [31:0] mul_vis_30 = in_channel_mul_result[3][0];
    wire [31:0] mul_vis_31 = in_channel_mul_result[3][1];
    wire [31:0] mul_vis_32 = in_channel_mul_result[3][2];
    wire [31:0] mul_vis_33 = in_channel_mul_result[3][3];
    wire [31:0] mul_vis_34 = in_channel_mul_result[3][4];
    wire [31:0] mul_vis_40 = in_channel_mul_result[4][0];
    wire [31:0] mul_vis_41 = in_channel_mul_result[4][1];
    wire [31:0] mul_vis_42 = in_channel_mul_result[4][2];
    wire [31:0] mul_vis_43 = in_channel_mul_result[4][3];
    wire [31:0] mul_vis_44 = in_channel_mul_result[4][4];*/
//assign in_channel_sum_result_s = in_channel_sum_result>>>20;
assign in_channel_sum_result_s = in_channel_sum_result >>> 12;
//assign in_channel_sum_result_s = in_channel_sum_result;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_out_valid = 1'b0;
    else begin
        if(x_cnt<5 || y_cnt <4 )
            data_out_valid <= 1'b0;
        if(in_channel_cnt == 6)
            data_out_valid <= 1'b1;
        else
            data_out_valid <= 1'b0;
    end
end

//assign data_out = (in_channel_sum_result[34]==1)?0:in_channel_sum_result;
assign data_out = (in_channel_sum_result_s[15]==1)?0:in_channel_sum_result_s;


endmodule
