// module uart_loopback_top(
//     input           sys_clk,
//     input           sys_rst_n,

//     input           uart_rxd,
//     output          uart_txd
//     );

// //parameter define
// parameter  CLK_FREQ = 12500000;
// parameter  UART_BPS = 9600;
    
// //wire define   
// wire       uart_recv_done;
// wire [7:0] uart_recv_data;
// wire       uart_send_en;
// wire [7:0] uart_send_data;
// wire       uart_tx_busy;

// wire      clk_25M;
// wire      clk_10M;
// wire      clk_12_5M;

// clk_div udiv(
//     .clk            (sys_clk),
//     .rst_n          (sys_rst_n),
//     .clk_25M        (clk_25M),
//     .clk_10M        (clk_10M),
//     .clk_12_5M      (clk_12_5M)
//     );
    
// uart_recv #(                          
//     .CLK_FREQ       (CLK_FREQ),
//     .UART_BPS       (UART_BPS))
// u_uart_recv(                 
//     .sys_clk        (clk_12_5M), 
//     .sys_rst_n      (sys_rst_n),
    
//     .uart_rxd       (uart_rxd),
//     .uart_done      (uart_recv_done),
//     .uart_data      (uart_recv_data)
//     );

// uart_send #(                          
//     .CLK_FREQ       (CLK_FREQ),
//     .UART_BPS       (UART_BPS))
// u_uart_send(                 
//     .sys_clk        (clk_12_5M),
//     .sys_rst_n      (sys_rst_n),
     
//     .uart_en        (uart_send_en),
//     .uart_din       (uart_send_data),
//     .uart_tx_busy   (uart_tx_busy),
//     .uart_txd       (uart_txd)
//     );
    
// uart_loop u_uart_loop(
//     .sys_clk        (clk_12_5M),             
//     .sys_rst_n      (sys_rst_n),           
   
//     .recv_done      (uart_recv_done),
//     .recv_data      (uart_recv_data),
   
//     .tx_busy        (uart_tx_busy),
//     .send_en        (uart_send_en),
//     .send_data      (uart_send_data)
//     );
    
// endmodule