
//缓存第一个池化层输出的数据，串行输入第二个卷积层
module p2_data_fifo(
        input               clk,
        input               rst_n,
        input               fc_ready,

        input [16-1:0]   data_in,
        input               data_in_valid,
        output [16-1:0]  data_out,
        output reg          data_out_valid
    );

//=======================================================
reg rd_en;
reg [9:0] cnt;
reg [9:0] valid_data_out_cnt;
reg [9:0] out_cnt;
wire fifo_read;
wire fifo_full;
wire fifo_empty;
assign fifo_read = (data_out_valid && fc_ready) ? 0 : (rd_en && fc_ready);
always@(posedge clk or negedge rst_n)begin
    if(~rst_n)
        out_cnt<=0;
    else if(out_cnt == 'd256)
        out_cnt <= 'd0;
    else if(data_out_valid)//cnt没有复位?
        out_cnt<=out_cnt+1'b1;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_en <= 'd0;
    end
    else begin
        if(cnt == 'd245)
            rd_en <= 'd1;
        else if(out_cnt == 'd256) begin
            rd_en <= 'd0;
        end
    end
end
always@(posedge clk,negedge rst_n)begin
    if(~rst_n)
        cnt<=0;
    else if(cnt == 'd256)
        cnt <= 'd0;
    else if(data_in_valid)//cnt没有复位?
        cnt<=cnt+1'b1;
end
always@(posedge clk,negedge rst_n)begin
    if(~rst_n)
        valid_data_out_cnt<=0;
    else if(valid_data_out_cnt == 'd256) begin
        valid_data_out_cnt <= 'd0;
    end
    else if(data_out_valid==1)
        valid_data_out_cnt<=valid_data_out_cnt+1'b1;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_out_valid <= 1'b0;
    else begin
        if(data_out_valid == 1'b1)
            data_out_valid <= 1'b0;
        else if(((rd_en)&&(valid_data_out_cnt>=0 &&valid_data_out_cnt<256)&&fc_ready))
            data_out_valid <= 1'b1;
    end
end

fcfifo cnnfifo2_u(
    .rst       (~rst_n          ),//asynchronous port,active hight
    .clk       (clk             ),//common clock for write and read
    .we        (data_in_valid   ),//write enable,active hight
    .di        (data_in         ),//write data
    .re        (fifo_read       ),//read enable,active hight
    .dout      (data_out        ),//read data
    .valid     (valid           ),//read data valid flag
    .full_flag (fifo_full       ),//fifo full flag
    .empty_flag(fifo_empty      ),//fifo empty flag
    .afull     (                ),//fifo almost full flag
    .aempty    (                ),//fifo almost empty flag
    .wrusedw   (                ),//stored data number in fifo
    .rdusedw   (                ) //available data number for read
);

endmodule
