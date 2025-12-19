module PipelineCPU(
    input clk,          // 时钟信号
    input rstn,         // 异步复位信号（低电平有效）
    input userbreak
);

    // ================== 内部信号定义 ==================

    // IF阶段信号
    wire [31:0] pc;                 // 当前PC值
    wire [31:0] npc;                // 下一个PC值
    wire [31:0] pc4_if;             // IF阶段PC+4
    wire [31:0] instruction;        // 从指令存储器获取的指令
    wire [2:0] pcsource_id;         // ID阶段产生的PC源选择信号
    wire [31:0] cpc_id, rpc_id, bpc_id, jpc_id; // 各种PC源值

    // IF/ID流水线寄存器信号
    wire [31:0] Dpc4;               // ID阶段PC+4
    wire [31:0] Dinstruction;       // ID阶段指令
    wire nostall;                   // 流水线暂停控制信号

    // ID阶段信号
    wire [31:0] Rsout_id, Rtout_id; // 寄存器输出
    wire [31:0] imm_id;             // 立即数
    wire [31:0] Hiout_id, Loout_id; // HI/LO寄存器输出
    wire [31:0] CP0out_id;          // CP0输出
    wire [4:0] rn_id;               // 目标寄存器编号
    wire sign_id, div_id;           // 符号扩展和除法标志
    wire [3:0] aluc_id;             // ALU操作码
    wire w_hi_id, w_lo_id, w_rf_id, w_dm_id; // 写使能标志
    wire asource_id, bsource_id;    // 操作数源选择
    wire [1:0] hisource_id, losource_id; // HI/LO源选择
    wire [2:0] rfsource_id;         // 寄存器文件源选择
    wire [1:0] SC_id;       // 存储器命令信号
    wire [2:0] LC_id;
    wire stall_id;                  // 流水线暂停信号
    wire isGoto_id;                 // 跳转指令标志
    wire [31:0] reg28_id;           // 特殊寄存器输出
    wire halt;
    // ID/EX流水线寄存器信号
    wire [31:0] Epc4, Ea, Eb, Eimm, Ecp0, Ehi, Elo;
    wire [4:0] Ern;
    wire Esign, Ediv;
    wire [3:0] Ealuc;
    wire Ew_rf, Ew_hi, Ew_lo, Ew_dm, EisGoto;
    wire Easource, Ebsource;
    wire [1:0] Ehisource, Elosource;
    wire [2:0] Erfsource;
    wire [1:0] ESC;
    wire [2:0] ELC;

    // EX阶段信号
    wire [31:0] Emuler_hi, Emuler_lo, Er, Eq, Ecounter, Ealu;
    wire Ew_dm_ex; // EX阶段写数据存储器标志

    // EX/MEM流水线寄存器信号
    wire [31:0] Mmuler_hi, Mmuler_lo, Mr, Mq, Mcounter, Malu;
    wire [31:0] Mpc4, Ma, Mb, Mcp0, Mhi, Mlo;
    wire [4:0] Mrn;
    wire Msign, Mw_rf, Mw_hi, Mw_lo, Mw_dm;
    wire [1:0] Mhisource, Mlosource;
    wire [2:0] Mrfsource;
    wire [1:0] MSC;
    wire [2:0] MLC;

    // MEM阶段信号
    wire [31:0] Mdm;                // 从数据存储器读取的数据
    wire [31:0] Mdm_out;           // MEM阶段输出到WB的数据
    wire [31:0] Mmuler_hi_mem, Mmuler_lo_mem, Mr_mem, Mq_mem, Mcounter_mem, Malu_mem;
    wire [31:0] Mpc4_mem, Ma_mem, Mb_mem, Mcp0_mem, Mhi_mem, Mlo_mem;
    wire [4:0] Mrn_mem;
    wire Mw_rf_mem, Mw_hi_mem, Mw_lo_mem;
    wire [1:0] Mhisource_mem, Mlosource_mem;
    wire [2:0] Mrfsource_mem;

    // MEM/WB流水线寄存器信号
    wire [31:0] Wmuler_hi, Wmuler_lo, Wr, Wq, Wcounter, Walu, Wdm;
    wire [31:0] Wpc4, Wa, Wb, Wcp0, Whi, Wlo;
    wire [4:0] Wrn;
    wire Ww_rf, Ww_hi, Ww_lo;
    wire [1:0] Whisource, Wlosource;
    wire [2:0] Wrfsource;

    // WB阶段信号
    wire [31:0] Wdata_hi, Wdata_lo, Wdata_rf;
    wire [4:0] Wrn_wb;
    wire Ww_rf_wb, Ww_hi_wb, Ww_lo_wb;

    // 写回数据到寄存器文件
    wire [31:0] Wdata_rf_to_regfile;
    wire [31:0] Wdata_lo_to_regfile;
    wire [31:0] Wdata_hi_to_regfile;
    wire [4:0] Wrn_to_regfile;
    wire Wena_rf, Wena_hi, Wena_lo;

    // 数据前递相关信号
    wire [1:0] fwhi_id, fwlo_id;
    wire [2:0] fwda_id, fwdb_id;
    

    // ================== 模块实例化 ==================

    // 1. PC寄存器
    PcReg pc_reg(
        .clk(clk),
        .rstn(rstn),
        .wena(1'b1),        // 假设始终允许写
        .data_in(npc),
        .halt(halt),
        .data_out(pc)
    );

    // 2. IF阶段

    PipeIF pipe_if(
        .pc(pc),
        .cpc(cpc_id),
        .bpc(bpc_id),
        .rpc(rpc_id),
        .jpc(jpc_id),
        .pcsource(pcsource_id),
        .npc(npc),
        .pc4(pc4_if),
        .instruction(instruction)
    );

    // 3. IF/ID流水线寄存器
    assign nostall = ~stall_id; // 暂停控制取反
    PipeIR pipe_ir(
        .clk(clk),
        .rstn(rstn),
        .pc4(pc4_if),
        .instruction(instruction),
        .nostall(nostall),
        .Dpc4(Dpc4),
        .Dinstruction(Dinstruction)
    );

    // 4. ID阶段
    PipeID pipe_id(
        .clk(clk),
        .rstn(rstn),
        .userbreak(userbreak),
        .pc4(Dpc4),
        .inst(Dinstruction),
        .Ealu(Ealu),
        .Malu(Malu_mem),
        .Mdm(Mdm),
        .Ehi(Ehi),
        .Elo(Elo),
        .Epc0(Ecp0),
        .Emuler_hi(Emuler_hi),
        .Emuler_lo(Emuler_lo),
        .Er(Er),
        .Eq(Eq),
        .Ecounter(Ecounter),
        .Ern(Ern),
        .Mrn(Mrn_mem),
        .Ew_rf(Ew_rf),
        .Mw_rf(Mw_rf_mem),
        .Ew_hi(Ew_hi),
        .Ew_lo(Ew_lo),
        .Erfsource(Erfsource),
        .Mrfsource(Mrfsource_mem),
        .Ehisource(Ehisource),
        .Elosource(Elosource),
        .Wdata_rf(Wdata_rf_to_regfile),
        .Wdata_hi(Wdata_hi_to_regfile),
        .Wdata_lo(Wdata_lo_to_regfile),
        .Wrn(Wrn_to_regfile),
        .Wena_rf(Wena_rf),
        .Wena_hi(Wena_hi),
        .Wena_lo(Wena_lo),
        .EisGoto(EisGoto),
        .cpc(cpc_id),
        .rpc(rpc_id),
        .bpc(bpc_id),
        .jpc(jpc_id),
        .Rsout(Rsout_id),
        .Rtout(Rtout_id),
        .imm(imm_id),
        .Dpc4(Dpc4),        // 传递给ID阶段内部使用
        .CP0out(CP0out_id),
        .Hiout(Hiout_id),
        .Loout(Loout_id),
        .rn(rn_id),
        .sign(sign_id),
        .div(div_id),
        .aluc(aluc_id),
        .w_hi(w_hi_id),
        .w_lo(w_lo_id),
        .w_rf(w_rf_id),
        .w_dm(w_dm_id),
        .asource(asource_id),
        .bsource(bsource_id),
        .hisource(hisource_id),
        .losource(losource_id),
        .rfsource(rfsource_id),
        .pcsource(pcsource_id),
        .SC(SC_id),
        .LC(LC_id),
        .stall(stall_id),
        .isGoto(isGoto_id),
        .reg28(reg28_id),
        .halt(halt)
    );

    // 5. ID/EX流水线寄存器
    PipeDEreg pipe_de(
        .clk(clk),
        .rstn(rstn),
        .wena(nostall),     // 与IF/ID寄存器同步
        .Dpc4(Dpc4),
        .Da(Rsout_id),
        .Db(Rtout_id),
        .Dimm(imm_id),
        .Dcp0(CP0out_id),
        .Dhi(Hiout_id),
        .Dlo(Loout_id),
        .Drn(rn_id),
        .Dsign(sign_id),
        .Ddiv(div_id),
        .Daluc(aluc_id),
        .Dw_rf(w_rf_id),
        .Dw_hi(w_hi_id),
        .Dw_lo(w_lo_id),
        .Dw_dm(w_dm_id),
        .DisGoto(isGoto_id),
        .Dasource(asource_id),
        .Dbsource(bsource_id),
        .Dhisource(hisource_id),
        .Dlosource(losource_id),
        .Drfsource(rfsource_id),
        .DSC(SC_id),
        .DLC(LC_id),
        .Epc4(Epc4),
        .Ea(Ea),
        .Eb(Eb),
        .Eimm(Eimm),
        .Ecp0(Ecp0),
        .Ehi(Ehi),
        .Elo(Elo),
        .Ern(Ern),
        .Esign(Esign),
        .Ediv(Ediv),
        .Ealuc(Ealuc),
        .Ew_rf(Ew_rf),
        .Ew_hi(Ew_hi),
        .Ew_lo(Ew_lo),
        .Ew_dm(Ew_dm),
        .EisGoto(EisGoto),
        .Easource(Easource),
        .Ebsource(Ebsource),
        .Ehisource(Ehisource),
        .Elosource(Elosource),
        .Erfsource(Erfsource),
        .ESC(ESC),
        .ELC(ELC)
    );

    // 6. EX阶段
    PipeEXE pipe_exe(
        .clk(clk),
        .rstn(rstn),
        .pc4(Epc4),
        .a(Ea),
        .b(Eb),
        .imm(Eimm),
        .cp0(Ecp0),
        .hi(Ehi),
        .lo(Elo),
        .rn(Ern),
        .sign(Esign),
        .div(Ediv),
        .aluc(Ealuc),
        .w_rf(Ew_rf),
        .w_hi(Ew_hi),
        .w_lo(Ew_lo),
        .w_dm(Ew_dm),
        .isGoto(EisGoto),
        .asource(Easource),
        .bsource(Ebsource),
        .hisource(Ehisource),
        .losource(Elosource),
        .rfsource(Erfsource),
        .SC(ESC),
        .LC(ELC),
        .Emuler_hi(Emuler_hi),
        .Emuler_lo(Emuler_lo),
        .Er(Er),
        .Eq(Eq),
        .Ecounter(Ecounter),
        .Ealu(Ealu),
        .Epc4(Epc4),
        .Ea(Ea),
        .Eb(Eb),
        .Ecp0(Ecp0),
        .Ehi(Ehi),
        .Elo(Elo),
        .Ern(Ern),
        .Ew_rf(Ew_rf),
        .Ew_hi(Ew_hi),
        .Ew_lo(Ew_lo),
        .Ew_dm(Ew_dm_ex),
        .EisGoto(EisGoto),
        .Ehisource(Ehisource),
        .Elosource(Elosource),
        .Erfsource(Erfsource),
        .ESC(ESC),
        .ELC(ELC)
    );

    // 7. EX/MEM流水线寄存器
    PipeEMreg pipe_em(
        .clk(clk),
        .rstn(rstn),
        .wena(1'b1),
        .Emuler_hi(Emuler_hi),
        .Emuler_lo(Emuler_lo),
        .Er(Er),
        .Eq(Eq),
        .Ecounter(Ecounter),
        .Ealu(Ealu),
        .Epc4(Epc4),
        .Ea(Ea),
        .Eb(Eb),
        .Ecp0(Ecp0),
        .Ehi(Ehi),
        .Elo(Elo),
        .Ern(Ern),
        .Esign(Esign),
        .Ew_rf(Ew_rf),
        .Ew_hi(Ew_hi),
        .Ew_lo(Ew_lo),
        .Ew_dm(Ew_dm_ex),
        .Ehisource(Ehisource),
        .Elosource(Elosource),
        .Erfsource(Erfsource),
        .ESC(ESC),
        .ELC(ELC),
        .Mmuler_hi(Mmuler_hi),
        .Mmuler_lo(Mmuler_lo),
        .Mr(Mr),
        .Mq(Mq),
        .Mcounter(Mcounter),
        .Malu(Malu),
        .Mpc4(Mpc4),
        .Ma(Ma),
        .Mb(Mb),
        .Mcp0(Mcp0),
        .Mhi(Mhi),
        .Mlo(Mlo),
        .Mrn(Mrn),
        .Msign(Msign),
        .Mw_rf(Mw_rf),
        .Mw_hi(Mw_hi),
        .Mw_lo(Mw_lo),
        .Mw_dn(Mw_dm),
        .Mhisource(Mhisource),
        .Mlosource(Mlosource),
        .Mrfsource(Mrfsource),
        .MSC(MSC),
        .MLC(MLC)
    );

    // 8. MEM阶段
    PipeMEM pipe_mem(
        .clk(clk),
        .muler_hi(Mmuler_hi),
        .muler_lo(Mmuler_lo),
        .r(Mr),
        .q(Mq),
        .counter(Mcounter),
        .alu(Malu),
        .pc4(Mpc4),
        .a(Ma),
        .b(Mb),
        .cp0(Mcp0),
        .hi(Mhi),
        .lo(Mlo),
        .rn(Mrn),
        .w_rf(Mw_rf),
        .w_hi(Mw_hi),
        .w_lo(Mw_lo),
        .w_dm(Mw_dm),
        .sign(Msign),
        .hisource(Mhisource),
        .losource(Mlosource),
        .rfsource(Mrfsource),
        .SC(MSC),
        .LC(MLC),
        .Mmuler_hi(Mmuler_hi_mem),
        .Mmuler_lo(Mmuler_lo_mem),
        .Mr(Mr_mem),
        .Mq(Mq_mem),
        .Mcounter(Mcounter_mem),
        .Malu(Malu_mem),
        .Mdm(Mdm),
        .Mpc4(Mpc4_mem),
        .Ma(Ma_mem),
        .Mb(Mb_mem),
        .Mcp0(Mcp0_mem),
        .Mhi(Mhi_mem),
        .Mlo(Mlo_mem),
        .Mrn(Mrn_mem),
        .Mw_rf(Mw_rf_mem),
        .Mw_hi(Mw_hi_mem),
        .Mw_lo(Mw_lo_mem),
        .Mhisource(Mhisource_mem),
        .Mlosource(Mlosource_mem),
        .Mrfsource(Mrfsource_mem),
        .MSC(),             // 未使用
        .MLC()              // 未使用
    );

    // 9. MEM/WB流水线寄存器
    PipeMWreg pipe_mw(
        .clk(clk),
        .rstn(rstn),
        .wena(1'b1),
        .Mmuler_hi(Mmuler_hi_mem),
        .Muler_lo(Mmuler_lo_mem),
        .Mr(Mr_mem),
        .Mq(Mq_mem),
        .Mcounter(Mcounter_mem),
        .Malu(Malu_mem),
        .Mdm(Mdm),
        .Mpc4(Mpc4_mem),
        .Ma(Ma_mem),
        .Mb(Mb_mem),
        .Mcp0(Mcp0_mem),
        .Mhi(Mhi_mem),
        .Mlo(Mlo_mem),
        .Mrn(Mrn_mem),
        .Mw_rf(Mw_rf_mem),
        .Mw_hi(Mw_hi_mem),
        .Mw_lo(Mw_lo_mem),
        .Mhisource(Mhisource_mem),
        .Mlosource(Mlosource_mem),
        .Mrfsource(Mrfsource_mem),
        .Wmuler_hi(Wmuler_hi),
        .Wmuler_lo(Wmuler_lo),
        .Wr(Wr),
        .Wq(Wq),
        .Wcounter(Wcounter),
        .Walu(Walu),
        .Wdm(Wdm),
        .Wpc4(Wpc4),
        .Wa(Wa),
        .Wb(Wb),
        .Wcp0(Wcp0),
        .Whi(Whi),
        .Wlo(Wlo),
        .Wrn(Wrn),
        .Ww_rf(Ww_rf),
        .Ww_hi(Ww_hi),
        .Ww_lo(Ww_lo),
        .Whisource(Whisource),
        .Wlosource(Wlosource),
        .Wrfsource(Wrfsource)
    );

    // 10. WB阶段
    PipeWB pipe_wb(
        .muler_hi(Wmuler_hi),
        .muler_lo(Wmuler_lo),
        .r(Wr),
        .q(Wq),
        .counter(Wcounter),
        .alu(Walu),
        .dm(Wdm),
        .pc4(Wpc4),
        .a(Wa),
        .b(Wb),
        .cp0(Wcp0),
        .hi(Whi),
        .lo(Wlo),
        .rn(Wrn),
        .w_rf(Ww_rf),
        .w_hi(Ww_hi),
        .w_lo(Ww_lo),
        .hisource(Whisource),
        .losource(Wlosource),
        .rfsource(Wrfsource),
        .Wdata_hi(Wdata_hi),
        .Wdata_lo(Wdata_lo),
        .Wdata_rf(Wdata_rf),
        .Wrn(Wrn_wb),
        .Ww_rf(Ww_rf_wb),
        .Ww_hi(Ww_hi_wb),
        .Ww_lo(Ww_lo_wb)
    );

    // 写回使能信号
    assign Wena_rf = Ww_rf_wb;
    assign Wena_hi = Ww_hi_wb;
    assign Wena_lo = Ww_lo_wb;
    assign Wrn_to_regfile = Wrn_wb;
    assign Wdata_rf_to_regfile = Wdata_rf;
    assign Wdata_hi_to_regfile = Wdata_hi;
    assign Wdata_lo_to_regfile = Wdata_lo;

endmodule