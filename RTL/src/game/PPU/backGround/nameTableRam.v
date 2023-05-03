/*
    nameTableRam:名称表32x30的尺寸，一共960个title
    RAM不能同时候进行写操作，最多支持Dual-Ram，因此个各种读写之间应该存在优先级
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

    //flashToNametable only_write
    input   wire        clk_flashToNametable    ,//100MHz
    input   wire [03:0] writeNameEn             ,
    input   wire [08:0] writeNameAddr           ,
    input   wire [31:0] writeNameData           ,
    input   wire [03:0] writeAttrEn             ,
    input   wire [08:0] writeAttrAddr           ,
    input   wire [31:0] writeAttrData           ,
    //到tiledraw函数 only read
    input   wire                                        clk_tileDraw        ,
    input           [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0]   nameTableRamIndex   ,
    output  reg     [31:0]                              nameTableRamDataO   ,
    input   wire    [9-1:0]                             attributeAddr       , //0~32*30/4=240
    output  reg     [4*(`BYTE)-1:0]                     attributeTableDataO 
);

    (* ram_style="block" *) reg  [4*(`BYTE)-1:0] nameTableRam [0:512-1];//适配安路的板子进行的修改，与地址线的位宽保持一致
    // initial begin
    //     $readmemh("C:/Users/hp/Desktop/my1942GameAn/RTL/src/game/PPU/ppuDocTxt/nameTable_test01.txt", nameTableRam);
    // end

/*****读操作*****/
    // //cpu
    // always@(posedge clk) begin
    //     doutb <= nameTableRam[addrb];
    // end

    always@(posedge clk_tileDraw) begin
        nameTableRamDataO <= nameTableRam[nameTableRamIndex];
    end

    always@(posedge clk_tileDraw)begin
        attributeTableDataO<=nameTableRam[attributeAddr];
    end

/*****写操作的优先级选择*****/
    // reg         clk_sel     ;
    reg [03:0]  writeEn_sel ;
    reg [08:0]  addr_sel    ;
    reg [31:0]  dataIn_sel  ;
    always@(*)begin
        if(wea!=0)begin
            // clk_sel     = clk_flashToNametable   ;
            writeEn_sel = wea   ;
            addr_sel    = addra ;
            dataIn_sel  = dina  ;
        end
        else if(writeNameEn!=0)begin
            // clk_sel     = clk_flashToNametable  ;
            writeEn_sel = writeNameEn           ;
            addr_sel    = writeNameAddr         ;
            dataIn_sel  = writeNameData         ;
        end
        else begin
            // clk_sel     = clk_flashToNametable  ;
            writeEn_sel = writeAttrEn           ;
            addr_sel    = writeAttrAddr         ;
            dataIn_sel  = writeAttrData         ;
        end
    end

    always@(posedge clk_flashToNametable) begin
        if(writeEn_sel[3]) nameTableRam[addr_sel][7:0] <= dataIn_sel[07:00];
    end
    always@(posedge clk_flashToNametable) begin
        if(writeEn_sel[2]) nameTableRam[addr_sel][15:8] <= dataIn_sel[15:08];
    end
    always@(posedge clk_flashToNametable) begin
        if(writeEn_sel[1]) nameTableRam[addr_sel][23:16] <= dataIn_sel[23:16];
    end
    always@(posedge clk_flashToNametable) begin
        if(writeEn_sel[0]) nameTableRam[addr_sel][31:24] <= dataIn_sel[31:24];
    end

endmodule


// `include "C:/Users/hp/Desktop/my1942GameAn/RTL/src/game/PPU/define.v"
// module nameTableRam(
//     //cortex-m0
//     input clk,
//     input [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] addra,
//     input [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] addrb,
//     input [31:0] dina,
//     input [3:0] wea,
//     output reg [31:0] doutb,

//     //flashToNametable only_write
//     input   wire        clk_flashToNametable    ,//100MHz
//     input   wire [03:0] writeNameEn             ,
//     input   wire [08:0] writeNameAddr           ,
//     input   wire [31:0] writeNameData           ,
//     input   wire [03:0] writeAttrEn             ,
//     input   wire [08:0] writeAttrAddr           ,
//     input   wire [31:0] writeAttrData           ,
//     //到tiledraw函数 only read
//     input   wire                                        clk_tileDraw        ,
//     input           [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0]   nameTableRamIndex   ,
//     output  reg     [31:0]                              nameTableRamDataO   ,
//     input   wire    [9-1:0]                             attributeAddr       , //0~32*30/4=240
//     output  reg     [4*(`BYTE)-1:0]                     attributeTableDataO 
// );

//     (* ram_style="block" *) reg  [4*(`BYTE)-1:0] nameTableRam [0:512-1];//适配安路的板子进行的修改，与地址线的位宽保持一致
//     // initial begin
//     //     $readmemh("C:/Users/hp/Desktop/my1942GameAn/RTL/src/game/PPU/ppuDocTxt/nameTable_test01.txt", nameTableRam);
//     // end

//     (* ram_style="block" *) reg  [4*(`BYTE)-1:0] attributeRam [0:32-1];//适配安路的板子进行的修改，与地址线的位宽保持一致

// /*****读操作*****/

//     always@(posedge clk_tileDraw) begin
//         nameTableRamDataO <= nameTableRam[nameTableRamIndex];
//     end

//     wire [4:0] attributeAddrRd={attributeAddr[8],attributeAddr[3:0]};
//     always@(posedge clk_tileDraw)begin
//         attributeTableDataO<=attributeRam[attributeAddrRd];
//     end

// /*****写操作的优先级选择*****/

//     wire cpu_attri_writeFlag;
//     assign cpu_attri_writeFlag = (addra[7:4]==4'b1111) ? 1'b1:1'b0;
//     //名称表的操作
//     reg [ 3:0]  name_writeEn_sel ;
//     reg [ 8:0]  name_addr_sel    ;
//     reg [31:0]  name_dataIn_sel  ;
//     always@(*)begin
//         if((wea!=0) && (cpu_attri_writeFlag==1'b0))begin
//             name_writeEn_sel = wea   ;
//             name_addr_sel    = addra ;
//             name_dataIn_sel  = dina  ;
//         end
//         else begin
//             name_writeEn_sel = writeNameEn   ;
//             name_addr_sel    = writeNameAddr ;
//             name_dataIn_sel  = writeNameData ;
//         end
//     end

//     always@(posedge clk_flashToNametable) begin
//         if(name_writeEn_sel[3]) nameTableRam[name_addr_sel][7:0] <= name_dataIn_sel[ 7: 0];
//     end
//     always@(posedge clk_flashToNametable) begin
//         if(name_writeEn_sel[2]) nameTableRam[name_addr_sel][15:8] <= name_dataIn_sel[15: 8];
//     end
//     always@(posedge clk_flashToNametable) begin
//         if(name_writeEn_sel[1]) nameTableRam[name_addr_sel][23:16] <= name_dataIn_sel[23:16];
//     end
//     always@(posedge clk_flashToNametable) begin
//         if(name_writeEn_sel[0]) nameTableRam[name_addr_sel][31:24] <= name_dataIn_sel[31:24];
//     end

//     //属性表的操作
//     reg [ 3:0]  attri_writeEn_sel ;
//     reg [ 4:0]  attri_addr_sel    ;
//     reg [31:0]  attri_dataIn_sel  ;
//     always@(*)begin
//         if((wea!=0) && (cpu_attri_writeFlag==1'b1))begin
//             attri_writeEn_sel = wea   ;
//             attri_addr_sel    = {addra[8],addra[3:0]} ;
//             attri_dataIn_sel  = dina  ;
//         end
//         else begin
//             attri_writeEn_sel = writeAttrEn   ;
//             attri_addr_sel    = {writeAttrAddr[8],writeAttrAddr[3:0]} ;
//             attri_dataIn_sel  = writeAttrData ;
//         end
//     end

//     always@(posedge clk_flashToNametable) begin
//         if(attri_writeEn_sel[3]) attributeRam[attri_addr_sel][7:0] <= attri_dataIn_sel[ 7: 0];
//     end
//     always@(posedge clk_flashToNametable) begin
//         if(attri_writeEn_sel[2]) attributeRam[attri_addr_sel][15:8] <= attri_dataIn_sel[15: 8];
//     end
//     always@(posedge clk_flashToNametable) begin
//         if(attri_writeEn_sel[1]) attributeRam[attri_addr_sel][23:16] <= attri_dataIn_sel[23:16];
//     end
//     always@(posedge clk_flashToNametable) begin
//         if(attri_writeEn_sel[0]) attributeRam[attri_addr_sel][31:24] <= attri_dataIn_sel[31:24];
//     end

// endmodule
