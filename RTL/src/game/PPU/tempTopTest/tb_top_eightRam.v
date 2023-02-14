
`timescale 1ns/1ps
module tb_top_eightRam();

    reg         clk_50MHz   ;
    reg         rstn        ;
    wire        hsync       ;
    wire        vsync       ;
    wire[11:0]  rgb         ;

    top_eightRamTest U_top_eightRamTest (
        .clk_50MHz(clk_50MHz),
        .rstn     (rstn     ),
        .hsync    (hsync    ),
        .vsync    (vsync    ),
        .rgb      (rgb      )
    );

    initial begin
        clk_50MHz=0;
        rstn=0;
        #100
        rstn=1;
    end
    always#2 clk_50MHz=~clk_50MHz;
    
endmodule