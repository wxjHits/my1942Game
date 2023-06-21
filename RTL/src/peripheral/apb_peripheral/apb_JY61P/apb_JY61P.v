/*
    JY61P串口接收陀螺仪
    BASE_ADDR 0x40002000
    0x000 R    JY61P_ROLL   
    0x004 R    JY61P_PITCH  
    0x008 R    JY61P_YAW    
*/
module apb_JY61P(
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

    input  wire         jy61p_uart_rx
);
    
/***例化***/
    wire signed [15:0]  Roll    ;
    wire signed [15:0]  Pitch   ;
    wire signed [15:0]  Yaw     ;

    JY61P_uart_data u_JY61P_uart_data(
        .clk            (PCLK           ),
        .rstn           (PRESETn        ),
        .jy61p_uart_rx  (jy61p_uart_rx  ),
        .Roll           (Roll           ),
        .Pitch          (Pitch          ),
        .Yaw            (Yaw            ) 
    );

/***APB读写(只有读操作)***/
    wire    read_enable     ;
    assign  read_enable  = PSEL & PENABLE & (~PWRITE);

    reg [31:0] read_mux_le;
    reg [31:0] read_mux_word;

    always@(*)begin
        case(PADDR[11:0])
            12'h000:read_mux_le<={{16{1'b0}}, Roll };
            12'h004:read_mux_le<={{16{1'b0}}, Pitch};
            12'h008:read_mux_le<={{16{1'b0}}, Yaw  };
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

endmodule