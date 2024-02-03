// `timescale 1ns / 1ps

// module uart_testbench;

// reg sys_clk;
// reg sys_rst_n;
// reg uart_rxd;
// wire uart_txd;
// wire [7:0] led_out;

// // 实例化待测试模块
// top uut (
//     .sys_clk(sys_clk),
//     .sys_rst_n(sys_rst_n),
//     .uart_rxd(uart_rxd),
//     .uart_txd(uart_txd),
//     .led_out(led_out)
// );

// initial begin
//     // 初始化时钟和复位信号
//     sys_clk = 0;
//     sys_rst_n = 0;
//     uart_rxd = 1; // UART空闲状态为高电平

//     // 复位系统
//     #100;
//     sys_rst_n = 1;

//     // 模拟接收UART数据
//     // 假设要传输的32-bit数据为0x12345678
//     // 注意：假定数据按大端格式传输
//     send_byte(8'h12); // 第1个字节
//     send_byte(8'h34); // 第2个字节
//     send_byte(8'h56); // 第3个字节
//     send_byte(8'h78); // 第4个字节

//     #100;
//     // 检查data_buffer是否正确组装为0x12345678
//     if (uut.data_buffer === 32'h12345678) begin
//         $display("Test Passed: data_buffer correctly assembled as 0x12345678.");
//     end else begin
//         $display("Test Failed: data_buffer incorrect. Expected 0x12345678, got %h", uut.data_buffer);
//     end

//     #100;
//     $finish;
// end

// // 生成系统时钟
// always #10 sys_clk = ~sys_clk;

// // 模拟UART发送字节的过程
// task send_byte;
//     input [7:0] byte;
//     integer i;
//     begin
//         // 模拟UART接收过程，包括启动位、数据位和停止位
//         uart_rxd = 0; // 启动位
//         #10417; // 根据115200波特率计算位周期
//         for (i = 0; i < 8; i = i + 1) begin
//             uart_rxd = byte[i];
//             #10417;
//         end
//         uart_rxd = 1; // 停止位
//         #10417; // 等待一个位周期后准备接收下一个字节
//     end
// endtask

// endmodule
