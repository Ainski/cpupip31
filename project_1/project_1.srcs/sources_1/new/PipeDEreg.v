`timescale 1ns / 1ps
// ID/EX流水线寄存器模块
// 功能：存储ID阶段的输出数据并传递给EXE阶段
module PipeDEreg(
    input clk,           // 时钟信号
    input rstn,          // 异步复位信号（低电平有效）
    input wena,          // 写使能信号
    input [31:0] Dpc4,   // PC+4值（来自ID阶段）
    input [31:0] Da,     // 寄存器A的值
    input [31:0] Db,     // 寄存器B的值
    input [31:0] Dimm,   // 立即数
    input [31:0] Dcp0,   // CP0相关数据
    input [31:0] Dhi,    // HI寄存器值
    input [31:0] Dlo,    // LO寄存器值
    input [4:0] Drn,     // 目标寄存器编号
    input Dsign,         // 符号扩展标志
    input Ddiv,          // 除法操作标志
    input [3:0] Daluc,   // ALU操作码
    input Dw_rf,         // 写寄存器文件标志
    input Dw_hi,         // 写HI标志
    input Dw_lo,         // 写LO标志
    input Dw_dm,         // 写数据存储器标志
    input DisGoto,       // 跳转指令标志
    input Dasource,      // A源选择标志
    input Dbsource,      // B源选择标志
    input [1:0] Dhisource,     // HI源选择
    input [1:0] Dlosource,     // LO源选择
    input [2:0] Drfsource,     // 寄存器文件源选择
    input [1:0] DSC,           // 存储器命令信号
    input [2:0] DLC,           // 加载命令信号
    output reg[31:0] Epc4,     // PC+4值（传给EXE阶段）
    output reg [31:0] Ea,      // 寄存器A的值（传给EXE阶段）
    output reg [31:0] Eb,      // 寄存器B的值（传给EXE阶段）
    output reg [31:0] Eimm,    // 立即数（传给EXE阶段）
    output reg [31:0] Ecp0,    // CP0相关数据（传给EXE阶段）
    output reg [31:0] Ehi,     // HI寄存器值（传给EXE阶段）
    output reg [31:0] Elo,     // LO寄存器值（传给EXE阶段）
    output reg [4:0] Ern,      // 目标寄存器编号（传给EXE阶段）
    output reg Esign,          // 符号扩展标志（传给EXE阶段）
    output reg Ediv,           // 除法操作标志（传给EXE阶段）
    output reg [3:0] Ealuc,    // ALU操作码（传给EXE阶段）
    output reg Ew_rf,          // 写寄存器文件标志（传给EXE阶段）
    output reg Ew_hi,          // 写HI标志（传给EXE阶段）
    output reg Ew_lo,          // 写LO标志（传给EXE阶段）
    output reg Ew_dm,          // 写数据存储器标志（传给EXE阶段）
    output reg EisGoto,        // 跳转指令标志（传给EXE阶段）
    output reg Easource,       // A源选择标志（传给EXE阶段）
    output reg Ebsource,       // B源选择标志（传给EXE阶段）
    output reg [1:0] Ehisource,     // HI源选择（传给EXE阶段）
    output reg [1:0] Elosource,     // LO源选择（传给EXE阶段）
    output reg [2:0] Erfsource,     // 寄存器文件源选择（传给EXE阶段）
    output reg [1:0] ESC,           // 存储器命令信号（传给EXE阶段）
    output reg [2:0] ELC            // 加载命令信号（传给EXE阶段）
);

always @ (posedge clk or posedge rstn) begin
    if (!rstn) begin
        // 异步复位，将所有输出清零
        Epc4 <= 0;
        Ea <= 0;
        Eb <= 0;
        Eimm <= 0 ;
        Ecp0 <= 0 ;
        Ehi <= 0 ;
        Elo <= 0 ;
        Ern <= 0 ;
        Esign <= 0 ;
        Ediv <= 0 ;
        Ealuc <= 0 ;
        Ew_rf <= 0 ;
        Ew_hi <= 0 ;
        Ew_lo <= 0 ;
        Ew_dm <= 0 ;
        EisGoto <= 0 ;
        Easource <= 0 ;
        Ebsource <= 0 ;
        Ehisource <= 0 ;
        Elosource <= 0 ;
        Erfsource <= 0 ;
        ESC <= 0 ;
        ELC <= 0 ;
    end else begin
        // 正常操作，将输入数据锁存到输出
        Epc4 <= Dpc4 ;
        Ea <= Da ;
        Eb <= Db ;
        Eimm <= Dimm ;
        Ecp0 <= Dcp0 ;
        Ehi <= Dhi ;
        Elo <= Dlo ;
        Ern <= Drn ;
        Esign <= Dsign ;
        Ediv <= Ddiv ;
        Ealuc <= Daluc ;
        Ew_rf <= Dw_rf ;
        Ew_hi <= Dw_hi ;
        Ew_lo <= Dw_lo ;
        Ew_dm <= Dw_dm ;
        EisGoto <= DisGoto ;
        Easource <= Dasource ;
        Ebsource <= Dbsource ;
        Ehisource <= Dhisource ;
        Elosource <= Dlosource ;
        Erfsource <= Drfsource ;
        ESC <= DSC ;              // 存储器命令信号
        ELC <= DLC ;              // 加载命令信号
    end
end

endmodule