`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
`define ANLOGIC
module CortexM3 #(
    parameter                   SimPresent = 1
)(
    input       wire            CLK50m      ,
    input       wire            RSTn        ,
    // SWD
    inout       wire            SWDIO       ,
    input       wire            SWCLK       ,
    // UART
    output      wire            TXD         ,
    input       wire            RXD         ,
    //SPI
    output      wire            SPI_CLK     ,
    output      wire            SPI_CS      ,
    output      wire            SPI_MOSI    ,
    input       wire            SPI_MISO    ,
    //PS2
    output      wire            PS2_CS      ,
    output      wire            PS2_CLK     ,
    output      wire            PS2_DO      ,
    input       wire            PS2_DI      ,
    //LED
    output      wire    [3:0]   OUTLED      ,
    //JY61P
    output      wire        JY61P_UART_VCC  ,//F13
    output      wire        JY61P_UART_GND  ,//F14
    output      wire        JY61P_UART_TX   ,//D14
    input       wire        JY61P_UART_RX   ,//C14

    `ifdef VGA
    //GAME VGA
    output      wire            hsync       ,
    output      wire            vsync       ,
    output      wire    [11:0]  rgb         ,
    `else
    //HDMI OUT PIN
    output      wire            tmds_clk_p  ,
    output      wire            tmds_clk_n  ,
    output      wire    [2:0]   tmds_data_p ,
    output      wire    [2:0]   tmds_data_n ,
    `endif

    `ifdef ANLOGIC
    `else
    // LCD
    output      wire            LCD_CS      ,
    output      wire            LCD_RS      ,
    output      wire            LCD_WR      ,
    output      wire            LCD_RD      ,
    output      wire            LCD_RST     ,
    output      wire    [15:0]  LCD_DATA    ,
    output      wire            LCD_BL_CTR  ,
    `endif

    output      wire            APU_VCC     ,   //B13
    output      wire            APU_GND     ,   //B14
    output      wire            APU_OUT     ,   //C12

    //CNN相关的PIN
    // output      wire    [3:0]   one_hot     ,
    //摄像头
    input       wire            cam_pclk    ,  //cmos 数据像素时钟
    input       wire            cam_vsync   ,  //cmos 场同步信号
    input       wire            cam_href    ,  //cmos 行同步信号
    input       wire    [7:0]   cam_data    ,  //cmos 数据
    output      wire            cam_rst_n   ,  //cmos 复位信号，低电平有效
    output      wire            cam_pwdn    ,  //cmos 电源休眠模式选择信号
    output      wire            cam_scl     ,  //cmos SCCB_SCL线
    inout       wire            cam_sda     ,  //cmos SCCB_SDA线
    //SDRAM 
    output      wire            sdram_clk   ,  //SDRAM 时钟
    output      wire            sdram_cke   ,  //SDRAM 时钟有效
    output      wire            sdram_cs_n  ,  //SDRAM 片选
    output      wire            sdram_ras_n ,  //SDRAM 行有效
    output      wire            sdram_cas_n ,  //SDRAM 列有效
    output      wire            sdram_we_n  ,  //SDRAM 写有效
    output      wire   [1:0]    sdram_ba    ,  //SDRAM Bank地址
    output      wire   [1:0]    sdram_dqm   ,  //SDRAM 数据掩码
    output      wire   [12:0]   sdram_addr  ,  //SDRAM 地址
    inout       wire   [15:0]   sdram_data  ,  //SDRAM 数据
    //CNN_HDMI接口
    output      wire            cnn_tmds_clk_p  ,
    output      wire            cnn_tmds_clk_n  ,
    output      wire   [2:0]    cnn_tmds_data_p ,
    output      wire   [2:0]    cnn_tmds_data_n 
);

//PLL
    //除了CNN部分以外的其余部分的时钟
    wire clk_125MHz         ;
    wire clk_100MHz         ;
    wire clk_100MHz_270deg  ; //没用到
    wire clk_25p2MHz        ;
    //CNN部分使用的时钟
    wire    clk_100m        ;
    wire    clk_100m_shift  ;
    wire    clk_50m         ;
    wire    hdmi_clk        ;
    wire    hdmi_clk_5      ;

    clk_pll u_clk_pll (
        .refclk     (CLK50m             ),//50MHz
        .clk0_out   (clk_100MHz         ),//100MHz
        .clk1_out   (clk_25p2MHz        ),//实际25MHz
        .clk2_out   (clk_125MHz         ),//125MHz
        .clk3_out   (clk_100MHz_270deg  ) //100MHz deg 270
    );

    //锁相环
    pll u_pll(
        .reset              (~RSTn)    ,
        .refclk             (CLK50m )       ,
        .clk0_out           (clk_100m)      ,
        .clk1_out           (clk_100m_shift),
    	.clk2_out           (clk_50m)       ,//实际是25MHz
        .lock               (locked)
        );

    pll_hdmi	pll_hdmi_inst (
        .reset 			    ( ~RSTn       ),
        .refclk 			( CLK50m      ),
        .clk0_out 	        ( hdmi_clk    ),//hdmi pixel clock 25.1Mhz
        .clk1_out 		    ( hdmi_clk_5  ),//hdmi pixel clock*5 125.5Mhz
        .lock 			    ( locked_hdmi )
    );

    // wire    clk_100m        = clk_100MHz        ;//100mhz时钟,SDRAM操作时钟
    // wire    clk_100m_shift  = clk_100MHz_270deg ;//100mhz时钟,SDRAM相位偏移时钟
    // wire    clk_50m         = CLK50m            ;
    // wire    hdmi_clk        = clk_25p2MHz       ;
    // wire    hdmi_clk_5      = clk_125MHz        ;


// spi switch
    wire SOFT_SPI_CLK ;
    wire SOFT_SPI_CS  ;
    wire SOFT_SPI_MOSI;
    wire SOFT_SPI_MISO;
    wire scrollEn     ;
    wire HARD_SPI_CLK ;
    wire HARD_SPI_CS  ;
    wire HARD_SPI_MOSI;
    wire HARD_SPI_MISO;
    assign SPI_CLK  = (scrollEn==1'b1) ? HARD_SPI_CLK :SOFT_SPI_CLK ;
    assign SPI_CS   = (scrollEn==1'b1) ? HARD_SPI_CS  :SOFT_SPI_CS  ;
    assign SPI_MOSI = (scrollEn==1'b1) ? HARD_SPI_MOSI:SOFT_SPI_MOSI;
    assign HARD_SPI_MISO = (scrollEn==1'b1) ? SPI_MISO : 1'b0;
    assign SOFT_SPI_MISO = (scrollEn==1'b1) ? 1'b0 : SPI_MISO;

/**********************INTERRUPT******************************/
    wire    [239:0] IRQ             ;
    wire            TXINT           ;
    wire            RXINT           ;
    wire            TXOVRINT        ;
    wire            RXOVRINT        ;
    wire            UARTINT         ;
    wire    [3:0]   GPIOINT         ;
    wire            TIMERINT        ;
    wire            VGA_Intr        ;
    wire            createPlaneIntr ;
    wire            PULSE0INT       ;//APU Intr
    wire            PULSE1INT       ;
    wire            TRIANGLEINT     ;
    wire            NOISEINT        ;

    assign IRQ = {226'b0,NOISEINT,TRIANGLEINT,PULSE1INT,PULSE0INT,createPlaneIntr,VGA_Intr,TIMERINT,GPIOINT,RXOVRINT,RXINT,TXINT};
//

/***************GLOBAL BUF********************/
    wire            clk;
    wire            swck;
    `ifdef ANLOGIC
        assign swck = SWCLK;
        assign clk  = CLK50m;
        // assign clk  = clk_25p2MHz;
    `else
        generate 
            if(SimPresent) begin : SimClock

                    assign swck = SWCLK;
                    assign clk  = CLK50m;

            end else begin : SynClock

                    GLOBAL sw_clk(
                            .in                     (SWCLK),
                            .out                    (swck)
                    );
                    PLL PLL(
                            .refclk                 (CLK50m),
                            .rst                    (~RSTn),
                            .outclk_0               (clk)
                    );
            end    
        endgenerate
    `endif
//

/***************DEBUG IOBUF********************/
    wire            SWDO;
    wire            SWDOEN;
    wire            SWDI;
    `ifdef ANLOGIC
        assign SWDI = SWDIO;
        assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;
    `else
        generate
            if(SimPresent) begin : SimIOBuf

                assign SWDI = SWDIO;
                assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;

            end else begin : SynIOBuf

                IOBUF SWIOBUF(
                    .datain                 (SWDO),
                    .oe                     (SWDOEN),
                    .dataout                (SWDI),
                    .dataio                 (SWDIO)
                );

            end
        endgenerate
    `endif
//

/**************** RESET *********************/
    wire            SYSRESETREQ;
    reg             cpuresetn;

    always @(posedge clk or negedge RSTn)begin
        if (~RSTn) 
            cpuresetn <= 1'b0;
        else if (SYSRESETREQ) 
            cpuresetn <= 1'b0;
        else 
            cpuresetn <= 1'b1;
    end
    wire        SLEEPing;
//

/*****************DEBUG CONFIG****************/
    wire            CDBGPWRUPREQ;
    reg             CDBGPWRUPACK;

    always @(posedge clk or negedge RSTn)begin
        if (~RSTn) 
            CDBGPWRUPACK <= 1'b0;
        else 
            CDBGPWRUPACK <= CDBGPWRUPREQ;
    end
//

/**********CPU INST*****************/
   // CPU I-Code 
    wire    [31:0]  HADDRI;
    wire    [1:0]   HTRANSI;
    wire    [2:0]   HSIZEI;
    wire    [2:0]   HBURSTI;
    wire    [3:0]   HPROTI;
    wire    [31:0]  HRDATAI;
    wire            HREADYI;
    wire    [1:0]   HRESPI;
    // CPU D-Code 
    wire    [31:0]  HADDRD;
    wire    [1:0]   HTRANSD;
    wire    [2:0]   HSIZED;
    wire    [2:0]   HBURSTD;
    wire    [3:0]   HPROTD;
    wire    [31:0]  HWDATAD;
    wire            HWRITED;
    wire    [31:0]  HRDATAD;
    wire            HREADYD;
    wire    [1:0]   HRESPD;
    wire    [1:0]   HMASTERD;
    // CPU System bus 
    wire    [31:0]  HADDRS;
    wire    [1:0]   HTRANSS;
    wire            HWRITES;
    wire    [2:0]   HSIZES;
    wire    [31:0]  HWDATAS;
    wire    [2:0]   HBURSTS;
    wire    [3:0]   HPROTS;
    wire            HREADYS;
    wire    [31:0]  HRDATAS;
    wire    [1:0]   HRESPS;
    wire    [1:0]   HMASTERS;
    wire            HMASTERLOCKS;

    cortexm3ds_logic ulogic(
        // PMU
        .ISOLATEn                           (1'b1),
        .RETAINn                            (1'b1),

        // RESETS
        .PORESETn                           (RSTn),
        .SYSRESETn                          (cpuresetn),
        .SYSRESETREQ                        (SYSRESETREQ),
        .RSTBYPASS                          (1'b0),
        .CGBYPASS                           (1'b0),
        .SE                                 (1'b0),

        // CLOCKS
        .FCLK                               (clk),
        .HCLK                               (clk),
        .TRACECLKIN                         (1'b0),

        // SYSTICK
        .STCLK                              (1'b0),
        .STCALIB                            (26'b0),
        .AUXFAULT                           (32'b0),

        // CONFIG - SYSTEM
        .BIGEND                             (1'b0),
        .DNOTITRANS                         (1'b1),

        // SWJDAP
        .nTRST                              (1'b1),
        .SWDITMS                            (SWDI),
        .SWCLKTCK                           (swck),
        .TDI                                (1'b0),
        .CDBGPWRUPACK                       (CDBGPWRUPACK),
        .CDBGPWRUPREQ                       (CDBGPWRUPREQ),
        .SWDO                               (SWDO),
        .SWDOEN                             (SWDOEN),

        // IRQS
        .INTISR                             (IRQ),
        .INTNMI                             (1'b0),

        // I-CODE BUS
        .HREADYI                            (HREADYI),
        .HRDATAI                            (HRDATAI),
        .HRESPI                             (HRESPI),
        .IFLUSH                             (1'b0),
        .HADDRI                             (HADDRI),
        .HTRANSI                            (HTRANSI),
        .HSIZEI                             (HSIZEI),
        .HBURSTI                            (HBURSTI),
        .HPROTI                             (HPROTI),

        // D-CODE BUS
        .HREADYD                            (HREADYD),
        .HRDATAD                            (HRDATAD),
        .HRESPD                             (HRESPD),
        .EXRESPD                            (1'b0),
        .HADDRD                             (HADDRD),
        .HTRANSD                            (HTRANSD),
        .HSIZED                             (HSIZED),
        .HBURSTD                            (HBURSTD),
        .HPROTD                             (HPROTD),
        .HWDATAD                            (HWDATAD),
        .HWRITED                            (HWRITED),
        .HMASTERD                           (HMASTERD),

        // SYSTEM BUS
        .HREADYS                            (HREADYS),
        .HRDATAS                            (HRDATAS),
        .HRESPS                             (HRESPS),
        .EXRESPS                            (1'b0),
        .HADDRS                             (HADDRS),
        .HTRANSS                            (HTRANSS),
        .HSIZES                             (HSIZES),
        .HBURSTS                            (HBURSTS),
        .HPROTS                             (HPROTS),
        .HWDATAS                            (HWDATAS),
        .HWRITES                            (HWRITES),
        .HMASTERS                           (HMASTERS),
        .HMASTLOCKS                         (HMASTERLOCKS),

        // SLEEP
        .RXEV                               (1'b0),
        .SLEEPHOLDREQn                      (1'b1),
        .SLEEPING                           (SLEEPing),

        // EXTERNAL DEBUG REQUEST
        .EDBGRQ                             (1'b0),
        .DBGRESTART                         (1'b0),

        // DAP HMASTER OVERRIDE
        .FIXMASTERTYPE                      (1'b0),

        // WIC
        .WICENREQ                           (1'b0),

        // TIMESTAMP INTERFACE
        .TSVALUEB                           (48'b0),

        // CONFIG - DEBUG
        .DBGEN                              (1'b1),
        .NIDEN                              (1'b1),
        .MPUDISABLE                         (1'b0)
    );
//

/**********************AHB L1 BUS MATRIX******************/
    // DMA MASTER
    wire    [31:0]  HADDRDM;
    wire    [1:0]   HTRANSDM;
    wire            HWRITEDM;
    wire    [2:0]   HSIZEDM;
    wire    [31:0]  HWDATADM;
    wire    [2:0]   HBURSTDM;
    wire    [3:0]   HPROTDM;
    wire            HREADYDM;
    wire    [31:0]  HRDATADM;
    wire    [1:0]   HRESPDM;
    wire    [1:0]   HMASTERDM;
    wire            HMASTERLOCKDM;

    assign  HADDRDM         =   32'b0;
    assign  HTRANSDM        =   2'b0;
    assign  HWRITEDM        =   1'b0;
    assign  HSIZEDM         =   3'b0;
    assign  HWDATADM        =   32'b0;
    assign  HBURSTDM        =   3'b0;
    assign  HPROTDM         =   4'b0;
    assign  HMASTERDM       =   2'b0;
    assign  HMASTERLOCKDM   =   1'b0;

    // RESERVED MASTER 
    wire    [31:0]  HADDRR;
    wire    [1:0]   HTRANSR;
    wire            WRITER;
    wire    [2:0]   HSIZER;
    wire    [31:0]  HWDATAR;
    wire    [2:0]   HBURSTR;
    wire    [3:0]   HPROTR;
    wire            HREADYR;
    wire    [31:0]  HRDATAR;
    wire    [1:0]   HRESPR;
    wire    [1:0]   HMASTERR;
    wire            HMASTERLOCKR;

    assign  HADDRR          =   32'b0;
    assign  HTRANSR         =   2'b0;
    assign  HWRITER         =   1'b0;
    assign  HSIZER          =   3'b0;
    assign  HWDATAR         =   32'b0;
    assign  HBURSTR         =   3'b0;
    assign  HPROTR          =   4'b0;
    assign  HMASTERR        =   2'b0;
    assign  HMASTERLOCKR    =   1'b0;

    wire    [31:0]  HADDR_AHBL1P0;
    wire    [1:0]   HTRANS_AHBL1P0;
    wire            HWRITE_AHBL1P0;
    wire    [2:0]   HSIZE_AHBL1P0;
    wire    [31:0]  HWDATA_AHBL1P0;
    wire    [2:0]   HBURST_AHBL1P0;
    wire    [3:0]   HPROT_AHBL1P0;
    wire            HREADY_AHBL1P0;
    wire    [31:0]  HRDATA_AHBL1P0;
    wire    [1:0]   HRESP_AHBL1P0;
    wire            HREADYOUT_AHBL1P0;
    wire            HSEL_AHBL1P0;
    wire    [1:0]   HMASTER_AHBL1P0;
    wire            HMASTERLOCK_AHBL1P0;

    wire    [31:0]  HADDR_AHBL1P1;
    wire    [1:0]   HTRANS_AHBL1P1;
    wire            HWRITE_AHBL1P1;
    wire    [2:0]   HSIZE_AHBL1P1;
    wire    [31:0]  HWDATA_AHBL1P1;
    wire    [2:0]   HBURST_AHBL1P1;
    wire    [3:0]   HPROT_AHBL1P1;
    wire            HREADY_AHBL1P1;
    wire    [31:0]  HRDATA_AHBL1P1;
    wire    [1:0]   HRESP_AHBL1P1;
    wire            HREADYOUT_AHBL1P1;
    wire            HSEL_AHBL1P1;
    wire    [1:0]   HMASTER_AHBL1P1;
    wire            HMASTERLOCK_AHBL1P1;

    wire    [31:0]  HADDR_AHBL1P4;
    wire    [1:0]   HTRANS_AHBL1P4;
    wire            HWRITE_AHBL1P4;
    wire    [2:0]   HSIZE_AHBL1P4;
    wire    [31:0]  HWDATA_AHBL1P4;
    wire    [2:0]   HBURST_AHBL1P4;
    wire    [3:0]   HPROT_AHBL1P4;
    wire            HREADY_AHBL1P4;
    wire    [31:0]  HRDATA_AHBL1P4;
    wire    [1:0]   HRESP_AHBL1P4;
    wire            HREADYOUT_AHBL1P4;
    wire            HSEL_AHBL1P4;
    wire    [1:0]   HMASTER_AHBL1P4;
    wire            HMASTERLOCK_AHBL1P4;

    wire    [31:0]  HADDR_AHBL1P2;
    wire    [1:0]   HTRANS_AHBL1P2;
    wire            HWRITE_AHBL1P2;
    wire    [2:0]   HSIZE_AHBL1P2;
    wire    [31:0]  HWDATA_AHBL1P2;
    wire    [2:0]   HBURST_AHBL1P2;
    wire    [3:0]   HPROT_AHBL1P2;
    wire            HREADY_AHBL1P2;
    wire    [31:0]  HRDATA_AHBL1P2;
    wire    [1:0]   HRESP_AHBL1P2;
    wire            HREADYOUT_AHBL1P2;
    wire            HSEL_AHBL1P2;
    wire    [1:0]   HMASTER_AHBL1P2;
    wire            HMASTERLOCK_AHBL1P2;

    wire    [31:0]  HADDR_AHBL1P3;
    wire    [1:0]   HTRANS_AHBL1P3;
    wire            HWRITE_AHBL1P3;
    wire    [2:0]   HSIZE_AHBL1P3;
    wire    [31:0]  HWDATA_AHBL1P3;
    wire    [2:0]   HBURST_AHBL1P3;
    wire    [3:0]   HPROT_AHBL1P3;
    wire            HREADY_AHBL1P3;
    wire    [31:0]  HRDATA_AHBL1P3;
    wire    [1:0]   HRESP_AHBL1P3;
    wire            HREADYOUT_AHBL1P3;
    wire            HSEL_AHBL1P3;
    wire    [1:0]   HMASTER_AHBL1P3;
    wire            HMASTERLOCK_AHBL1P3;

    L1AhbMtx    L1AhbMtx(
        .HCLK                               (clk),
        .HRESETn                            (cpuresetn),

        .REMAP                              (4'b0),

        .HSELS1                             (1'b1),
        .HADDRS1                            (HADDRI),
        .HTRANSS1                           (HTRANSI),
        .HWRITES1                           (1'b0),
        .HSIZES1                            (HSIZEI),
        .HBURSTS1                           (HBURSTI),
        .HPROTS1                            (HPROTI),
        .HMASTERS1                          (4'b0),
        .HWDATAS1                           (32'b0),
        .HMASTLOCKS1                        (1'b0),
        .HREADYS1                           (HREADYI),
        .HRDATAS1                           (HRDATAI),
        .HREADYOUTS1                        (HREADYI),
        .HRESPS1                            (HRESPI),

        .HSELS0                             (1'b1),
        .HADDRS0                            (HADDRD),
        .HTRANSS0                           (HTRANSD),
        .HWRITES0                           (HWRITED),
        .HSIZES0                            (HSIZED),
        .HBURSTS0                           (HBURSTD),
        .HPROTS0                            (HPROTD),
        .HMASTERS0                          ({2'b0,HMASTERD}),
        .HWDATAS0                           (HWDATAD),
        .HMASTLOCKS0                        (1'b0),
        .HREADYS0                           (HREADYD),
        .HREADYOUTS0                        (HREADYD),
        .HRESPS0                            (HRESPD),
        .HRDATAS0                           (HRDATAD),

        .HSELS2                             (1'b1),
        .HADDRS2                            (HADDRS),
        .HTRANSS2                           (HTRANSS),
        .HWRITES2                           (HWRITES),
        .HSIZES2                            (HSIZES),
        .HBURSTS2                           (HBURSTS),
        .HPROTS2                            (HPROTS),
        .HMASTERS2                          ({2'b0,HMASTERS}),
        .HWDATAS2                           (HWDATAS),
        .HMASTLOCKS2                        (HMASTERLOCKS),
        .HREADYS2                           (HREADYS),
        .HREADYOUTS2                        (HREADYS),
        .HRESPS2                            (HRESPS),
        .HRDATAS2                           (HRDATAS),    

        .HSELS3                             (1'b1),
        .HADDRS3                            (HADDRDM),
        .HTRANSS3                           (HTRANSDM),
        .HWRITES3                           (HWRITEDM),
        .HSIZES3                            (HSIZEDM),
        .HBURSTS3                           (HBURSTDM),
        .HPROTS3                            (HPROTDM),
        .HMASTERS3                          ({2'b0,HMASTERDM}),
        .HWDATAS3                           (HWDATADM),
        .HMASTLOCKS3                        (HMASTERLOCKDM),
        .HREADYS3                           (1'b1),
        .HREADYOUTS3                        (HREADYDM),
        .HRESPS3                            (HRESPDM),
        .HRDATAS3                           (HRDATADM),

        .HSELS4                             (1'b1),
        .HADDRS4                            (HADDRR),
        .HTRANSS4                           (HTRANSR),
        .HWRITES4                           (HWRITER),
        .HSIZES4                            (HSIZER),
        .HBURSTS4                           (HBURSTR),
        .HPROTS4                            (HPROTR),
        .HMASTERS4                          ({2'b0,HMASTERR}),
        .HWDATAS4                           (HWDATAR),
        .HMASTLOCKS4                        (HMASTERLOCKR),
        .HREADYS4                           (1'b1),
        .HREADYOUTS4                        (HREADYR),
        .HRESPS4                            (HRESPR),
        .HRDATAS4                           (HRDATAR),

        .HSELM0                             (HSEL_AHBL1P0),
        .HADDRM0                            (HADDR_AHBL1P0),
        .HTRANSM0                           (HTRANS_AHBL1P0),
        .HWRITEM0                           (HWRITE_AHBL1P0),
        .HSIZEM0                            (HSIZE_AHBL1P0),
        .HBURSTM0                           (HBURST_AHBL1P0),
        .HPROTM0                            (HPROT_AHBL1P0),
        .HMASTERM0                          (HMASTER_AHBL1P0),
        .HWDATAM0                           (HWDATA_AHBL1P0),
        .HMASTLOCKM0                        (HMASTERLOCK_AHBL1P0),
        .HREADYMUXM0                        (HREADY_AHBL1P0),
        .HRDATAM0                           (HRDATA_AHBL1P0),
        .HREADYOUTM0                        (HREADYOUT_AHBL1P0),
        .HRESPM0                            (HRESP_AHBL1P0),

        .HSELM1                             (HSEL_AHBL1P1),
        .HADDRM1                            (HADDR_AHBL1P1),
        .HTRANSM1                           (HTRANS_AHBL1P1),
        .HWRITEM1                           (HWRITE_AHBL1P1),
        .HSIZEM1                            (HSIZE_AHBL1P1),
        .HBURSTM1                           (HBURST_AHBL1P1),
        .HPROTM1                            (HPROT_AHBL1P1),
        .HMASTERM1                          (HMASTER_AHBL1P1),
        .HWDATAM1                           (HWDATA_AHBL1P1),
        .HMASTLOCKM1                        (HMASTERLOCK_AHBL1P1),
        .HREADYMUXM1                        (HREADY_AHBL1P1),
        .HRDATAM1                           (HRDATA_AHBL1P1),
        .HREADYOUTM1                        (HREADYOUT_AHBL1P1),
        .HRESPM1                            (HRESP_AHBL1P1),

        .HSELM2                             (HSEL_AHBL1P2),
        .HADDRM2                            (HADDR_AHBL1P2),
        .HTRANSM2                           (HTRANS_AHBL1P2),
        .HWRITEM2                           (HWRITE_AHBL1P2),
        .HSIZEM2                            (HSIZE_AHBL1P2),
        .HBURSTM2                           (HBURST_AHBL1P2),
        .HPROTM2                            (HPROT_AHBL1P2),
        .HMASTERM2                          (HMASTER_AHBL1P2),
        .HWDATAM2                           (HWDATA_AHBL1P2),
        .HMASTLOCKM2                        (HMASTERLOCK_AHBL1P2),
        .HREADYMUXM2                        (HREADY_AHBL1P2),
        .HRDATAM2                           (HRDATA_AHBL1P2),
        .HREADYOUTM2                        (HREADYOUT_AHBL1P2),
        .HRESPM2                            (HRESP_AHBL1P2),

        .HSELM3                             (HSEL_AHBL1P3),
        .HADDRM3                            (HADDR_AHBL1P3),
        .HTRANSM3                           (HTRANS_AHBL1P3),
        .HWRITEM3                           (HWRITE_AHBL1P3),
        .HSIZEM3                            (HSIZE_AHBL1P3),
        .HBURSTM3                           (HBURST_AHBL1P3),
        .HPROTM3                            (HPROT_AHBL1P3),
        .HMASTERM3                          (HMASTER_AHBL1P3),
        .HWDATAM3                           (HWDATA_AHBL1P3),
        .HMASTLOCKM3                        (HMASTERLOCK_AHBL1P3),
        .HREADYMUXM3                        (HREADY_AHBL1P3),
        .HRDATAM3                           (HRDATA_AHBL1P3),
        .HREADYOUTM3                        (HREADYOUT_AHBL1P3),
        .HRESPM3                            (HRESP_AHBL1P3),

        .HSELM4                             (HSEL_AHBL1P4),
        .HADDRM4                            (HADDR_AHBL1P4),
        .HTRANSM4                           (HTRANS_AHBL1P4),
        .HWRITEM4                           (HWRITE_AHBL1P4),
        .HSIZEM4                            (HSIZE_AHBL1P4),
        .HBURSTM4                           (HBURST_AHBL1P4),
        .HPROTM4                            (HPROT_AHBL1P4),
        .HMASTERM4                          (HMASTER_AHBL1P4),
        .HWDATAM4                           (HWDATA_AHBL1P4),
        .HMASTLOCKM4                        (HMASTERLOCK_AHBL1P4),
        .HREADYMUXM4                        (HREADY_AHBL1P4),
        .HRDATAM4                           (HRDATA_AHBL1P4),
        .HREADYOUTM4                        (HREADYOUT_AHBL1P4),
        .HRESPM4                            (HRESP_AHBL1P4),

        .SCANENABLE                         (1'b0),
        .SCANINHCLK                         (1'b0),
        .SCANOUTHCLK                        ()
    );
//

/******************** 第二级 AHB ***********************/
    wire    [31:0]  HADDR_AHBL2M;
    wire    [1:0]   HTRANS_AHBL2M;
    wire    [2:0]   HSIZE_AHBL2M;
    wire            HWRITE_AHBL2M;
    wire    [3:0]   HPROT_AHBL2M;
    wire    [1:0]   HMASTER_AHBL2M;
    wire            HMASTERLOCK_AHBL2M;
    wire    [31:0]  HWDATA_AHBL2M;
    wire    [2:0]   HBURST_AHBL2M;
    wire            HREADY_AHBL2M;
    wire    [1:0]   HRESP_AHBL2M;
    wire    [31:0]  HRDATA_AHBL2M;

    cmsdk_ahb_to_ahb_sync #(
        .AW                                 (32),
        .DW                                 (32),
        .MW                                 (2),
        .BURST                              (1)
    )   AhbBridge   (
        .HCLK                               (clk),
        .HRESETn                            (cpuresetn),
        .HSELS                              (HSEL_AHBL1P4),
        .HADDRS                             (HADDR_AHBL1P4),
        .HTRANSS                            (HTRANS_AHBL1P4),
        .HSIZES                             (HSIZE_AHBL1P4),
        .HWRITES                            (HWRITE_AHBL1P4),
        .HREADYS                            (HREADY_AHBL1P4),
        .HPROTS                             (HPROT_AHBL1P4),
        .HMASTERS                           (HMASTER_AHBL1P4),
        .HMASTLOCKS                         (HMASTERLOCK_AHBL1P4),
        .HWDATAS                            (HWDATA_AHBL1P4),
        .HBURSTS                            (HBURST_AHBL1P4),
        .HREADYOUTS                         (HREADYOUT_AHBL1P4),
        .HRESPS                             (HRESP_AHBL1P4[0]),
        .HRDATAS                            (HRDATA_AHBL1P4),
        .HADDRM                             (HADDR_AHBL2M),
        .HTRANSM                            (HTRANS_AHBL2M),
        .HSIZEM                             (HSIZE_AHBL2M),
        .HWRITEM                            (HWRITE_AHBL2M),
        .HPROTM                             (HPROT_AHBL2M),
        .HMASTERM                           (HMASTER_AHBL2M),
        .HMASTLOCKM                         (HMASTERLOCK_AHBL2M),
        .HWDATAM                            (HWDATA_AHBL2M),
        .HBURSTM                            (HBURST_AHBL2M),
        .HREADYM                            (HREADYOUT_AHBL2M),
        .HRESPM                             (HRESP_AHBL2M[0]),
        .HRDATAM                            (HRDATA_AHBL2M)
    );
    assign  HRESP_AHBL1P4[1]    =   1'b0;

    wire    [31:0]  HADDR_AHBL2P0;
    wire    [1:0]   HTRANS_AHBL2P0;
    wire            HWRITE_AHBL2P0;
    wire    [2:0]   HSIZE_AHBL2P0;
    wire    [31:0]  HWDATA_AHBL2P0;
    wire    [2:0]   HBURST_AHBL2P0;
    wire    [3:0]   HPROT_AHBL2P0;
    wire            HREADY_AHBL2P0;
    wire    [31:0]  HRDATA_AHBL2P0;
    wire    [1:0]   HRESP_AHBL2P0;
    wire            HREADYOUT_AHBL2P0;
    wire            HSEL_AHBL2P0;
    wire    [1:0]   HMASTER_AHBL2P0;
    wire            HMASTERLOCK_AHBL2P0;

    wire    [31:0]  HADDR_AHBL2P1;
    wire    [1:0]   HTRANS_AHBL2P1;
    wire            HWRITE_AHBL2P1;
    wire    [2:0]   HSIZE_AHBL2P1;
    wire    [31:0]  HWDATA_AHBL2P1;
    wire    [2:0]   HBURST_AHBL2P1;
    wire    [3:0]   HPROT_AHBL2P1;
    wire            HREADY_AHBL2P1;
    wire    [31:0]  HRDATA_AHBL2P1;
    wire    [1:0]   HRESP_AHBL2P1;
    wire            HREADYOUT_AHBL2P1;
    wire            HSEL_AHBL2P1;
    wire    [1:0]   HMASTER_AHBL2P1;
    wire            HMASTERLOCK_AHBL2P1;

    wire    [31:0]        HADDR_AHBL2P2;
    wire    [1:0]        HTRANS_AHBL2P2;
    wire                 HWRITE_AHBL2P2;
    wire    [2:0]         HSIZE_AHBL2P2;
    wire    [31:0]       HWDATA_AHBL2P2;
    wire    [2:0]        HBURST_AHBL2P2;
    wire    [3:0]         HPROT_AHBL2P2;
    wire                 HREADY_AHBL2P2;
    wire    [31:0]       HRDATA_AHBL2P2;
    wire    [1:0]         HRESP_AHBL2P2;
    wire              HREADYOUT_AHBL2P2;
    wire                   HSEL_AHBL2P2;
    wire    [1:0]       HMASTER_AHBL2P2;
    wire            HMASTERLOCK_AHBL2P2;

    wire    [31:0]        HADDR_AHBL2P3;
    wire    [1:0]        HTRANS_AHBL2P3;
    wire                 HWRITE_AHBL2P3;
    wire    [2:0]         HSIZE_AHBL2P3;
    wire    [31:0]       HWDATA_AHBL2P3;
    wire    [2:0]        HBURST_AHBL2P3;
    wire    [3:0]         HPROT_AHBL2P3;
    wire                 HREADY_AHBL2P3;
    wire    [31:0]       HRDATA_AHBL2P3;
    wire    [1:0]         HRESP_AHBL2P3;
    wire              HREADYOUT_AHBL2P3;
    wire                   HSEL_AHBL2P3;
    wire    [1:0]       HMASTER_AHBL2P3;
    wire            HMASTERLOCK_AHBL2P3;

    L2AhbMtx    L2AhbMtx(
        .HCLK                               (clk),
        .HRESETn                            (cpuresetn),

        .REMAP                              (4'b0),

        .HSELS0                             (1'b1),
        .HADDRS0                            (HADDR_AHBL2M),
        .HTRANSS0                           (HTRANS_AHBL2M),
        .HWRITES0                           (HWRITE_AHBL2M),
        .HSIZES0                            (HSIZE_AHBL2M),
        .HBURSTS0                           (HBURST_AHBL2M),
        .HPROTS0                            (HPROT_AHBL2M),
        .HMASTERS0                          (HMASTER_AHBL2M),
        .HWDATAS0                           (HWDATA_AHBL2M),
        .HMASTLOCKS0                        (HMASTERLOCK_AHBL2M),
        .HREADYS0                           (HREADYOUT_AHBL2M),
        .HRDATAS0                           (HRDATA_AHBL2M),
        .HREADYOUTS0                        (HREADYOUT_AHBL2M),
        .HRESPS0                            (HRESP_AHBL2M),

        .HSELM0                             (HSEL_AHBL2P0),
        .HADDRM0                            (HADDR_AHBL2P0),
        .HTRANSM0                           (HTRANS_AHBL2P0),
        .HWRITEM0                           (HWRITE_AHBL2P0),
        .HSIZEM0                            (HSIZE_AHBL2P0),
        .HBURSTM0                           (HBURST_AHBL2P0),
        .HPROTM0                            (HPROT_AHBL2P0),
        .HMASTERM0                          (HMASTER_AHBL2P0),
        .HWDATAM0                           (HWDATA_AHBL2P0),
        .HMASTLOCKM0                        (HMASTERLOCK_AHBL2P0),
        .HREADYMUXM0                        (HREADY_AHBL2P0),
        .HRDATAM0                           (HRDATA_AHBL2P0),
        .HREADYOUTM0                        (HREADYOUT_AHBL2P0),
        .HRESPM0                            (HRESP_AHBL2P0),

        .HSELM1                             (HSEL_AHBL2P1),
        .HADDRM1                            (HADDR_AHBL2P1),
        .HTRANSM1                           (HTRANS_AHBL2P1),
        .HWRITEM1                           (HWRITE_AHBL2P1),
        .HSIZEM1                            (HSIZE_AHBL2P1),
        .HBURSTM1                           (HBURST_AHBL2P1),
        .HPROTM1                            (HPROT_AHBL2P1),
        .HMASTERM1                          (HMASTER_AHBL2P1),
        .HWDATAM1                           (HWDATA_AHBL2P1),
        .HMASTLOCKM1                        (HMASTERLOCK_AHBL2P1),
        .HREADYMUXM1                        (HREADY_AHBL2P1),
        .HRDATAM1                           (HRDATA_AHBL2P1),
        .HREADYOUTM1                        (HREADYOUT_AHBL2P1),
        .HRESPM1                            (HRESP_AHBL2P1),

        .HSELM2                             (HSEL_AHBL2P2),
        .HADDRM2                            (HADDR_AHBL2P2),
        .HTRANSM2                           (HTRANS_AHBL2P2),
        .HWRITEM2                           (HWRITE_AHBL2P2),
        .HSIZEM2                            (HSIZE_AHBL2P2),
        .HBURSTM2                           (HBURST_AHBL2P2),
        .HPROTM2                            (HPROT_AHBL2P2),
        .HMASTERM2                          (HMASTER_AHBL2P2),
        .HWDATAM2                           (HWDATA_AHBL2P2),
        .HMASTLOCKM2                        (HMASTERLOCK_AHBL2P2),
        .HREADYMUXM2                        (HREADY_AHBL2P2),
        .HRDATAM2                           (HRDATA_AHBL2P2),
        .HREADYOUTM2                        (HREADYOUT_AHBL2P2),
        .HRESPM2                            (HRESP_AHBL2P2),

        .HSELM3                             (HSEL_AHBL2P3),
        .HADDRM3                            (HADDR_AHBL2P3),
        .HTRANSM3                           (HTRANS_AHBL2P3),
        .HWRITEM3                           (HWRITE_AHBL2P3),
        .HSIZEM3                            (HSIZE_AHBL2P3),
        .HBURSTM3                           (HBURST_AHBL2P3),
        .HPROTM3                            (HPROT_AHBL2P3),
        .HMASTERM3                          (HMASTER_AHBL2P3),
        .HWDATAM3                           (HWDATA_AHBL2P3),
        .HMASTLOCKM3                        (HMASTERLOCK_AHBL2P3),
        .HREADYMUXM3                        (HREADY_AHBL2P3),
        .HRDATAM3                           (HRDATA_AHBL2P3),
        .HREADYOUTM3                        (HREADYOUT_AHBL2P3),
        .HRESPM3                            (HRESP_AHBL2P3),

        .SCANENABLE                         (1'b0),
        .SCANINHCLK                         (1'b0),
        .SCANOUTHCLK                        ()
    );
//

/**********************AHB TO APB Bridge******************************/
    wire    [15:0]  PADDR;    
    wire            PENABLE;  
    wire            PWRITE;   
    wire    [3:0]   PSTRB;    
    wire    [2:0]   PPROT;    
    wire    [31:0]  PWDATA;   
    wire            PSEL;     
    wire            APBACTIVE;                  
    wire    [31:0]  PRDATA;   
    wire            PREADY;  
    wire            PSLVERR; 

    cmsdk_ahb_to_apb #(
        .ADDRWIDTH                          (16),
        .REGISTER_RDATA                     (1),
        .REGISTER_WDATA                     (1)
    )    ApbBridge  (
        .HCLK                               (clk),
        .HRESETn                            (cpuresetn),
        .PCLKEN                             (1'b1),
        .HSEL                               (HSEL_AHBL1P2),
        .HADDR                              (HADDR_AHBL1P2),
        .HTRANS                             (HTRANS_AHBL1P2),
        .HSIZE                              (HSIZE_AHBL1P2),
        .HPROT                              (HPROT_AHBL1P2),
        .HWRITE                             (HWRITE_AHBL1P2),
        .HREADY                             (HREADY_AHBL1P2),
        .HWDATA                             (HWDATA_AHBL1P2),
        .HREADYOUT                          (HREADYOUT_AHBL1P2),
        .HRDATA                             (HRDATA_AHBL1P2),
        .HRESP                              (HRESP_AHBL1P2[0]),        
        .PADDR                              (PADDR),
        .PENABLE                            (PENABLE),
        .PWRITE                             (PWRITE),
        .PSTRB                              (PSTRB),
        .PPROT                              (PPROT),
        .PWDATA                             (PWDATA),
        .PSEL                               (PSEL),
        .APBACTIVE                          (APBACTIVE),
        .PRDATA                             (PRDATA),
        .PREADY                             (PREADY),
        .PSLVERR                            (PSLVERR)                      
    );
    assign  HRESP_AHBL1P2[1]    =   1'b0;

    wire            PSEL_APBP0;
    wire            PREADY_APBP0;
    wire    [31:0]  PRDATA_APBP0;
    wire            PSLVERR_APBP0;

    wire            PSEL_APBP1;
    wire            PREADY_APBP1;
    wire    [31:0]  PRDATA_APBP1;
    wire            PSLVERR_APBP1;

    wire            PSEL_APBP2;
    wire            PREADY_APBP2;
    wire    [31:0]  PRDATA_APBP2;
    wire            PSLVERR_APBP2;

    wire            PSEL_APBP4;
    wire            PREADY_APBP4;
    wire    [31:0]  PRDATA_APBP4;
    wire            PSLVERR_APBP4;

    wire            PSEL_APBP5;
    wire            PREADY_APBP5;
    wire    [31:0]  PRDATA_APBP5;
    wire            PSLVERR_APBP5;

    wire            PSEL_APBP6;
    wire            PREADY_APBP6;
    wire    [31:0]  PRDATA_APBP6;
    wire            PSLVERR_APBP6;

    cmsdk_apb_slave_mux   u_cmsdk_apb_slave_mux (
        .DECODE4BIT                         (PADDR[15:12]),
        .PSEL                               (PSEL),

        .PSEL0                              (PSEL_APBP0),
        .PREADY0                            (PREADY_APBP0),
        .PRDATA0                            (PRDATA_APBP0),
        .PSLVERR0                           (PSLVERR_APBP0),

        .PSEL1                              (PSEL_APBP1),
        .PREADY1                            (PREADY_APBP1),
        .PRDATA1                            (PRDATA_APBP1),
        .PSLVERR1                           (PSLVERR_APBP1),

        .PSEL2                              (PSEL_APBP2   ),
        .PREADY2                            (PREADY_APBP2 ),
        .PRDATA2                            (PRDATA_APBP2 ),
        .PSLVERR2                           (PSLVERR_APBP2),

        .PSEL3                              (),
        .PREADY3                            (1'b1),
        .PRDATA3                            (32'b0),
        .PSLVERR3                           (1'b0),

        .PSEL4                              (PSEL_APBP4),
        .PREADY4                            (PREADY_APBP4),
        .PRDATA4                            (PRDATA_APBP4),
        .PSLVERR4                           (PSLVERR_APBP4),

        .PSEL5                              (PSEL_APBP5),
        .PREADY5                            (PREADY_APBP5),
        .PRDATA5                            (PRDATA_APBP5),
        .PSLVERR5                           (PSLVERR_APBP5),

        .PSEL6                              (PSEL_APBP6),
        .PREADY6                            (PREADY_APBP6),
        .PRDATA6                            (PRDATA_APBP6),
        .PSLVERR6                           (PSLVERR_APBP6),

        .PSEL7                              (),
        .PREADY7                            (1'b1),
        .PRDATA7                            (32'b0),
        .PSLVERR7                           (1'b0),

        .PSEL8                              (),
        .PREADY8                            (1'b1),
        .PRDATA8                            (32'b0),
        .PSLVERR8                           (1'b0),

        .PSEL9                              (),
        .PREADY9                            (1'b1),
        .PRDATA9                            (32'b0),
        .PSLVERR9                           (1'b0),

        .PSEL10                             (),
        .PREADY10                           (1'b1),
        .PRDATA10                           (32'b0),
        .PSLVERR10                          (1'b0),

        .PSEL11                             (),
        .PREADY11                           (1'b1),
        .PRDATA11                           (32'b0),
        .PSLVERR11                          (1'b0),

        .PSEL12                             (),
        .PREADY12                           (1'b1),
        .PRDATA12                           (32'b0),
        .PSLVERR12                          (1'b0),

        .PSEL13                             (),
        .PREADY13                           (1'b1),
        .PRDATA13                           (32'b0),
        .PSLVERR13                          (1'b0),

        .PSEL14                             (),
        .PREADY14                           (1'b1),
        .PRDATA14                           (32'b0),
        .PSLVERR14                          (1'b0),

        .PSEL15                             (),
        .PREADY15                           (1'b1),
        .PRDATA15                           (32'b0),
        .PSLVERR15                          (1'b0),

        .PREADY                             (PREADY),
        .PRDATA                             (PRDATA),
        .PSLVERR                            (PSLVERR)

    );
//

/**********************AHB ITCM******************************/
    wire [13:0] ITCM_RDADDR;
    wire [13:0] ITCM_WRADDR;
    wire [31:0] ITCM_RDATA,ITCM_WDATA;
    wire [3:0] ITCM_WRITE;
    
    AHBlite_Block_RAM #(
            .ADDR_WIDTH                     (14)
    )       ITCM_Interface(
            .HCLK                           (clk),
            .HRESETn                        (cpuresetn),
            .HADDR                          (HADDR_AHBL1P0),
            .HPROT                          (HPROT_AHBL1P0),
            .HSEL                           (HSEL_AHBL1P0),
            .HSIZE                          (HSIZE_AHBL1P0),
            .HTRANS                         (HTRANS_AHBL1P0),
            .HWRITE                         (HWRITE_AHBL1P0),
            .HRDATA                         (HRDATA_AHBL1P0),
            .HREADY                         (HREADY_AHBL1P0),
            .HREADYOUT                      (HREADYOUT_AHBL1P0),
            .HRESP                          (HRESP_AHBL1P0),
            .HWDATA                         (HWDATA_AHBL1P0),
            .BRAM_RDADDR                    (ITCM_RDADDR),
            .BRAM_WRADDR                    (ITCM_WRADDR),
            .BRAM_RDATA                     (ITCM_RDATA),
            .BRAM_WDATA                     (ITCM_WDATA),
            .BRAM_WRITE                     (ITCM_WRITE)
    );
    
    Block_RAM #(
            .ADDR_WIDTH                     (14)
    )       ITCM(
            .clka                           (clk),
            .addra                          (ITCM_WRADDR),
            .addrb                          (ITCM_RDADDR),
            .dina                           (ITCM_WDATA),
            .doutb                          (ITCM_RDATA),
            .wea                            (ITCM_WRITE)
    );
//

/**********************AHB DTCM******************************/
    wire [13:0] DTCM_RDADDR;
    wire [13:0] DTCM_WRADDR;
    wire [31:0] DTCM_RDATA,DTCM_WDATA;
    wire [3:0] DTCM_WRITE;

    AHBlite_Block_RAM #(
            .ADDR_WIDTH                     (14)
    )       DTCM_Interface(
            .HCLK                           (clk),
            .HRESETn                        (cpuresetn),
            .HADDR                          (HADDR_AHBL1P1),
            .HPROT                          (HPROT_AHBL1P1),
            .HSEL                           (HSEL_AHBL1P1),
            .HSIZE                          (HSIZE_AHBL1P1),
            .HTRANS                         (HTRANS_AHBL1P1),
            .HWRITE                         (HWRITE_AHBL1P1),
            .HRDATA                         (HRDATA_AHBL1P1),
            .HREADY                         (HREADY_AHBL1P1),
            .HREADYOUT                      (HREADYOUT_AHBL1P1),
            .HRESP                          (HRESP_AHBL1P1),
            .HWDATA                         (HWDATA_AHBL1P1),
            .BRAM_RDADDR                    (DTCM_RDADDR),
            .BRAM_WRADDR                    (DTCM_WRADDR),
            .BRAM_RDATA                     (DTCM_RDATA),
            .BRAM_WDATA                     (DTCM_WDATA),
            .BRAM_WRITE                     (DTCM_WRITE)
    );

    Block_RAM #(
            .ADDR_WIDTH                     (14)
    )       DTCM(
            .clka                           (clk),
            .addra                          (DTCM_WRADDR),
            .addrb                          (DTCM_RDADDR),
            .dina                           (DTCM_WDATA),
            .doutb                          (DTCM_RDATA),
            .wea                            (DTCM_WRITE)
    );
//

/**********************APB0 UART******************************/    
    cmsdk_apb_uart UART(
        .PCLK                               (clk),
        .PCLKG                              (clk),
        .PRESETn                            (cpuresetn),
        .PSEL                               (PSEL_APBP0),
        .PADDR                              (PADDR),
        .PENABLE                            (PENABLE), 
        .PWRITE                             (PWRITE),
        .PWDATA                             (PWDATA),
        .ECOREVNUM                          (4'b0),
        .PRDATA                             (PRDATA_APBP0),
        .PREADY                             (PREADY_APBP0),
        .PSLVERR                            (PSLVERR_APBP0),
    
        .RXD                                (RXD),
        .TXD                                (TXD),
        .TXEN                               (TXEN),
        .BAUDTICK                           (BAUDTICK),
        .TXINT                              (TXINT),
        .RXINT                              (RXINT),
        .TXOVRINT                           (TXOVRINT),
        .RXOVRINT                           (RXOVRINT),
        .UARTINT                            (UARTINT)
    );
//

/**********************APB1 LED******************************/
    wire [7:0] LED;
    apb_led led(
    	.PCLK                               (clk),
        .PCLKG                              (clk),
        .PRESETn                            (cpuresetn),
        .PSEL                               (PSEL_APBP1),
        .PADDR                              (PADDR),
        .PENABLE                            (PENABLE), 
        .PWRITE                             (PWRITE),
        .PWDATA                             (PWDATA),
        .ECOREVNUM                          (4'b0),
        .PRDATA                             (PRDATA_APBP1),
        .PREADY                             (PREADY_APBP1),
        .PSLVERR                            (PSLVERR_APBP1),
    	.LED                                (LED)
    
    );
    assign OUTLED = LED[3:0];
//

/**********************APB2 JY61P******************************/
    apb_JY61P JY61P(
        .PCLK        (clk           ),
        .PCLKG       (clk           ),
        .PRESETn     (cpuresetn     ),
        .PSEL        (PSEL_APBP2    ),
        .PADDR       (PADDR[15:0]   ),
        .PENABLE     (PENABLE       ),
        .PWRITE      (PWRITE        ),
        .PWDATA      (PWDATA        ),
        .ECOREVNUM   (4'b0          ),
        .PRDATA      (PRDATA_APBP2  ),
        .PREADY      (PREADY_APBP2  ),
        .PSLVERR     (PSLVERR_APBP2 ),

        .jy61p_uart_rx(JY61P_UART_RX)
    );

    assign JY61P_UART_VCC = 1'b1    ;
    assign JY61P_UART_GND = 1'b0    ;
    assign JY61P_UART_TX  = 1'bz    ;
//

/**********************APB4 SPI_FLASH******************************/
    apb_spi u_apb_spi(
        .PCLK     (clk),   // PCLK for timer operation
        .PCLKG    (clk),   // Gated clock
        .PRESETn  (cpuresetn),   // Reset
        .PSEL     (PSEL_APBP4),   // Device select
        .PADDR    (PADDR[15:0]),   // Address
        .PENABLE  (PENABLE),   // Transfer control
        .PWRITE   (PWRITE),   // Write control
        .PWDATA   (PWDATA),   // Write data
        .ECOREVNUM(4'b0),   // Engineering-change-order revision bits
        .PRDATA   (PRDATA_APBP4),   // Read data
        .PREADY   (PREADY_APBP4),   // Device ready
        .PSLVERR  (PSLVERR_APBP4),   // Device error response
        .SPI_CLK  (SOFT_SPI_CLK ),   //SPI clk
        .SPI_CS   (SOFT_SPI_CS  ),   //SPI cs
        .SPI_MOSI (SOFT_SPI_MOSI),   //SPI mosi
        .SPI_MISO (SOFT_SPI_MISO)    //SPI miso
    );
//

/**********************APB5 PS2_FLASH******************************/
    apb_pstwo u_apb_pstwo(
        .PCLK       (clk),   // PCLK for timer operation
        .PCLKG      (clk),   // Gated clock
        .PRESETn    (cpuresetn),   // Reset
        .PSEL       (PSEL_APBP5),   // Device select
        .PADDR      (PADDR[15:0]),   // Address
        .PENABLE    (PENABLE),   // Transfer control
        .PWRITE     (PWRITE),   // Write control
        .PWDATA     (PWDATA),   // Write data
        .ECOREVNUM  (4'b0),   // Engineering-change-order revision bits
        .PRDATA     (PRDATA_APBP5),   // Read data
        .PREADY     (PREADY_APBP5),   // Device ready
        .PSLVERR    (PSLVERR_APBP5),   // Device error response
        //PS2
        .PS2_CS     (PS2_CS )     ,
        .PS2_CLK    (PS2_CLK)     ,
        .PS2_DO     (PS2_DO )     ,
        .PS2_DI     (PS2_DI )
    );
//

/**********************APB6 CNN******************************/
//     apb_cnn u_apb_cnn(
//         .rstn       (RSTn       )   ,//系统复位
//         //
//         .clk_100m       (clk_100m       ),
//         .clk_100m_shift (clk_100m_shift ),
//         .clk_50m        (clk_50m        ),
//         .hdmi_clk       (hdmi_clk       ),//25MHz
//         .hdmi_clk_5     (hdmi_clk_5     ),//125MHz
//         .locked         (locked         ),
//         .locked_hdmi    (locked_hdmi    ),

//         //APB-bus
//         .PCLK       (clk        )   ,
//         .PCLKG      (clk        )   ,
//         .PRESETn    (cpuresetn  )   ,
//         .PSEL       (PSEL_APBP6 )   ,
//         .PADDR      (PADDR[15:0])   ,
//         .PENABLE    (PENABLE    )   ,
//         .PWRITE     (PWRITE     )   ,
//         .PWDATA     (PWDATA     )   ,
//         .ECOREVNUM  (4'b0       )   ,
//         .PRDATA     (PRDATA_APBP6)  ,
//         .PREADY     (PREADY_APBP6)  ,
//         .PSLVERR    (PSLVERR_APBP6) ,

//         // .one_hot    (one_hot    )   ,
//         //摄像头
//         .cam_pclk   (cam_pclk   )   ,
//         .cam_vsync  (cam_vsync  )   ,
//         .cam_href   (cam_href   )   ,
//         .cam_data   (cam_data   )   ,
//         .cam_rst_n  (cam_rst_n  )   ,
//         .cam_pwdn   (cam_pwdn   )   ,
//         .cam_scl    (cam_scl    )   ,
//         .cam_sda    (cam_sda    )   ,
//         //SDRAM 
//         .sdram_clk  (sdram_clk  )   ,
//         .sdram_cke  (sdram_cke  )   ,
//         .sdram_cs_n (sdram_cs_n )   ,
//         .sdram_ras_n(sdram_ras_n)   ,
//         .sdram_cas_n(sdram_cas_n)   ,
//         .sdram_we_n (sdram_we_n )   ,
//         .sdram_ba   (sdram_ba   )   ,
//         .sdram_dqm  (sdram_dqm  )   ,
//         .sdram_addr (sdram_addr )   ,
//         .sdram_data (sdram_data )   ,
//         //HDMI接口
//         .tmds_clk_p (cnn_tmds_clk_p ) ,    // TMDS 时钟通道
//         .tmds_clk_n (cnn_tmds_clk_n ) ,
//         .tmds_data_p(cnn_tmds_data_p) ,   // TMDS 数据通道
//         .tmds_data_n(cnn_tmds_data_n) 
// );

    ahb_cnn u_ahb_cnn(
        .rstn       (RSTn       )   ,//系统复位
        //pll
        .clk_100m       (clk_100m       ),
        .clk_100m_shift (clk_100m_shift ),
        .clk_50m        (clk_50m        ),
        .hdmi_clk       (hdmi_clk       ),
        .hdmi_clk_5     (hdmi_clk_5     ),
        .locked         (locked         ),
        .locked_hdmi    (locked_hdmi    ),

        //AHB-bus
        .HCLK           (clk                ),
        .HRESETn        (cpuresetn          ),
        .HSEL           (HSEL_AHBL1P3       ),
        .HADDR          (HADDR_AHBL1P3      ),
        .HTRANS         (HTRANS_AHBL1P3     ),
        .HSIZE          (HSIZE_AHBL1P3      ),
        .HPROT          (HPROT_AHBL1P3      ),
        .HWRITE         (HWRITE_AHBL1P3     ),
        .HWDATA         (HWDATA_AHBL1P3     ),
        .HREADY         (HREADY_AHBL1P3     ),

        .HREADYOUT      (HREADYOUT_AHBL1P3  ),
        .HRDATA         (HRDATA_AHBL1P3     ),
        .HRESP          (HRESP_AHBL1P3      ),

        //摄像头
        .cam_pclk   (cam_pclk   )   ,
        .cam_vsync  (cam_vsync  )   ,
        .cam_href   (cam_href   )   ,
        .cam_data   (cam_data   )   ,
        .cam_rst_n  (cam_rst_n  )   ,
        .cam_pwdn   (cam_pwdn   )   ,
        .cam_scl    (cam_scl    )   ,
        .cam_sda    (cam_sda    )   ,
        //SDRAM 
        .sdram_clk  (sdram_clk  )   ,
        .sdram_cke  (sdram_cke  )   ,
        .sdram_cs_n (sdram_cs_n )   ,
        .sdram_ras_n(sdram_ras_n)   ,
        .sdram_cas_n(sdram_cas_n)   ,
        .sdram_we_n (sdram_we_n )   ,
        .sdram_ba   (sdram_ba   )   ,
        .sdram_dqm  (sdram_dqm  )   ,
        .sdram_addr (sdram_addr )   ,
        .sdram_data (sdram_data )   ,
        //HDMI接口
        .tmds_clk_p (cnn_tmds_clk_p ) ,    // TMDS 时钟通道
        .tmds_clk_n (cnn_tmds_clk_n ) ,
        .tmds_data_p(cnn_tmds_data_p) ,   // TMDS 数据通道
        .tmds_data_n(cnn_tmds_data_n) 
    );

/**********************AHB 4 L2-0 LCD 0x50000000~0x5000ffff******************************/
    `ifdef ANLOGIC

    `else
        custom_ahb_lcd LCD(
            .HCLK                   (clk),
            .HRESETn                (cpuresetn),
            .HSEL                   (HSEL_AHBL2P0),
            .HADDR                  (HADDR_AHBL2P0),
            .HPROT                  (HPROT_AHBL2P0),
            .HSIZE                  (HSIZE_AHBL2P0),
            .HTRANS                 (HTRANS_AHBL2P0),
            .HWDATA                 (HWDATA_AHBL2P0),
            .HWRITE                 (HWRITE_AHBL2P0),
            .HRDATA                 (HRDATA_AHBL2P0),
            .HREADY                 (HREADY_AHBL2P0),
            .HREADYOUT              (HREADYOUT_AHBL2P0),
            .HRESP                  (HRESP_AHBL2P0[0]),
            .LCD_CS                 (LCD_CS),
            .LCD_RS                 (LCD_RS),
            .LCD_WR                 (LCD_WR),
            .LCD_RD                 (LCD_RD),
            .LCD_RST                (LCD_RST),
            .LCD_DATA               (LCD_DATA),
            .LCD_BL_CTR             (LCD_BL_CTR)
        );
        assign  HRESP_AHBL2P0[1] = 1'b0;
    `endif
//

/**********************AHB 4 L2-1&L2-2 PPU 0x50010000~0x5001ffff & 0x50020000~0x5002ffff******************************/
    topPPU PPU(
        .clk_50MHz          (clk                ),
        .clk_125MHz         (clk_125MHz         ),
        .clk_100MHz         (clk_100MHz         ),
        .clk_25p2MHz        (clk_25p2MHz        ),
        .rstn               (RSTn               ),
        //CPU AHB interface 对spriteRam进行写操作 0x50010000
        .SPRITE_HCLK        (clk                ),
        .SPRITE_HRESETn     (cpuresetn          ),
        .SPRITE_HSEL        (HSEL_AHBL2P1       ),
        .SPRITE_HADDR       (HADDR_AHBL2P1      ),
        .SPRITE_HTRANS      (HTRANS_AHBL2P1     ),
        .SPRITE_HSIZE       (HSIZE_AHBL2P1      ),
        .SPRITE_HPROT       (HPROT_AHBL2P1      ),
        .SPRITE_HWRITE      (HWRITE_AHBL2P1     ),
        .SPRITE_HWDATA      (HWDATA_AHBL2P1     ),
        .SPRITE_HREADY      (HREADY_AHBL2P1     ),
        .SPRITE_HREADYOUT   (HREADYOUT_AHBL2P1  ),
        .SPRITE_HRDATA      (HRDATA_AHBL2P1     ),
        .SPRITE_HRESP       (HRESP_AHBL2P1      ),
        //CPU AHB interface 对nameTable进行写操作 0x50020000
        .NAMETABLE_HCLK     (clk                ),
        .NAMETABLE_HRESETn  (cpuresetn          ),
        .NAMETABLE_HSEL     (HSEL_AHBL2P2       ),
        .NAMETABLE_HADDR    (HADDR_AHBL2P2      ),
        .NAMETABLE_HTRANS   (HTRANS_AHBL2P2     ),
        .NAMETABLE_HSIZE    (HSIZE_AHBL2P2      ),
        .NAMETABLE_HPROT    (HPROT_AHBL2P2      ),
        .NAMETABLE_HWRITE   (HWRITE_AHBL2P2     ),
        .NAMETABLE_HWDATA   (HWDATA_AHBL2P2     ),
        .NAMETABLE_HREADY   (HREADY_AHBL2P2     ),
        .NAMETABLE_HREADYOUT(HREADYOUT_AHBL2P2  ),
        .NAMETABLE_HRDATA   (HRDATA_AHBL2P2     ),
        .NAMETABLE_HRESP    (HRESP_AHBL2P2      ),
    
        .createPlaneIntr    (createPlaneIntr    ),
    
        .scrollEn           (scrollEn           ),
        .SPI_CLK            (HARD_SPI_CLK       ),
        .SPI_CS             (HARD_SPI_CS        ),
        .SPI_MOSI           (HARD_SPI_MOSI      ),
        .SPI_MISO           (HARD_SPI_MISO      ),
        `ifdef VGA
        //VGA PIN
        .hsync              (hsync              ),//输出行同步信号
        .vsync              (vsync              ),//输出场同步信号
        .rgb                (rgb                ),//输出像素点色彩信息
        `else
        //HDMI OUT PIN
        .tmds_clk_p         (tmds_clk_p         ),
        .tmds_clk_n         (tmds_clk_n         ),
        .tmds_data_p        (tmds_data_p        ),
        .tmds_data_n        (tmds_data_n        ),
        `endif
        //VGA中断信号
        .VGA_Intr           (VGA_Intr           )
    );
//
/**********************AHB 4 L2-3 APU 0x50030000~0x5003ffff******************************/
    ahb_apu APU(
            .HCLK		(clk                ),
            .HRESETn	(cpuresetn          ),
            .HSEL		(HSEL_AHBL2P3       ),
            .HADDR		(HADDR_AHBL2P3      ),
            .HPROT		(HPROT_AHBL2P3      ),
            .HSIZE		(HSIZE_AHBL2P3      ),
            .HTRANS		(HTRANS_AHBL2P3     ),
            .HWDATA		(HWDATA_AHBL2P3     ),
            .HWRITE		(HWRITE_AHBL2P3     ),
            .HRDATA		(HRDATA_AHBL2P3     ),
            .HREADY		(HREADY_AHBL2P3     ),
            .HREADYOUT	(HREADYOUT_AHBL2P3  ),
            .HRESP		(HRESP_AHBL2P3[0]   ),
            .mute_in    (4'b0000            ),
            .audio_out  (APU_OUT            ),

            .PULSE0INT  (PULSE0INT          ),
            .PULSE1INT  (PULSE1INT          ),
            .TRIANGLEINT(TRIANGLEINT        ),
            .NOISEINT   (NOISEINT           )
    );
    assign  HRESP_AHBL2P3[1] = 1'b0;

    assign APU_VCC = 1'b1 ;
    assign APU_GND = 1'b0 ;
//

endmodule
