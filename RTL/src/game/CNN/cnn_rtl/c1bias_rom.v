`include "cnn_defines.v"
module c1bias_rom
#(
    parameter FILE_NAME = "file.txt"
)
(
    clk         ,
    rom_raddr   ,
    rom_dout

);
    input                               clk         ;
    input       [4:0]                   rom_raddr   ;
    output reg  [`CNN_PARA_WIDTH-1:0]   rom_dout    ;

    reg [`CNN_PARA_WIDTH-1:0] para_rom [`CNN_BIAS_SIZE-1:0];

    /* 初始化 */
    initial begin
        $readmemh(FILE_NAME, para_rom);
    end

    /* 读rom */
    always@(posedge clk) begin
            rom_dout = para_rom[rom_raddr];
    end
endmodule
