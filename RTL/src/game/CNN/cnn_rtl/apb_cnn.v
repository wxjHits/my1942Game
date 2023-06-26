/*
    APB读去CNN手势识别结果
    base_addr 0x40006000
    0x000 R  cnn_result
*/
module apb_cnn(
    input  wire         rstn        ,//系统复位
    //pll
    input wire    clk_100m       ,  //100mhz时钟,SDRAM操作时钟
    input wire    clk_100m_shift ,  //100mhz时钟,SDRAM相位偏移时钟
    input wire    clk_50m        ,
    input wire    hdmi_clk       ,
    input wire    hdmi_clk_5     ,
    input wire    locked         ,
    input wire    locked_hdmi    ,

    //APB-bus
    input  wire         PCLK        ,// Clock
    input  wire         PCLKG       ,// Gated Clock
    input  wire         PRESETn     ,// Reset
    input  wire         PSEL        ,// Device select
    input  wire [15:0]  PADDR       ,// Address
    input  wire         PENABLE     ,// Transfer control
    input  wire         PWRITE      ,// Write control
    input  wire [31:0]  PWDATA      ,// Write data
    input  wire [03:0]  ECOREVNUM   ,// Engineering-change-order revision bits
    output wire [31:0]  PRDATA      ,// Read data
    output wire         PREADY      ,// Device ready
    output wire         PSLVERR     ,// Device error response

    // output wire [3:0]   one_hot     ,
    //pin
    //摄像头
    input           cam_pclk    ,  //cmos 数据像素时钟
    input           cam_vsync   ,  //cmos 场同步信号
    input           cam_href    ,  //cmos 行同步信号
    input  [7:0]    cam_data    ,  //cmos 数据
    output          cam_rst_n   ,  //cmos 复位信号，低电平有效
    output          cam_pwdn    ,  //cmos 电源休眠模式选择信号
    output          cam_scl     ,  //cmos SCCB_SCL线
    inout           cam_sda     ,  //cmos SCCB_SDA线
    //SDRAM 
    output          sdram_clk   ,  //SDRAM 时钟
    output          sdram_cke   ,  //SDRAM 时钟有效
    output          sdram_cs_n  ,  //SDRAM 片选
    output          sdram_ras_n ,  //SDRAM 行有效
    output          sdram_cas_n ,  //SDRAM 列有效
    output          sdram_we_n  ,  //SDRAM 写有效
    output [1:0]    sdram_ba    ,  //SDRAM Bank地址
    output [1:0]    sdram_dqm   ,  //SDRAM 数据掩码
    output [12:0]   sdram_addr  ,  //SDRAM 地址
    inout  [15:0]   sdram_data  ,  //SDRAM 数据
    //HDMI接口
    output          tmds_clk_p  ,    // TMDS 时钟通道
    output          tmds_clk_n  ,
    output [2:0]    tmds_data_p ,   // TMDS 数据通道
    output [2:0]    tmds_data_n 
);

    wire [3:0] one_hot      ;
    wire       cnn_out_valid;

    reg  [3:0] cnn_result   ;
/***寄存操作***/
    always@(posedge PCLK or negedge PRESETn)begin
        if(~PRESETn)
            cnn_result<=4'b0000;
        else begin
            if(cnn_out_valid)
                cnn_result<=one_hot;
            else
                cnn_result<=cnn_result;
        end
    end

/***APB读写(只有读操作)***/
    wire    read_enable     ;
    assign  read_enable  = PSEL & PENABLE & (~PWRITE);

    reg [31:0] read_mux_le;
    reg [31:0] read_mux_word;

    always@(*)begin
        case(PADDR[11:0])
            12'h000:read_mux_le={{28{1'b0}}, cnn_result};
            default:read_mux_le={32{1'bx}};
        endcase
    end

    always@(posedge PCLK or negedge PRESETn)begin
        if(~PRESETn)
            read_mux_word<='d0;
        else
            read_mux_word<=read_mux_le;
    end

    assign PRDATA = (read_enable) ? read_mux_word : {32{1'b0}};
    assign PREADY  = 1'b1   ;
    assign PSLVERR = 1'b0   ;

/***例化***/
ov5640_hdmi u_ov5640_hdmi(
    .sys_clk    (PCLK    ),  //系统时钟   //50MHz
    .sys_rst_n  (PRESETn|rstn ),  //系统复位，低电平有效
    //
    .clk_100m       (clk_100m      ),  //100mhz时钟,SDRAM操作时钟
    .clk_100m_shift (clk_100m_shift),  //100mhz时钟,SDRAM相位偏移时钟
    .clk_50m        (clk_50m       ),
    .hdmi_clk       (hdmi_clk      ),
    .hdmi_clk_5     (hdmi_clk_5    ),
    .locked         (locked        ),
    .locked_hdmi    (locked_hdmi   ),

    //摄像头
    .cam_pclk   (cam_pclk ),  //cmos 数据像素时钟
    .cam_vsync  (cam_vsync),  //cmos 场同步信号
    .cam_href   (cam_href ),  //cmos 行同步信号
    .cam_data   (cam_data ),  //cmos 数据
    .cam_rst_n  (cam_rst_n),  //cmos 复位信号，低电平有效
    .cam_pwdn   (cam_pwdn ),  //cmos 电源休眠模式选择信号
    .cam_scl    (cam_scl  ),  //cmos SCCB_SCL线
    .cam_sda    (cam_sda  ),  //cmos SCCB_SDA线
    //SDRAM
    .sdram_clk  (sdram_clk  ),  //SDRAM 时钟
    .sdram_cke  (sdram_cke  ),  //SDRAM 时钟有效
    .sdram_cs_n (sdram_cs_n ),  //SDRAM 片选
    .sdram_ras_n(sdram_ras_n),  //SDRAM 行有效
    .sdram_cas_n(sdram_cas_n),  //SDRAM 列有效
    .sdram_we_n (sdram_we_n ),  //SDRAM 写有效
    .sdram_ba   (sdram_ba   ),  //SDRAM Bank地址
    .sdram_dqm  (sdram_dqm  ),  //SDRAM 数据掩码
    .sdram_addr (sdram_addr ),  //SDRAM 地址
    .sdram_data (sdram_data ),  //SDRAM 数据
    //HDMI接口
    .tmds_clk_p (tmds_clk_p ),    // TMDS 时钟通道
    .tmds_clk_n (tmds_clk_n ),
    .tmds_data_p(tmds_data_p),   // TMDS 数据通道
    .tmds_data_n(tmds_data_n),
    //CNN数据端口
    .one_hot      (one_hot      ),
    .cnn_out_valid(cnn_out_valid)
    );


endmodule