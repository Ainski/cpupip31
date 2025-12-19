// Compare_ID 模块
// 功能：比较两个输入值，根据不同的分支指令类型判断是否发生分支转移
module Compare_ID(
    input [31:0] a,           // 第一个操作数 (通常来自寄存器Rs)
    input [31:0] b,           // 第二个操作数 (通常来自寄存器Rt或常量)
    input beq,                // BEQ 指令信号 (Branch if Equal)
    input bne,                // BNE 指令信号 (Branch if Not Equal)
    input bgez,               // BGEZ 指令信号 (Branch if Greater or Equal Than Zero)
    input teq,                // TEQ 指令信号 (Trap if EQual)，对于分支而言可当作BEQ处理
    output isBranch           // 是否发生分支的输出信号
);

// 根据不同的分支指令类型进行比较，并产生分支信号
assign isBranch =
    (beq & (a == b)) |                       // BEQ: 如果 a 等于 b 则分支
    (bne & (a != b)) |                       // BNE: 如果 a 不等于 b 则分支
    (bgez & ($signed(a) >= 0)) |             // BGEZ: 如果 a >= 0 则分支 (对寄存器rs值做有符号比较)
    (teq & (a == b));                        // TEQ: 如果 a 等于 b 则可能触发陷阱，此处简单按相等处理

endmodule