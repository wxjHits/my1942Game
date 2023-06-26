module add_tree_conv1 (
    clk                 ,
    add_tree_data_in    ,
    add_tree_data_out
);
    input                   clk                 ;
    input  signed [26*16-1:0]     add_tree_data_in    ;
    output signed [16-1:0]        add_tree_data_out   ;

    reg signed [16-1:0] add0 [12:0]; // 26/2=13
    reg signed [16-1:0] add1 [6:0]; // 13/2=6
    reg signed [16-1:0] add2 [3:0]; // 8/2=4
    reg signed [16-1:0] add3 [1:0];
    wire signed [32-1:0] add_tree_data_out_01;
    integer i;
    always @(posedge clk) begin
        for(i=0; i<13; i=i+1) begin
            add0[i] <= add_tree_data_in[(i*32)+:16] + add_tree_data_in[(i*32+16)+:16];
        end
        for(i=0; i<6; i=i+1) begin
            add1[i] <= add0[i*2] + add0[i*2+1];
        end
        add1[6] <= add0[12];
        for(i=0; i<3; i=i+1)begin
            add2[i] <= add1[i*2] + add1[i*2+1];
        end
        add2[3]<= add1[6]+0;
         //=========add3============
        for(i=0; i<2; i=i+1)begin
            add3[i] <= add2[i*2] + add2[i*2+1];
        end
    end
    assign add_tree_data_out = add3[0] + add3[1];
    //assign add_tree_data_out_01 = (add3[0] + add3[1]) << 8;
    //assign add_tree_data_out = add_tree_data_out_01 >> 12;
endmodule //add_tree_conv1