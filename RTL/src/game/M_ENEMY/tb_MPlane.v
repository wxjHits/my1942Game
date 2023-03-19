module tb_MPlane ();

    reg             clk         ;//系统时钟50MHz
    reg             rstn        ;
    reg             update_clk  ;//数据更新clk
    reg             create      ;//创建单位
    reg             Hit         ;//被击中
    //初始化的数据
    reg     [7:0]   Init_POS_X  ;
    reg     [7:0]   Init_POS_Y  ;
    wire    [7:0]   PosX_out    ;
    wire    [7:0]   PosY_out    ;
    wire    [7:0]   Attitude    ;
    wire            isLive      ;

    m_enemyPlane_logic u_m_enemyPlane_logic(
        .clk         (clk       ),//系统时钟50MHz
        .rstn        (rstn      ),
        .update_clk  (update_clk),//数据更新clk
        .create      (create    ),//创建单位
        .Hit         (Hit       ),//被击中
        .Init_POS_X  (Init_POS_X),
        .Init_POS_Y  (Init_POS_Y),
        .PosX_out    (PosX_out  ),
        .PosY_out    (PosY_out  ),
        .Attitude    (Attitude  ),
        .isLive      (isLive    )
    );

    initial begin
        clk=0;
        rstn=0;
        // update_clk=0;
        create=0;
        Hit=0;
        Init_POS_X=50;
        Init_POS_Y=40;
        #10
        rstn=1;
        #100
        create=1;
        #2
        create=0;
    end
    always #1 clk=~clk;
    reg [7:0]cnt=0;
    localparam CNT_MAX=20;
    always @(posedge clk) begin
        if(cnt>=CNT_MAX)
            cnt<=0;
        else
            cnt<=cnt+1'b1;
    end
    always@(*)begin
        if(cnt==CNT_MAX)
            update_clk=1;
        else
            update_clk=0;
    end

endmodule