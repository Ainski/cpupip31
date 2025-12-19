// 指令获取阶段模块（IF）
// 功能：根据程序计数器获取指令，计算下一个PC值
module PipeIF (
    input [31:0] pc,              // 当前程序计数器值
    input [31:0] cpc,             // CP0控制寄存器提供的PC值
    input [31:0] bpc,             // 分支指令计算的PC值
    input [31:0] rpc,             // 返回指令的PC值
    input [31:0] jpc,             // 跳转指令的PC值
    input [2:0] pcsource,         // PC源选择信号
    output [31:0] npc,            // 下一个程序计数器值
    output [31:0] pc4,            // 当前PC+4的值
    output [31:0] instruction     // 从指令存储器获取的指令
);
    // 计算PC+4的值
    assign pc4 = pc + 32'h4;

    // 根据pcsource信号选择下一个PC值
    // 0: 32'h4
    // 1: CP0提供的PC值
    // 2: 返回指令的PC值
    // 3: 分支指令计算的PC值
    // 4: 跳转指令的PC值
    // 5: 当前PC+4
    MUX6_1 next_pc(
        .d0(32'h4),
        .d1(cpc),
        .d2(rpc),
        .d3(bpc),
        .d4(jpc),
        .d5(pc4),
        .sel(pcsource),
        .y(npc)
    );

    // 从指令存储器中获取指令，地址为pc[11:2]（使用pc的[11:2]位作为地址）
    IMEM_ip imem(
        .a(pc[12:2]),
        .spo(instruction)
    );
endmodule