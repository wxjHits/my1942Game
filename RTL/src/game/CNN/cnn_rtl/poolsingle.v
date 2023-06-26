module poolsingle
#(
    parameter DATA_W = 32,
    parameter IMG_IN_W = 24,
    parameter BUFFER_ADDR_W = $clog2(IMG_IN_W)
)
(
    input clk,
    input rst_n,

    input   [DATA_W-1:0] data_in,
    input   data_in_valid,


    output  reg [DATA_W-1:0] data_out,
    output  reg data_out_valid
    );
wire [DATA_W-1:0] w_data_out;
reg [BUFFER_ADDR_W-1:0] x_cnt;
reg [BUFFER_ADDR_W-1:0] y_cnt;
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        x_cnt <= 0;
    else if(data_in_valid && x_cnt == (IMG_IN_W-1) )
        x_cnt <= 0;
    else if(data_in_valid)
        x_cnt <=x_cnt +1'b1;
end
always@(posedge clk ,negedge rst_n)begin
    if(~rst_n)
        y_cnt <= 0;
    else if(data_in_valid && x_cnt == (IMG_IN_W-1) && y_cnt == (IMG_IN_W-1)  )
        y_cnt <= 0;
    else if(data_in_valid && x_cnt == (IMG_IN_W-1) )
        y_cnt <=y_cnt +1'b1;
end
//==================== delay data_in =============
reg [DATA_W-1:0] delay_data_in;
always@(posedge clk) begin
    if(data_in_valid)
        delay_data_in <= data_in;
end
//==================== prepare for ram =============
wire    [DATA_W-1:0] wr_data;
wire    [DATA_W-1:0] rd_data;
wire                wr_en;
reg     [BUFFER_ADDR_W-1:0]           wr_addr;
reg     [BUFFER_ADDR_W-1:0]           rd_addr;
assign wr_en = data_in_valid;
assign wr_data = (data_in > delay_data_in) ? data_in : delay_data_in;

wire [BUFFER_ADDR_W-1:0]  rd_addr_pre2 = wr_addr +2;
always@(posedge clk,negedge rst_n)begin
    if(~rst_n)begin
        wr_addr <=0;
        rd_addr <= 0;
    end
    else if(data_in_valid )begin
        if(wr_addr == (IMG_IN_W-1))
            wr_addr<=0;
        else
            wr_addr <= wr_addr +1'b1;

        if(rd_addr == (IMG_IN_W-1))
            rd_addr <= 0;
        else
            rd_addr <= rd_addr + 1;
    end
end

linebuffer
#(
    DATA_W,(BUFFER_ADDR_W),IMG_IN_W
)
pool1_data_linebuffer_U (
    .clkw(clk),    // input wire clka
    .w_en(wr_en),      // input wire [0 : 0] wea
    .waddr(wr_addr),  // input wire [4 : 0] addra
    .din(wr_data),    // input wire [30 : 0] dina
    .r_en(1'b1),
    .clkr(clk),    // input wire clkb
    .raddr(rd_addr),  // input wire [4 : 0] addrb
    .dout(rd_data)  // output wire [30 : 0] doutb
);

assign w_data_out = ( rd_data > wr_data )?rd_data :wr_data;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_out_valid <= 1'b0;
    else begin
        if(data_out_valid == 1'b1)
            data_out_valid <= 1'b0;
        else if(y_cnt[0] == 1 && x_cnt[0] == 1 && data_in_valid)
            data_out_valid <= 1'b1;
    end
end
//assign data_out_valid = data_in_valid &&  y_cnt[0] == 1 && x_cnt[0] == 1;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_out <= 'd0;
    else
        data_out <= w_data_out;
end

endmodule
