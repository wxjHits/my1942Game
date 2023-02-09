/*
    对64个精灵进行碰撞检测(在游戏画面显示完成后进行)
    64个时钟流水线式的方式生成hitMap,对64个进行均进行hit判断
*/
`include "C:/Users/hp/Desktop/my_1942/define.v"
module hitCheck(

    input   wire    clk,
    input   wire    rstn,

    //
    input   wire    hitCheckStart,

    //to spriteRam.v
    output  reg    [$clog2(`SPRITE_NUM_MAX)-1:0]   hitCheck_spriteViewRamIndex,
    //from spriteRam.v
    input   wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO_hitCheck,
    
    //64个精灵是否发生hit的输出
    output reg [`SPRITE_NUM_MAX-1:0] allSpriteHit,
    //该模块的状态标志位
    output wire hitCheckBusy
);

reg drawHitMapFlag;//绘制hitMap的标志
reg createHitStateFlag;//在完成hitMap绘制之后完成对64个精灵hit情况生成的标志位
assign hitCheckBusy = drawHitMapFlag | createHitStateFlag;
reg hitCheckStartDelay;
always @(posedge clk) begin
    if(~rstn)
        hitCheckStartDelay<=0;
    else
        hitCheckStartDelay<=hitCheckStart;
end
always@(posedge clk)begin
    if(~rstn)
        drawHitMapFlag<=0;
    else if(hitCheckStartDelay)
        drawHitMapFlag<=1;
    else if(drawHitMapFlag<=1 && hitCheck_spriteViewRamIndex==6'd63)
        drawHitMapFlag<=0;
end

always@(posedge clk)begin
    if(~rstn)
        hitCheck_spriteViewRamIndex<=0;
    else if(drawHitMapFlag)
        hitCheck_spriteViewRamIndex<=hitCheck_spriteViewRamIndex+1'b1;
    else if(createHitStateFlag)
        hitCheck_spriteViewRamIndex<=hitCheck_spriteViewRamIndex+1'b1;
    else
        hitCheck_spriteViewRamIndex<=0;
end

always@(posedge clk)begin
    if(~rstn)
        createHitStateFlag<=0;
    else if(drawHitMapFlag && hitCheck_spriteViewRamIndex==6'd63)
        createHitStateFlag<=1;
    else if(createHitStateFlag==1 && hitCheck_spriteViewRamIndex==6'd63)
        createHitStateFlag<=0;
end

//spriteViewRamDataO_hitCheck数据译码
reg [5-1:0] gridPosX;
reg [5-1:0] gridPosY;
reg [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex;

always@(*)begin
    gridPosX = spriteViewRamDataO_hitCheck[4*(`BYTE)-1:3*(`BYTE)+3];
    gridPosY = spriteViewRamDataO_hitCheck[3*(`BYTE)-1:2*(`BYTE)+3];
    tileIndex = spriteViewRamDataO_hitCheck[2*(`BYTE)-3-1:1*(`BYTE)];
end
//tileType的判断: 1主角飞机 2主角子弹 3敌机 4敌机子弹
    reg [2:0] tileType;
    always@(*)begin
        case (tileIndex)
            10,11,12,13: tileType = 1;
            14: tileType = 2;
            15,16,17: tileType = 3;
            18: tileType = 4;
            default: tileType = 0;
        endcase
    end
    wire [`GAME_GRID_WIDTH-1:0] mask = 1<<(gridPosX);

//hitMap以及64个精灵hit情况的生成
    reg [`GAME_GRID_WIDTH-1:0] heroHitMap [0:`GAME_GRID_HEIGHT-1];
    reg [`GAME_GRID_WIDTH-1:0] enemyHitMap[0:`GAME_GRID_HEIGHT-1];

    integer i;
    always@(posedge clk)begin
        if(~rstn|hitCheckStart)begin
            for(i=0;i<`GAME_GRID_HEIGHT;i=i+1)begin
                heroHitMap[i]<=0;
                enemyHitMap[i]<=0;
            end
        end
        if(drawHitMapFlag)begin//drawHitMap时间段
            if(tileType==1||tileType==2)
                heroHitMap[gridPosY]<=heroHitMap[gridPosY]|mask;
            else if(tileType==3||tileType==4)
                enemyHitMap[gridPosY]<=enemyHitMap[gridPosY]|mask;
        end
    end

    wire hitOccured;
    assign hitOccured = createHitStateFlag ? ((heroHitMap[gridPosY][gridPosX] & enemyHitMap[gridPosY][gridPosX]) ? 1'b1:1'b0) : 1'b0;

    always@(posedge clk)begin
        if(~rstn)
            allSpriteHit<=0;
        else if(createHitStateFlag==1)begin
            if(hitOccured)
                allSpriteHit[hitCheck_spriteViewRamIndex]<=1'b1;
            else
                allSpriteHit[hitCheck_spriteViewRamIndex]<=1'b0;
        end
    end

endmodule