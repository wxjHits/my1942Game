module AHBlite_Decoder
#(
    parameter Port0_en = 1,
    parameter Port1_en = 1,
    parameter Port2_en = 1,
    parameter Port3_en = 1,
    parameter Port4_en = 1,
    parameter Port5_en = 1,
    parameter Port6_en = 1,
    parameter Port7_en = 1
)(
    input [31:0] HADDR,
    
    output wire P0_HSEL,
    output wire P1_HSEL,
    output wire P2_HSEL,
    output wire P3_HSEL,       
    output wire P4_HSEL,
    output wire P5_HSEL,
    output wire P6_HSEL,
    output wire P7_HSEL
);

//RAMCODE-----------------------------------

//0x00000000-0x0000ffff
/*Insert RAMCODE decoder code there*/
assign P0_HSEL = (HADDR[31:16] == 16'h0000) ? Port0_en : 1'd0;
/***********************************/

//RAMDATA-----------------------------
//0X20000000-0X2000FFFF
/*Insert RAMDATA decoder code there*/
assign P1_HSEL = (HADDR[31:16] == 16'h2000) ? Port1_en : 1'b0;
/***********************************/

//AHB_TO_APB_BRIDGE-----------------------------
//0X40000000
/*Insert WaterLight decoder code there*/
assign P2_HSEL = (HADDR[31:16] == 16'h4000) ? Port2_en : 1'd0;
/***********************************/

//0X40010000 CAMERA
//0X40010000-0X4004FFFF CAMERA-Cache
//0X40050000 CAMERA-Config
/*Insert UART decoder code there*/
assign P3_HSEL = (  HADDR[31:16] == 16'h4001||
                    HADDR[31:16] == 16'h4002||
                    HADDR[31:16] == 16'h4003||
                    HADDR[31:16] == 16'h4004||
                    HADDR[31:16] == 16'h4005) ? Port3_en : 1'd0;
/***********************************/

//0x50000000 LCD
assign P4_HSEL = (HADDR[31:16] == 16'h5000) ? Port4_en : 1'd0;
/***********************************/

//0x50010000 GAME_SPRITERAM 游戏的精灵数据RAM
assign P5_HSEL = (HADDR[31:16] == 16'h5001) ? Port5_en : 1'd0;
/***********************************/

//0x50020000 GAME_NAMETABLE_RAM 游戏的背景nameTable外设
assign P6_HSEL = (HADDR[31:16] == 16'h5002) ? Port6_en : 1'd0;
/***********************************/

//0x50030000 留给APU的接口
assign P7_HSEL = (HADDR[31:16] == 16'h5003) ? Port7_en : 1'd0;
/***********************************/

endmodule