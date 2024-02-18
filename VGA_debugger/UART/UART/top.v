module top(
    input           sys_clk,            
    input           sys_rst_n,          

    input           uart_rxd,           
    output          uart_txd,
    output [7:0] led_out         
    );

parameter  CLK_FREQ = 200000000;        //sys_clk = 200MHz
parameter  UART_BPS = 115200;           //
parameter  FIFO_DEPTH = 42;
parameter  DATA_WIDTH = 32;

wire       uart_recv_done;              
wire [7:0] uart_recv_data;              
wire       uart_send_en;                
wire [7:0] uart_send_data;              
wire       uart_tx_busy;     

reg new_byte_ready = 0; // 1: new byte received, 0: no new byte

// buffer for a single 32-bit data
reg [1:0] byte_count = 0; // 0: 1st byte, 1: 2nd byte, 2: 3rd byte, 3: 4th byte
reg [31:0] data_buffer;   // reassemble 4 bytes into a 32-bit data

// FIFO
wire [31:0] fifo_din;
reg wr_en;
wire [5:0] data_count;
wire rd_en = (data_count >= 6'd2) ? 1'b1 : 1'b0;
wire [31:0] fifo_dout;

reg [63:0] debug_output = 0;

assign fifo_din = data_buffer;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        byte_count <= 2'b0;
        data_buffer <= 32'b0;
        wr_en <= 0;
    end
    else begin
        if (wr_en) begin // disable write when data_buffer is not ready
            wr_en <= 0;
        end

        if (uart_recv_done && ~new_byte_ready) begin
            new_byte_ready <= 1; // set new_byte_ready
            case (byte_count)
                0:  data_buffer[7:0] <= uart_recv_data;
                1:  data_buffer[15:8] <= uart_recv_data;
                2:  data_buffer[23:16] <= uart_recv_data;
                3:  begin
                    data_buffer[31:24] <= uart_recv_data;
                    wr_en <= 1;
                end
                // default: wr_en <= 0;
            endcase
            byte_count <= (byte_count + 1) % 4; // update byte_count
        end
        else if (!uart_recv_done) begin 
            // no new data but next byte start, wr_en <= 0, ready <= 0, prepare for next byte
            new_byte_ready <= 0;  
            // wr_en <= 0;
        end
    end
end

uart_recv #(                          
    .CLK_FREQ       (CLK_FREQ),         
    .UART_BPS       (UART_BPS))         
u_uart_recv(                 
    .sys_clk        (sys_clk), 
    .sys_rst_n      (sys_rst_n),
    
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_recv_done),
    .uart_data      (uart_recv_data)
    );

fifo_42 u_fifo (
  .clk(sys_clk),                // input wire clk
  .rst_n(sys_rst_n),            // input wire rst_n
  .din(fifo_din),               // input wire [31 : 0] din
  .wr_en(wr_en),                // input wire wr_en
  .rd_en(rd_en),                // input wire rd_en
  .dout(fifo_dout),             // output wire [31 : 0] dout
  .data_count(data_count)       // output wire [5 : 0] data_count
);

uart_send #(                          
    .CLK_FREQ       (CLK_FREQ),         
    .UART_BPS       (UART_BPS))
u_uart_send(                 
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
     
    .uart_en        (uart_send_en),
    .uart_din       (uart_send_data),
    .uart_tx_busy   (uart_tx_busy),
    .uart_txd       (uart_txd)
    );
    
uart_loop u_uart_loop(
    .sys_clk        (sys_clk),             
    .sys_rst_n      (sys_rst_n),           
   
    .recv_done      (uart_recv_done),   
    .recv_data      (uart_recv_data),   
   
    .tx_busy        (uart_tx_busy),     
    .send_en        (uart_send_en),     
    .send_data      (uart_send_data)    
    );
    
    // assign led_out = 8'b10010101;
    assign led_out = uart_recv_data;


endmodule