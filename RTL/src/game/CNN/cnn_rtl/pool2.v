module pool2 (
    input               clk,
    input               rst_n,

    input      [16-1:0] data_in,//需要调整
    input               data_in_valid,
    input      [4:0]    in_channel,

    output reg [16-1:0]   data_out,//需要调整
    output reg          data_out_valid
);
	localparam DATA_W = 16;//需要修改
	localparam IMG_IN_W = 8;
	localparam BUFFER_ADDR_W = $clog2(IMG_IN_W);

	reg [15:0] valid_channel;
	wire [16-1:0] data_out_channel [15:0];
	wire [15:0] data_out_valid_channel;
	genvar i;
	generate
		for(i=0;i<16;i=i+1) begin
			always@(*) begin
				if(i==in_channel)
					valid_channel[i] = data_in_valid;
				else
					valid_channel[i] = 1'b0;
			end
		end
	endgenerate
	genvar j;
	generate
		for(j=0;j<16;j=j+1) begin
			poolsingle
			#(
				DATA_W,IMG_IN_W,BUFFER_ADDR_W
			)
			poolsingle_u(
				.clk           (clk           				),
				.rst_n         (rst_n         				),
				.data_in       (data_in       				),
				.data_in_valid (valid_channel[j]			),
				.data_out      (data_out_channel[j]		),
				.data_out_valid(data_out_valid_channel[j]	)
			);
		end
	endgenerate
	always @(*) begin
		case (in_channel)
			'd0: begin
				data_out = data_out_channel[0];
				data_out_valid = data_out_valid_channel[0];
			end
			'd1: begin
				data_out = data_out_channel[1];
				data_out_valid = data_out_valid_channel[1];
			end
			'd2: begin
				data_out = data_out_channel[2];
				data_out_valid = data_out_valid_channel[2];
			end
			'd3: begin
				data_out = data_out_channel[3];
				data_out_valid = data_out_valid_channel[3];
			end
			'd4: begin
				data_out = data_out_channel[4];
				data_out_valid = data_out_valid_channel[4];
			end
			'd5: begin
				data_out = data_out_channel[5];
				data_out_valid = data_out_valid_channel[5];
			end
			'd6: begin
				data_out = data_out_channel[6];
				data_out_valid = data_out_valid_channel[6];
			end
			'd7: begin
				data_out = data_out_channel[7];
				data_out_valid = data_out_valid_channel[7];
			end
			'd8: begin
				data_out = data_out_channel[8];
				data_out_valid = data_out_valid_channel[8];
			end
			'd9: begin
				data_out = data_out_channel[9];
				data_out_valid = data_out_valid_channel[9];
			end
			'd10: begin
				data_out = data_out_channel[10];
				data_out_valid = data_out_valid_channel[10];
			end
			'd11: begin
				data_out = data_out_channel[11];
				data_out_valid = data_out_valid_channel[11];
			end
			'd12: begin
				data_out = data_out_channel[12];
				data_out_valid = data_out_valid_channel[12];
			end
			'd13: begin
				data_out = data_out_channel[13];
				data_out_valid = data_out_valid_channel[13];
			end
			'd14: begin
				data_out = data_out_channel[14];
				data_out_valid = data_out_valid_channel[14];
			end
			'd15: begin
				data_out = data_out_channel[15];
				data_out_valid = data_out_valid_channel[15];
			end
		endcase
	end
endmodule //pool2