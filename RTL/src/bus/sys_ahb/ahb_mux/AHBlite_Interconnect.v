module AHBlite_Interconnect(

    // CLK & RST
    input   wire    HCLK,
    input   wire    HRESETn,

    // CORE SIDE
    input   wire            HSEL,
    input   wire    [31:0]  HADDR,
    input   wire    [2:0]   HBURST,
    input   wire            HMASTLOCK,
    input   wire    [3:0]   HPROT,
    input   wire    [2:0]   HSIZE,
    input   wire    [1:0]   HTRANS,
    input   wire    [31:0]  HWDATA,
    input   wire            HWRITE,
    output  wire            HREADY,
    output  wire    [31:0]  HRDATA,
    output  wire            HRESP,

    // Peripheral 4
    output  wire            HSEL_P4,
    output  wire    [31:0]  HADDR_P4,
    output  wire    [2:0]   HBURST_P4,
    output  wire            HMASTLOCK_P4,
    output  wire    [3:0]   HPROT_P4,
    output  wire    [2:0]   HSIZE_P4,
    output  wire    [1:0]   HTRANS_P4,
    output  wire    [31:0]  HWDATA_P4,
    output  wire            HWRITE_P4,
    output  wire            HREADY_P4,
    input   wire            HREADYOUT_P4,
    input   wire    [31:0]  HRDATA_P4,
    input   wire            HRESP_P4,

    // Peripheral 5
    output  wire            HSEL_P5,
    output  wire    [31:0]  HADDR_P5,
    output  wire    [2:0]   HBURST_P5,
    output  wire            HMASTLOCK_P5,
    output  wire    [3:0]   HPROT_P5,
    output  wire    [2:0]   HSIZE_P5,
    output  wire    [1:0]   HTRANS_P5,
    output  wire    [31:0]  HWDATA_P5,
    output  wire            HWRITE_P5,
    output  wire            HREADY_P5,
    input   wire            HREADYOUT_P5,
    input   wire    [31:0]  HRDATA_P5,
    input   wire            HRESP_P5,

    // Peripheral 6
    output  wire            HSEL_P6,
    output  wire    [31:0]  HADDR_P6,
    output  wire    [2:0]   HBURST_P6,
    output  wire            HMASTLOCK_P6,
    output  wire    [3:0]   HPROT_P6,
    output  wire    [2:0]   HSIZE_P6,
    output  wire    [1:0]   HTRANS_P6,
    output  wire    [31:0]  HWDATA_P6,
    output  wire            HWRITE_P6,
    output  wire            HREADY_P6,
    input   wire            HREADYOUT_P6,
    input   wire    [31:0]  HRDATA_P6,
    input   wire            HRESP_P6,

    // Peripheral 7
    output  wire            HSEL_P7,
    output  wire    [31:0]  HADDR_P7,
    output  wire    [2:0]   HBURST_P7,
    output  wire            HMASTLOCK_P7,
    output  wire    [3:0]   HPROT_P7,
    output  wire    [2:0]   HSIZE_P7,
    output  wire    [1:0]   HTRANS_P7,
    output  wire    [31:0]  HWDATA_P7,
    output  wire            HWRITE_P7,
    output  wire            HREADY_P7,
    input   wire            HREADYOUT_P7,
    input   wire    [31:0]  HRDATA_P7,
    input   wire            HRESP_P7
);

// Public signals--------------------------------
//-----------------------------------------------

// HADDR
assign  HADDR_P4    =   HADDR;
assign  HADDR_P5    =   HADDR;
assign  HADDR_P6    =   HADDR;
assign  HADDR_P7    =   HADDR;

// HBURST
assign  HBURST_P4   =   HBURST;
assign  HBURST_P5   =   HBURST;
assign  HBURST_P6   =   HBURST;
assign  HBURST_P7   =   HBURST;

// HMASTLOCK
assign HMASTLOCK_P4 =   HMASTLOCK;
assign HMASTLOCK_P5 =   HMASTLOCK;
assign HMASTLOCK_P6 =   HMASTLOCK;
assign HMASTLOCK_P7 =   HMASTLOCK;

// HPROT
assign HPROT_P4     =   HPROT;
assign HPROT_P5     =   HPROT;
assign HPROT_P6     =   HPROT;
assign HPROT_P7     =   HPROT;

// HSIZE
assign HSIZE_P4     =   HSIZE;
assign HSIZE_P5     =   HSIZE;
assign HSIZE_P6     =   HSIZE;
assign HSIZE_P7     =   HSIZE;

// HTRANS
assign HTRANS_P4     =   HTRANS;
assign HTRANS_P5     =   HTRANS;
assign HTRANS_P6     =   HTRANS;
assign HTRANS_P7     =   HTRANS;

// HWDATA
assign HWDATA_P4     =   HWDATA;
assign HWDATA_P5     =   HWDATA;
assign HWDATA_P6     =   HWDATA;
assign HWDATA_P7     =   HWDATA;

// HWRITE
assign HWRITE_P4     =   HWRITE;
assign HWRITE_P5     =   HWRITE;
assign HWRITE_P6     =   HWRITE;
assign HWRITE_P7     =   HWRITE;

// HREADY
assign HREADY_P4     =   HREADY;
assign HREADY_P5     =   HREADY;
assign HREADY_P6     =   HREADY;
assign HREADY_P7     =   HREADY;

// Decoder---------------------------------------
//-----------------------------------------------

AHBlite_Decoder Decoder(
    .HSEL       (HSEL),
    .HADDR      (HADDR),
    .P4_HSEL    (HSEL_P4),
    .P5_HSEL    (HSEL_P5),
    .P6_HSEL    (HSEL_P6),
    .P7_HSEL    (HSEL_P7)
);

// Slave MUX-------------------------------------
//-----------------------------------------------
AHBlite_SlaveMUX SlaveMUX(

    // CLOCK & RST
    .HCLK           (HCLK),
    .HRESETn        (HRESETn),
    .HREADY         (HREADY),

    //P4
    .P4_HSEL        (HSEL_P4),
    .P4_HREADYOUT   (HREADYOUT_P4),
    .P4_HRESP       (HRESP_P4),
    .P4_HRDATA      (HRDATA_P4),

    //P5
    .P5_HSEL        (HSEL_P5),
    .P5_HREADYOUT   (HREADYOUT_P5),
    .P5_HRESP       (HRESP_P5),
    .P5_HRDATA      (HRDATA_P5),

    //P6
    .P6_HSEL        (HSEL_P6),
    .P6_HREADYOUT   (HREADYOUT_P6),
    .P6_HRESP       (HRESP_P6),
    .P6_HRDATA      (HRDATA_P6),

    //P7
    .P7_HSEL        (HSEL_P7),
    .P7_HREADYOUT   (HREADYOUT_P7),
    .P7_HRESP       (HRESP_P7),
    .P7_HRDATA      (HRDATA_P7),

    .HREADYOUT      (HREADY),
    .HRESP          (HRESP),
    .HRDATA         (HRDATA)
);

endmodule