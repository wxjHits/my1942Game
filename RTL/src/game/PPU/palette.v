/*
    weixuejing 2023.02.06
    调色板
*/
`include "define.v"
module palette (
    input  wire [1:0] PaletteChoice,
    output reg  [`RGB_BIT-1:0] PaletteColor00,
    output reg  [`RGB_BIT-1:0] PaletteColor01,
    output reg  [`RGB_BIT-1:0] PaletteColor10,
    output reg  [`RGB_BIT-1:0] PaletteColor11
);
    reg  [4*(`RGB_BIT)-1:0] palettemem [0:3];
    initial begin
	    $readmemh("C:/Users/hp/Desktop/my_1942/palette.txt", palettemem);
	end

    reg  [4*(`RGB_BIT)-1:0] PaletteColor;
    always@(*)begin
        PaletteColor=palettemem[PaletteChoice];
        PaletteColor00=PaletteColor[4*(`RGB_BIT)-1:3*(`RGB_BIT)];
        PaletteColor01=PaletteColor[3*(`RGB_BIT)-1:2*(`RGB_BIT)];
        PaletteColor10=PaletteColor[2*(`RGB_BIT)-1:1*(`RGB_BIT)];
        PaletteColor11=PaletteColor[1*(`RGB_BIT)-1:0*(`RGB_BIT)];
    end
endmodule