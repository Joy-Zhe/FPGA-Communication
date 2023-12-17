module top(
    input           sys_clk,
    input           sys_rst_n,

    input           uart_rxd,
    output          uart_txd,
    output reg [3:0] led,
    // lcd
    output lcd_de,
    output lcd_hs,
    output lcd_vs,
    output lcd_clk,
    output lcd_rst,
    inout [23:0] lcd_rgb,
    output lcd_bl
    );

//parameter define
parameter  CLK_FREQ = 12500000;
parameter  UART_BPS = 9600;
    
//wire define   
wire       uart_recv_done;
wire [7:0] uart_recv_data;
wire       uart_send_en;
wire [7:0] uart_send_data;
wire       uart_tx_busy;

wire      clk_25M;
wire      clk_10M;
wire      clk_12_5M;

reg [1:0] led_state = 0;

always @(posedge clk_12_5M or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        led_state <= 0;
        led <= 0;
    end
    else begin
        if (uart_recv_done) begin
            led_state <= led_state + 1;
            case (led_state)
                2'b00: led <= 4'b0001;
                2'b01: led <= 4'b0010;
                2'b10: led <= 4'b0100;
                2'b11: led <= 4'b1000; 
                default: led <= 4'b0000;
            endcase
        end
    end
end

clk_div_UART udiv(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .clk_25M        (clk_25M),
    .clk_10M        (clk_10M),
    .clk_12_5M      (clk_12_5M)
    );
    
uart_recv #(                          
    .CLK_FREQ       (CLK_FREQ),
    .UART_BPS       (UART_BPS))
u_uart_recv(                 
    .sys_clk        (clk_12_5M), 
    .sys_rst_n      (sys_rst_n),
    
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_recv_done),
    .uart_data      (uart_recv_data)
    );

uart_send #(                          
    .CLK_FREQ       (CLK_FREQ),
    .UART_BPS       (UART_BPS))
u_uart_send(                 
    .sys_clk        (clk_12_5M),
    .sys_rst_n      (sys_rst_n),
     
    .uart_en        (uart_send_en),
    .uart_din       (uart_send_data),
    .uart_tx_busy   (uart_tx_busy),
    .uart_txd       (uart_txd)
    );
    
uart_loop u_uart_loop(
    .sys_clk        (clk_12_5M),             
    .sys_rst_n      (sys_rst_n),           
   
    .recv_done      (uart_recv_done),
    .recv_data      (uart_recv_data),
   
    .tx_busy        (uart_tx_busy),
    .send_en        (uart_send_en),
    .send_data      (uart_send_data)
    );
    

    //LCD

    wire [15:0] lcd_id;
    wire lcd_pclk;
    wire [10:0] pixel_x;
    wire [10:0] pixel_y;
    wire [10:0] h_disp;
    wire [10:0] v_disp;
    wire [23:0] pixel_data;
    wire [23:0] lcd_rgb_out;
    wire [23:0] lcd_rgb_in;

    assign lcd_rgb = lcd_de ? lcd_rgb_out : {24{1'bz}};
    assign lcd_rgb_in = lcd_rgb;

    read_id id(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .id(lcd_id),
        .rgb(lcd_rgb_in)
    );

    clk_div u_clk_div(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .lcd_id(lcd_id),
        .lcd_pclk(lcd_pclk)
    );

    driver u_driver(
        .rst_n(sys_rst_n),
        .lcd_pclk(lcd_pclk),
        .lcd_id(lcd_id),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .h_disp(h_disp),
        .v_disp(v_disp),
        .pixel_data(pixel_data),
        .lcd_de(lcd_de),
        .lcd_hs(lcd_hs),
        .lcd_vs(lcd_vs),
        .lcd_bl(lcd_bl),
        .lcd_clk(lcd_clk),
        .lcd_rgb(lcd_rgb_out),
        .lcd_rst(lcd_rst)
    );

    display u_display(
        .lcd_pclk(lcd_pclk),
        .rst_n(sys_rst_n),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .h_disp(h_disp),
        .v_disp(v_disp),
        .pixel_data(pixel_data)
    );
endmodule