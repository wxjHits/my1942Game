module ppu_hdmi_driver(
    input 		   hdmi_clk     ,//640*480@60Hz:25.2MHz
    input 		   hdmi_clk_5   ,//640*480@60Hz:25.2MHz*5
    input 		   rstn         ,//
    
    output [11:0 ] pixel_xpos   ,//像素点横坐标
    output [11:0 ] pixel_ypos   ,//像素点纵坐标
    input  [15:0]  rd_data      ,

    input   wire   IsGameWindow ,
    
    //HDMI OUT PIN
    output         tmds_clk_p   ,// TMDS 时钟通道
    output         tmds_clk_n   ,
    output [2:0]   tmds_data_p  ,// TMDS 数据通道
    output [2:0]   tmds_data_n  
);

//wire define
wire         video_hs      ;
wire         video_vs      ;
wire         video_de      ;
wire [23:0 ] video_rgb     ;

//例化视频显示驱动模块
ppu_video_driver u_ppu_video_driver(
    .pixel_clk      (hdmi_clk    ),
    .sys_rst_n      (rstn       ),

    .pixel_xpos     (pixel_xpos  ),
    .pixel_ypos     (pixel_ypos  ),
    .video_rgb_565  (rd_data     ),

    .IsGameWindow   (IsGameWindow),

    .video_hs       (video_hs    ),
    .video_vs       (video_vs    ),
    .video_de       (video_de    ),
    .video_rgb      (video_rgb   ) 
    );

//例化HDMI驱动模块
dvi_transmitter u_rgb2dvi(
    .pclk           (hdmi_clk   ),
    .pclk_x5        (hdmi_clk_5 ),
    .reset_n        (rstn      ),

    .video_din      (video_rgb  ),
    .video_hsync    (video_hs   ),
    .video_vsync    (video_vs   ),
    .video_de       (video_de   ),

    .tmds_clk_p     (tmds_clk_p ),
    .tmds_clk_n     (tmds_clk_n ),
    .tmds_data_p    (tmds_data_p),
    .tmds_data_n    (tmds_data_n)
    );

endmodule