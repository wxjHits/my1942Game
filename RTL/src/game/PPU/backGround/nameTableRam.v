/*
    nameTableRam:名称表32x30的尺寸，一共960个title
    RAM不能同时候进行写操作，最多支持Dual-Ram，因此个各种读写之间应该存在优先级
*/

`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module nameTableRam(
    // //cortex-m0
    input clk,
    input [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] addra,
    input [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] addrb,
    input [31:0] dina,
    input [3:0] wea,
    output reg [31:0] doutb,

    //flashToNametable only_write
    input   wire        clk_flashToNametable    ,//100MHz
    input   wire [03:0] writeNameEn             ,
    input   wire [08:0] writeNameAddr           ,
    input   wire [31:0] writeNameData           ,
    input   wire [03:0] writeAttrEn             ,
    input   wire [08:0] writeAttrAddr           ,
    input   wire [31:0] writeAttrData           ,

    //到tiledraw函数
    input   wire                                        clk_tileDraw        ,
    input           [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0]   nameTableRamIndex   ,
    output  reg     [31:0]                              nameTableRamDataO   ,
    input   wire    [9-1:0]                             attributeAddr       , //0~32*30/4=240
    output  reg     [4*(`BYTE)-1:0]                     attributeTableDataO 
);

    // (* ram_style="block" *) reg  [4*(`BYTE)-1:0] nameTableRam [0:((`NAMETABLE_HEIGHT)*(`NAMETABLE_WIDTH))>>2-1];
    (* ram_style="block" *) reg  [4*(`BYTE)-1:0] nameTableRam [0:512-1];//适配安路的板子进行的修改，与地址线的位宽保持一致
    initial begin
	    $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/backGround/nameTable_test02.txt", nameTableRam);
	end

// /*与CPU M0软核的交互 注意与其他的ram写的高低位位置不一样*/
//     always@(posedge clk) begin
//         if(wea[3]) nameTableRam[addra][7:0] <= dina[07:00];
//     end
//     always@(posedge clk) begin
//         if(wea[2]) nameTableRam[addra][15:8] <= dina[15:08];
//     end
//     always@(posedge clk) begin
//         if(wea[1]) nameTableRam[addra][23:16] <= dina[23:16];
//     end
//     always@(posedge clk) begin
//         if(wea[0]) nameTableRam[addra][31:24] <= dina[31:24];
//     end

/*****读操作*****/
    //cpu
    always@(posedge clk) begin
        doutb <= nameTableRam[addrb];
    end

    always@(posedge clk_tileDraw) begin
        nameTableRamDataO <= nameTableRam[nameTableRamIndex];
    end

    always@(posedge clk_tileDraw)begin
        attributeTableDataO<=nameTableRam[attributeAddr];
    end

/*****写操作的优先级选择*****/

    reg         clk_sel     ;
    reg [03:0]  writeEn_sel ;
    reg [08:0]  addr_sel    ;
    reg [31:0]  dataIn_sel  ;
    always@(*)begin
        if(wea!=0)begin
            clk_sel     = clk   ;
            writeEn_sel = wea   ;
            addr_sel    = addra ;
            dataIn_sel  = dina  ;
        end
        else if(writeNameEn!=0)begin
            clk_sel     = clk_flashToNametable  ;
            writeEn_sel = writeNameEn           ;
            addr_sel    = writeNameAddr         ;
            dataIn_sel  = writeNameData         ;
        end
        else begin
            clk_sel     = clk_flashToNametable  ;
            writeEn_sel = writeAttrEn           ;
            addr_sel    = writeAttrAddr         ;
            dataIn_sel  = writeAttrData         ;
        end
    end

    always@(posedge clk_sel) begin
        if(writeEn_sel[3]) nameTableRam[addr_sel][7:0] <= dataIn_sel[07:00];
    end
    always@(posedge clk_sel) begin
        if(writeEn_sel[2]) nameTableRam[addr_sel][15:8] <= dataIn_sel[15:08];
    end
    always@(posedge clk_sel) begin
        if(writeEn_sel[1]) nameTableRam[addr_sel][23:16] <= dataIn_sel[23:16];
    end
    always@(posedge clk_sel) begin
        if(writeEn_sel[0]) nameTableRam[addr_sel][31:24] <= dataIn_sel[31:24];
    end
    // /*与CPU M0软核的交互 注意与其他的ram写的高低位位置不一样*/
    // always@(posedge clk) begin
    //     if(wea[3]) nameTableRam[addra][7:0] <= dina[07:00];
    // end
    // always@(posedge clk) begin
    //     if(wea[2]) nameTableRam[addra][15:8] <= dina[15:08];
    // end
    // always@(posedge clk) begin
    //     if(wea[1]) nameTableRam[addra][23:16] <= dina[23:16];
    // end
    // always@(posedge clk) begin
    //     if(wea[0]) nameTableRam[addra][31:24] <= dina[31:24];
    // end

    // always@(posedge clk_flashToNametable)begin//这两次读写，在时间上一前一后
    //     if(writeNameEn)
    //         nameTableRam[writeNameAddr]<=writeNameData;
    //     if(writeAttrEn)
    //         nameTableRam[writeAttrAddr]<=writeAttrData;
    // end

endmodule