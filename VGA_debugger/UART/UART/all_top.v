module all_top(
    input           CLK_200M_P,            
    input           CLK_200M_N,
    input           RSTN,          

    input           uart_rxd,           
    output          uart_txd
    // output          led_out
    );

    wire sys_clk;

    clk_diff u_clk_diff(
        .clk200P(CLK_200M_P),
        .clk200N(CLK_200M_N),
        .clk200MHz(sys_clk)
    );

    top #(.CLK_FREQ(200000000),
        .UART_BPS(9600),
        .FIFO_DEPTH(42),
        .DATA_WIDTH(32))
    u_top (
        .sys_clk(sys_clk),
        .sys_rst_n(RSTN),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd)
        // .led_out(led_out)
    );

endmodule