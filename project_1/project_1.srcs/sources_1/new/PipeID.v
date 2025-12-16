// 指令译码阶段模块（ID）
// 功能：译码指令，读取寄存器文件，处理数据前递和控制信号
module PipeID(
    input clk,                    // 时钟信号
    input rstn,                   // 异步复位信号（低电平有效）
    input [31:0] pc4,             // PC+4值
    input [31:0] inst,            // 指令输入
    input [31:0] Ealu,            // EX阶段的ALU结果
    input [31:0] Malu,            // MEM阶段的ALU结果
    input [31:0] Mdm,             // MEM阶段的数据内存结果
    input [31:0] Ehi,             // EX阶段的HI寄存器值
    input [31:0] Elo,             // EX阶段的LO寄存器值
    input [31:0] Epc0,            // EX阶段的CP0值
    input [31:0] Emuler_hi,       // EX阶段乘法高32位结果
    input [31:0] Emuler_lo,       // EX阶段乘法低32位结果
    input [31:0] Er,              // EX阶段除法余数
    input [31:0] Eq,              // EX阶段除法商
    input [31:0] Ecounter,        // EX阶段计数器结果
    input [4:0] Ern,              // EX阶段目标寄存器编号
    input [4:0] Mrn,              // MEM阶段目标寄存器编号
    input Ew_rf,                  // EX阶段写寄存器文件标志
    input Mw_rf,                  // MEM阶段写寄存器文件标志
    input Ew_hi,                  // EX阶段写HI标志
    input Ew_lo,                  // EX阶段写LO标志
    input [2:0] Erfsource,        // EX阶段寄存器文件源选择
    input [2:0] Mrfsource,        // MEM阶段寄存器文件源选择
    input [1:0] Ehisource,        // EX阶段HI源选择
    input [1:0] Elosourse,        // EX阶段LO源选择（注意：这里可能是拼写错误，应为Elosource）
    input [31:0] Wdata_rf,        // 写入寄存器文件的数据
    input [4:0] Wrn,              // 写入寄存器编号
    input Wena_rf,                // 写入寄存器文件使能
    input Wena_hi,                // 写入HI使能
    input Wena_lo,                // 写入LO使能
    input EisGoto,                // EX阶段跳转指令标志
    output [31:0] cpc,            // CP0寄存器输出
    output [31:0] rpc,            // 寄存器PC输出
    output [31:0] bpc,            // 分支PC输出
    output [31:0] jpc,            // 跳转PC输出
    output [31:0] Rsout,          // 寄存器Rs输出
    output [31:0] Rtout,          // 寄存器Rt输出
    output [31:0] imm,            // 立即数输出
    output [31:0] Dpc4,           // D阶段PC+4输出
    output [31:0] CP0out,         // CP0输出
    output [31:0] Hiout,          // HI寄存器输出
    output [31:0] Loout,          // LO寄存器输出
    output [4:0] rn,              // 目标寄存器编号输出
    output sign,                  // 符号扩展标志输出
    output div,                   // 除法操作标志输出
    output [3:0] aluc,            // ALU操作码输出
    output w_hi,                  // 写HI标志输出
    output w_lo,                  // 写LO标志输出
    output w_rf,                  // 写寄存器文件标志输出
    output w_dm,                  // 写数据存储器标志输出
    output asource,               // A源选择输出
    output bsource,               // B源选择输出
    output [1:0] cuttersource,    // 数据切割源选择输出
    output [1:0] hisource,        // HI源选择输出
    output [1:0] losource,        // LO源选择输出
    output [2:0] rfsource,        // 寄存器文件源选择输出
    output [1:0] pcsource,        // PC源选择输出
    output stall,                 // 流水线暂停信号输出
    output isGoto,                // 跳转指令标志输出
    output [31:0] reg28           // 特殊寄存器输出（可能是$gp寄存器）
);

// 调试信号定义
(* MARK_DEBUG="true" *) wire[5:0] op, func;              // 操作码和功能码
(* MARK_DEBUG="true" *) wire [4:0] rsc, rtc, rdc, mf;    // 寄存器源和目标编号
(* MARK_DEBUG="true" *) wire [15:0] ext16;               // 16位扩展值
(* MARK_DEBUG="true" *) wire [1:0] fwda, fwdb;           // 数据前递选择信号
(* MARK_DEBUG="true" *) wire sign_ext;                    // 符号扩展标志
(* MARK_DEBUG="true" *) wire mfc0, mtc0, eret, teq, bre, sys, beq, bne, bgez;  // 指令类型标志
(* MARK_DEBUG="true" *) wire isBranch;                    // 分支指令标志
(* MARK_DEBUG="true" *) wire [31:0] aout, bout, cp0, hi, lo;  // 寄存器输出值
(* MARK_DEBUG="true" *) wire [1:0] fwhi, fwlo;           // HI和LO前递选择信号
(* MARK_DEBUG="true" *) wire [2:0] fwda, dwdb;           // （注：这里存在重复定义，应为不同信号）
(* MARK_DEBUG="true" *) wire [4:5] ex_cause;             // 异常原因

// 指令字段解析
assign func = inst[5:0];         // 指令功能码（[5:0]位）
assign op = inst[31:26];         // 指令操作码（[31:26]位）
assign mf = inst[25:21];         // CP0寄存器字段（[25:21]位）
assign rsc = inst[25:21];        // 源寄存器Rs（[25:21]位）
assign rtc = inst[20:16];        // 源寄存器Rt（[20:16]位）
assign rdc = inst[15:11];        // 目标寄存器Rd（[15:11]位）
assign ext16 = inst[15:0];       // 16位立即数字段（[15:0]位）
assign jpc = {pc4[31:28], inst[25:0], 2'b00};  // 跳转目标地址（J型指令）

// 分支目标地址计算
wire[31:0] ext_18;
assign ext_18 = {14'b0, ext16, 2'b00};  // 扩展16位立即数为18位并左移2位
assign bpc = pc4 + ext_18;       // 分支目标地址

// 输出分配
assign rpc = Rsout;              // 寄存器PC输出
assign cpc = CP0out;             // CP0输出
assign Dpc4 = pc4;               // D阶段PC+4输出
assign imm = sign_ext ? {{16{ext16[15]}}, ext16} : {16'b0, ext16};  // 立即数符号扩展

// 寄存器文件模块实例化
Regfile regfile(clk, rstn, Wena_rf, rsc, rtc, Wrn, Wdata_rf, aout, bout, reg28);

// A和B操作数数据前递多路选择器
MUX8_1 alu_aout(Ecounter, Ehi, Elo, Emuler_lo, Mdm, Malu, Ealu, aout, fwda, Rsout);
MUX8_1 alu_bout(Ecounter, Ehi, Elo, Emuler_lo, Mdm, Malu, Ealu, bout, fwdb, Rtout);

// CP0协处理器模块实例化
CP0 cp0reg(
    clk, rstn,
    mfc0, mtc0, eret, teq, bre, sys,
    wcau, wsta, wepc, woth,
    rsc, ex_cause,
    Rtout,
    CP0out
);

// HI寄存器模块实例化
Reg hireg(clk, rstn, Wena_hi, Wdata_hi, hi);
MUX4_1 hiout(Er, Emuler_hi, Ehi, hi, fwhi, Hiout);

// LO寄存器模块实例化
Reg loreg(clk, rstn, Wena_lo, Wdata_lo, lo);
MUX4_1 loout(Eq, Emuler_lo, Elo, lo, fwlo, Loout);

// 比较模块实例化（用于分支指令）
Compare_ID compare(Rsout, Rtout, beq, bne, bgez, teq, isBranch);

// 流水线控制单元模块实例化
PipeControlUnit CU(
    rsc, rtc, rdc, func, op, mf, isBranch,
    EisGoto,
    Ern, Mrn,
    Ew_rf, Mw_rf, Ew_hi, Ew_lo,
    Erfsource, Mrfsource, Ehisource, Elosourse,
    fwhi, fwlo, fwda, fwdb,
    rn, sign, div, mfc0, mfc0, mtc0, sys, eret, bre, teq, beq, bne, bgez, aluc,
    wcau, wsta, wepc, wotr, w_hi, w_lo, w_rf, w_dm,
    ex_cause,
    asource, bsource, cuttersource, hisource, losource, rfsource, pcsource,
    stall, isGoto
);

endmodule
