`timescale 1ns/1ps

module all_top_tb;

reg CLK_200M_P;
reg CLK_200M_N;
reg RSTN;
reg uart_rxd;
wire uart_txd;

all_top #(
    .SYSTEM_CLK(200000000),
    .UART_BPS(10000),
    .FIFO_DEPTH(42),
    .DATA_WIDTH(32)
)
uAT(
    .CLK_200M_P(CLK_200M_P),
    .CLK_200M_N(CLK_200M_N),
    .RSTN(RSTN),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd)
);

initial begin
    CLK_200M_P = 1;
    CLK_200M_N = 0;
    RSTN = 0;
    uart_rxd = 1;

    #100000;
    RSTN = 1;
    uart_rxd = 1;

    #300000;
    uart_rxd = 1;

    send_byte(8'h12);
    send_byte(8'h34);
    send_byte(8'h56);
    send_byte(8'h78);

    #300000;
    uart_rxd = 1;

    send_byte(8'hab);
    send_byte(8'hcd);
    send_byte(8'hef);
    send_byte(8'h12);

    #100;
    $finish;
end

always #5 CLK_200M_P = ~CLK_200M_P;
always #5 CLK_200M_N = ~CLK_200M_N;

task send_byte;
    input [7:0] byte;
    integer i;
    begin
        uart_rxd = 0;
        #200000;
        for (i = 0; i < 8; i = i + 1) begin
            uart_rxd = byte[i];
            #200000;
        end
        uart_rxd = 1;
        #600000;
    end
endtask

endmodule