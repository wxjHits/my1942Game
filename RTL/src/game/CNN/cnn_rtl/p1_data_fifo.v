//缓存第一个池化层输出的数据，串行输入第二个卷积层
module p1_data_fifo(
        input               clk,
        input               rst_n,
        input               c2_ready,

        input [6*16-1:0]   data_in,
        input               data_in_valid,
        output [6*16-1:0]  data_out,
        output reg          data_out_valid
    );

//=======================================================
reg rd_en;
reg [9:0] cnt;
reg [9:0] out_cnt;
reg [9:0] valid_data_out_cnt;
wire data_out_valid_pre;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_en <= 'd0;
    end
    else begin
        if(cnt == 'd144)
            rd_en <= 'd1;
        else if(out_cnt == 'd144)
            rd_en <= 'd0;
    end
end
always@(posedge clk,negedge rst_n)begin
    if(~rst_n)
        cnt<=0;
    else if(cnt == 'd144)
        cnt <= 'd0;
    else if(data_in_valid)//cnt没有复位?
        cnt<=cnt+1'b1;
end
always@(posedge clk,negedge rst_n)begin
    if(~rst_n)
        out_cnt<=0;
    else if(out_cnt == 'd144)
        out_cnt <= 'd0;
    else if(data_out_valid)//cnt没有复位?
        out_cnt<=out_cnt+1'b1;
end
always@(posedge clk,negedge rst_n)begin
    if(~rst_n)
        valid_data_out_cnt<=0;
    else if(valid_data_out_cnt == 'd144)
        valid_data_out_cnt <= 'd0;
    else if(data_out_valid_pre==1)
        valid_data_out_cnt<=valid_data_out_cnt+1'b1;
end
assign data_out_valid_pre = ((rd_en)&&(valid_data_out_cnt>=0 &&valid_data_out_cnt<144)&&c2_ready)?1'b1:1'b0;

always@(posedge clk)
    data_out_valid <= data_out_valid_pre;

/*p1_fifo U_p1_fifo ( //depth:256
  .clk(clk),                  // input wire clk
  .srst(~rst_n),                // input wire srst
  .din(data_in),                  // input wire [191 : 0] din
  .wr_en(data_in_valid),              // input wire wr_en
  .rd_en(rd_en&c2_ready),              // input wire rd_en
  .dout(data_out),                // output wire [191 : 0] dout
  .full(),                // output wire full
  .almost_full(),  // output wire almost_full
  .empty()              // output wire empty
);*/
cnnfifo1 cnnfifo1_u(
    .rst       (~rst_n          ),//asynchronous port,active hight
    .clk       (clk             ),//common clock for write and read
    .we        (data_in_valid   ),//write enable,active hight
    .di        (data_in         ),//write data
    .re        (rd_en&c2_ready  ),//read enable,active hight
    .dout      (data_out        ),//read data
    .valid     (valid           ),//read data valid flag
    .full_flag (                ),//fifo full flag
    .empty_flag(                ),//fifo empty flag
    .afull     (                ),//fifo almost full flag
    .aempty    (                ),//fifo almost empty flag
    .wrusedw   (                ),//stored data number in fifo
    .rdusedw   (                ) //available data number for read
);

endmodule
