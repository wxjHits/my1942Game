/****************************/
//作者:Wei Xuejing
//邮箱:2682152871@qq.com
//描述:spi
//时间:2022.10.08
/****************************/

module spi
#(
    parameter BIT = 8
)(
    input               clk             ,   //系统时钟
    input               rstn            ,   //系统复位型号

    input   [7:0]       clk_div         ,   //时钟分频 4~255
    input               cs              ,   //片选信号

    input               tx_req          ,   //发送请求信号
    input   [BIT-1: 0]  data_tx         ,   //待发送的数据
    output  [BIT-1: 0]  data_rx         ,   //接受到的数据
    output              spi_ready       ,   //SPI一次发送完成信号

    //SPI
    output  reg         SPI_CLK         ,
    output  reg         SPI_CS          ,
    output  reg         SPI_MOSI        ,
    input               SPI_MISO        
);


    //reg & wire 定义
    reg  [7:0] div_cnt      ;   //时钟分频计数器
    reg  [7:0] HALF_PERIOD_DIV;
    always@(posedge clk)begin
        HALF_PERIOD_DIV <= clk_div>>1;
    end

    wire half_bit_flag      ;
    wire bit_mid_flag       ;   //bit中间的标志位
    wire bit_tail_flag      ;   //bit截为的标志位

    reg  spi_ready_r        ;   //spi空闲
    reg  tx_en              ;   //spi 发送使能信号
    wire spi_start          ;
    wire spi_end            ;
    assign spi_start = spi_ready_r & tx_req & ~cs;
    //传输使能的标志位
    always@(posedge clk)begin
        if(~rstn)
            tx_en<=1'b0;
        else begin
            if(spi_start)
                tx_en<=1'b1;
            else if(spi_end)
                tx_en <= 1'b0;
        end
    end

    always@(posedge clk)begin
        if(~rstn)
            spi_ready_r<=1'b1;
        else begin
            if(spi_end)
                spi_ready_r<=1'b1;
            else if(tx_en)
                spi_ready_r<=1'b0;
        end
    end
    //时钟分频计数器
    always @(posedge clk) begin
        if(tx_en==1'b1)begin
            if(div_cnt>=HALF_PERIOD_DIV-1)
                div_cnt<='d0;
            else
                div_cnt<=div_cnt+1'b1;
        end
        else
            div_cnt<='d0;
    end

    //半周期标志位
    assign half_bit_flag = (div_cnt==HALF_PERIOD_DIV-1)?1'b1:1'b0;

    //半周期的计数
    reg [BIT:0] half_bit_cnt ;
    always@(posedge clk)begin
        if(tx_en==1'b1)begin
            if(half_bit_flag==1'b1)
                half_bit_cnt<=half_bit_cnt+1'b1;
            else
                half_bit_cnt<=half_bit_cnt;
        end
        else
            half_bit_cnt<='d0;
    end

    //移位信号的生成
    assign bit_mid_flag  = half_bit_flag & (half_bit_cnt[0]==1'b0) & (tx_en==1'b1);
    assign bit_tail_flag = half_bit_flag & (half_bit_cnt[0]==1'b1) & (tx_en==1'b1);

    //数据移位使能
    reg shift_en;
    always@(posedge clk)begin
        if(~rstn)
            shift_en<=0;
        else if(bit_mid_flag)begin
            if(half_bit_cnt[BIT:1]==0)
                shift_en <=1'b1;
            else if(half_bit_cnt[BIT:1]==BIT)
                shift_en <=1'b0;
        end
    end

    //CS片选信号的生成
    always@(posedge clk)begin
        if(!rstn)
            SPI_CS<=1'b1;
        else
            SPI_CS<=cs;
    end

    //发送移位寄存器的并转串输出,输入
    // reg [BIT-1:0]  data_tx_r ;
    // always@(posedge clk)begin
    //     if(~rstn)
    //         data_tx_r<='d0;
    //     else
    //         data_tx_r<=data_tx;
    // end
    wire shift_load;
    reg [BIT-1:0] shift_reg;
    assign shift_load = tx_en & spi_ready_r;
    always @(posedge clk) begin
        if(~rstn)begin
            shift_reg<={BIT{1'b0}};
            SPI_MOSI<=1'b0;
        end
        else begin
            if(shift_load==1'b1)
                shift_reg<=data_tx;
            else begin
                if(shift_en==1'b1 && bit_tail_flag==1'b1)begin
                    SPI_MOSI<=shift_reg[BIT-1];
                    shift_reg<=shift_reg<<1;
                end
                else if(shift_en==1'b1 && bit_mid_flag==1'b1)
                    shift_reg[0]<=SPI_MISO;
            end
        end
    end

    //SPI_CLK时钟生成
    reg spi_clk_en;
    always@(posedge clk)begin
        if(~rstn)
            spi_clk_en<=0;
        else begin
            if(half_bit_cnt[BIT:1]==0 && bit_tail_flag==1'b1)
                spi_clk_en<=1'b1;
            else if(half_bit_cnt[BIT:1]==BIT && bit_tail_flag==1'b1)
                spi_clk_en<=1'b0;
        end
    end

    always@(posedge clk)begin
        if(~rstn)
            SPI_CLK<=0;
        else if(spi_clk_en)begin
            if(bit_mid_flag||bit_tail_flag)
                SPI_CLK<=~SPI_CLK;
        end
        else
            SPI_CLK<=0;
    end

    //传输完成标志位
    assign spi_end = half_bit_cnt[BIT:1]==BIT && bit_tail_flag;

    //输出端口赋值
    assign data_rx = shift_reg ;
    assign spi_ready = spi_ready_r;
endmodule