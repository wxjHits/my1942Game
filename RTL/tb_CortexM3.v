`timescale 1ns/1ps
module tb_CortexM3 ();

reg            CLK50m;
reg            RSTn;


CortexM3 tb_u_CortexM3(
    .CLK50m(CLK50m),
    .RSTn  (RSTn  ) 
);
initial begin
    CLK50m=0;
    RSTn=0;
    #10
    RSTn=1;
    #15000000;
    $stop();
end

always #1 CLK50m=~CLK50m;

endmodule
