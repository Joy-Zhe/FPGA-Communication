`timescale 1ns / 1ps

module clk_div(input clk,
               input rst_n,
               output reg clk_100M,
               output reg clk_50M,
               output reg clk_25M,
               output reg clk_40M);
    
    reg [2:0] cnt_25M;
    reg [2:0] cnt_40M;
    reg cnt_50M;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_25M  <= 3'b0;
            cnt_40M  <= 3'b0;
            cnt_50M  <= 1'b0;
            clk_25M  <= 1'b0;
            clk_40M  <= 1'b0;
            clk_50M  <= 1'b0;
            clk_100M <= 1'b0;
        end
        else begin
            clk_100M <= ~clk_100M;
            
            if (cnt_40M > 3'd4) begin
                cnt_40M <= 3'b0;
                clk_40M <= ~clk_40M;
            end
            else begin
                cnt_40M <= cnt_40M + 2'b10;
            end
            
            if (cnt_25M == 2'd3) begin
                cnt_25M <= 2'b0;
                clk_25M <= ~clk_25M;
            end
            else begin
                cnt_25M <= cnt_25M + 1'b1;
            end
            
            if (cnt_50M == 1'd1) begin
                cnt_50M <= 1'b0;
                clk_50M <= ~clk_50M;
            end
            else begin
                cnt_50M <= cnt_50M + 1'b1;
            end
        end
    end
endmodule
