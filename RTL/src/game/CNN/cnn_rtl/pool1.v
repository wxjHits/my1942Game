// 第一个池化层
module pool1(
    input clk,
    input rst_n,

    input   [16*6-1:0] data_in,
    input   data_in_valid,


    output  [16*6-1:0] data_out,
    output   data_out_valid
    );

reg [4:0]   x_cnt;
reg [4:0]   y_cnt;
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        x_cnt <= 0;
    else if(data_in_valid && x_cnt == 'd23 )
        x_cnt <= 0;
    else if(data_in_valid)
        x_cnt <=x_cnt +1'b1;
end
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        y_cnt <= 0;
    else if(data_in_valid && x_cnt == 'd23 && y_cnt == 'd23  )
        y_cnt <= 0;
    else if(data_in_valid && x_cnt == 'd23 )
        y_cnt <=y_cnt +1'b1;
end
//==================== delay data_in =============
reg [16*6-1:0] delay_data_in;
always@(posedge clk)
        delay_data_in<=data_in;
//==================== prepare for ram =============
wire    [15:0] wr_data[0:5];
wire    [15:0] rd_data[0:5];
wire                wr_en;
reg     [4:0]           wr_addr;
reg     [4:0]           rd_addr;
assign wr_en = x_cnt >0;
genvar k;
generate
    for (k=0;k<6;k=k+1)begin
        assign wr_data[k] = ( data_in[(k+1)*16-1:k*16] > delay_data_in[(k+1)*16-1:k*16])?data_in[(k+1)*16-1:k*16]:delay_data_in[(k+1)*16-1:k*16];
    end
endgenerate

wire [4:0]  rd_addr_pre2 = wr_addr +2;
always@(posedge clk,negedge rst_n)begin
    if(~rst_n)begin
        wr_addr <=0;
        rd_addr <= 0;
    end
    else if(data_in_valid )begin
        if(wr_addr == 'd23)
            wr_addr<=0;
        else
            wr_addr <= wr_addr +1'b1;

        if(rd_addr_pre2 > 'd23)
            rd_addr <= rd_addr_pre2-'d24;
        else
            rd_addr <= rd_addr_pre2;
    end
end

generate
for (k=0;k<6;k=k+1)begin
linebuffer
#(
    16,5,24
)
pool1_data_linebuffer_U (
    .clkw(clk),    // input wire clka
    .w_en(wr_en),      // input wire [0 : 0] wea
    .waddr(wr_addr),  // input wire [4 : 0] addra
    .din(wr_data[k]),    // input wire [30 : 0] dina
    .r_en(1'b1),
    .clkr(clk),    // input wire clkb
    .raddr(rd_addr),  // input wire [4 : 0] addrb
    .dout(rd_data[k])  // output wire [30 : 0] doutb
);
end
endgenerate

generate
    for (k=0;k<6;k=k+1)begin
        assign data_out[(k+1)*16-1:k*16] = ( rd_data[k] > wr_data[k] )?rd_data[k] :wr_data[k];
    end
endgenerate

assign data_out_valid = ( x_cnt[0:0]==1 &&  y_cnt[0:0]==1)?1'b1:1'b0;

endmodule
