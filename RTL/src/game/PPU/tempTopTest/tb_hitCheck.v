`timescale 1ns/1ps

`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"

module tb_hitCheck();
    reg                                     clk                         ;
    reg                                     rstn                        ;
    reg                                     hitCheckStart               ;
    reg                                     hitCheckStartReg            ;
    wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   hitCheck_spriteViewRamIndex ;
    wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO_hitCheck ;
    wire    [`SPRITE_NUM_MAX-1:0]           allSpriteHit                ;
    wire                                    hitCheckBusy                ;

initial begin
    clk=0;
    rstn=0;
    hitCheckStart=0;
    #11
    rstn=1;
    #100
    hitCheckStart=1;
    #2
    hitCheckStart=0;
    #1000
    hitCheckStart=1;
    #2
    hitCheckStart=0;
end
always@(posedge clk)begin
    if(~rstn)
        hitCheckStartReg<=0;
    else
        hitCheckStartReg<=hitCheckStart;
end
always #1 clk=~clk;


hitCheck u_hitCheck(
    .clk                        (clk                        ),
    .rstn                       (rstn                       ),
    .hitCheckStart              (hitCheckStartReg           ),
    .hitCheck_spriteViewRamIndex(hitCheck_spriteViewRamIndex),
    .spriteViewRamDataO_hitCheck(spriteViewRamDataO_hitCheck),
    .allSpriteHit               (allSpriteHit               ),
    .hitCheckBusy               (hitCheckBusy               )
);

spriteRam u_spriteRam(
    .hitCheck_spriteViewRamIndex(hitCheck_spriteViewRamIndex),
    .spriteViewRamDataO_hitCheck(spriteViewRamDataO_hitCheck)
);

endmodule