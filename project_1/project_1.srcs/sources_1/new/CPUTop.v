// 顶层CPU模块
// 5级MIPS-like流水线处理器
// 实例化并连接所有流水线阶段和组件

module CPUTop (
    input clk,                    // 系统时钟
    input rstn,                   // 系统复位（低电平有效）

    // 指令存储器接口
    output [11:2] imem_addr,      // 指令存储器地址
    input [31:0] imem_data,       // 指令存储器数据输入

    // 数据存储器接口
    output [11:2] dmem_addr,      // 数据存储器地址
    output [31:0] dmem_data,      // 数据存储器写入数据
    output dmem_we,               // 数据存储器写使能
    input [31:0] dmem_q           // 数据存储器读取数据
);

// 连接流水线阶段的内部信号
wire [31:0] pc_current, next_pc, pc_plus_4;  // 程序计数器信号
wire [31:0] instruction;                      // IF阶段的指令

// IF和ID阶段之间的信号
wire [31:0] pc4_d, inst_d;                   // ID阶段的PC+4和指令

// PC选择的控制信号
wire [2:0] pcsource_ctrl;
wire [31:0] cpc, rpc, bpc, jpc;

// ID、EXE、MEM阶段之间的信号（转发路径）
wire [31:0] rf_a, rf_b;                      // 来自ID阶段的寄存器文件输出
wire [31:0] ex_alu_result;                   // EX阶段的ALU结果
wire [31:0] mem_alu_result, mem_result;      // MEM阶段的ALU结果
wire [31:0] mem_data_result;                 // MEM阶段的存储器数据结果
wire [4:0] ex_reg_num;                       // EX阶段的目标寄存器编号
wire [4:0] mem_reg_num;                      // MEM阶段的目标寄存器编号
wire ex_w_rf, mem_w_rf;                      // 写寄存器文件标志

// ID阶段控制信号
wire id_sign, id_div, id_w_hi, id_w_lo, id_w_rf, id_w_dm;
wire id_isGoto, id_stall;
wire [3:0] id_aluc;
wire [2:0] id_rfsource;
wire [1:0] id_asource, id_bsource;
wire [1:0] id_hisource, id_losource;
wire [2:0] id_pcsource;
wire [4:0] id_rn;

// EX阶段控制信号
wire ex_w_hi, ex_w_lo, ex_w_rf, ex_w_dm, ex_isGoto;
wire [2:0] ex_rfsource;
wire [1:0] ex_hisource, ex_losource, ex_cuttersource;

// EX阶段数据信号
wire [31:0] ex_a, ex_b, ex_imm, ex_cp0, ex_hi, ex_lo;
wire [4:0] ex_rn;
wire ex_sign, ex_div;
wire [3:0] ex_aluc;
wire [1:0] ex_asource, ex_bsource;

// MEM阶段控制信号
wire mem_w_hi, mem_w_lo, mem_w_rf;
wire [2:0] mem_rfsource;
wire [1:0] mem_hisource, mem_losource;
wire [1:0] mem_cuttersource;

// WB阶段控制/输出信号
wire wb_w_rf, wb_w_hi, wb_w_lo;
wire [4:0] wb_wrn;
wire [31:0] wb_data_rf, wb_data_hi, wb_data_lo;

// 流水线寄存器控制信号
wire de_wena = ~id_stall;  // 如果不停顿则启用DE寄存器
wire em_wena = 1'b1;       // 启用EM寄存器（目前）
wire mw_wena = 1'b1;       // 启用MW寄存器（目前）

// 实例化PC寄存器
PcReg pc_reg (
    .clk(clk),
    .rstn(rstn),
    .wena(1'b1),  // 为简化起见始终启用-可由冒险检测控制
    .data_in(next_pc),
    .data_out(pc_current)
);

// 实例化指令获取阶段
PipeIF if_stage (
    .pc(pc_current),
    .cpc(cpc),
    .bpc(bpc),
    .rpc(rpc),
    .jpc(jpc),
    .pcsource(id_pcsource),
    .npc(next_pc),
    .pc4(pc_plus_4),
    .instruction(instruction)
);

// 连接IF到指令存储器
assign imem_addr = pc_current[11:2];
assign instruction = imem_data;

// 实例化IF/ID流水线寄存器
PipeIR if_id_reg (
    .clk(clk),
    .rstn(rstn),
    .pc4(pc_plus_4),
    .instruction(instruction),
    .nostall(de_wena),
    .Dpc4(pc4_d),
    .Dinstruction(inst_d)
);

// 实例化指令译码阶段
PipeID id_stage (
    .clk(clk),
    .rstn(rstn),
    .pc4(pc4_d),
    .inst(inst_d),
    .Ealu(ex_alu_result),
    .Malu(mem_alu_result),
    .Mdm(mem_data_result),
    .Ehi(ex_hi),        // EX阶段HI寄存器反馈
    .Elo(ex_lo),        // EX阶段LO寄存器反馈
    .Epc0(32'h0),       // CP0反馈的占位符
    .Emuler_hi(32'h0),  // 乘法器HI反馈的占位符
    .Emuler_lo(32'h0),  // 乘法器LO反馈的占位符
    .Er(32'h0),         // 除法器余数反馈的占位符
    .Eq(32'h0),         // 除法器商反馈的占位符
    .Ecounter(32'h0),   // 计数器反馈的占位符
    .Ern(ex_reg_num),
    .Mrn(mem_reg_num),
    .Ew_rf(ex_w_rf),
    .Mw_rf(mem_w_rf),
    .Ew_hi(ex_w_hi),
    .Ew_lo(ex_w_lo),
    .Erfsource(ex_rfsource),
    .Mrfsource(mem_rfsource),
    .Ehisource(ex_hisource),
    .Elosource(ex_losource), // 注意：原模块中拼写错误 - Elosourse
    .Wdata_rf(wb_data_rf),
    .Wrn(wb_wrn),
    .Wena_rf(wb_w_rf),
    .Wena_hi(wb_w_hi),
    .Wena_lo(wb_w_lo),
    .EisGoto(ex_isGoto),
    .cpc(cpc),
    .rpc(rpc),
    .bpc(bpc),
    .jpc(jpc),
    .Rsout(rf_a),
    .Rtout(rf_b),
    .imm(ex_imm),
    .Dpc4(),
    .CP0out(ex_cp0),
    .Hiout(ex_hi),
    .Loout(ex_lo),
    .rn(id_rn),
    .sign(id_sign),
    .div(id_div),
    .aluc(id_aluc),
    .w_hi(id_w_hi),
    .w_lo(id_w_lo),
    .w_rf(id_w_rf),
    .w_dm(id_w_dm),
    .asource(id_asource),
    .bsource(id_bsource),
    .cuttersource(id_hisource),  // 正确连接
    .hisource(id_hisource),
    .losource(id_losource),
    .rfsource(id_rfsource),
    .pcsource(id_pcsource),
    .stall(id_stall),
    .isGoto(id_isGoto),
    .reg28()
);

// 实例化ID/EX流水线寄存器
PipeDEreg de_reg (
    .clk(clk),
    .rstn(rstn),
    .wena(de_wena),
    .Dpc4(pc4_d),
    .Da(rf_a),
    .Db(rf_b),
    .Dimm(ex_imm),
    .Dcp0(ex_cp0),
    .Dhi(ex_hi),
    .Dlo(ex_lo),
    .Drn(id_rn),
    .Dsign(id_sign),
    .Ddiv(id_div),
    .Daluc(id_aluc),
    .Dw_rf(id_w_rf),
    .Dw_hi(id_w_hi),
    .Dw_lo(id_w_lo),
    .Dw_dm(id_w_dm),
    .DisGoto(id_isGoto),
    .Dasource(id_asource),
    .Dbsource(id_bsource),
    .Dcuttersource(id_hisource),
    .Dhisource(id_hisource),
    .Dlosource(id_losource),
    .Drfsource(id_rfsource),
    .Epc4(ex_a),
    .Ea(ex_a),
    .Eb(ex_b),
    .Eimm(ex_imm),
    .Ecp0(ex_cp0),
    .Ehi(ex_hi),
    .Elo(ex_lo),
    .Ern(ex_rn),
    .Esign(ex_sign),
    .Ediv(ex_div),
    .Ealuc(ex_aluc),
    .Ew_rf(ex_w_rf),
    .Ew_hi(ex_w_hi),
    .Ew_lo(ex_w_lo),
    .Ew_dm(ex_w_dm),
    .EisGoto(ex_isGoto),
    .Easource(ex_asource),
    .Ebsource(ex_bsource),
    .Ecuttersource(ex_cuttersource),
    .Ehisource(ex_hisource),
    .Elosource(ex_losource),
    .Erfsource(ex_rfsource)
);

// 注意：EX阶段需要实际计算值，而不是仅仅分配
// 我们在下面实例化模块

// 实例化执行阶段
PipeEXE exe_stage (
    .clk(clk),
    .rstn(rstn),
    .pc4(ex_a),
    .a(ex_a),
    .b(ex_b),
    .imm(ex_imm),
    .cp0(ex_cp0),
    .hi(ex_hi),
    .lo(ex_lo),
    .rn(ex_rn),
    .sign(ex_sign),
    .div(ex_div),
    .aluc(ex_aluc),
    .w_rf(ex_w_rf),
    .w_hi(ex_w_hi),
    .w_lo(ex_w_lo),
    .w_dm(ex_w_dm),
    .isGoto(ex_isGoto),
    .asource(ex_asource),
    .bsource(ex_bsource),
    .cuttersource(ex_cuttersource),
    .hisource(ex_hisource),
    .losource(ex_losource),
    .rfsource(ex_rfsource),
    .Emuler_hi(),       // 乘法器HI结果
    .Emuler_lo(),       // 乘法器LO结果
    .Er(),              // 除法器余数
    .Eq(),              // 除法器商
    .Ecounter(),        // 计数器结果
    .Ealu(ex_alu_result),
    .Epc4(),            // 传到MEM的PC+4
    .Ea(ex_a),          // 传到MEM的寄存器A
    .Eb(ex_b),          // 传到MEM的寄存器B
    .Ecp0(ex_cp0),      // 传到MEM的CP0数据
    .Ehi(ex_hi),        // 传到MEM的HI寄存器
    .Elo(ex_lo),        // 传到MEM的LO寄存器
    .Ern(ex_reg_num),
    .Ew_rf(ex_w_rf),
    .Ew_hi(ex_w_hi),
    .Ew_lo(ex_w_lo),
    .Ew_dm(ex_w_dm),
    .EisGoto(ex_isGoto),
    .Ecuttersource(ex_cuttersource),
    .Ehisource(ex_hisource),
    .Elosource(ex_losource),
    .Erfsource(ex_rfsource)
);

// 实例化EX/MEM流水线寄存器
PipeEMreg em_reg (
    .clk(clk),
    .rstn(rstn),
    .wena(em_wena),
    .Emuler_hi(32'h0),  // 占位符
    .Emuler_lo(32'h0),  // 占位符
    .Er(32'h0),         // 占位符
    .Eq(32'h0),         // 占位符
    .Ecounter(32'h0),   // 占位符
    .Ealu(ex_alu_result),
    .Epc4(ex_a),        // 传到MEM的PC+4
    .Ea(ex_a),          // 传到MEM的寄存器A
    .Eb(ex_b),          // 传到MEM的寄存器B
    .Ecp0(ex_cp0),      // 传到MEM的CP0数据
    .Ehi(ex_hi),        // 传到MEM的HI寄存器
    .Elo(ex_lo),        // 传到MEM的LO寄存器
    .Ern(ex_reg_num),
    .Esign(ex_sign),    // 传到MEM的符号扩展标志
    .Ew_rf(ex_w_rf),    // 传到MEM的写RF标志
    .Ew_hi(ex_w_hi),    // 传到MEM的写HI标志
    .Ew_lo(ex_w_lo),    // 传到MEM的写LO标志
    .Ew_dm(ex_w_dm),    // 传到MEM的写DM标志
    .Ecuttersource(ex_cuttersource),
    .Ehisource(ex_hisource),
    .Elosource(ex_losource),
    .Erfsource(ex_rfsource),
    .Mmuler_hi(),       // 传到MEM的乘法器HI
    .Mmuler_lo(),       // 传到MEM的乘法器LO
    .Mr(),              // 传到MEM的除法器余数
    .Mq(),              // 传到MEM的除法器商
    .Mcounter(),        // 传到MEM的计数器
    .Malu(mem_alu_result),
    .Mpc4(),            // 传到MEM的PC+4
    .Ma(),              // 传到MEM的寄存器A
    .Mb(),              // 传到MEM的寄存器B
    .Mcp0(),            // 传到MEM的CP0数据
    .Mhi(),             // 传到MEM的HI寄存器
    .Mlo(),             // 传到MEM的LO寄存器
    .Mrn(mem_reg_num),
    .Msign(),           // 传到MEM的符号扩展标志
    .Mw_rf(mem_w_rf),   // 传到MEM的写RF标志
    .Mw_hi(mem_w_hi),   // 传到MEM的写HI标志
    .Mw_lo(mem_w_lo),   // 传到MEM的写LO标志
    .Mw_dn(mem_w_dm),   // 修正信号名 Mw_dn -> mem_w_dm
    .Mcuttersource(mem_cuttersource), // 修正信号名
    .Mhisource(mem_hisource),     // 修正信号名
    .Mlosource(mem_losource),     // 修正信号名
    .Mrfsource(mem_rfsource)
);

// 实例化存储器访问阶段
PipeMEM mem_stage (
    .clk(clk),
    .muler_hi(32'h0),        // 占位符
    .muler_lo(32'h0),        // 占位符
    .r(32'h0),               // 占位符
    .q(32'h0),               // 占位符
    .counter(32'h0),         // 占位符
    .alu(mem_alu_result),    // 存储器访问的地址
    .pc4(),                  // 来自EX阶段的PC+4
    .a(),                    // 来自EX阶段的寄存器A
    .b(),                    // 来自EX阶段的寄存器B（写入数据）
    .cp0(),                  // 来自EX阶段的CP0数据
    .hi(),                   // 来自EX阶段的HI寄存器
    .lo(),                   // 来自EX阶段的LO寄存器
    .rn(mem_reg_num),
    .w_rf(mem_w_rf),
    .w_hi(mem_w_hi),
    .w_lo(mem_w_lo),
    .w_dm(mem_w_dm),
    .sign(),                 // 来自EX的符号扩展
    .cuttersource(mem_cuttersource),  // 来自EX的数据切割源
    .hisource(mem_hisource),          // 来自EX的HI源
    .losource(mem_losource),          // 来自EX的LO源
    .rfsource(mem_rfsource),          // 来自EX的RF源
    .alusource(2'b00),       // ALU源（占位符）
    .Mmuler_hi(),            // 传到WB的乘法器HI
    .Mmuler_lo(),            // 传到WB的乘法器LO
    .Mr(),                   // 传到WB的除法器余数
    .Mq(),                   // 传到WB的除法器商
    .Mcounter(),             // 传到WB的计数器
    .Malu(mem_alu_result),   // 传到WB的ALU结果
    .Mdm(mem_data_result),   // 传到WB的存储器数据
    .Mpc4(),                 // 传到WB的PC+4
    .Ma(),                   // 传到WB的寄存器A
    .Mb(),                   // 传到WB的寄存器B
    .Mcp0(),                 // 传到WB的CP0数据
    .Mhi(),                  // 传到WB的HI寄存器
    .Mlo(),                  // 传到WB的LO寄存器
    .Mrn(),                  // 传到WB的寄存器编号
    .Mw_rf(),                // 传到WB的写RF标志
    .Mw_hi(),                // 传到WB的写HI标志
    .Mw_lo(),                // 传到WB的写LO标志
    .Mhisource(),            // 传到WB的HI源
    .Mlosource(),            // 传到WB的LO源
    .Mrfsource()             // 传到WB的RF源
);

// 连接MEM阶段到数据存储器
assign dmem_addr = mem_alu_result[11:2];  // 使用ALU结果作为存储器地址
assign dmem_data = 32'h0;                 // 将被实际寄存器B值替换
assign dmem_we = mem_w_dm;                // 使用来自MEM阶段的写使能

// 分配存储器输出到内部信号
assign mem_data_result = dmem_q;

// 实例化MEM/WB流水线寄存器
PipeMWreg mw_reg (
    .clk(clk),
    .rstn(rstn),
    .wena(mw_wena),
    .Mmuler_hi(),    // 来自MEM的乘法器HI
    .Mmuler_lo(),    // 修正拼写错误：Muler_lo -> Mmuler_lo
    .Mr(),           // 来自MEM的除法器余数
    .Mq(),           // 来自MEM的除法器商
    .Mcounter(),     // 来自MEM的计数器
    .Malu(mem_alu_result),  // 来自MEM的ALU结果
    .Mdm(mem_data_result),  // 来自MEM的存储器数据
    .Mpc4(),         // 来自MEM的PC+4
    .Ma(),           // 来自MEM的寄存器A
    .Mb(),           // 来自MEM的寄存器B
    .Mcp0(),         // 来自MEM的CP0数据
    .Mhi(),          // 来自MEM的HI寄存器
    .Mlo(),          // 来自MEM的LO寄存器
    .Mrn(mem_reg_num),    // 来自MEM的寄存器编号
    .Mw_rf(mem_w_rf),     // 来自MEM的写RF标志
    .Mw_hi(mem_w_hi),     // 来自MEM的写HI标志
    .Mw_lo(mem_w_lo),     // 来自MEM的写LO标志
    .Mcuttersource(mem_cuttersource),  // 来自MEM的切割源
    .Mhisource(mem_hisource),          // 来自MEM的HI源
    .Mlosource(mem_losource),          // 来自MEM的LO源
    .Mrfsource(mem_rfsource),          // 来自MEM的RF源
    .Wmuler_hi(),    // 传到WB的乘法器HI
    .Wmuler_lo(),    // 传到WB的乘法器LO
    .Wr(),           // 传到WB的除法器余数
    .Wq(),           // 传到WB的除法器商
    .Wcounter(),     // 传到WB的计数器
    .Walu(mem_alu_result),  // 传到WB的ALU结果
    .Wdm(mem_data_result),  // 传到WB的存储器数据
    .Wpc4(),         // 传到WB的PC+4
    .Wa(),           // 传到WB的寄存器A
    .Wb(),           // 传到WB的寄存器B
    .Wcp0(),         // 传到WB的CP0数据
    .Whi(),          // 传到WB的HI寄存器
    .Wlo(),          // 传到WB的LO寄存器
    .Wrn(wb_wrn),    // 传到WB的寄存器编号
    .Ww_rf(wb_w_rf), // 传到WB的写RF标志
    .Ww_hi(wb_w_hi), // 传到WB的写HI标志
    .Ww_lo(wb_w_lo), // 传到WB的写LO标志
    .Wcuttersource(), // 传到WB的切割源
    .Whisource(),    // 传到WB的HI源
    .Wlosource(),    // 传到WB的LO源
    .Wrfsource()     // 传到WB的RF源
);

// 实例化写回阶段
PipeWB wb_stage (
    .muler_hi(),          // 来自MEM的乘法器HI结果
    .muler_lo(),          // 来自MEM的乘法器LO结果
    .r(),                 // 来自MEM的除法器余数
    .q(),                 // 来自MEM的除法器商
    .counter(),           // 来自MEM的计数器结果
    .alu(mem_alu_result), // 来自MEM的ALU结果
    .dm(mem_data_result), // 来自MEM的存储器数据
    .pc4(),               // 来自MEM的PC+4
    .a(),                 // 来自MEM的寄存器A
    .b(),                 // 来自MEM的寄存器B
    .rn(wb_wrn),          // 来自MEM的目标寄存器编号
    .w_rf(wb_w_rf),       // 来自MEM的写RF标志
    .w_hi(wb_w_hi),       // 来自MEM的写HI标志
    .w_lo(wb_w_lo),       // 来自MEM的写LO标志
    .hisource(),          // 来自MEM的HI源选择
    .losource(),          // 来自MEM的LO源选择
    .rfsource(mem_rfsource), // 来自MEM的RF源选择
    .Wdata_hi(wb_data_hi),   // HI写入数据
    .Wdata_lo(wb_data_lo),   // LO写入数据
    .Wdata_rf(wb_data_rf),   // RF写入数据
    .Wrn(wb_wrn),          // 写入寄存器编号
    .Ww_rf(wb_w_rf),       // 写入RF使能
    .Ww_hi(wb_w_hi),       // 写入HI使能
    .Ww_lo(wb_w_lo)        // 写入LO使能
);

endmodule