module capture_reshape_pool (
    input       pclk            ,
    input       cnnclk          ,
    input       rst_n           ,
    input       bin_data        ,
    input       gray_en         ,
    output reg  data_out_valid  ,
    output      bin_data_out    ,

    output      fifo_wr_en
);
reg data_in_valid;
reg [4:0] reshape_cnt;//8取1行
reg [4:0] reshape_cnt_col;
//wire fifo_wr_en;
reg r_gray_en;//上升沿检测
wire pos_gray_en;
//reg [10:0]cnt_gray_en;
always @(posedge pclk) r_gray_en <= gray_en;
assign pos_gray_en = ~r_gray_en && gray_en;

//有效数据(2clk一个)
always @(posedge pclk or negedge rst_n) begin
    if(!rst_n) begin
        data_in_valid <= 'd0;
    end
    else begin
        if(data_in_valid)
            data_in_valid <= 'd0;
        else if(!data_in_valid && gray_en) begin
            data_in_valid <= 'd1;
        end
    end
end
//maxpool
localparam DATA_WIDTH = 1;
localparam IMG_IN_W1 = 224;
localparam BUFFER_ADDR_W1 = $clog2(IMG_IN_W1);
localparam IMG_IN_W2 = IMG_IN_W1/2;
localparam BUFFER_ADDR_W2 = $clog2(IMG_IN_W2);
localparam IMG_IN_W3 = IMG_IN_W2/2;
localparam BUFFER_ADDR_W3 = $clog2(IMG_IN_W3);
wire maxpool1_out;
wire maxpool2_out;
wire maxpool3_out;
wire maxpool1_out_valid;
wire maxpool2_out_valid;
wire maxpool3_out_valid;
poolsingle
#(
	DATA_WIDTH,IMG_IN_W1,BUFFER_ADDR_W1
)
maxpool1(
	.clk           (pclk           				),
	.rst_n         (rst_n         				),
	.data_in       (bin_data      				),
	.data_in_valid (data_in_valid			    ),
	.data_out      (maxpool1_out		        ),
	.data_out_valid(maxpool1_out_valid	        )
);
poolsingle
#(
	DATA_WIDTH,IMG_IN_W2,BUFFER_ADDR_W2
)
maxpool2(
	.clk           (pclk           				),
	.rst_n         (rst_n         				),
	.data_in       (bin_data      				),
	.data_in_valid (maxpool1_out_valid			),
	.data_out      (maxpool2_out		        ),
	.data_out_valid(maxpool2_out_valid	        )
);
poolsingle
#(
	DATA_WIDTH,IMG_IN_W3,BUFFER_ADDR_W3
)
maxpool3(
	.clk           (pclk           				),
	.rst_n         (rst_n         				),
	.data_in       (bin_data      				),
	.data_in_valid (maxpool2_out_valid			),
	.data_out      (maxpool3_out		        ),
	.data_out_valid(maxpool3_out_valid	        )
);
//fifo写使能
assign fifo_wr_en = maxpool3_out_valid;
reg fifo_rd_en;
reg [10:0] out_cnt;
wire [10:0] data_used;//存进fifo的数量
wire [10:0] data_stored;

always @(posedge cnnclk or negedge rst_n) begin
    if(!rst_n) begin
        out_cnt <= 'd0;
    end
    else begin
        if(out_cnt == 'd784)
            out_cnt <= 'd0;
        else if(data_stored == 'd784)
            out_cnt <= out_cnt + 1'b1;
        else if(out_cnt != 'd0) begin
            out_cnt <= out_cnt + 1'b1;
        end
    end
end
always @(posedge cnnclk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_rd_en <= 'd0;
    end
    else begin
        if(data_stored == 'd784)
            fifo_rd_en <= 1'b1;
        else if(out_cnt == 'd784) begin
            fifo_rd_en <= 1'b0;
        end
    end
end
always @ (posedge cnnclk) data_out_valid <= fifo_rd_en;
cam_reshape_fifo cam_reshape_fifo_u(
    .rst       (~rst_n       ),  //asynchronous port,active hight
    .clkw      (pclk        ),  //write clock
    .clkr      (cnnclk      ),  //read clock
    .we        (fifo_wr_en  ),  //write enable,active hight
    .di        (bin_data    ),  //write data
    .re        (fifo_rd_en  ),  //read enable,active hight
    .dout      (bin_data_out),  //read data
    .valid     (        ),  //read data valid flag
    .full_flag (        ),  //fifo full flag
    .empty_flag(        ),  //fifo empty flag
    .afull     (        ),  //fifo almost full flag
    .aempty    (        ),  //fifo almost empty flag
    .wrusedw   (data_used   ),  //stored data number in fifo
    .rdusedw   (data_stored )   //available data number for read
);
//debug
reg [31:0] valid_cnt_in_1 ;
reg [31:0] valid_cnt_in_2 ;
reg [31:0] valid_cnt_in_3 ;
reg [31:0] valid_cnt_out_3;
always @(posedge pclk or negedge rst_n) begin
    if(!rst_n) begin
        valid_cnt_in_1  = 'd0;
        valid_cnt_in_2  = 'd0;
        valid_cnt_in_3  = 'd0;
        valid_cnt_out_3 = 'd0;
    end
    else begin
        if(data_in_valid)
            valid_cnt_in_1 <= valid_cnt_in_1 + 'd1;
        if(maxpool1_out_valid)
            valid_cnt_in_2 <= valid_cnt_in_2 + 'd1;
        if(maxpool2_out_valid)
            valid_cnt_in_3 <= valid_cnt_in_3 + 'd1;
        if(maxpool3_out_valid)
            valid_cnt_out_3 <= valid_cnt_out_3 + 'd1;
    end
end
endmodule //capture_reshape