`timescale 1ns / 1ps

module read_id(
    input clk,
    input rst_n,
    input [23:0] rgb,
    output reg [15:0] id
    );

    reg read_flag;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_flag <= 1'b0;
            id <= 16'h0000;
        end
        else begin
            if (!read_flag) begin
                read_flag <= 1'b1;
                case ({rgb[7], rgb[15], rgb[23]})
                    3'b000: id <= 16'h4342;
                    3'b001: id <= 16'h7084;
                    3'b010: id <= 16'h7016;
                    3'b100: id <= 16'h4384;
                    3'b101: id <= 16'h1018;
                    default: id <= 16'h0000; 
                endcase
            end
        end
    end
endmodule
