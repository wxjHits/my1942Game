`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ValentineHP
// 
// Create Date: 2023/05/10 17:45:28
// Design Name: 
// Module Name: FIR_Filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIR_Filter(

    input       clk,
    input       rst_n,

    input       fir_filter_req,
    output      fir_filter_ack,

    input signed[31:0]      filter_data_in,
    output signed[31:0]     filter_data_out
);




reg signed[31:0]    filter_data_reg0;
reg signed[31:0]    filter_data_reg1;
reg signed[31:0]    filter_data_reg2;
reg signed[31:0]    filter_data_reg3;

reg signed[31:0]    filter_data_out_reg;      

reg     filter_delay;

assign filter_data_out  = filter_data_out_reg;
assign fir_filter_ack   = (filter_delay == 1'b1) ? 1'b1 : 1'b0;


always@(posedge clk or negedge rst_n)
begin
    if( rst_n == 1'b0)
        filter_delay <= 1'b0;
    else
        filter_delay <= fir_filter_req;

end

always@(posedge clk or negedge rst_n)
begin
    if( rst_n == 1'b0)
    begin
        filter_data_reg0 <= 'd0;
        filter_data_reg1 <= 'd0;
        filter_data_reg2 <= 'd0;
        filter_data_reg3 <= 'd0;
    end
    else if(fir_filter_req == 1'b1)
    begin
        filter_data_reg0 <= filter_data_in;
        filter_data_reg1 <= filter_data_reg0;
        filter_data_reg2 <= filter_data_reg1;
        filter_data_reg3 <= filter_data_reg2;
    end
    else
    begin
        filter_data_reg0 <= filter_data_reg0 ;
        filter_data_reg1 <= filter_data_reg1 ;
        filter_data_reg2 <= filter_data_reg2 ;
        filter_data_reg3 <= filter_data_reg3 ;
    end
end



always@(posedge clk or negedge rst_n)
begin
    if( rst_n == 1'b0)
        filter_data_out_reg <= 'd0;
    else if( filter_delay == 1'b1)
        filter_data_out_reg <= ( filter_data_reg0 + filter_data_reg1 + filter_data_reg2 + filter_data_reg3 ) >>> 2;
    else
        filter_data_out_reg <= filter_data_out_reg;
end

endmodule
