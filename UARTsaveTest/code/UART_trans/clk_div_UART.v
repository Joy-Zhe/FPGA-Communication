`timescale 1ns / 1ps

module clk_div_UART(
    input clk,
    input rst_n,
    output reg clk_25M,
    output reg clk_10M,
    output reg clk_12_5M
    );

    reg cnt_12_5M;
    reg [2:0] cnt_10M;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_25M <= 1'b0;
            clk_10M <= 1'b0;
            cnt_10M <= 3'b0;
            cnt_12_5M <= 1'b0;
            clk_12_5M <= 1'b0;
        end
        else begin
            clk_25M <= ~clk_25M;

            if (cnt_12_5M == 1'b1) begin
                cnt_12_5M <= 1'b0;
                clk_12_5M <= ~clk_12_5M;
            end
            else begin
                cnt_12_5M <= 1'b1;
            end

            if (cnt_10M > 3'd4) begin
                cnt_10M <= 0;
                clk_10M <= ~clk_10M;
            end
            else begin
                cnt_10M <= cnt_10M + 2'd2;
            end
        end
    end
endmodule
