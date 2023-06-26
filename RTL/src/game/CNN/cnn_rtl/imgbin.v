
module imgbin
(
    //module clock
    input               clk             ,   // 模块驱动时钟
    input               rst_n           ,   // 复位信号
    input               gray_en         ,

    //图像处理前的数据接口
    input               pre_frame_vsync ,   // vsync信号
    input               pre_frame_hsync ,   // hsync信号
    input               pre_frame_de    ,   // data enable信号

    input       [15:0]  box_data_out    ,
    //图像处理后的数据接口
    output              post_frame_vsync,   // vsync信号
    output              post_frame_hsync,   // hsync信号
    output              post_frame_de   ,   // data enable信号
    output      [15:0]  out_gray        ,
    output              post_gray_en    ,
    output reg          bin_data            //输出的二值信号(0和1)
);


//reg define
reg  [15:0]   rgb_r_m0, rgb_r_m1, rgb_r_m2;
reg  [15:0]   rgb_g_m0, rgb_g_m1, rgb_g_m2;
reg  [15:0]   rgb_b_m0, rgb_b_m1, rgb_b_m2;
reg  [15:0]   img_y0 ;
reg  [15:0]   img_cb0;
reg  [15:0]   img_cr0;
reg  [ 7:0]   img_y1 ;
reg  [ 7:0]   img_cb1;
reg  [ 7:0]   img_cr1;

reg  [ 3:0]   pre_frame_vsync_d;
reg  [ 3:0]   pre_frame_hsync_d;
reg  [ 3:0]   pre_frame_de_d   ;

reg  [15:0] box_data_out_d1,box_data_out_d2,box_data_out_d3,box_data_out_d4;
reg  gray_en_d1,gray_en_d2,gray_en_d3,gray_en_d4;
//wire define
wire [ 7:0]   rgb888_r;
wire [ 7:0]   rgb888_g;
wire [ 7:0]   rgb888_b;
wire  [4:0]   img_red         ;   // 输入图像数据R
wire  [5:0]   img_green       ;   // 输入图像数据G
wire  [4:0]   img_blue        ;   // 输入图像数据B
wire  [7:0]   img_y           ;
//*****************************************************
//**                    main code
//*****************************************************
assign img_red = box_data_out[15:11];
assign img_green = box_data_out[10:5];
assign img_blue = box_data_out[4:0];
//RGB565 to RGB 888
assign rgb888_r         = {img_red  , img_red[4:2]  };
assign rgb888_g         = {img_green, img_green[5:4]};
assign rgb888_b         = {img_blue , img_blue[4:2] };
//同步输出数据接口信号
assign post_frame_vsync = pre_frame_vsync_d[3]      ;
assign post_frame_hsync = pre_frame_hsync_d[3]      ;
assign post_frame_de    = pre_frame_de_d[3]         ;
assign img_y            = post_frame_hsync ? img_y1 : 8'd0;
//--------------------------------------------
//RGB 888 to YCbCr

/********************************************************
            RGB888 to YCbCr
 Y  = 0.299R +0.587G + 0.114B
 Cb = 0.568(B-Y) + 128 = -0.172R-0.339G + 0.511B + 128
 CR = 0.713(R-Y) + 128 = 0.511R-0.428G -0.083B + 128

 Y  = (77 *R    +    150*G    +    29 *B)>>8
 Cb = (-43*R    -    85 *G    +    128*B)>>8 + 128
 Cr = (128*R    -    107*G    -    21 *B)>>8 + 128

 Y  = (77 *R    +    150*G    +    29 *B        )>>8
 Cb = (-43*R    -    85 *G    +    128*B + 32768)>>8
 Cr = (128*R    -    107*G    -    21 *B + 32768)>>8
*********************************************************/

//step1 pipeline mult
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rgb_r_m0 <= 16'd0;
        rgb_r_m1 <= 16'd0;
        rgb_r_m2 <= 16'd0;
        rgb_g_m0 <= 16'd0;
        rgb_g_m1 <= 16'd0;
        rgb_g_m2 <= 16'd0;
        rgb_b_m0 <= 16'd0;
        rgb_b_m1 <= 16'd0;
        rgb_b_m2 <= 16'd0;
    end
    else begin
        rgb_r_m0 <= rgb888_r * 8'd77 ;
        rgb_r_m1 <= rgb888_r * 8'd43 ;
        rgb_r_m2 <= rgb888_r << 3'd7 ;
        rgb_g_m0 <= rgb888_g * 8'd150;
        rgb_g_m1 <= rgb888_g * 8'd85 ;
        rgb_g_m2 <= rgb888_g * 8'd107;
        rgb_b_m0 <= rgb888_b * 8'd29 ;
        rgb_b_m1 <= rgb888_b << 3'd7 ;
        rgb_b_m2 <= rgb888_b * 8'd21 ;
    end
end

//step2 pipeline add
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_y0  <= 16'd0;
        img_cb0 <= 16'd0;
        img_cr0 <= 16'd0;
    end
    else begin
        img_y0  <= rgb_r_m0 + rgb_g_m0 + rgb_b_m0;
        img_cb0 <= rgb_b_m1 - rgb_r_m1 - rgb_g_m1 + 16'd32768;
        img_cr0 <= rgb_r_m2 - rgb_g_m2 - rgb_b_m2 + 16'd32768;
    end

end

//step3 pipeline div
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_y1  <= 8'd0;
        img_cb1 <= 8'd0;
        img_cr1 <= 8'd0;
    end
    else begin
        img_y1  <= img_y0 [15:8];
        img_cb1 <= img_cb0[15:8];
        img_cr1 <= img_cr0[15:8];
    end
end

//延时3拍以同步数据信号
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pre_frame_vsync_d <= 4'd0;
        pre_frame_hsync_d <= 4'd0;
        pre_frame_de_d    <= 4'd0;
    end
    else begin
        pre_frame_vsync_d <= {pre_frame_vsync_d[2:0], pre_frame_vsync};
        pre_frame_hsync_d <= {pre_frame_hsync_d[2:0], pre_frame_hsync};
        pre_frame_de_d    <= {pre_frame_de_d[2:0]   , pre_frame_de   };
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        box_data_out_d1 = 16'd0;
        box_data_out_d2 = 16'd0;
        box_data_out_d3 = 16'd0;
        box_data_out_d4 = 16'd0;
        gray_en_d1 = 1'b0;
        gray_en_d2 = 1'b0;
        gray_en_d3 = 1'b0;
        gray_en_d4 = 1'b0;
    end
    else begin
        box_data_out_d4 <= box_data_out_d3;
        box_data_out_d3 <= box_data_out_d2;
        box_data_out_d2 <= box_data_out_d1;
        box_data_out_d1 <= box_data_out;
        gray_en_d4 <= gray_en_d3;
        gray_en_d3 <= gray_en_d2;
        gray_en_d2 <= gray_en_d1;
        gray_en_d1 <= gray_en;
    end
end

//*****************binary******************
wire [15:0] post_binary;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bin_data <= 'd0;
    end
    else begin
        if((img_cr1 > 'd135) & (img_cr1 < 'd160) & (img_cb1 > 'd115) & (img_cb1 < 'd140))
            bin_data <= 'd1;
        else
            bin_data <= 'd0;
    end
end
//产生1bit阈值输出
//70,160,115,140
//135,160,115,140
//产生16bit阈值输出
assign post_binary = {16{bin_data}};
assign  out_gray = gray_en_d4 ? post_binary : box_data_out_d4;
assign post_gray_en = gray_en_d4;
endmodule