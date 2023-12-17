`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/17 00:50:55
// Design Name: 
// Module Name: display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module display(
    input lcd_pclk,
    input rst_n,
    input [10:0] pixel_x,
    input [10:0] pixel_y,
    input [10:0] h_disp,
    input [10:0] v_disp,
    output reg [23:0] pixel_data
    );

    parameter WHITE = 24'hFFFFFF;
    parameter BLACK = 24'h000000;
    parameter RED   = 24'hFF0000;
    parameter GREEN = 24'h00FF00;
    parameter BLUE  = 24'h0000FF;

    always @(posedge lcd_pclk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data <= WHITE;
        end
        else begin
            if ((pixel_x >= 11'd0) && (pixel_x < h_disp / 5 * 1)) begin
                pixel_data <= WHITE;                
            end
            else if ((pixel_x >= h_disp / 5 * 1) && (pixel_x < h_disp / 5 * 2)) begin
                pixel_data <= BLACK;                
            end
            else if ((pixel_x >= h_disp / 5 * 2) && (pixel_x < h_disp / 5 * 3)) begin
                pixel_data <= GREEN;                
            end
            else if ((pixel_x >= h_disp / 5 * 3) && (pixel_x < h_disp / 5 * 4)) begin
                pixel_data <= BLUE;                
            end
            else begin
                pixel_data <= RED;
            end
        end
    end
endmodule
