// Select the pixel region of interest
module box_select
#(
    parameter tl_row = 10'd100, //top left corner row number
    parameter tl_col = 10'd100, //top left corner col number
    parameter box_width = 10'd50
)
(
    rst_n       ,
    cam_pclk    , //from cmos
    pos_vsync   , //posedge signal of vsync
    pos_href    , //posedge signal of herf
    cam_href    ,
    cmos_data_t , //16bit rgb565 from module cmos_capture_data
    box_data_out, //after processed data stream

    gray_en
);
    input           rst_n           ;
    input           cam_pclk        ;
    input           pos_vsync       ;
    input           pos_href        ;
    input           cam_href        ;
    input [15:0]    cmos_data_t     ;
    output[15:0]    box_data_out    ;
    output          gray_en       ;

    reg [15:0] h_cnt; //cnt for lines
    reg [15:0] p_cnt; //cnt for pixels

    assign gray_en = (h_cnt >= tl_row) && (h_cnt <= tl_row + box_width - 1) &&
                        (p_cnt >= 2*tl_col) && (p_cnt <= 2*(tl_col + box_width) - 1);
    wire box_data_out_b;
    wire paint_flag; //1：paint the pixel as box
    wire paint_up;   //1: paint the up edge
    wire paint_left; //1: paint the left edge
    wire paint_right; //1: paint the right edge
    wire paint_bottom; //1: paint the bottom edge

    assign paint_up = (h_cnt == (tl_row-1)) && (p_cnt >= 2*(tl_col-1)) && (p_cnt <= (2*tl_col + 2*box_width + 1));//前后多一个像素，包住采样区域
    assign paint_left = (h_cnt >= tl_row) && (h_cnt < (tl_row + box_width)) && (p_cnt >= 2*tl_col - 2) && (p_cnt <= 2*tl_col -1);
    assign paint_right = (h_cnt >= tl_row) && (h_cnt < (tl_row + box_width)) && (p_cnt >= 2*(tl_col + box_width)) && (p_cnt <= (2*(tl_col + box_width) + 1));
    assign paint_bottom = (h_cnt == (tl_row + box_width)) && (p_cnt >= 2*(tl_col-1)) && (p_cnt <= 2*(tl_col + box_width)+1);
    assign paint_flag = paint_up || paint_left || paint_right || paint_bottom;

    assign box_data_out = paint_flag ? 16'b0000011111111111 : cmos_data_t;
    //assign box_data_out = gray_en ? box_data_out_b : box_data_out_b;
    //assign box_data_out = gray_en ? 16'b0000011111100000 : box_data_out_b;
    // count for lines
    always@(posedge cam_pclk or negedge rst_n) begin
        if(!rst_n) begin
            h_cnt <= 15'd0;
        end
        else if(pos_vsync || (h_cnt == 15'd960)) //tp = 2*pclk
            h_cnt <= 15'd0;
        else if(pos_href)
            h_cnt <= h_cnt + 1'd1;
    end

    //count for pixels
    always@(posedge cam_pclk or negedge rst_n) begin
        if(!rst_n) begin
            p_cnt <= 15'd0;
        end
        else if(pos_href || (p_cnt == 15'd1280) || (~cam_href))
            p_cnt <= 15'd0;
        else
            p_cnt <= p_cnt + 1'd1;
    end

    //采样使能信号
endmodule