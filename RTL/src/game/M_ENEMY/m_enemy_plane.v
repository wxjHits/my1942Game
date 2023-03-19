/*
    M中型飞机的运行逻辑
*/
module m_enemyPlane_logic(
    input  wire         clk         ,//系统时钟50MHz
    input  wire         rstn        ,
    //
    input  wire         update_clk  ,//数据更新clk
    input  wire         create      ,//创建单位
    input  wire         Hit         ,//被击中

    //初始化的数据
    input  wire [7:0]   Init_POS_X  ,
    input  wire [7:0]   Init_POS_Y  ,
    //
    output wire [7:0]   PosX_out    ,//用于碰撞Mask和绘图
    output wire [7:0]   PosY_out    ,//用于碰撞Mask和绘图
    output wire [7:0]   Attitude    ,//用于判断当前单位应该是动画的第几帧
    output wire         isLive       //用于CPU获取单位状态
);
    //输入数据检测上升沿
    reg update_clk_r0,update_clk_r1,update_clk_pluse;
    reg create_r0,create_r1,create_pluse;
    // reg Hit_r0,Hit_r1,Hit_pluse;
    always@(posedge clk)begin
        if(~rstn)begin
            update_clk_r0       <=0;
            update_clk_r1       <=0;
            update_clk_pluse    <=0;
            create_r0           <=0;
            create_r1           <=0;
            create_pluse        <=0;
        end
        else begin
            update_clk_r0       <=update_clk;
            update_clk_r1       <=update_clk_r0;
            update_clk_pluse    <=update_clk_r0&(~update_clk_r1);
            create_r0           <=create;
            create_r1           <=create_r0;
            create_pluse        <=create_r0&(~create_r1);
        end
    end

    //该单位的属性寄存器
    reg [07:0]  pos_x   ;
    reg [07:0]  pos_y   ;
    reg         liveFlag;
    reg [07:0]  hp      ;
    reg [07:0]  attitude;//当前状态
    reg [07:0]  y_turn0 ;
    reg [07:0]  y_turn1 ;
    reg [07:0]  y_turn2 ;
    reg [07:0]  y_turn3 ;
    reg [07:0]  x_turn0 ;
    reg [07:0]  x_turn1 ;
    
    //是否超出边界
    wire outEdge = (pos_x<10||pos_x>230)||(pos_y<10||pos_y>230);
    //是否被击中
    wire hit_flag = Hit;
    //状态机定义
    reg [3:0] now_state=0;
    reg [3:0] next_state=0;
    localparam DEAD = 4'd0;
    localparam ROUTE_00 = 4'd1;
    localparam ROUTE_01 = 4'd2;
    localparam ROUTE_02 = 4'd3;
    localparam ROUTE_03 = 4'd4;
    localparam ROUTE_04 = 4'd5;
    localparam ROUTE_05 = 4'd6;
    localparam ROUTE_06 = 4'd7;
    localparam ROUTE_07 = 4'd8;
    localparam ROUTE_08 = 4'd9;
    //数据的计算
    reg [7:0] plane_pos;
    reg [7:0] turn_pos;
    reg [7:0] sub_result;
    reg       turn_flag_r0;
    reg       turn_flag_r1;
    wire      turn_flag;
    reg [07:0]next_pos_x   ;
    reg [07:0]next_pos_y   ;
    wire dead_flag = (hp==0) || outEdge;
    assign turn_flag = turn_flag_r0&(~turn_flag_r1);

    always@(posedge update_clk_pluse)begin
        if(~rstn)begin
            turn_flag_r0<=0;
            turn_flag_r1<=0;
        end
        else begin
            turn_flag_r0<=(sub_result<2);
            turn_flag_r1<=turn_flag_r0;
        end
    end

    always@(*)begin
        if(turn_pos>plane_pos)
            sub_result=turn_pos-plane_pos;
        else
            sub_result=plane_pos-turn_pos;
        case(now_state)
            ROUTE_00:begin
                plane_pos = pos_y  ;
                turn_pos  = y_turn2;
                next_pos_x= pos_x+0;
                next_pos_y= pos_y+2;
                next_state=ROUTE_01;
                attitude=0;
            end
            ROUTE_01:begin
                plane_pos = pos_y  ;
                turn_pos  = y_turn3;
                next_pos_x= pos_x+1;
                next_pos_y= pos_y+1;
                next_state=ROUTE_02;
                attitude=1;
            end
            ROUTE_02:begin
                plane_pos = pos_x  ;
                turn_pos  = x_turn1;
                next_pos_x= pos_x+2;
                next_pos_y= pos_y+0;
                next_state=ROUTE_03;
                attitude=2;
            end
            ROUTE_03:begin
                plane_pos = pos_y  ;
                turn_pos  = y_turn2;
                next_pos_x= pos_x+1;
                next_pos_y= pos_y-1;
                next_state=ROUTE_04;
                attitude=3;
            end
            ROUTE_04:begin
                plane_pos = pos_y  ;
                turn_pos  = y_turn1;
                next_pos_x= pos_x+0;
                next_pos_y= pos_y-2;
                next_state=ROUTE_05;
                attitude=4;
            end
            ROUTE_05:begin
                plane_pos = pos_y  ;
                turn_pos  = y_turn0;
                next_pos_x= pos_x-1;
                next_pos_y= pos_y-1;
                next_state=ROUTE_06;
                attitude=5;
            end
            ROUTE_06:begin
                plane_pos = pos_x  ;
                turn_pos  = x_turn0;
                next_pos_x= pos_x-2;
                next_pos_y= pos_y+0;
                next_state=ROUTE_07;
                attitude=6;
            end
            ROUTE_07:begin
                plane_pos = pos_y  ;
                turn_pos  = y_turn1;
                next_pos_x= pos_x-1;
                next_pos_y= pos_y+1;
                next_state=ROUTE_08;
                attitude=7;
            end
            ROUTE_08:begin
                plane_pos = pos_y  ;
                turn_pos  = y_turn2;
                next_pos_x= pos_x+0;
                next_pos_y= pos_y+2;
                next_state= ROUTE_08;
                attitude=0;
            end
            default:begin
                plane_pos = 255  ;
                turn_pos  = 0   ;
                next_pos_x= pos_x+0;
                next_pos_y= pos_y+0;
                next_state=DEAD;
                attitude=0;
            end
        endcase
    end
    /**************状态机***************/
    always @(posedge clk) begin
        if(~rstn)begin
            pos_x<=0;
            pos_y<=0;
            liveFlag<=0;
            hp<=0;
            y_turn0<=0;
            y_turn1<=0;
            y_turn2<=0;
            y_turn3<=0;
            x_turn0<=0;
            x_turn1<=0;
        end
        else if(now_state==DEAD)begin
            if(create_pluse==1)begin//初始化
                pos_x<=Init_POS_X;
                pos_y<=Init_POS_Y;
                liveFlag<=1;
                hp<=3;
                y_turn0<=Init_POS_Y+50;
                y_turn1<=Init_POS_Y+50+20;
                y_turn2<=Init_POS_Y+50+20+40;
                y_turn3<=Init_POS_Y+50+20+40+20;
                x_turn0<=Init_POS_X+20;
                x_turn1<=Init_POS_X+20+80;
                now_state<=ROUTE_00;
            end
        end
        else if(update_clk_pluse)begin
            if(dead_flag)begin//死亡判断
                liveFlag<=0;
                now_state<=DEAD;
            end
            else begin
                pos_x<=next_pos_x;
                pos_y<=next_pos_y;
                if(hit_flag)
                    hp<=hp-1;
                if(turn_flag==1)//状态更新
                    now_state<=next_state;
                else
                    now_state<=now_state;
            end
        end
    end

//模块输出信号的幅值
assign PosX_out = pos_x;
assign PosY_out = pos_y;
assign Attitude = attitude;
assign isLive = liveFlag;

endmodule