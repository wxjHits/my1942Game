module pRandomNum(
    input wire clk,
    input wire enable,

    output reg [8-1:0]dataO
);
localparam [8-1:0]  SEED = 19;//随机数种子
always @(posedge clk) begin
    if(~enable)
        dataO<=SEED;
    else begin
        dataO[0]<=dataO[7];
        dataO[1]<=dataO[0]^dataO[5];
        dataO[2]<=dataO[1];
        dataO[3]<=dataO[2]^dataO[0];
        dataO[4]<=dataO[3]^dataO[6];
        dataO[5]<=dataO[4];
        dataO[6]<=dataO[5];
        dataO[7]<=dataO[6];
    end
end
endmodule