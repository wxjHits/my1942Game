/*
    nameTableRam:名称表32x30的尺寸，一共960个title
*/

`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module nameTableRam(
    //cortex-m0
    input clk,
    input [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] addra,
    input [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] addrb,
    input [31:0] dina,
    input [3:0] wea,
    output reg [31:0] doutb,


    //到tiledraw函数
    input clk_tileDraw,
    input [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] nameTableRamIndex,
    output reg [31:0] nameTableRamDataO
);

    (* ram_style="block" *) reg  [4*(`BYTE)-1:0] nameTableRam [0:((`NAMETABLE_HEIGHT)*(`NAMETABLE_WIDTH))>>2-1];
    initial begin
	    $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/backGround/nameTable.txt", nameTableRam);
	end

/*与CPU M0软核的交互*/
    always@(posedge clk) begin
        if(wea[0]) nameTableRam[addra][7:0] <= dina[7:0];
    end
    always@(posedge clk) begin
        if(wea[1]) nameTableRam[addra][15:8] <= dina[15:8];
    end
    always@(posedge clk) begin
        if(wea[2]) nameTableRam[addra][23:16] <= dina[23:16];
    end
    always@(posedge clk) begin
        if(wea[3]) nameTableRam[addra][31:24] <= dina[31:24];
    end

    always@(posedge clk) begin
        doutb <= nameTableRam[addrb];
    end

/*与其他PPU模块的交互*/
    always@(posedge clk_tileDraw) begin
        nameTableRamDataO <= nameTableRam[nameTableRamIndex];
    end

endmodule