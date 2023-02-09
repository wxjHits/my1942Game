
module buzzerDriver (
    input  wire clk,//50MHz
    input  wire rstn,

    // input  wire key,

    output wire buzzer
);

    reg [7:0] cnt;
    reg [7:0] cntMax;

    localparam DIVMAX = 100_000_000;//分频系数,分出sampleClk
    reg [31:0] divCnt;
    reg sampleClk ;//可以取为
    always@(posedge clk)begin
        if(~rstn)
            divCnt<=0;
        else if(divCnt<DIVMAX>>1-1)
            divCnt<=divCnt+1;
        else
            divCnt<=0;
    end

    always@(posedge clk)begin
        if(~rstn)
            sampleClk<=0;
        else if(divCnt==DIVMAX>>1-1)
            sampleClk<=1;
        else
            sampleClk<=0;
    end
    
    always@(posedge clk)begin
        if(~rstn)
            cntMax<=100;
        else if(sampleClk==1)
            cntMax<=cntMax+5;
        else
            cntMax<=cntMax;
    end

    always@(posedge clk)begin
        if(~rstn)
            cnt<=0;
        else
            cnt<=cnt+1;
    end

    assign buzzer = (cnt<cntMax)?1'b1:1'b0;
endmodule