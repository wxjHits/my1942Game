/********************************************/
/*   LCD                                    */
/*   update_clk     0X5003_0000             */
/*   create         0X5003_0004             */
/*   Hit            0X5003_0008             */
/*   Init_POS_X     0X5003_000C             */
/*   Init_POS_Y     0X5003_0010             */
/*   PosX_out       0X5003_0014             */
/*   PosY_out       0X5003_0018             */
/*   Attitude       0X5003_001C             */
/*   isLive         0X5003_0020             */
/********************************************/
module ahb_plane_interface(
    input  wire                         HCLK,    
    input  wire                         HRESETn, 
    input  wire                         HSEL,    
    input  wire   [31:0]                HADDR,   
    input  wire    [1:0]                HTRANS,  
    input  wire    [2:0]                HSIZE,   
    input  wire    [3:0]                HPROT,   
    input  wire                         HWRITE,  
    input  wire   [31:0]                HWDATA,  
    input  wire                         HREADY,  
	
    output wire                         HREADYOUT, 
    output wire    [31:0]               HRDATA,  
    output wire                         HRESP,

    //m_enemyPlane_logic.v
    input  wire     [7:0]               PosX_out    ,//用于碰撞Mask和绘图
    input  wire     [7:0]               PosY_out    ,//用于碰撞Mask和绘图
    input  wire     [7:0]               Attitude    ,//用于判断当前单位应该是动画的第几帧
    input  wire                         isLive      ,//用于CPU获取单位状态
    output reg                          update_clk  ,//数据更新clk
    output reg                          create      ,//创建单位
    output reg                          Hit         ,//被击中
    output reg      [7:0]               Init_POS_X  ,
    output reg      [7:0]               Init_POS_Y  
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

wire read_en;
assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;

wire write_en;
assign write_en=HSEL&HTRANS[1]&(HWRITE)&HREADY;

reg [5:0] addr;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) addr <= 6'b0;
  else if(read_en || write_en) addr <= HADDR[7:2];
end

reg write_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) write_en_reg <= 1'b0;
  else if(write_en) write_en_reg <= 1'b1;
  else  write_en_reg <= 1'b0;
end

//写寄存器
wire write_update_clk_en        = addr == 6'h00 & write_en_reg;
wire write_create_en            = addr == 6'h01 & write_en_reg;
wire write_hit_clk_en           = addr == 6'h02 & write_en_reg;
wire write_init_pos_x_clk_en    = addr == 6'h03 & write_en_reg;
wire write_init_pos_y_clk_en    = addr == 6'h04 & write_en_reg;

// reg         update_clk  ;
// reg         create      ;
// reg         Hit         ;
// reg [7:0]   Init_POS_X  ;
// reg [7:0]   Init_POS_Y  ;

always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
        update_clk  <=  0;
        create      <=  0;
        Hit         <=  0;
        Init_POS_X  <=  0;
        Init_POS_Y  <=  0;
    end 
    else begin
        if (write_update_clk_en) 
            update_clk <= HWDATA[0];
        if (write_create_en) 
            create <= HWDATA[0];
        if (write_hit_clk_en)
            Hit <= HWDATA[0];
        if (write_init_pos_x_clk_en)
            Init_POS_X <= HWDATA[7:0];
        if (write_init_pos_y_clk_en)
            Init_POS_Y <= HWDATA[7:0];
    end
end

//-------------------------------------------------------------------       
//                  HRDATA DECODER
//-------------------------------------------------------------------

assign HRDATA    =  (   addr == 6'h00   ) ?  {31'b0,update_clk      }  :   (         
                    (   addr == 6'h01   ) ?  {31'b0,create          }  :   (
                    (   addr == 6'h02   ) ?  {31'b0,Hit             }  :   (
                    (   addr == 6'h03   ) ?  {24'b0,Init_POS_X      }  :   (
                    (   addr == 6'h04   ) ?  {24'b0,Init_POS_Y      }  :   (
                    (   addr == 6'h05   ) ?  {24'b0,PosX_out        }  :   (
                    (   addr == 6'h06   ) ?  {24'b0,PosY_out        }  :   (
                    (   addr == 6'h07   ) ?  {24'b0,Attitude        }  :   (
                    (   addr == 6'h08   ) ?  {31'b0,isLive          }  :   32'b0))))))));

endmodule


