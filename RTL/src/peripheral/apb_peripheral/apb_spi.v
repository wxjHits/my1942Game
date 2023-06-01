/****************************/
//作者:Wei Xuejing
//邮箱:2682152871@qq.com
//描述:apb_spi
//时间:2022.11.09
/****************************/
// BASE_ADDR:0x40006000
// 0x00 RW   [0]   SPI_CS
// 0x04 RW   [7:0] CLK_DIV
// 0x08 RW   [7:0] DATA_TX
// 0x0C RW   [0]   TX_REQ
// 0x10 R    [7:0] DATA_RX
// 0x14 R    [0]   SPI_READY
module apb_spi(
    input  wire        PCLK     ,   // PCLK for timer operation
    input  wire        PCLKG    ,   // Gated clock
    input  wire        PRESETn  ,   // Reset

    input  wire        PSEL     ,   // Device select
    input  wire [15:0] PADDR    ,   // Address
    input  wire        PENABLE  ,   // Transfer control
    input  wire        PWRITE   ,   // Write control
    input  wire [31:0] PWDATA   ,   // Write data

    input  wire [ 3:0] ECOREVNUM,   // Engineering-change-order revision bits

    output wire [31:0] PRDATA   ,   // Read data
    output wire        PREADY   ,   // Device ready
    output wire        PSLVERR  ,   // Device error response

    output wire        SPI_CLK  ,   //SPI clk
    output wire        SPI_CS   ,   //SPI cs
    output wire        SPI_MOSI ,   //SPI mosi
    input  wire        SPI_MISO     //SPI miso
); 

    // Signals for read/write controls
    wire          read_enable       ;
    wire          write_enable      ;
    wire          write_enable00    ;
    wire          write_enable04    ;
    wire          write_enable08    ;
    wire          write_enable0c    ;

    reg     [7:0] read_mux_byte0    ;
    reg     [7:0] read_mux_byte0_reg;
    reg    [31:0] read_mux_word     ;

    // Signals for Control registers
    reg           reg_cs            ;
    reg    [ 7:0] reg_clk_div       ;
    reg    [ 7:0] reg_tx_data       ;
    reg           reg_tx_req        ;

    // Internal signals
    wire          spi_ready         ;
    wire   [ 7:0] spi_rx_data       ;

// ila_0 u_ila_0 (
// 	.clk(PCLK), // input wire clk

// 	.probe0(reg_cs), // input wire [0:0]  probe0  
// 	.probe1(reg_clk_div), // input wire [7:0]  probe1 
// 	.probe2(reg_tx_data), // input wire [7:0]  probe2 
// 	.probe3(reg_tx_req), // input wire [0:0]  probe3 
// 	.probe4(spi_ready), // input wire [0:0]  probe4 
// 	.probe5(spi_rx_data), // input wire [7:0]  probe5 
// 	.probe6(SPI_CLK ), // input wire [0:0]  probe6 
// 	.probe7(SPI_CS  ), // input wire [0:0]  probe7 
// 	.probe8(SPI_MOSI), // input wire [0:0]  probe8 
// 	.probe9(SPI_MISO) // input wire [0:0]  probe9
// );

    // Start of main code
    // Read and write control signals
    assign  read_enable  = PSEL & (~PWRITE); // assert for whole APB read transfer
    assign  write_enable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer
    assign  write_enable00 = write_enable & (PADDR[11:2] == 10'h000);
    assign  write_enable04 = write_enable & (PADDR[11:2] == 10'h001);
    assign  write_enable08 = write_enable & (PADDR[11:2] == 10'h002);
    assign  write_enable0c = write_enable & (PADDR[11:2] == 10'h003);
// Write operations
    // cs register
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            reg_cs <= 1'b1;
        else if (write_enable00)
            reg_cs <= PWDATA[0:0];
    end

    // clk_div Value register
    always @(posedge PCLK or negedge PRESETn)begin
        if (~PRESETn)
            reg_clk_div <= {8{1'b0}};
        else if (write_enable04)
            reg_clk_div <= PWDATA[7:0];
    end

    // tx data Value register
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            reg_tx_data <= {8{1'b0}};
        else if (write_enable08)
            reg_tx_data <= PWDATA[7:0];
    end

    // tx req Value register
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            reg_tx_req <= 1'b0;
        else if (write_enable0c)
            reg_tx_req <= PWDATA[0:0];
    end

// Read operation, partitioned into two parts to reduce gate counts
// and improve timing
    // lower 8 bits -registered. Current value register mux not done here
    // because the value can change every cycle
    always @(PADDR or reg_cs or reg_clk_div or reg_tx_data or reg_tx_req or spi_rx_data or spi_ready)begin
        if(PADDR[11:5] == 7'h00) begin
            case (PADDR[4:2])
                3'h0: read_mux_byte0 =  {{7{1'b0}}, reg_cs}     ;
                3'h1: read_mux_byte0 =  reg_clk_div             ;
                3'h2: read_mux_byte0 =  reg_tx_data             ;
                3'h3: read_mux_byte0 =  {{7{1'b0}}, reg_tx_req} ;
                3'h4: read_mux_byte0 =  spi_rx_data             ;
                3'h5: read_mux_byte0 =  {{7{1'b0}}, spi_ready}  ;
                default:  read_mux_byte0 =   {8{1'bx}};// x propagation
            endcase
        end
        else
            read_mux_byte0 =   {8{1'b0}};     //default read out value
    end

    // Register read data
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            read_mux_byte0_reg <= {8{1'b0}};
        else if (read_enable)begin
            read_mux_byte0_reg <= read_mux_byte0;     //default read out value
        end
    end

    // // Second level of read mux
    // always @(PADDR or read_mux_byte0_reg or reg_curr_val or reg_reload_val)begin
    //     if(PADDR[11:5] == 7'h00) begin
    //         case (PADDR[4:2])
    //             3'b001:   read_mux_word = {reg_curr_val[31:0]};
    //             3'b010:   read_mux_word = {reg_reload_val[31:8],read_mux_byte0_reg};
    //             3'b100:   read_mux_word = {reg_inverse_val[31:8],read_mux_byte0_reg};
    //             3'b000,3'b011:  read_mux_word = {{24{1'b0}} ,read_mux_byte0_reg};
    //             default : read_mux_word = {32{1'bx}};
    //         endcase
    //     end
    //     else
    //         read_mux_word = {{24{1'b0}} ,read_mux_byte0_reg};
    // end

    // Output read data to APB
    assign PRDATA  = read_enable ?  {24'b0,read_mux_byte0_reg}: 32'b0;
    assign PREADY  = 1'b1; // Always ready
    assign PSLVERR = 1'b0; // Always okay

    // SPI instance
    spi u_spi(
        .clk        (PCLK       ),   //系统时钟
        .rstn       (PRESETn    ),   //系统复位型号

        .clk_div    (reg_clk_div),   //时钟分频 4~255
        .cs         (reg_cs     ),   //片选信号

        .tx_req     (reg_tx_req ),   //发送请求信号
        .data_tx    (reg_tx_data),   //待发送的数据
        .data_rx    (spi_rx_data),   //接受到的数据
        .spi_ready  (spi_ready  ),   //SPI一次发送完成信号

        .SPI_CLK    (SPI_CLK    ),
        .SPI_CS     (SPI_CS     ),
        .SPI_MOSI   (SPI_MOSI   ),
        .SPI_MISO   (SPI_MISO   )
);

endmodule