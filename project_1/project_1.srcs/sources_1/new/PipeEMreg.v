// EX/MEM流水线寄存器模块
// 功能：存储EX阶段的输出数据并传递给MEM阶段
module PipeEMreg(
    input clk,                  // 时钟信号
    input rstn,                 // 异步复位信号（低电平有效）
    input wena,                 // 写使能信号
    input [31:0] Emuler_hi,     // 乘法高32位结果（来自EX阶段）
    input [31:0] Emuler_lo,     // 乘法低32位结果（来自EX阶段）
    input [31:0] Er,            // 除法余数（来自EX阶段）
    input [31:0] Eq,            // 除法商（来自EX阶段）
    input [31:0] Ecounter,      // 计数器结果（来自EX阶段）
    input [31:0] Ealu,          // ALU结果（来自EX阶段）
    input [31:0] Epc4,          // PC+4值（来自EX阶段）
    input [31:0] Ea,            // 寄存器A的值（来自EX阶段）
    input [31:0] Eb,            // 寄存器B的值（来自EX阶段）
    input [31:0] Ecp0,          // CP0相关数据（来自EX阶段）
    input [31:0] Ehi,           // HI寄存器值（来自EX阶段）
    input [31:0] Elo,           // LO寄存器值（来自EX阶段）
    input [4:0] Ern,            // 目标寄存器编号（来自EX阶段）
    input Esign,                // 符号扩展标志（来自EX阶段）
    input Ew_rf,                // 写寄存器文件标志（来自EX阶段）
    input Ew_hi,                // 写HI标志（来自EX阶段）
    input Ew_lo,                // 写LO标志（来自EX阶段）
    input Ew_dm,                // 写数据存储器标志（来自EX阶段）
    input [1:0] Ecuttersource,  // 数据切割源选择（来自EX阶段）
    input [1:0] Ehisource,      // HI源选择（来自EX阶段）
    input [1:0] Elosource,      // LO源选择（来自EX阶段）
    input [2:0] Erfsource,      // 寄存器文件源选择（来自EX阶段）

    output reg [31:0] Mmuler_hi, // 乘法高32位结果（传给MEM阶段）
    output reg [31:0] Mmuler_lo, // 乘法低32位结果（传给MEM阶段）
    output reg [31:0] Mr,        // 除法余数（传给MEM阶段）
    output reg [31:0] Mq,        // 除法商（传给MEM阶段）
    output reg [31:0] Mcounter,  // 计数器结果（传给MEM阶段）
    output reg [31:0] Malu,      // ALU结果（传给MEM阶段）
    output reg [31:0] Mpc4,      // PC+4值（传给MEM阶段）
    output reg [31:0] Ma,        // 寄存器A的值（传给MEM阶段）
    output reg [31:0] Mb,        // 寄存器B的值（传给MEM阶段）
    output reg [31:0] Mcp0,      // CP0相关数据（传给MEM阶段）
    output reg [31:0] Mhi,       // HI寄存器值（传给MEM阶段）
    output reg [31:0] Mlo,       // LO寄存器值（传给MEM阶段）
    output reg [4:0] Mrn,        // 目标寄存器编号（传给MEM阶段）
    output reg Msign,            // 符号扩展标志（传给MEM阶段）
    output reg Mw_rf,            // 写寄存器文件标志（传给MEM阶段）
    output reg Mw_hi,            // 写HI标志（传给MEM阶段）
    output reg Mw_lo,            // 写LO标志（传给MEM阶段）
    output reg Mw_dn,            // 写数据存储器标志（传给MEM阶段）
    output reg [1:0] Mcuttersource, // 数据切割源选择（传给MEM阶段）
    output reg [1:0] Mhisource,     // HI源选择（传给MEM阶段）
    output reg [1:0] Mlosource,     // LO源选择（传给MEM阶段）
    output reg [2:0] Mrfsource     // 寄存器文件源选择（传给MEM阶段）
);

always @(posedge clk) begin
    if (!rstn) begin
        // 异步复位，将所有输出清零
        Mpc4 <= 0;
        Ma <= 0;
        Mb <= 0;
        Mcp0 <= 0;
        Mhi <= 0;
        Mlo <= 0;
        Mrn <= 0;
        Mmuler_hi <= 0;
        Mmuler_lo <= 0;
        Mr <= 0;
        Mq <= 0;
        Mcounter <= 0;
        Malu <= 0;
        Msign <= 0;
        Mw_rf <= 0;
        Mw_hi <= 0;
        Mw_lo <= 0;
        Mw_dn <= 0;
        Mcuttersource <= 0;
        Mhisource <= 0;
        Mlosource <= 0;
        Mrfsource <= 0;
    end else begin
        // 正常操作，将输入数据锁存到输出
        Mpc4 <= Epc4;
        Ma <= Ea;
        Mb <= Eb;
        Mcp0 <= Ecp0;
        Mhi <= Ehi;
        Mlo <= Elo;
        Mrn <= Ern;
        Mmuler_hi <= Emuler_hi;
        Mmuler_lo <= Emuler_lo;
        Mr <= Er;
        Mq <= Eq;
        Mcounter <= Ecounter;
        Malu <= Ealu;
        Msign <= Esign;
        Mw_rf <= Ew_rf;
        Mw_hi <= Ew_hi;
        Mw_lo <= Ew_lo;
        Mw_dn <= Ew_dm;
        Mcuttersource <= Ecuttersource;
        Mhisource <= Ehisource;
        Mlosource <= Elosource;
        Mrfsource <= Erfsource;
    end
end

endmodule