/* 灰度流缓存 双口ram*/
module linebuffer
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 5,
    parameter IMG_WIDTH = 28
)
(
    clkw    ,
    w_en    ,
    waddr   ,
    din     ,

    clkr    ,
    r_en    ,
    raddr   ,
    dout
);
    input                                   clkw    ;
    input                                   clkr    ;
    input                                   w_en    ;
    input                                   r_en    ;
    input  [ADDR_WIDTH-1:0]    waddr   ;
    input  [ADDR_WIDTH-1:0]    raddr   ;
    input  [DATA_WIDTH-1:0]             din     ;

    output reg [DATA_WIDTH-1:0] dout;

    reg [DATA_WIDTH-1:0] buffer [IMG_WIDTH-1:0];

    always@(posedge clkw) begin
        if(w_en)
            buffer[waddr] <= din;
        else
            ;
    end

    always@(posedge clkr) begin
        if(r_en)
            dout <= buffer[raddr];
        else
            ;
    end


endmodule
