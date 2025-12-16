// 指令寄存器模块（IR）
// 功能：锁存指令获取阶段的PC+4和指令，传递给译码阶段
module PipeIR (
    input clk,                    // 时钟信号
    input rstn,                   // 异步复位信号（低电平有效）
    input [31:0] pc4,             // PC+4值（来自IF阶段）
    input [31:0] instruction,     // 从指令存储器获取的指令
    input nostall,                // 不暂停信号（流水线控制）
    output [31:0] Dpc4,           // 传递给ID阶段的PC+4值
    output [31:0] Dinstruction    // 传递给ID阶段的指令
);
// 锁存PC+4值到Dpc4
Reg dpc4(clk, rstn, nostall, pc4, Dpc4);

// 锁存指令到Dinstruction
Reg ir(clk, rstn, nostall, instruction, Dinstruction);

endmodule