// 执行阶段模块（EXE）
// 功能：执行算术逻辑运算、乘除法运算、地址计算等
module PipeEXE(
    input clk,                    // 时钟信号
    input rstn,                   // 异步复位信号（低电平有效）
    input [31:0] pc4,             // PC+4值
    input [31:0] a,               // 寄存器A的值
    input [31:0] b,               // 寄存器B的值
    input [31:0] imm,             // 立即数
    input [31:0] cp0,             // CP0相关数据
    input [31:0] hi,              // HI寄存器值
    input [31:0] lo,              // LO寄存器值
    input [4:0] rn,               // 目标寄存器编号
    input sign,                   // 符号扩展标志
    input div,                    // 除法操作标志
    input [3:0] aluc,             // ALU操作码
    input w_rf,                   // 写寄存器文件标志
    input w_hi,                   // 写HI标志
    input w_lo,                   // 写LO标志
    input w_dm,                   // 写数据存储器标志
    input isGoto,                 // 跳转指令标志
    input asource,                // A源选择标志
    input bsource,                // B源选择标志
    input [1:0] cuttersource,     // 数据切割源选择
    input [1:0] hisource,         // HI源选择
    input [1:0] losource,         // LO源选择
    input [2:0] rfsource,         // 寄存器文件源选择
    output [31:0] Emuler_hi,      // 乘法高32位结果
    output [31:0] Emuler_lo,      // 乘法低32位结果
    output [31:0] Er,             // 除法余数
    output [31:0] Eq,             // 除法商
    output [31:0] Ecounter,       // 计数器结果
    output [31:0] Ealu,           // ALU结果
    output [31:0] Epc4,           // 传给MEM阶段的PC+4值
    output [31:0] Ea,             // 传给MEM阶段的寄存器A值
    output [31:0] Eb,             // 传给MEM阶段的寄存器B值
    output [31:0] Ecp0,           // 传给MEM阶段的CP0相关数据
    output [31:0] Ehi,            // 传给MEM阶段的HI寄存器值
    output [31:0] Elo,            // 传给MEM阶段的LO寄存器值
    output [4:0] Ern,             // 传给MEM阶段的目标寄存器编号
    output Ew_rf,                 // 传给MEM阶段的写寄存器文件标志
    output Ew_hi,                 // 传给MEM阶段的写HI标志
    output Ew_lo,                 // 传给MEM阶段的写LO标志
    output Ew_dm,                 // 传给MEM阶段的写数据存储器标志
    output EisGoto,               // 传给MEM阶段的跳转指令标志
    output [1:0] Ecuttersource,   // 传给MEM阶段的数据切割源选择
    output [1:0] Ehisource,       // 传给MEM阶段的HI源选择
    output [1:0] Elosource,       // 传给MEM阶段的LO源选择
    output [2:0] Erfsource        // 传给MEM阶段的寄存器文件源选择
);

    // 直接传递输入到输出（流水线操作）
    assign Ea = a;
    assign Eb = b;
    assign Epc4 = pc4;
    assign Ehi = hi;
    assign Elo = lo;
    assign Ecp0 = cp0;
    assign Ern = rn;
    assign Ew_rf = w_rf;
    assign Ew_hi = w_hi;
    assign Ew_lo = w_lo;
    assign Ew_dm = w_dm;
    assign EisGoto = isGoto;
    assign Ecuttersource = cuttersource;
    assign Ehisource = hisource;
    assign Elosource = losource;
    assign Erfsource = rfsource;

    (* MARK_DEBUG = "TRUE" *) wire [31:0] ain, bin, saout;  // 调试信号
    wire zero, carry, negative, overflow;  // ALU状态信号

    Counter counter (a, Ecounter);  // 计数器模块，输入a，输出Ecounter
    MULer muler (clk, rstn, sign, a, b, Emuler_hi, Emuler_lo);  // 乘法器模块
    DIVer diver (clk, rstn, sign, div, a, b, Eq, Er);  // 除法器模块
    MUX2_1 mux_a({27'b0, imm[10:6]}, a, asource, ain);  // A源多路选择器，可以选择立即数的[10:6]位或寄存器a
    MUX2_1 mux_b(imm, b, bsource, bin);  // B源多路选择器，可以选择立即数或寄存器b
    ALU alu (aluc, ain, bin, saout, zero, carry, negative, overflow);  // ALU模块执行运算
endmodule