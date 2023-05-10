module video_driver(
    input           pixel_clk     ,//25.2MHz
    input           sys_rst_n     ,

    //索引像素数据的信号
    output  [11:0]  pixel_xpos    ,   //像素点横坐标
    output  [11:0]  pixel_ypos    ,   //像素点纵坐标
    input   [15:0]  video_rgb_565 ,   //像素点数据

    input   wire   IsGameWindow ,
    //to dvi_transmitter_top.v
    output          video_hs      ,   //行同步信号
    output          video_vs      ,   //场同步信号
    output          video_de      ,   //数据使能
    output  [23:0]  video_rgb         //RGB888颜色数据
);

//parameter define
//640*480 60hz分辨率时序参数
parameter  H_SYNC   =  11'd96;  //行同步
parameter  H_BACK   =  11'd48;  //行显示后沿
parameter  H_DISP   =  11'd640; //行有效数据
parameter  H_FRONT  =  11'd16;   //行显示前沿
parameter  H_TOTAL  =  11'd800; //行扫描周期

parameter  V_SYNC   =  11'd2;    //场同步
parameter  V_BACK   =  11'd33;   //场显示后沿
parameter  V_DISP   =  11'd480;  //场有效数据
parameter  V_FRONT  =  11'd10;    //场显示前沿
parameter  V_TOTAL  =  11'd525;  //场扫描周期

//reg define
reg  [11:0] cnt_h;
reg  [11:0] cnt_v;

//wire define
wire       video_en;
wire [23:0]pixel_data;
//*****************************************************
//**                    main code
//*****************************************************

assign video_de  = video_en;

assign video_hs  = ( cnt_h < H_SYNC ) ? 1'b0 : 1'b1;  //行同步信号赋值
assign video_vs  = ( cnt_v < V_SYNC ) ? 1'b0 : 1'b1;  //场同步信号赋值

//使能RGB数据输出
assign video_en  = (((cnt_h >= H_SYNC+H_BACK) && (cnt_h < H_SYNC+H_BACK+H_DISP))
                    &&((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                    ?  1'b1 : 1'b0;

//RGB888数据输出
assign video_rgb = video_en ? (IsGameWindow ==1'b1 ? pixel_data:24'ha0a000) : 24'h000000;

//请求像素点颜色数据输入
wire   data_req      ;
assign data_req = (((cnt_h >= H_SYNC+H_BACK-1'b1) &&
                    (cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))
                    && ((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                    ?  1'b1 : 1'b0;

//像素点坐标
assign pixel_xpos = data_req ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 12'd0;
assign pixel_ypos = data_req ? (cnt_v - (V_SYNC + V_BACK - 1'b1)) : 12'd0;

assign pixel_data = {video_rgb_565[15:11],3'b000,video_rgb_565[10:5],2'b00,
                    video_rgb_565[4:0],3'b000};

//行计数器对像素时钟计数
always @(posedge pixel_clk ) begin
    if (!sys_rst_n)
        cnt_h <= 12'd0;
    else begin
        if(cnt_h < H_TOTAL - 1'b1)
            cnt_h <= cnt_h + 1'b1;
        else
            cnt_h <= 12'd0;
    end
end

//场计数器对行计数
always @(posedge pixel_clk ) begin
    if (!sys_rst_n)
        cnt_v <= 12'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else
            cnt_v <= 12'd0;
    end
end

endmodule