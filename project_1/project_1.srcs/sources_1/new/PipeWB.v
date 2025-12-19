`timescale 1ns / 1ps
// 写回阶段模块（WB）
// 功能：将执行结果写回到寄存器文件或特殊寄存器
module PipeWB(
    input [31:0] muler_hi,        // 乘法高32位结果
    input [31:0] muler_lo,        // 乘法低32位结果
    input [31:0] r,               // 除法余数
    input [31:0] q,               // 除法商
    input [31:0] counter,         // 计数器结果
    input [31:0] alu,             // ALU结果
    input [31:0] dm,              // 从数据存储器读取的数据
    input [31:0] pc4,             // PC+4值
    input [31:0] a,               // 寄存器A的值
    input [31:0] b,               // 寄存器B的值
    input [31:0] cp0,             // CP0数据
    input [31:0] hi,              // HI寄存器值
    input [31:0] lo,              // LO寄存器值
    input [4:0] rn,               // 目标寄存器编号
    input w_rf,                   // 写寄存器文件标志
    input w_hi,                   // 写HI标志
    input w_lo,                   // 写LO标志
    input [1:0] hisource,         // HI源选择
    input [1:0] losource,         // LO源选择
    input [2:0] rfsource,         // 寄存器文件源选择
    output [31:0] Wdata_hi,       // 写入HI寄存器的数据
    output [31:0] Wdata_lo,       // 写入LO寄存器的数据
    output [31:0] Wdata_rf,       // 写入寄存器文件的数据
    output [4:0] Wrn,             // 写入寄存器编号
    output Ww_rf,                 // 写寄存器文件使能
    output Ww_hi,                 // 写HI使能
    output Ww_lo                  // 写LO使能
);
    // HI寄存器写入数据选择：根据hisource信号选择数据源
    // 0: 0 (不写入)
    // 1: 除法余数(r)
    // 2: 乘法高32位结果(muler_hi)
    // 3: 寄存器A的值(a)
    MUX4_1 mux_hi(
        .d0(32'b0),
        .d1(r),
        .d2(muler_hi),
        .d3(a),
        .sel(hisource),
        .y(Wdata_hi)
    );

    // LO寄存器写入数据选择：根据losource信号选择数据源
    // 0: 0 (不写入)
    // 1: 除法余数(r)
    // 2: 乘法低32位结果(muler_lo)
    // 3: 寄存器B的值(b)
    MUX4_1 mux_lo(
        .d0(32'b0),
        .d1(r),
        .d2(muler_lo),
        .d3(b),
        .sel(losource),
        .y(Wdata_lo)
    );

    // 寄存器文件写入数据选择：根据rfsource信号选择数据源
    // 0: 0 (不写入)
    // 1: CP0数据(cp0)
    // 2: 乘法低32位结果(muler_lo)
    // 3: 计数器结果(counter)
    // 4: HI寄存器值(hi)
    // 5: LO寄存器值(lo)
    // 6: 从数据存储器读取的数据(dm)
    // 7: ALU结果(alu)
    MUX8_1 mux_rf(
        .d0(32'b0),
        .d1(cp0),
        .d2(muler_lo),
        .d3(counter),
        .d4(hi),
        .d5(lo),
        .d6(dm),
        .d7(alu),
        .sel(rfsource),
        .y(Wdata_rf)
    );

    // 直接传递目标寄存器编号和写使能信号
    assign Wrn = rn;
    assign Ww_rf = w_rf;
    assign Ww_hi = w_hi;
    assign Ww_lo = w_lo;
endmodule