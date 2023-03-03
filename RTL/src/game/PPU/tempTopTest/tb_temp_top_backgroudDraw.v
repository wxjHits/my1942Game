`timescale 1ns/1ps

module tb_temp_top_backgroudDraw ();

    reg  clk;
    reg  rstn;
    wire            hsync       ;
    wire            vsync       ;
    wire    [11:0]  rgb         ;

    temp_top_backgroudDraw u_temp_top_backgroudDraw(
        .clk   (clk   ) ,
        .rstn  (rstn  ) ,
        .hsync (hsync ) ,
        .vsync (vsync ) ,
        .rgb   (rgb   )  
    );

    initial begin
        clk=0;
        rstn=0;
        #100;
        rstn=1;
    end
    always #4 clk=~clk;

endmodule //moduleName
