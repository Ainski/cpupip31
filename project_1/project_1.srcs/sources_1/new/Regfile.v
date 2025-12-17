`timescale 1ns / 1ps
// 寄存器文件模块
// 功能：提供32个32位寄存器，支持同时读两个寄存器和写一个寄存器
module Regfile(
    input clk,                    // 时钟信号
    input rstn,                   // 复位信号（低电平有效，同步复位）
    input RF_W,                   // 写使能信号
    input [4:0] rsc,              // 第一个源寄存器地址 (rs)
    input [4:0] rtc,              // 第二个源寄存器地址 (rt)
    input [4:0] Wrn,              // 写寄存器编号 (rd)
    input [31:0] Wdata_rf,        // 写入寄存器的数据
    output [31:0] aout,           // 第一个操作数输出 (rs)
    output [31:0] bout,           // 第二个操作数输出 (rt)
    output [31:0] reg28           // 特殊寄存器28输出
);

    reg [31:0] array_reg[0:31];

    // 复位时初始化寄存器
    integer i;
    always @(posedge clk or posedge rstn) begin
        if (!rstn) begin  // 遵循其他模块的约定 - 同步低电平有效复位
            for (i = 0; i < 32; i = i + 1) begin
                if (i == 28) begin
                    // 初始化寄存器28到特殊值（例如栈指针）
                    array_reg[i] <= 32'h7fffefff;
                end
                else begin
                    array_reg[i] <= 32'h0;
                end
            end
        end
        else if (RF_W && Wrn != 5'b0) begin  // 防止写入寄存器0（零寄存器）
            array_reg[Wrn] <= Wdata_rf;
        end
    end

    // 输出分配
    assign aout = array_reg[rsc];       // rs操作数输出
    assign bout = array_reg[rtc];       // rt操作数输出
    assign reg28 = array_reg[28];       // 特殊寄存器28输出

endmodule