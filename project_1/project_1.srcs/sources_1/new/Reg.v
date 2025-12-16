// 通用32位寄存器模块
// 功能：在时钟信号控制下存储和输出数据
module Reg(
    input clk,                    // 时钟信号
    input rstn,                   // 异步复位信号（低电平有效）
    input wena,                   // 写使能信号
    input [31:0] data_in,         // 输入数据（32位）
    output reg [31:0] data_out    // 输出数据（32位）
);

always @(posedge clk or posedge rstn) begin
    if (!rstn) begin
        // 复位时将输出清零
        data_out <= 32'h0;
    end else begin
        // 在时钟上升沿将输入数据锁存到输出
        data_out <= data_in;
    end
end
endmodule