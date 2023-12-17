`timescale 1ns / 1ps
`include "driver.vh"

module driver(
    input lcd_pclk,
    input rst_n,
    input [15:0] lcd_id,
    input [23:0] pixel_data,
    output [10:0] pixel_x,
    output [10:0] pixel_y,
    output reg [10:0] h_disp,
    output reg [10:0] v_disp,

    // LCD part
    output lcd_de,
    output lcd_hs,
    output lcd_vs,
    output lcd_bl,
    output lcd_clk,
    output [23:0] lcd_rgb,
    output lcd_rst
    );

    reg [10:0] h_sync;
    reg [10:0] v_sync;
    reg [10:0] h_back;
    reg [10:0] v_back;
    reg [10:0] h_total;
    reg [10:0] v_total;
    reg [10:0] h_cnt;
    reg [10:0] v_cnt;

    wire lcd_en;
    wire data_req;

    assign  lcd_hs = 1'b1;        //LCD行同步信号
    assign  lcd_vs = 1'b1;        //LCD场同步信号
    assign  lcd_rst = 1'b1;       //LCD复位  
    assign  lcd_bl = 1'b1;        //LCD背光控制信号  
    assign  lcd_clk = lcd_pclk;   //LCD像素时钟
    assign  lcd_de = lcd_en;      //LCD数据有效信号

    // 使能RGB888数据输出
    assign  lcd_en = ((h_cnt >= h_sync + h_back) && (h_cnt < h_sync + h_back + h_disp)
                    && (v_cnt >= v_sync + v_back) && (v_cnt < v_sync + v_back + v_disp)) 
                    ? 1'b1 : 1'b0;

    // 请求像素点颜色数据输入  
    assign data_req = ((h_cnt >= h_sync + h_back - 1'b1) && (h_cnt < h_sync + h_back + h_disp - 1'b1)
                    && (v_cnt >= v_sync + v_back) && (v_cnt < v_sync + v_back + v_disp)) 
                    ? 1'b1 : 1'b0;

    //像素点坐标  
    assign pixel_x = data_req ? (h_cnt - (h_sync + h_back - 1'b1)) : 11'd0;
    assign pixel_y = data_req ? (v_cnt - (v_sync + v_back - 1'b1)) : 11'd0;

    //RGB888数据输出
    assign lcd_rgb = lcd_en ? pixel_data : 24'd0;

    //行场时序参数
    always @(posedge lcd_pclk) begin
        case(lcd_id)
            16'h4342 : begin
                h_sync  <= `H_SYNC_4342; 
                h_back  <= `H_BACK_4342; 
                h_disp  <= `H_DISP_4342; 
                h_total <= `H_TOTAL_4342;
                v_sync  <= `V_SYNC_4342; 
                v_back  <= `V_BACK_4342; 
                v_disp  <= `V_DISP_4342; 
                v_total <= `V_TOTAL_4342;            
            end
            16'h7084 : begin
                h_sync  <= `H_SYNC_7084; 
                h_back  <= `H_BACK_7084; 
                h_disp  <= `H_DISP_7084; 
                h_total <= `H_TOTAL_7084;
                v_sync  <= `V_SYNC_7084; 
                v_back  <= `V_BACK_7084; 
                v_disp  <= `V_DISP_7084; 
                v_total <= `V_TOTAL_7084;        
            end
            16'h7016 : begin
                h_sync  <= `H_SYNC_7016; 
                h_back  <= `H_BACK_7016; 
                h_disp  <= `H_DISP_7016; 
                h_total <= `H_TOTAL_7016;
                v_sync  <= `V_SYNC_7016; 
                v_back  <= `V_BACK_7016; 
                v_disp  <= `V_DISP_7016; 
                v_total <= `V_TOTAL_7016;            
            end
            16'h4384 : begin
                h_sync  <= `H_SYNC_4384; 
                h_back  <= `H_BACK_4384; 
                h_disp  <= `H_DISP_4384; 
                h_total <= `H_TOTAL_4384;
                v_sync  <= `V_SYNC_4384; 
                v_back  <= `V_BACK_4384; 
                v_disp  <= `V_DISP_4384; 
                v_total <= `V_TOTAL_4384;             
            end        
            16'h1018 : begin
                h_sync  <= `H_SYNC_1018; 
                h_back  <= `H_BACK_1018; 
                h_disp  <= `H_DISP_1018; 
                h_total <= `H_TOTAL_1018;
                v_sync  <= `V_SYNC_1018; 
                v_back  <= `V_BACK_1018; 
                v_disp  <= `V_DISP_1018; 
                v_total <= `V_TOTAL_1018;        
            end
            default : begin
                h_sync  <= `H_SYNC_4342; 
                h_back  <= `H_BACK_4342; 
                h_disp  <= `H_DISP_4342; 
                h_total <= `H_TOTAL_4342;
                v_sync  <= `V_SYNC_4342; 
                v_back  <= `V_BACK_4342; 
                v_disp  <= `V_DISP_4342; 
                v_total <= `V_TOTAL_4342;          
            end
        endcase
    end

    always@ (posedge lcd_pclk or negedge rst_n) begin
        if(!rst_n) 
            h_cnt <= 11'd0;
        else begin
            if(h_cnt == h_total - 1'b1)
                h_cnt <= 11'd0;
            else
                h_cnt <= h_cnt + 1'b1;           
        end
    end

    always@ (posedge lcd_pclk or negedge rst_n) begin
        if(!rst_n) 
            v_cnt <= 11'd0;
        else begin
            if(h_cnt == h_total - 1'b1) begin
                if(v_cnt == v_total - 1'b1)
                    v_cnt <= 11'd0;
                else
                    v_cnt <= v_cnt + 1'b1;    
            end
        end    
    end

endmodule
