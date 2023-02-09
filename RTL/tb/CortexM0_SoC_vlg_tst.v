`timescale 1 ns/ 1 ps
module CortexM0_SoC_vlg_tst();

reg clk;
reg RSTn;
reg SPI_MISO;

CortexM0_SoC i1 (
    .clk(clk),
    .RSTn(RSTn),
    .SPI_MISO(SPI_MISO)
);

initial begin                                                  
    clk = 0;
    RSTn=0;
    #100
    RSTn=1;
end 

always begin                                                  
    #1 clk = ~clk;
end       

initial begin
    SPI_MISO = 0;
    #4200
    SPI_MISO = 1;
    #180
    SPI_MISO = 0;
end
endmodule
