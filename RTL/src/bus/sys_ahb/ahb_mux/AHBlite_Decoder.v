module AHBlite_Decoder
#(
    parameter Port4_en = 1,
    parameter Port5_en = 1,
    parameter Port6_en = 1,
    parameter Port7_en = 1
)(
    input        HSEL,
    input [31:0] HADDR,
    
    output wire P4_HSEL,
    output wire P5_HSEL,
    output wire P6_HSEL,
    output wire P7_HSEL
);
//0x50000000 LCD
assign P4_HSEL = (HSEL && HADDR[31:16] == 16'h5000) ? Port4_en : 1'd0;
/***********************************/

//0x50010000 GAME_SPRITERAM 游戏的精灵数据RAM
assign P5_HSEL = (HSEL && HADDR[31:16] == 16'h5001) ? Port5_en : 1'd0;
/***********************************/

//0x50020000 GAME_NAMETABLE_RAM 游戏的背景nameTable外设
assign P6_HSEL = (HSEL && HADDR[31:16] == 16'h5002) ? Port6_en : 1'd0;
/***********************************/

//0x50030000 留给APU的接口
assign P7_HSEL = (HSEL && HADDR[31:16] == 16'h5003) ? Port7_en : 1'd0;
/***********************************/

endmodule