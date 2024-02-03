module top (input CLK_200M_P,
            CLK_200M_N,
            input [15:0] SW,
            input RSTN,
            input [3:0] BTN_Y,
            output [4:0] BTN_X,
            output SEGLED_CLK,
            output SEGLED_PEN,
            output SEGLED_DO,
            output LED_PEN,
            output LED_DO,
            output LED_CLK,
            output [3:0] VGA_R,
            output [3:0] VGA_G,
            output [3:0] VGA_B,
            output HS,
            output VS);
    
    
    
    // clock generator
    wire sys_clk, clk_disp;
    wire locked;
    wire clk200MHz, clk100MHz, clk50Mhz;
    
    clk_diff dual2single_clk (
    .clk200P(CLK_200M_P),
    .clk200N(CLK_200M_N),
    .clk200MHz(clk200MHz)
    );
    
    my_clk_gen clk_div (
    .clkin1(clk200MHz),
    .CLK_OUT1(clk100MHz), //100MHz
    .CLK_OUT2(clk50Mhz), //50MHz
    .CLK_OUT3(clk_disp), //25MHz
    .CLK_OUT4(sys_clk) //10MHz
    );
    
    wire [6:0] debug_addr;
    wire [31:0] debug_data;

    assign debug_addr = 7'b0;
    assign debug_data = 32'h0;
    
    
    VGA_TESTP vga(.clk(clk100MHz),
    .clk25(clk_disp),
    .Debug_addr(debug_addr),
    .Debug_data(debug_data),
    .SWO15(SW[15]),
    .SWO14(SW[14]),
    .SWO13(SW[13]),
    .Red(VGA_R),
    .Green(VGA_G),
    .Blue(VGA_B),
    .VSYNC(VS),
    .HSYNC(HS));
    
    // reset
    reg rst_all;
    reg [15:0] rst_count = 16'hFFFF;
    
    // btn
    btn_scan #(
    .CLK_FREQ(25)
    ) BTN_SCAN (
    .clk(clk_disp),
    .rst(1'b0),
    .btn_x(BTN_X),
    .btn_y(BTN_Y),
    .result(btn)
    );

    wire [31:0] disp_data;
    assign disp_data = 32'h0;
    
    display DISPLAY (
    .clk(clk_disp),
    .rst(rst_all),
    .en(8'b11111111),
    .data(0),
    .dot(8'b00000000),
    .led(~{1'b0, 1'b0, 6'b0, SW[7:0]}),
    .led_clk(LED_CLK),
    .led_en(LED_PEN),
    .led_do(LED_DO),
    .seg_clk(SEGLED_CLK),
    .seg_en(SEGLED_PEN),
    .seg_do(SEGLED_DO),
    .led_clr_n(),
    .seg_clr_n()
    );
    
    
endmodule
