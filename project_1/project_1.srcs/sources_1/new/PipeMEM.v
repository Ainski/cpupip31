// 内存访问阶段模块（MEM）
// 功能：执行数据存储器访问（加载/存储操作），处理数据读/写
module PipeMEM(
    input clk,                    // 时钟信号
    input [31:0] muler_hi,        // 乘法高32位结果
    input [31:0] muler_lo,        // 乘法低32位结果
    input [31:0] r,               // 除法余数
    input [31:0] q,               // 除法商
    input [31:0] counter,         // 计数器结果
    input [31:0] alu,             // ALU结果（通常作为内存地址）
    input [31:0] pc4,             // PC+4值
    input [31:0] a,               // 寄存器A的值
    input [31:0] b,               // 寄存器B的值（通常作为写入数据）
    input [31:0] cp0,             // CP0相关数据
    input [31:0] hi,              // HI寄存器值
    input [31:0] lo,              // LO寄存器值
    input [4:0] rn,               // 目标寄存器编号
    input w_rf,                   // 写寄存器文件标志
    input w_hi,                   // 写HI标志
    input w_lo,                   // 写LO标志
    input w_dm,                   // 写数据存储器标志
    input sign,                   // 符号扩展标志
    input [1:0] cuttersource,     // 数据切割源选择
    input [1:0] hisource,         // HI源选择
    input [1:0] losource,         // LO源选择
    input [2:0] rfsource,         // 寄存器文件源选择
    input [1:0] alusource,        // ALU源选择
    output [31:0] Mmuler_hi,      // 传递给WB阶段的乘法高32位结果
    output [31:0] Mmuler_lo,      // 传递给WB阶段的乘法低32位结果
    output [31:0] Mr,             // 传递给WB阶段的除法余数
    output [31:0] Mq,             // 传递给WB阶段的除法商
    output [31:0] Mcounter,       // 传递给WB阶段的计数器结果
    output [31:0] Malu,           // 传递给WB阶段的ALU结果
    output [31:0] Mdm,            // 从数据存储器读取的数据
    output [31:0] Mpc4,           // 传递给WB阶段的PC+4值
    output [31:0] Ma,             // 传递给WB阶段的寄存器A值
    output [31:0] Mb,             // 传递给WB阶段的寄存器B值
    output [31:0] Mcp0,           // 传递给WB阶段的CP0相关数据
    output [31:0] Mhi,            // 传递给WB阶段的HI寄存器值
    output [31:0] Mlo,            // 传递给WB阶段的LO寄存器值
    output [4:0] Mrn,             // 传递给WB阶段的目标寄存器编号
    output Mw_rf,                 // 传递给WB阶段的写寄存器文件标志
    output Mw_hi,                 // 传递给WB阶段的写HI标志
    output Mw_lo,                 // 传递给WB阶段的写LO标志
    output [1:0] Mhisource,       // 传递给WB阶段的HI源选择
    output [1:0] Mlosource,       // 传递给WB阶段的LO源选择
    output [2:0] Mrfsource        // 传递给WB阶段的寄存器文件源选择
);

// 直接传递输入信号到输出，实现流水线操作
assign Mpc4 = pc4;
assign Ma = a;
assign Mb = b;
assign Mcp0 = cp0;
assign Mhi = hi;
assign Mlo = lo;
assign Mmuler_hi = muler_hi;
assign Mmuler_lo = muler_lo;
assign Mr = r;
assign Mq = q;
assign Mcounter = counter;
assign Malu = alu;
assign Mrn = rn;
assign Mw_rf = w_rf;
assign Mw_hi = w_hi;
assign Mw_lo = w_lo;
assign Mhisource = hisource;
assign Mlosource = losource;
assign Mrfsource = rfsource;

// 数据存储器访问
wire [31:0] dmout;               // 从数据存储器读取的原始数据
DMEM_ip dmem(                     // 数据存储器IP模块
    .a(alu[11:2]),               // 使用ALU结果的[11:2]位作为存储器地址（32位对齐）
    .d(b),                       // 寄存器B的值作为写入数据
    .clk(clk),                   // 时钟信号
    .we(w_dm),                   // 写使能信号
    .spo(dmout)                  // 存储器输出数据
);

// 数据切割模块，根据cuttersource和sign信号处理读取的数据
Cutter cutter(dmout, cuttersource, sign, Mdm);

endmodule