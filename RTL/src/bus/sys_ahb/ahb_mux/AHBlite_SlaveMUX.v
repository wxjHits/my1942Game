module AHBlite_SlaveMUX (

    input HCLK,
    input HRESETn,
    input HREADY,

    //port 4
    input P4_HSEL,
    input P4_HREADYOUT,
    input P4_HRESP,
    input [31:0] P4_HRDATA,

    //port 5
    input P5_HSEL,
    input P5_HREADYOUT,
    input P5_HRESP,
    input [31:0] P5_HRDATA,

    //port 6
    input P6_HSEL,
    input P6_HREADYOUT,
    input P6_HRESP,
    input [31:0] P6_HRDATA,

    //port 7
    input P7_HSEL,
    input P7_HREADYOUT,
    input P7_HRESP,
    input [31:0] P7_HRDATA,

    //output
    output wire HREADYOUT,
    output wire HRESP,
    output wire [31:0] HRDATA
);

//reg the hsel
reg [3:0] hsel_reg;

always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) hsel_reg <= 4'b0000;
    else if(HREADY) hsel_reg <= {P4_HSEL,P5_HSEL,P6_HSEL,P7_HSEL};
end

//hready mux
reg hready_mux;

always@(*) begin
    case(hsel_reg)
    4'b0001 : begin hready_mux = P7_HREADYOUT;end
    4'b0001 : begin hready_mux = P6_HREADYOUT;end
    4'b0001 : begin hready_mux = P5_HREADYOUT;end
    4'b0001 : begin hready_mux = P4_HREADYOUT;end
    default : begin hready_mux = 1'b1;end
    endcase
end

assign HREADYOUT = hready_mux;

//hresp mux
reg hresp_mux;

always@(*) begin
    case(hsel_reg)
    4'b0001 : begin hresp_mux = P7_HRESP;end
    4'b0001 : begin hresp_mux = P6_HRESP;end
    4'b0001 : begin hresp_mux = P5_HRESP;end
    4'b0001 : begin hresp_mux = P4_HRESP;end
    default : begin hresp_mux = 1'b0;end
    endcase
end

assign HRESP = hresp_mux;

//hrdata mux
reg [31:0] hrdata_mux;

always@(*) begin
    case(hsel_reg)
    4'b0001 : begin hrdata_mux = P7_HRDATA;end
    4'b0001 : begin hrdata_mux = P6_HRDATA;end
    4'b0001 : begin hrdata_mux = P5_HRDATA;end
    4'b0001 : begin hrdata_mux = P4_HRDATA;end
    default : begin hrdata_mux = 32'b0;end
    endcase
end

assign HRDATA = hrdata_mux;

endmodule 