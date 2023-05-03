module colorbar_top(
    input wire sys_clk,
    input wire rstn   ,

    output         tmds_clk_p   ,  // TMDS 时钟通道
    output         tmds_clk_n   ,
    output [2:0]   tmds_data_p  ,  // TMDS 数据通道
    output [2:0]   tmds_data_n
);

    wire [11:0 ] pixel_xpos   ;  //像素点横坐标
    wire [11:0 ] pixel_ypos   ;  //像素点纵坐标
    wire [15:0]  rd_data      ;

    wire        hdmi_clk      ;
    wire        hdmi_clk_5    ;

    clk_pll u_clk_pll (
        .refclk(sys_clk),//50MHz
        .clk0_out(hdmi_clk),//25MHz
        .clk1_out(hdmi_clk_5) ////125MHz
    );

hdmi_driver u_hdmi_driver(
    .hdmi_clk   (hdmi_clk   )  ,
    .hdmi_clk_5 (hdmi_clk_5 )  ,
    .rstn      (rstn      )  ,
    .pixel_xpos (pixel_xpos )  ,  //像素点横坐标
    .pixel_ypos (pixel_ypos )  ,  //像素点纵坐标
    .rd_data    (rd_data    )  ,
    .tmds_clk_p (tmds_clk_p )  ,  // TMDS 时钟通道
    .tmds_clk_n (tmds_clk_n )  ,
    .tmds_data_p(tmds_data_p)  ,  // TMDS 数据通道
    .tmds_data_n(tmds_data_n)
);

colorbar_data_gen u_colorbar_data_gen (
    .pixel_xpos(pixel_xpos)   ,  //像素点横坐
    .pixel_ypos(pixel_ypos)   ,  //像素点纵坐标
    .rd_data   (rd_data   )   
);

endmodule