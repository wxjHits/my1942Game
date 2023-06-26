module fcweights_rom
#(
    parameter FILE_NAME = "file.txt",
    parameter FC_DATA_W = 8,
    parameter DATA_NUM = 16*4*4*32,
    parameter ADDR_W = $clog2(DATA_NUM)
)
(
    clk         ,
    rom_raddr   ,
    rom_dout

);
    input                               clk         ;
    input       [ADDR_W-1:0]                   rom_raddr   ;
    output reg  [FC_DATA_W-1:0]   rom_dout    ;

    reg [FC_DATA_W-1:0] para_rom [DATA_NUM-1:0];

    /* 初始化 */
    initial begin
        $readmemh(FILE_NAME, para_rom);
    end

    /* 读rom */
    always@(posedge clk) begin
        rom_dout = para_rom[rom_raddr];
    end
endmodule

