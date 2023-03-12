`timescale 1ns/1ps
module tb_pRandomNum();

    reg             clk     ;
    reg             enable    ;
    wire [8-1:0]    dataO   ;

    pRandomNum tb_pRandomNum(
        .clk  (clk  ),
        .enable (enable ),
        .dataO(dataO)
    );

    initial begin
        clk=0;
        enable=0;
        #10
        enable=1;
    end
    always #1 clk=~clk;

endmodule