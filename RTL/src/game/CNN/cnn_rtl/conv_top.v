`include "cnn_defines.v"
module conv_top (
    clk             ,
    rst_n               ,
    top_data_in         ,
    top_data_in_valid   ,
    top_data_out        ,
    top_data_out_valid  ,
    debug
);
input                           clk               ;
input                           rst_n             ;
input [`CNN_DATA_IN_W-1:0]      top_data_in       ;
input                           top_data_in_valid ;
output [4-1:0]                  top_data_out      ;
output                          top_data_out_valid;

input                           debug             ;

wire [6*16-1:0]    conv1_data_out;
wire               conv1_data_out_valid;
wire [6*16-1:0]    pool1_data_out;
wire               pool1_data_out_valid;
wire               ones_test = 0;
conv1 conv1_u(
    .clk               (clk                 ),
    .rst_n             (rst_n               ),
    //.cnn_data_in       (ones_test         ),
    .cnn_data_in       (top_data_in         ),
    .cnn_data_in_valid (top_data_in_valid   ),
    .cnn_data_out      (conv1_data_out      ),
    .cnn_data_out_valid(conv1_data_out_valid)
);

pool1 pool1_u(
    .clk           (clk                     ),
    .rst_n         (rst_n                   ),
    .data_in       (conv1_data_out          ),
    .data_in_valid (conv1_data_out_valid    ),
    .data_out      (pool1_data_out          ),
    .data_out_valid(pool1_data_out_valid    )
);

wire                c2_ready;
wire [16*6-1:0]     p1_fifo_out;
wire                p1_fifo_out_valid;

p1_data_fifo U2_p1_data_fifo(
    .clk            (clk                    ),
    .rst_n          (rst_n                  ),
    .c2_ready       (c2_ready               ),
    .data_in        (pool1_data_out         ),
    .data_in_valid  (pool1_data_out_valid   ),
    .data_out       (p1_fifo_out            ),
    .data_out_valid (p1_fifo_out_valid      )
);

wire [15:0] conv2_data_out;//需要调整
wire        conv2_data_out_valid;
wire [4:0]  conv2_out_channel;

conv2 conv2_u(
    .clk            (clk                    ),
    .rst_n          (rst_n                  ),
    .c2_ready       (c2_ready               ),
    .data_in        (p1_fifo_out            ),
    .data_in_valid  (p1_fifo_out_valid      ),
    .data_out       (conv2_data_out         ),
    .data_out_valid (conv2_data_out_valid   ),
    .out_channel_cnt(conv2_out_channel      )
);

wire [15:0] pool2_data_out;
wire        pool2_data_out_valid;

pool2 pool2_u(
    .clk            (clk                    ),
    .rst_n          (rst_n                  ),
    .data_in        (conv2_data_out         ),
    .data_in_valid  (conv2_data_out_valid   ),
    .in_channel     (conv2_out_channel      ),
    .data_out       (pool2_data_out         ),
    .data_out_valid (pool2_data_out_valid   )
);

wire                fc_ready;
wire [16-1:0]       p2_fifo_out;
wire                p2_fifo_out_valid;
p2_data_fifo U_p2_data_fifo(
    .clk            (clk                    ),
    .rst_n          (rst_n                  ),
    .fc_ready       (fc_ready               ),
    .data_in        (pool2_data_out         ),
    .data_in_valid  (pool2_data_out_valid   ),
    .data_out       (p2_fifo_out            ),
    .data_out_valid (p2_fifo_out_valid      )
);

wire [16*32-1:0] fc1_data_out;
wire        fc1_data_out_valid;

fc1 fc1_u(
    .clk            (clk                    ),
    .rst_n          (rst_n                  ),
    .fc_ready       (fc_ready               ),
    .data_in        (p2_fifo_out            ),
    .data_in_valid  (p2_fifo_out_valid      ),
    .data_out       (fc1_data_out           ),
    .data_out_valid (fc1_data_out_valid     )
);

wire [3:0] one_hot;
wire        fc2_data_out_valid;
fc2 fc2_u(
    .clk            (clk                    ),
    .rst_n          (rst_n                  ),
    .data_in        (fc1_data_out           ),
    .data_in_valid  (fc1_data_out_valid     ),
    .one_hot        (one_hot                ),
    .data_out_valid (fc2_data_out_valid     )
);
/*assign top_data_out = conv1_data_out[15:0];
assign top_data_out_valid = conv1_data_out_valid;*/
/*assign top_data_out = pool1_data_out[15:0];
assign top_data_out_valid = pool1_data_out_valid;*/
/*assign top_data_out = p1_fifo_out[15:0];
assign top_data_out_valid = p1_fifo_out_valid;*/
/*assign top_data_out = conv2_data_out;
assign top_data_out_valid = conv2_data_out_valid;*/
/*assign top_data_out = pool2_data_out;
assign top_data_out_valid = pool2_data_out_valid;*/
/*assign top_data_out = p2_fifo_out;
assign top_data_out_valid = p2_fifo_out_valid;*/
assign top_data_out = one_hot;
assign top_data_out_valid = fc2_data_out_valid;
endmodule //conv_top