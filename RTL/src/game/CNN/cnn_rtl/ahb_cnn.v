/*
    AHB读去CNN手势识别结果
    base_addr 0x60000000
    0x000 R  cnn_result
    0x004 R  bus_bin_mode_ctrl       0:肤色 1:RGB分割
    0x008 R  bus_bin_rgb_threshold 
    0x00C R  bus_bin_crbr_threshold
*/
module ahb_cnn(
    input  wire         rstn        ,//系统复位
    //pll
    input wire    clk_100m       ,  //100mhz时钟,SDRAM操作时钟
    input wire    clk_100m_shift ,  //100mhz时钟,SDRAM相位偏移时钟
    input wire    clk_50m        ,
    input wire    hdmi_clk       ,
    input wire    hdmi_clk_5     ,
    input wire    locked         ,
    input wire    locked_hdmi    ,

    //AHB-bus
    input  wire                         HCLK        ,
    input  wire                         HRESETn     ,
    input  wire                         HSEL        ,
    input  wire   [31:0]                HADDR       ,
    input  wire    [1:0]                HTRANS      ,
    input  wire    [2:0]                HSIZE       ,
    input  wire    [3:0]                HPROT       ,
    input  wire                         HWRITE      ,
    input  wire   [31:0]                HWDATA      ,
    input  wire                         HREADY      ,

    output wire                         HREADYOUT   ,
    output wire    [31:0]               HRDATA      ,
    output wire                         HRESP       ,

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

    assign HRESP = 1'b0;
    assign HREADYOUT = 1'b1;

/***信号定义***/
    wire [3:0] one_hot      ;
    wire       cnn_out_valid;

    reg  [3:0] cnn_result   ;

    reg         bus_bin_mode_ctrl       ;
    reg  [ 7:0] bus_bin_rgb_threshold   ;
    reg  [31:0] bus_bin_crbr_threshold  ;

/***寄存操作***/
    always@(posedge HCLK or negedge HRESETn)begin
        if(~HRESETn)
            cnn_result<=4'b0000;
        else begin
            if(cnn_out_valid)
                cnn_result<=one_hot;
            else
                cnn_result<=cnn_result;
        end
    end
/***APB读写(只有读操作)***/
wire write_en;
assign write_en=HSEL&HTRANS[1]&(HWRITE)&HREADY;
wire read_en;
assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;

reg [5:0] addr;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) 
        addr <= 6'b0;
    else if(read_en||write_en) 
        addr <= HADDR[7:2];
end

/***AHB写操作***/
reg write_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        write_en_reg <= 1'b0;
    else if(write_en)
        write_en_reg <= 1'b1;
    else
        write_en_reg <= 1'b0;
end

always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
        bus_bin_mode_ctrl     <=1'b0;
        bus_bin_rgb_threshold <=8'd70;
        bus_bin_crbr_threshold<=32'hFF_00_FF_00;
    end
    else if(write_en_reg)begin
        case (addr)
            6'd1: bus_bin_mode_ctrl     <=HWDATA[0];
            6'd2: bus_bin_rgb_threshold <=HWDATA[7:0];
            6'd3: bus_bin_crbr_threshold<=HWDATA[31:0];
            default:;
        endcase
    end
end

/***AHB读操作***/
reg [31:0] read_data;
always @(*) begin
    if(~HRESETn)
        read_data=0;
    else begin
        case(addr)
            6'd0: read_data =   {28'b0,cnn_result};
            6'd1: read_data =   {31'b0,bus_bin_mode_ctrl};
            6'd2: read_data =   {24'b0,bus_bin_rgb_threshold};
            6'd3: read_data =   bus_bin_crbr_threshold;
            default: read_data = 0;
        endcase
    end
end

assign HRDATA = read_data ;
// assign HRDATA = (addr == 6'h00) ? {28'b0,cnn_result} : 32'b0 ;

/***例化***/

    wire        wire_bus_bin_mode_ctrl     =bus_bin_mode_ctrl     ;
    wire [ 7:0] wire_bus_bin_rgb_threshold =bus_bin_rgb_threshold ;
    wire [31:0] wire_bus_bin_crbr_threshold=bus_bin_crbr_threshold;

    ov5640_hdmi u_ov5640_hdmi(
        .sys_clk    (HCLK    ),  //系统时钟   //50MHz
        .sys_rst_n  (HRESETn|rstn ),  //系统复位，低电平有效
        //
        .clk_100m       (clk_100m      ),  //100mhz时钟,SDRAM操作时钟
        .clk_100m_shift (clk_100m_shift),  //100mhz时钟,SDRAM相位偏移时钟
        .clk_50m        (clk_50m       ),
        .hdmi_clk       (hdmi_clk      ),
        .hdmi_clk_5     (hdmi_clk_5    ),
        .locked         (locked        ),
        .locked_hdmi    (locked_hdmi   ),
        //AHB-Lite下发的三个控制字
        .bus_bin_mode_ctrl     (wire_bus_bin_mode_ctrl     ),
        .bus_bin_rgb_threshold (wire_bus_bin_rgb_threshold ),
        .bus_bin_crbr_threshold(wire_bus_bin_crbr_threshold),

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
