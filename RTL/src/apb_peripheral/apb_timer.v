// BASE_ADDR:0x40005000
// 0x00 RW    CTRL[1:0]
//              [2] PWM_out Enable
//              [1] Timer Interrupt Enable
//              [0] Enable
// 0x04 RW    Current Value[31:0]
// 0x08 RW    Reload Value[31:0]
// 0x0C R/Wc  Timer Interrupt
//              [0] Interrupt, right 1 to clear
// 0x10 RW    INVERSE Value[31:0]
//-------------------------------------
module apb_timer (
    input  wire        PCLK     ,   // PCLK for timer operation
    input  wire        PCLKG    ,   // Gated clock
    input  wire        PRESETn  ,   // Reset

    input  wire        PSEL     ,   // Device select
    input  wire [15:0] PADDR    ,   // Address
    input  wire        PENABLE  ,   // Transfer control
    input  wire        PWRITE   ,   // Write control
    input  wire [31:0] PWDATA   ,   // Write data

    input  wire  [3:0] ECOREVNUM,   // Engineering-change-order revision bits

    output wire [31:0] PRDATA   ,   // Read data
    output wire        PREADY   ,   // Device ready
    output wire        PSLVERR  ,   // Device error response

    output wire        PWM_out  ,   //PWM mode out
    output wire        TIMERINT     // Timer interrupt output
); 

    // Signals for read/write controls
    wire          read_enable       ;
    wire          write_enable      ;
    wire          write_enable00    ; // Write enable for Control register
    wire          write_enable04    ; // Write enable for Current Value register
    wire          write_enable08    ; // Write enable for Reload Value register
    wire          write_enable0c    ; // Write enable for Interrupt register
    wire          write_enable10    ;
    reg     [7:0] read_mux_byte0    ;
    reg     [7:0] read_mux_byte0_reg;
    reg    [31:0] read_mux_word     ;

    // Signals for Control registers
    reg     [2:0] reg_ctrl          ;
    reg    [31:0] reg_curr_val      ;
    reg    [31:0] reg_reload_val    ;
    reg    [31:0] reg_inverse_val   ;
    reg    [31:0] nxt_curr_val      ;

    // Internal signals
    reg           reg_timer_int     ; // Timer interrupt output register
    wire          timer_int_clear   ; // Clear timer interrupt status
    wire          timer_int_set     ;   // Set timer interrupt status
    wire          update_timer_int  ;// Update Timer interrupt output register
    reg           reg_pwm_out       ;

    // Start of main code
    // Read and write control signals
    assign  read_enable  = PSEL & (~PWRITE); // assert for whole APB read transfer
    assign  write_enable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer
    assign  write_enable00 = write_enable & (PADDR[11:2] == 10'h000);
    assign  write_enable04 = write_enable & (PADDR[11:2] == 10'h001);
    assign  write_enable08 = write_enable & (PADDR[11:2] == 10'h002);
    assign  write_enable0c = write_enable & (PADDR[11:2] == 10'h003);
    assign  write_enable10 = write_enable & (PADDR[11:2] == 10'h004);
// Write operations
    // Control register
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            reg_ctrl <= {3{1'b0}};
        else if (write_enable00)
            reg_ctrl <= PWDATA[2:0];
    end

    // Current Value register
    always @(posedge PCLK or negedge PRESETn)begin
        if (~PRESETn)
            reg_curr_val <= {32{1'b0}};
        else
            reg_curr_val <= nxt_curr_val;
    end

    // Reload Value register
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            reg_reload_val <= {32{1'b0}};
        else if (write_enable08)
            reg_reload_val <= PWDATA[31:0];
    end

    // Inverse Value register
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            reg_inverse_val <= 32'h5555_5555;
        else if (write_enable10)
            reg_inverse_val <= PWDATA[31:0];
    end

// Read operation, partitioned into two parts to reduce gate counts
// and improve timing

    // lower 8 bits -registered. Current value register mux not done here
    // because the value can change every cycle
    always @(PADDR or reg_ctrl or reg_reload_val or reg_timer_int)begin
        if(PADDR[11:5] == 7'h00) begin
            case (PADDR[4:2])
                3'h0: read_mux_byte0 =  {{6{1'b0}}, reg_ctrl};
                3'h1: read_mux_byte0 =   {8{1'b0}};
                3'h2: read_mux_byte0 =  reg_reload_val[7:0];
                3'h3: read_mux_byte0 =  {{7{1'b0}}, reg_timer_int};
                3'h4: read_mux_byte0 =  reg_inverse_val[7:0];
                default:  read_mux_byte0 =   {8{1'bx}};// x propagation
            endcase
        end
        else
            read_mux_byte0 =   {8{1'b0}};     //default read out value
    end

    // Register read data
    always @(posedge PCLKG or negedge PRESETn)begin
        if (~PRESETn)
            read_mux_byte0_reg <= {8{1'b0}};
        else if (read_enable)
            read_mux_byte0_reg <= read_mux_byte0;
    end

    // Second level of read mux
    always @(PADDR or read_mux_byte0_reg or reg_curr_val or reg_reload_val)begin
        if(PADDR[11:5] == 7'h00) begin
            case (PADDR[4:2])
                3'b001:   read_mux_word = {reg_curr_val[31:0]};
                3'b010:   read_mux_word = {reg_reload_val[31:8],read_mux_byte0_reg};
                3'b100:   read_mux_word = {reg_inverse_val[31:8],read_mux_byte0_reg};
                3'b000,3'b011:  read_mux_word = {{24{1'b0}} ,read_mux_byte0_reg};
                default : read_mux_word = {32{1'bx}};
            endcase
        end
        else
            read_mux_word = {{24{1'b0}} ,read_mux_byte0_reg};
    end

    // Output read data to APB
    assign PRDATA = (read_enable) ? read_mux_word : {32{1'b0}};
    assign PREADY  = 1'b1; // Always ready
    assign PSLVERR = 1'b0; // Always okay

    // Decrement counter
    always @(write_enable04 or PWDATA or reg_curr_val or reg_reload_val)begin
        if (write_enable04)
            nxt_curr_val = PWDATA[31:0]; // Software write to timer
        else if (reg_ctrl[0])begin
            if (reg_curr_val == {32{1'b0}})
                nxt_curr_val = reg_reload_val; // Reload
            else
                nxt_curr_val = reg_curr_val - 1'b1; // Decrement
        end
        else
            nxt_curr_val = reg_curr_val; // Unchanged
    end

    // Interrupt generation
    // Trigger an interrupt when decrement to 0 and interrupt enabled
    // and hold it until clear by software
    assign timer_int_set   = (reg_ctrl[0] & reg_ctrl[1] & (reg_curr_val==reg_inverse_val));
    //assign timer_int_clear = write_enable0c & PWDATA[0];
    //assign update_timer_int= timer_int_set | timer_int_clear;

    // Registering interrupt output
    always @(posedge PCLK or negedge PRESETn)begin
        if (~PRESETn)
            reg_timer_int <= 1'b0;
        else
            reg_timer_int <= timer_int_set;
    end

    //PWM_out
    always@(posedge PCLK or negedge PRESETn)begin
        if(~PRESETn)
            reg_pwm_out<=1'b0;
        else if((reg_curr_val<=reg_inverse_val)&(reg_ctrl[2]))
            reg_pwm_out<=1'b1;
        else
            reg_pwm_out<=1'b0;
    end

    // Connect to external
    assign TIMERINT = reg_timer_int;
    assign PWM_out = reg_pwm_out;

endmodule
