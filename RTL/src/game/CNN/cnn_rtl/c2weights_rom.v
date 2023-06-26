module c2weights_rom
#(
    parameter FILE_NAME = "file.txt"
)
(
    clk         ,
    rom_raddr   ,
    rom_dout

);
    input                               clk         ;
    input       [8:0]                   rom_raddr   ;
    output reg  [25*16-1:0]   rom_dout    ;

    reg [25*16-1:0] para_rom [16*6-1:0];

    /* 初始化 */
    initial begin
        $readmemb(FILE_NAME, para_rom);
    end

    /* 读rom */
    always@(posedge clk) begin
        rom_dout = para_rom[rom_raddr];
    end
endmodule
