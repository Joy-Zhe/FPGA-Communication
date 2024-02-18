`timescale 1ns / 1ps

module fifo_42 (
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [31 : 0] din,
    output reg [31 : 0] dout,
    output wire [5 : 0] data_count,
    output wire empty,
    output wire full
    );

    parameter COUNT = 43; // 42 + 1
    parameter ADDR_BTIS = 6; // 42 data need 6 bits to address

    reg [31 : 0] fifo[COUNT - 1 : 0];
    reg [ADDR_BTIS - 1 : 0] wr_ptr; // write pointer
    reg [ADDR_BTIS - 1 : 0] rd_ptr; // read pointer
    reg [ADDR_BTIS - 1 : 0] cnt = 0; // data count

    assign empty = (cnt == 0);
    assign full = (cnt == COUNT);
    assign data_count = cnt;

    // write
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            cnt <= 0;
        end
        else if (wr_en && ~full) begin
            fifo[wr_ptr] <= din;
            wr_ptr <= (wr_ptr + 1) % COUNT;
            cnt <= cnt + 1;
        end
    end

    // read
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
        end
        else if (rd_en && ~empty) begin
            dout <= fifo[rd_ptr];
            rd_ptr <= (rd_ptr + 1) % COUNT;
            cnt <= cnt - 1;
        end
    end

endmodule