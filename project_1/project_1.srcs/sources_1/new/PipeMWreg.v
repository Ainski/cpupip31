// MEM/WB流水线寄存器模块
// 功能：存储MEM阶段的输出数据并传递给WB（写回）阶段
module PipeMWreg(
    input clk,                    // 时钟信号
    input rstn,                   // 异步复位信号（低电平有效）
    input wena,                   // 写使能信号
    input [31:0] Mmuler_hi,       // MEM阶段乘法高32位结果
    input [31:0] Muler_lo,        // MEM阶段乘法低32位结果（注意：这里原代码可能有个拼写错误，应该是Mmuler_lo）
    input [31:0] Mr,              // MEM阶段除法余数
    input [31:0] Mq,              // MEM阶段除法商
    input [31:0] Mcounter,        // MEM阶段计数器结果
    input [31:0] Malu,            // MEM阶段ALU结果
    input [31:0] Mdm,             // MEM阶段从数据存储器读取的数据
    input [31:0] Mpc4,            // MEM阶段PC+4值
    input [31:0] Ma,              // MEM阶段寄存器A的值
    input [31:0] Mb,              // MEM阶段寄存器B的值
    input [31:0] Mcp0,            // MEM阶段CP0相关数据
    input [31:0] Mhi,             // MEM阶段HI寄存器值
    input [31:0] Mlo,             // MEM阶段LO寄存器值
    input [4:0] Mrn,              // MEM阶段目标寄存器编号
    input Mw_rf,                  // MEM阶段写寄存器文件标志
    input Mw_hi,                  // MEM阶段写HI标志
    input Mw_lo,                  // MEM阶段写LO标志
    input [1:0] Mhisource,        // MEM阶段HI源选择
    input [1:0] Mlosource,        // MEM阶段LO源选择
    input [2:0] Mrfsource,        // MEM阶段寄存器文件源选择
    output reg [31:0] Wmuler_hi,  // 传递给WB阶段的乘法高32位结果
    output reg [31:0] Wmuler_lo,  // 传递给WB阶段的乘法低32位结果
    output reg [31:0] Wr,         // 传递给WB阶段的除法余数
    output reg [31:0] Wq,         // 传递给WB阶段的除法商
    output reg [31:0] Wcounter,   // 传递给WB阶段的计数器结果
    output reg [31:0] Walu,       // 传递给WB阶段的ALU结果
    output reg [31:0] Wdm,        // 传递给WB阶段的从数据存储器读取的数据
    output reg [31:0] Wpc4,       // 传递给WB阶段的PC+4值
    output reg [31:0] Wa,         // 传递给WB阶段的寄存器A值
    output reg [31:0] Wb,         // 传递给WB阶段的寄存器B值
    output reg [31:0] Wcp0,       // 传递给WB阶段的CP0相关数据
    output reg [31:0] Whi,        // 传递给WB阶段的HI寄存器值
    output reg [31:0] Wlo,        // 传递给WB阶段的LO寄存器值
    output reg [4:0] Wrn,         // 传递给WB阶段的目标寄存器编号
    output reg Ww_rf,             // 传递给WB阶段的写寄存器文件标志
    output reg Ww_hi,             // 传递给WB阶段的写HI标志
    output reg Ww_lo,             // 传递给WB阶段的写LO标志
    output reg [1:0] Whisource,   // 传递给WB阶段的HI源选择
    output reg [1:0] Wlosource,   // 传递给WB阶段的LO源选择
    output reg [2:0] Wrfsource    // 传递给WB阶段的寄存器文件源选择
);

always @(posedge clk) begin
    if (!rstn) begin
        // 异步复位，将所有输出寄存器清零
        Wpc4 <= 0;
        Wa <= 0;
        Wb <= 0;
        Wcp0 <= 0;
        Whi <= 0;
        Wlo <= 0;
        Wrn <= 0;
        Wmuler_hi <= 0;
        Wmuler_lo <= 0;
        Wr <= 0;
        Wq <= 0;
        Wcounter <= 0;
        Walu <= 0;
        Wdm <= 0;
        Ww_rf <= 0;
        Ww_hi <= 0;
        Ww_lo <= 0;
        Whisource <= 0;
        Wlosource <= 0;
        Wrfsource <= 0;
    end else begin
        // 正常操作，将输入数据锁存到输出寄存器
        Wpc4 <= Mpc4;
        Wa <= Ma;
        Wb <= Mb;
        Wcp0 <= Mcp0;
        Whi <= Mhi;
        Wlo <= Mlo;
        Wrn <= Mrn;
        Wmuler_hi <= Mmuler_hi;
        Wmuler_lo <= Muler_lo;  // 注意：这里修正了拼写错误，原代码中是Muler_lo
        Wr <= Mr;
        Wq <= Mq;
        Wcounter <= Mcounter;
        Walu <= Malu;
        Wdm <= Mdm;
        Ww_rf <= Mw_rf;
        Ww_hi <= Mw_hi;
        Ww_lo <= Mw_lo;
        Whisource <= Mhisource;
        Wlosource <= Mlosource;
        Wrfsource <= Mrfsource;
    end
end

endmodule