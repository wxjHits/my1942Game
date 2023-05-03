module colorbar_data_gen (
    
    input  [11:0 ] pixel_xpos   ,  //像素点横坐标
    input  [11:0 ] pixel_ypos   ,  //像素点纵坐标

    output reg [15:0]  rd_data      
);

always@(*)begin
    case (pixel_ypos[7:6])
        2'b00:rd_data=16'b00000_111111_00000;
        2'b01:rd_data=16'b11111_000000_00000;
        2'b10:rd_data=16'b00000_000000_11111;
        2'b11:rd_data=16'b00000_111111_11111;
    endcase
end
    
endmodule