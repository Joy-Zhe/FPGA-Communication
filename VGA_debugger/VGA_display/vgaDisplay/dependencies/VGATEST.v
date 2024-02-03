`timescale 1ns / 1ps

module VGA_TESTP(
	input clk,
	input clk25,
    input SWO15,                                           //pipeline 新增 反汇编与指令切换
	input SWO14,                                           //存储数据翻页�??2021 Modify :增加显示两帧ROM数据
	input SWO13,                                           //ROM、RAM切换
	input [31:0] Debug_data,

	output[3:0] Red,
    output[3:0] Green,
    output[3:0] Blue,
    output VSYNC,
    output HSYNC,
	output [6:0] Debug_addr);

reg [8*89-1:0] Headline="FPGA-Communication VGA";
reg [31:0] data_buf [0:3];
reg [31:0] MEMBUF[0:255];
reg [7:0] ascii_code;
reg [8*7:0] strdata;
reg [11:0]dout;
wire pixel;
wire [9:0] PRow, PCol;

wire  [9:0] row_addr =  PRow - 10'd35;     // pixel ram row addr
wire  [9:0] col_addr =  PCol- 10'd143;    // pixel ram col addr

wire should_latch_debug_data = (PCol < 10'd143) && (PCol[2:0] == 3'b000) && (row_addr[3:0] == 4'b0000);

wire [4:0] char_index_row = row_addr[8:4] - 3;
wire [6:0] char_index_col = (PCol < 10'd143) ? 0 : (col_addr / 8 + 1);
wire [1:0] char_page = char_index_col / 20;
wire [4:0] char_index_in_page = char_index_col % 20;

reg flag;
    always @* begin                                                            // 2021 Modify 区域分色方便观察
       if(pixel)
            if(flag)dout = 12'b0000_0000_1111;
            else
            case(Debug_addr[6:5])
                2'b00:   dout = 12'b1111_1111_1111;
                2'b01:   dout = 12'b1111_1111_1111; // B G R  Red
                2'b10:   dout = 12'b1111_1111_1111; // B G R  Yellow
                default: dout = 12'b0000_1111_1111;
            endcase
      else if(SWO15 && ((row_addr[9:4] == 19 && col_addr[9:3] > 21 && col_addr[9:3] < 38)
                    || (row_addr[9:4] == 20 && col_addr[9:3] > 25 && col_addr[9:3] < 42)
                    || (row_addr[9:4] == 21 && col_addr[9:3] > 30 && col_addr[9:3] < 47)
                    || (row_addr[9:4] == 22 && col_addr[9:3] > 35 && col_addr[9:3] < 52)
                    || (row_addr[9:4] == 23 && col_addr[9:3] > 40 && col_addr[9:3] < 58)))
                dout = 12'b1100_1100_1100;
           else dout = 12'b0000_0000_0000;
    end

assign Debug_addr = {char_index_row , PCol[4:3]};
wire[7:0] current_display_reg_addr = {1'b0, char_index_row, char_page};
reg[31:0] code_if, code_id, code_exe, code_mem, code_wb;
wire [19*8-1:0] inst_if, inst_id, inst_exe, inst_mem, inst_wb;
    always @(negedge clk) begin                                     //2021 Modify ：ROM工作数据写入
        case(Debug_addr)
            7'b00100001: code_if <= Debug_data;
            7'b00100101: code_id <= Debug_data;
            7'b00101001: code_exe <= Debug_data;
            7'b00101101: code_mem <= Debug_data;
            7'b00110001: code_wb <= Debug_data;
            default: begin
                code_if <= code_if;
                code_id <= code_id;
                code_exe <= code_exe;
                code_mem <= code_mem;
                code_wb <= code_wb;
            end
        endcase
    end
    

    wire [31:0] MEMDATA = MEMBUF[{SWO13,1'b0,SWO14 + Debug_addr[5],Debug_addr[4:0]}];  //2021 Modify 显示ROM/RAM数据，没有读过的�??0000_00000H。SWO14控制两帧，每�??32个字

always @(posedge clk) begin                                         //2021 Modify
	if (should_latch_debug_data) begin
		if(Debug_addr[6]) data_buf[Debug_addr[1:0]] <= MEMDATA;   //屏幕下方显示ROM数据
		else data_buf[Debug_addr[1:0]] <= Debug_data;
	end
end
always @(posedge clk) begin
    flag <=0;                                                    //2021 Modify：动态显示定�??
	if ((row_addr < 1 * 16) || (row_addr >= 480 - 1 * 16))
        ascii_code <= " ";
    else if(row_addr[9:4] <= 2)
        ascii_code <= row_addr[9:4] == 1 ? (col_addr[9:3] > 13 && col_addr[9:3] < 68 ) ? Headline[(89 - col_addr[9:3] +13)*8 +:8] : " "
                                         : (col_addr[9:3] > 23 && col_addr[9:3] < 58 ) ? Headline[(34 - col_addr[9:3] +23)*8 +:8] : " ";
    else begin
      if(SWO15 && row_addr[9:4] >= 19 && row_addr[9:4] <= 23 && col_addr[9:3] > 21 && col_addr[9:3] < 60) begin
        if(SWO15 && row_addr[9:4] == 19 && col_addr[9:3] > 21 && col_addr[9:3] < 40)begin
           ascii_code <= inst_if[(38 - col_addr[9:3] +2)*8 +:8] ;
           flag <= 1;
        end
        else if(SWO15 && row_addr[9:4] == 20 && col_addr[9:3] > 25 && col_addr[9:3] < 44)begin
           ascii_code <= inst_id[(42 - col_addr[9:3] +2)*8 +:8] ;
           flag <= 1;
        end
        else if(SWO15 && row_addr[9:4] == 21 && col_addr[9:3] > 30 && col_addr[9:3] < 49)begin
           ascii_code <= inst_exe[(47 - col_addr[9:3] +2)*8 +:8] ;
           flag <= 1;
        end
        else if(SWO15 && row_addr[9:4] == 22 && col_addr[9:3] > 35 && col_addr[9:3] < 54)begin
           ascii_code <= inst_mem[(52 - col_addr[9:3] +2)*8 +:8] ;
           flag <= 1;
        end
        else if(SWO15 && row_addr[9:4] == 23 && col_addr[9:3] > 41 && col_addr[9:3] < 60)begin
           ascii_code <= inst_wb[(58 - col_addr[9:3] +2)*8 +:8] ;
           flag <= 1;
        end
        else ascii_code <= " ";
     end
        else if (col_addr[2:0] == 3'b111) begin     //--------------
            if ((char_index_in_page >= 2) && (char_index_in_page <= 8)) begin
                    ascii_code <= strdata[(6 - (char_index_in_page - 2)) * 8 +:8];
            end
            else if ((char_index_in_page >= 10) && (char_index_in_page <= 10 + 7)) begin
                    ascii_code <=  num2str(data_buf[char_page][(7 - (char_index_in_page - 10)) * 4  +: 4]);
            end else ascii_code <= " ";
        end
        else ascii_code <= ascii_code;
    end
end

    wire [8*5:0] MEMADDRSTR = SWO13 ? "RAM:0" : "CODE-";                                   //切换RAM/ROM地址显示标志
always @(posedge clk) begin                                                                 //2021 Modify ,后期还需要调�??
		case (current_display_reg_addr[7:5])
			3'b000: //strdata <= {"REG-x", num2str(current_display_reg_addr[5:4]), num2str(current_display_reg_addr[3:0])};
			//begin strdata[23:0] <= {"x",num2str(current_display_reg_addr[5:4]), num2str(current_display_reg_addr[3:0])};
			       case (current_display_reg_addr[4:0])
			       0: strdata <= "data0: ";
			       1: strdata <= "data1: ";
			       2: strdata <= "data2: ";
			       3: strdata <= "data3: ";
			       4: strdata <= "data4: ";
                   5: strdata <= "data5: ";
                   6: strdata <= "data6: ";
                   7: strdata <= "data7: ";

 			       8: strdata <= "data8: ";
                   9: strdata <= "data9: ";
                  10: strdata <= "data10:";
                  11: strdata <= "data11:";
                  12: strdata <= "data12:";
                  13: strdata <= "data13:";
                  14: strdata <= "data14:";
                  15: strdata <= "data15:";
                  16: strdata <= "data16:";
                  17: strdata <= "data17:";

                  18: strdata <= "data18:";
                  19: strdata <= "data19:";
                  20: strdata <= "data20:";
                  21: strdata <= "data21:";
                  22: strdata <= "data22:";
                  23: strdata <= "data23:";
                  24: strdata <= "data24:";
                  25: strdata <= "data25:";
                  26: strdata <= "data26:";
                  27: strdata <= "data27:";
                  28: strdata <= "data28:";
                  29: strdata <= "data29:";
                  30: strdata <= "data30:";
                  31: strdata <= "data31:";
			      default: strdata <= "-------";
               endcase
//            end

			3'b001: case (current_display_reg_addr[4:0])
				// datapath debug signals, MUST be compatible with 'debug_data_signal' in 'datapath.v'
				0:  strdata <= "data32:";
				1:  strdata <= "data33:";
				2:  strdata <= "data34:";
				3:  strdata <= "data35:";

				4:  strdata <= "data36:";
				5:  strdata <= "data37:";
				7:  strdata <= "data38:";
				6:  strdata <= "data39:";

				8:  strdata <= "data40:";
				9:  strdata <= "data41:";
				10: strdata <= "-------";
				11: strdata <= "-------";

				12: strdata <= "-------";
				13: strdata <= "-------";
				14: strdata <= "-------";
				15: strdata <= "-------";

				16: strdata <= "-------";
				17: strdata <= "-------";
				18: strdata <= "-------";
				19: strdata <= "-------";

                20: strdata <= "-------";
				21: strdata <= "-------";
				22: strdata <= "-------";
				23: strdata <= "-------";

				24: strdata <= "-------";
				25: strdata <= "-------";
				26: strdata <= "-------";
				27: strdata <= "-------";

                28: strdata <= "-------";
                29: strdata <= "-------";
                30: strdata <= "-------";
                31: strdata <= "-------";

				default: strdata <= "RESERVE";
			endcase
			3'b010: strdata <= {MEMADDRSTR, num2str({SWO14 + current_display_reg_addr[5],current_display_reg_addr[4]}), num2str(current_display_reg_addr[3:0])};
			3'b011: strdata <= {MEMADDRSTR, num2str({SWO14 ,current_display_reg_addr[5]}+1'b1), num2str(current_display_reg_addr[3:0])};

			default: strdata <= "RESERVE";
		endcase
end


FONT8_16 FONT_8X16 (
	.clk(clk),
	.ascii_code(ascii_code[6:0]),
	.row(row_addr[3:0]),
	.col(col_addr[2:0]),
	.row_of_pixels(pixel)
);

	function [7:0] num2str;
		input [3:0] number;
		begin
			if (number < 10)
				num2str = "0" + number;
			else
				num2str = "A" - 10 + number;
		end
	endfunction


        vga     U12(.clk(clk25),
                    .rst(1'b0),
                    .Din(dout),
                    .PCol(PCol),
                    .PRow(PRow),
                    .R(Red),
                    .G(Green),
                    .B(Blue),
                    .VS(VSYNC),
                    .HS(HSYNC),
                    .rdn(),
                    .vgaclk()
                     );


endmodule
