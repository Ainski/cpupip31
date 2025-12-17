// ============================================================
// 指令操作码 (OPCODE) 定义
// ============================================================

// R型指令操作码
`define OP_R_TYPE      6'b000000

// I型指令操作码
`define OP_BGEZ        6'b000001
`define OP_J           6'b000010
`define OP_JAL         6'b000011
`define OP_BEQ         6'b000100
`define OP_BNE         6'b000101
`define OP_ADDI        6'b001000
`define OP_ADDIU       6'b001001
`define OP_SLTI        6'b001010
`define OP_SLTIU       6'b001011
`define OP_ANDI        6'b001100
`define OP_ORI         6'b001101
`define OP_XORI        6'b001110
`define OP_LUI         6'b001111
`define OP_COPROC0     6'b010000  // CP0相关指令
`define OP_CLZ         6'b011100
`define OP_LB          6'b100000
`define OP_LH          6'b100001
`define OP_LW          6'b100011
`define OP_LBU         6'b100100
`define OP_LHU         6'b100101
`define OP_SB          6'b101000
`define OP_SH          6'b101001
`define OP_SW          6'b101011

// ============================================================
// R型指令功能码 (FUNCTION) 定义
// ============================================================

// 移位操作
`define FUNC_SLL       6'b000000
`define FUNC_SRL       6'b000010
`define FUNC_SRA       6'b000011
`define FUNC_SLLV      6'b000100
`define FUNC_SRLV      6'b000110
`define FUNC_SRAV      6'b000111

// 跳转操作
`define FUNC_JR        6'b001000
`define FUNC_JALR      6'b001001

// 特殊寄存器操作
`define FUNC_MFHI      6'b010000
`define FUNC_MTHI      6'b010001
`define FUNC_MFLO      6'b010010
`define FUNC_MTLO      6'b010011

// 乘除操作
`define FUNC_MULT      6'b011000
`define FUNC_MULTU     6'b011001
`define FUNC_DIV       6'b011010
`define FUNC_DIVU      6'b011011

// 算术逻辑操作
`define FUNC_ADD       6'b100000
`define FUNC_ADDU      6'b100001
`define FUNC_SUB       6'b100010
`define FUNC_SUBU      6'b100011
`define FUNC_AND       6'b100100
`define FUNC_OR        6'b100101
`define FUNC_XOR       6'b100110
`define FUNC_NOR       6'b100111
`define FUNC_SLT       6'b101010
`define FUNC_SLTU      6'b101011

// 异常操作
`define FUNC_TEQ       6'b110100
`define FUNC_SYSCALL   6'b001100
`define FUNC_BREAK     6'b001101
`define FUNC_ERET      6'b011000  // ERET指令功能码

// ============================================================
// RT字段特殊值定义
// ============================================================

// BGEZ指令的RT字段
`define RT_BGEZ        5'b00001

// CP0指令的RS字段
`define RS_MFC0        5'b00000
`define RS_MTC0        5'b00100
`define RS_ERET        5'b10000

// ============================================================
// 特殊指令编码定义
// ============================================================

// 完整指令编码
`define INSTR_BREAK    32'b000000_00000_00000_00000_00000_001101
`define INSTR_SYSCALL  32'b000000_00000_00000_00000_00000_001100
`define INSTR_ERET     32'b010000_10000_00000_00000_00000_011000
`define INSTR_HALT     32'b111111_11111_11111_11111_11111_111111
`define INSTR_NOP      32'b000000_00000_00000_00000_00000_000000

// ============================================================
// ALU控制信号定义
// ============================================================

// 基本算术逻辑运算
`define ALUC_ADD       4'b0010
`define ALUC_ADDU      4'b0000
`define ALUC_SUB       4'b0011
`define ALUC_SUBU      4'b0001
`define ALUC_AND       4'b0100
`define ALUC_OR        4'b0101
`define ALUC_XOR       4'b0110
`define ALUC_NOR       4'b0111
`define ALUC_SLT       4'b1011
`define ALUC_SLTU      4'b1010

// 移位运算
`define ALUC_SLL       4'b1110
`define ALUC_SRL       4'b1101
`define ALUC_SRA       4'b1100
`define ALUC_SLA       4'b1111  // 算术左移（同逻辑左移）

// 特殊运算
`define ALUC_LUI       4'b1000   // 加载高位立即数
`define ALUC_BGEZ      4'b1001   // 大于等于零比较
`define ALUC_CLZ       4'b1010   // 前导零计数

// ============================================================
// ALU乘除单元控制信号定义
// ============================================================

// 乘除运算类型
`define ALUMCTR_NVL    3'b000   // 非乘除指令
`define ALUMCTR_MULT   3'b001   // 有符号乘法
`define ALUMCTR_MULTU  3'b010   // 无符号乘法
`define ALUMCTR_DIV    3'b011   // 有符号除法
`define ALUMCTR_DIVU   3'b100   // 无符号除法
`define ALUMCTR_MTHI   3'b101   // 移动到HI
`define ALUMCTR_MTLO   3'b110   // 移动到LO

// ============================================================
// 异常原因编码定义
// ============================================================

`define CAUSE_SYSCALL  4'b1000
`define CAUSE_BREAK    4'b1001
`define CAUSE_TEQ      4'b1101
`define CAUSE_INTERRUPT 4'b0000  // 中断异常
`define CAUSE_OVERFLOW 4'b1100   // 溢出异常

// ============================================================
// 存储器访问控制信号定义
// ============================================================

// 存储指令控制（写内存）
`define MEM_STORE_BYTE    2'b10
`define MEM_STORE_HALF    2'b01
`define MEM_STORE_WORD    2'b00

// 加载指令控制（读内存）
`define MEM_LOAD_WORD     3'b000
`define MEM_LOAD_HALF_U   3'b001   // 无符号半字
`define MEM_LOAD_HALF_S   3'b010   // 有符号半字
`define MEM_LOAD_BYTE     3'b100   // 有符号字节
`define MEM_LOAD_BYTE_U   3'b011   // 无符号字节

// ============================================================
// 数据前递源选择定义
// ============================================================

`define FWD_SRC_NONE     3'b000    // 不前递，使用寄存器值
`define FWD_SRC_EX_ALU   3'b001    // 来自EX阶段ALU结果
`define FWD_SRC_EX_MULT  3'b010    // 来自EX阶段乘法器结果
`define FWD_SRC_EX_HI    3'b011    // 来自EX阶段HI寄存器
`define FWD_SRC_EX_LO    3'b100    // 来自EX阶段LO寄存器
`define FWD_SRC_MEM      3'b101    // 来自MEM阶段结果
`define FWD_SRC_WB       3'b110    // 来自WB阶段结果

// HI/LO寄存器前递选择
`define FWD_HILO_NONE    2'b00     // 不前递
`define FWD_HILO_EX      2'b01     // 来自EX阶段
`define FWD_HILO_MEM     2'b10     // 来自MEM阶段
`define FWD_HILO_WB      2'b11     // 来自WB阶段

// ============================================================
// 寄存器堆写入源选择定义
// ============================================================

`define RF_SRC_ALU      3'b000   // ALU计算结果
`define RF_SRC_MEM      3'b001   // 内存读取数据
`define RF_SRC_PC_PLUS4 3'b010   // PC+4（用于JAL）
`define RF_SRC_HILO     3'b011   // HI/LO寄存器
`define RF_SRC_CP0      3'b100   // CP0寄存器

// ============================================================
// PC源选择定义
// ============================================================

`define PC_SRC_SEQ      2'b00    // 顺序执行 (PC+4)
`define PC_SRC_JUMP     2'b01    // 跳转地址
`define PC_SRC_BRANCH   2'b10    // 分支地址
`define PC_SRC_REG      2'b11    // 寄存器地址（用于JR）
`define PC_SRC_EXCEPTION 2'b11   // 异常地址

// ============================================================
// HI/LO寄存器源选择定义
// ============================================================

`define HILO_SRC_NONE   2'b00    // 不写入
`define HILO_SRC_MULT   2'b01    // 乘法结果
`define HILO_SRC_DIV    2'b10    // 除法结果
`define HILO_SRC_MOVE   2'b11    // 寄存器移动

// ============================================================
// Tomasulo算法相关定义
// ============================================================

// 保留站类型
`define RS_TYPE_IDLE    3'b000   // 空闲
`define RS_TYPE_ALU     3'b001   // ALU操作
`define RS_TYPE_MULDIV  3'b010   // 乘除操作
`define RS_TYPE_MEM     3'b011   // 内存操作
`define RS_TYPE_BRANCH  3'b100   // 分支操作

// 功能单元状态
`define FU_IDLE         3'b000   // 空闲
`define FU_BUSY         3'b001   // 忙碌
`define FU_COMPLETE     3'b010   // 完成

// 操作数源类型
`define OP_SRC_REG      1'b0     // 来自寄存器
`define OP_SRC_IMM      1'b1     // 来自立即数

// 保留站操作数状态
`define RS_OP_READY     1'b1     // 操作数就绪
`define RS_OP_WAIT      1'b0     // 操作数等待

// ============================================================
// 控制信号默认值
// ============================================================

// 默认控制信号值
`define DEFAULT_ALUC    4'b0000
`define DEFAULT_RF_SRC  3'b000
`define DEFAULT_PC_SRC  2'b00
`define DEFAULT_MEM_CTL 2'b00
`define DEFAULT_LOAD_CTL 3'b000

// ============================================================
// 其他控制信号定义
// ============================================================

// 数据切割源选择
`define CUTTER_SRC_NONE  2'b00   // 不切割
`define CUTTER_SRC_HALF  2'b01   // 半字切割
`define CUTTER_SRC_BYTE  2'b10   // 字节切割

// CP0写控制
`define CP0_WRITE_NONE  1'b0     // 不写入CP0
`define CP0_WRITE_EN    1'b1     // 写入CP0

// 流水线控制
`define STALL_DISABLE   1'b0     // 不暂停
`define STALL_ENABLE    1'b1     // 暂停

// 跳转控制
`define GOTO_DISABLE    1'b0     // 非跳转指令
`define GOTO_ENABLE     1'b1     // 跳转指令