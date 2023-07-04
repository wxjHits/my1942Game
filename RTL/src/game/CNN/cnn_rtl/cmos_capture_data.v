
module cmos_capture_data(
    input                 rst_n            ,  //复位信号
    //摄像头接口
    input                 cam_pclk         ,  //cmos 数据像素时钟
    input                 cam_vsync        ,  //cmos 场同步信号
    input                 cam_href         ,  //cmos 行同步信号
    input  [7:0]          cam_data         ,
    //用户接口
    output                cmos_frame_vsync ,  //帧有效信号
    output                cmos_frame_href  ,  //行有效信号
    output                cmos_frame_valid ,  //数据有效使能信号
    output       [15:0]   cmos_frame_data  ,  //有效数据
    output                bin_data         ,
    output                gray_en          ,
    //总线接口
    input               bus_bin_mode_ctrl       ,
    input       [7:0]   bus_bin_rgb_threshold   ,
    input       [31:0]  bus_bin_crbr_threshold
    );

//寄存器全部配置完成后，先等待10帧数据
//待寄存器配置生效后再开始采集图像
parameter  WAIT_FRAME = 4'd10    ;            //寄存器数据稳定等待的帧个数


//reg define
reg             cam_vsync_d0     ;
reg             cam_vsync_d1     ;
reg             cam_href_d0      ;
reg             cam_href_d1      ;
reg    [3:0]    cmos_ps_cnt      ;            //等待帧数稳定计数器
reg    [7:0]    cam_data_d0      ;
reg    [15:0]   cmos_data_t      ;            //用于8位转16位的临时寄存器
reg             byte_flag        ;            //16位RGB数据转换完成的标志信号
reg             byte_flag_d0     ;
reg             frame_val_flag   ;            //帧有效的标志

wire            pos_vsync        ;            //采输入场同步信号的上升沿
wire            pos_href         ;
wire    [15:0]  box_data_out     ;
wire    [15:0]  out_gray         ;

//摄像头输出的时序控制信号
wire cmos_frame_vsync_o;
wire cmos_frame_href_o;
wire cmos_frame_valid_o;
//灰度转化模块输出的时序信号
wire post_frame_vsync;
wire post_frame_hsync;
wire post_frame_de   ;
wire post_gray_en    ;
//resize模块输出的时序信号
//*****************************************************
//**                    main code
//*****************************************************
assign pos_href = (~cam_href_d1) & cam_href_d0;
//采输入场同步信号的上升沿
assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0;

//输出帧有效信号
assign  cmos_frame_vsync_o = frame_val_flag  ?  cam_vsync_d1  :  1'b0;

//输出行有效信号
assign  cmos_frame_href_o  = frame_val_flag  ?  cam_href_d1   :  1'b0;

//输出数据使能有效信号
assign  cmos_frame_valid_o = frame_val_flag  ?  byte_flag_d0  :  1'b0;

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;
        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
    end
end

//对帧数进行计数
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_ps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_ps_cnt < WAIT_FRAME))
        cmos_ps_cnt <= cmos_ps_cnt + 4'd1;
end

//帧有效标志
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        frame_val_flag <= 1'b0;
    else if((cmos_ps_cnt == WAIT_FRAME) && pos_vsync)
        frame_val_flag <= 1'b1;
    else;
end

//8位数据转16位RGB565数据
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cmos_data_t <= 16'd0;
        cam_data_d0 <= 8'd0;
        byte_flag <= 1'b0;
    end
    else if(cam_href) begin
        byte_flag <= ~byte_flag;
        cam_data_d0 <= cam_data;
        if(byte_flag)
            cmos_data_t <= {cam_data_d0,cam_data};
        else;
    end
    else begin
        byte_flag <= 1'b0;
        cam_data_d0 <= 8'b0;
    end
end

//产生输出数据有效信号(cmos_frame_valid)
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;
end
box_select #(10'd200, 10'd100, 10'd224) box_select_u(
    .rst_n       (rst_n        ),
    .cam_pclk    (cam_pclk     ),
    .pos_vsync   (pos_vsync    ),
    .pos_href    (pos_href     ),
    .cam_href    (cam_href     ),
    .cmos_data_t (cmos_data_t  ),
    .box_data_out(box_data_out ),
    .gray_en     (post_gray_en )
);

/*wire bus_bin_mode_ctrl = 1'b0;
wire [7:0] bus_bin_rgb_threshold = 'd70;
//{cb_high,cb_low,cr_high,cr_low}
wire [31:0] bus_bin_crbr_threshold = 'hFF_00_FF_00;*/
imgbin u_rgb2ycbcr(
    //module clock
    .clk             (cam_pclk    ),            // 时钟信号
    .rst_n           (rst_n  ),            // 复位信号（低有效）
    .gray_en         (post_gray_en),
    //图像处理前的数据接口
    .pre_frame_vsync (cmos_frame_vsync_o),    // vsync信号
    .pre_frame_hsync (cmos_frame_href_o),    // href信号
    .pre_frame_de    (cmos_frame_valid_o   ),    // data enable信号
    .box_data_out    (box_data_out),
    //图像处理后的数据接口
    .post_frame_vsync(cmos_frame_vsync),   // vsync信号
    .post_frame_hsync(cmos_frame_hsync),   // href信号
    .post_frame_de   (cmos_frame_valid),      // data enable信号
    .post_gray_en    (gray_en         ),
    .out_gray        (cmos_frame_data ),
    .bin_data        (bin_data        ),
    //总线
    .bus_bin_mode_ctrl(bus_bin_mode_ctrl),
    .bus_bin_rgb_threshold(bus_bin_rgb_threshold),
    .bus_bin_crbr_threshold(bus_bin_crbr_threshold)
);
/*rgb2ycbcr u_rgb2ycbcr(
    //module clock
    .clk             (cam_pclk    ),            // 时钟信号
    .rst_n           (rst_n  ),            // 复位信号（低有效）
    .gray_en         (post_gray_en),
    //图像处理前的数据接口
    .pre_frame_vsync (cmos_frame_vsync_o),    // vsync信号
    .pre_frame_hsync (cmos_frame_href_o),    // href信号
    .pre_frame_de    (cmos_frame_valid_o   ),    // data enable信号
    .box_data_out    (box_data_out),
    //图像处理后的数据接口
    .post_frame_vsync(cmos_frame_vsync),   // vsync信号
    .post_frame_hsync(cmos_frame_hsync),   // href信号
    .post_frame_de   (cmos_frame_valid),      // data enable信号
    .post_gray_en    (gray_en         ),
    .out_gray        (cmos_frame_data ),
    .bin_data        (bin_data        )
);*/
/*imresize imresize_u(
    .clk             (cam_pclk        ),
    .rst_n           (rst_n           ),
    .post_gray_en    (post_gray_en    ),
    .post_frame_vsync(post_frame_vsync),
    .post_frame_hsync(post_frame_hsync),
    .post_frame_de   (post_frame_de   ),
    .out_gray        (out_gray        ),
    .rsze_frame_vsync(cmos_frame_vsync),
    .rsze_frame_hsync(cmos_frame_href ),
    .rsze_frame_de   (cmos_frame_valid),
    .out_gray_resize (cmos_frame_data )
);*/
endmodule