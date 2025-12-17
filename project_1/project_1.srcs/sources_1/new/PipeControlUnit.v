`timescale 1ns / 1ps
`include "def.v"

// ============================================================
// 基于Tomasulo算法的动态流水线控制单元模块
// 功能：根据指令生成各种控制信号，控制CPU流水线各阶段的操作
// ============================================================
module PipeControlUnit(
    // 输入端口
    input [4:0] rsc,              // 源寄存器Rs编号 [25:21]
    input [4:0] rtc,              // 源寄存器Rt编号 [20:16]
    input [4:0] rdc,              // 目标寄存器Rd编号 [15:11]
    input [5:0] func,             // 指令功能码 [5:0]
    input [5:0] op,               // 指令操作码 [31:26]
    input [4:0] mf,               // CP0寄存器字段 [25:21]
    input isBranch,               // 分支指令标志
    input EisGoto,                // EX阶段跳转指令标志
    input [4:0] Ern,              // EX阶段目标寄存器编号
    input [4:0] Mrn,              // MEM阶段目标寄存器编号
    input Ew_rf,                  // EX阶段写寄存器堆标志
    input Mw_rf,                  // MEM阶段写寄存器堆标志
    input Ew_hi,                  // EX阶段写HI寄存器标志
    input Ew_lo,                  // EX阶段写LO寄存器标志
    input [2:0] Erfsource,        // EX阶段寄存器堆源选择
    input [2:0] Mrfsource,        // MEM阶段寄存器堆源选择
    input [1:0] Ehisource,        // EX阶段HI源选择
    input [1:0] Elosource,        // EX阶段LO源选择
    
    // 输出端口
    output reg [1:0] fwhi,        // HI寄存器数据前递选择 [1:0]
    output reg [1:0] fwlo,        // LO寄存器数据前递选择 [1:0]
    output reg [2:0] fwda,        // A操作数数据前递选择 [2:0]
    output reg [2:0] fwdb,        // B操作数数据前递选择 [2:0]
    output reg [4:0] rn,          // 目标寄存器编号 [4:0]
    output reg sign,              // 符号扩展标志 [0]
    output reg div,               // 除法操作标志 [0]
    output reg mfc0,              // 从CP0读取标志 [0]
    output reg mtc0,              // 写入CP0标志 [0]
    output reg sys,               // 系统调用标志 [0]
    output reg eret,              // 异常返回标志 [0]
    output reg bre,               // 系统调用错误标志 [0]
    output reg teq,               // 相等测试标志 [0]
    output reg beq,               // 相等分支标志 [0]
    output reg bne,               // 不等分支标志 [0]
    output reg bgez,              // 大于等于零分支标志 [0]
    output [3:0] aluc,            // ALU操作码 [3:0]
    output reg wcau,              // 写入CAUSE寄存器标志 [0]
    output reg wsta,              // 写入STATUS寄存器标志 [0]
    output reg wepc,              // 写入EPC寄存器标志 [0]
    output reg wotr,              // 写入其他寄存器标志 [0]
    output reg w_hi,              // 写HI寄存器标志 [0]
    output reg w_lo,              // 写LO寄存器标志 [0]
    output reg w_rf,              // 写寄存器堆标志 [0]
    output reg w_dm,              // 写数据存储器标志 [0]
    output [2:0] ex_cause,        // 异常原因编码 [2:0]
    output reg asource,           // A源选择标志 [0]
    output reg bsource,           // B源选择标志 [0]
    output reg [1:0] cuttersource,// 数据切割源选择 [1:0]
    output reg [1:0] hisource,    // HI寄存器源选择 [1:0]
    output reg [1:0] losource,    // LO寄存器源选择 [1:0]
    output [2:0] rfsource,        // 寄存器堆源选择 [2:0]
    output reg [1:0] pcsource,    // PC源选择 [1:0]
    output reg [1:0] SC,          // 存储器命令信号 [1:0]
    output reg [2:0] LC,          // 加载命令信号 [2:0]
    output reg stall,             // 流水线暂停信号 [0]
    output reg isGoto             // 跳转指令标志 [0]
);

    // ============================================================
    // Tomasulo算法相关参数
    // ============================================================
    parameter NUM_RESERVATION_STATIONS = 6;  // 保留站数量
    parameter NUM_FUNCTION_UNITS = 4;        // 功能单元数量
    parameter NUM_CDB_BUSES = 2;             // 公共数据总线数量
    
    // ============================================================
    // 内部寄存器定义
    // ============================================================
    
    // 保留站状态定义
    reg [31:0] reservation_stations [0:NUM_RESERVATION_STATIONS-1];
    reg [2:0] station_type [0:NUM_RESERVATION_STATIONS-1];   // 保留站类型
    reg [4:0] station_dest [0:NUM_RESERVATION_STATIONS-1];   // 目标寄存器
    reg [3:0] station_opcode [0:NUM_RESERVATION_STATIONS-1]; // 操作码
    reg station_busy [0:NUM_RESERVATION_STATIONS-1];         // 忙碌标志
    reg [1:0] station_qj [0:NUM_RESERVATION_STATIONS-1];     // 源1状态
    reg [1:0] station_qk [0:NUM_RESERVATION_STATIONS-1];     // 源2状态
    reg [31:0] station_vj [0:NUM_RESERVATION_STATIONS-1];    // 源1值
    reg [31:0] station_vk [0:NUM_RESERVATION_STATIONS-1];    // 源2值
    
    // 寄存器状态表 - 跟踪每个寄存器的生产者
    reg [2:0] reg_status [0:31];  // 每个寄存器的状态: 0:空闲, >0:保留站编号
    
    // HI/LO寄存器状态
    reg [2:0] hi_status;          // HI寄存器状态
    reg [2:0] lo_status;          // LO寄存器状态
    
    // 公共数据总线(CDB)信号
    reg [31:0] cdb_value [0:NUM_CDB_BUSES-1];
    reg [4:0] cdb_reg [0:NUM_CDB_BUSES-1];
    reg [2:0] cdb_rs_id [0:NUM_CDB_BUSES-1];  // 来源保留站ID
    reg cdb_valid [0:NUM_CDB_BUSES-1];
    
    // 功能单元状态
    reg [2:0] fu_busy [0:NUM_FUNCTION_UNITS-1];
    reg [4:0] fu_dest [0:NUM_FUNCTION_UNITS-1];
    reg [2:0] fu_rs_id [0:NUM_FUNCTION_UNITS-1];  // 关联的保留站ID
    
    // 内部控制信号
    reg [3:0] aluc_reg;
    reg [2:0] rfsource_reg;
    reg [2:0] ex_cause_reg;
    
    // 指令译码辅助信号
    reg isRType, isIType, isJType, isLoad, isStore, isBranchType;
    reg isMultDiv, isMFHI, isMFLO, isMTHI, isMTLO;
    reg isJump, isJR, isJAL, isJALR, isSpecialInstr;
    reg isShift, isShiftV, isALUOp, isMemOp;
    
    // ============================================================
    // Tomasulo算法辅助函数
    // ============================================================
    
    // 分配保留站
    function automatic integer allocate_reservation_station(input [2:0] type_req);
        integer i;
        begin
            allocate_reservation_station = -1;  // 默认返回无效
            for (i = 0; i < NUM_RESERVATION_STATIONS; i = i + 1) begin
                if (!station_busy[i] && station_type[i] == `RS_TYPE_IDLE) begin
                    allocate_reservation_station = i;
                    break;
                end
            end
        end
    endfunction
    
    // 释放保留站
    function automatic void free_reservation_station(input integer rs_id);
        begin
            if (rs_id >= 0 && rs_id < NUM_RESERVATION_STATIONS) begin
                station_busy[rs_id] = `STALL_DISABLE;
                station_type[rs_id] = `RS_TYPE_IDLE;
                station_dest[rs_id] = 5'b00000;
                station_opcode[rs_id] = `DEFAULT_ALUC;
            end
        end
    endfunction
    
    // 检查冒险
    function automatic reg check_hazards(
        input [4:0] rs, 
        input [4:0] rt, 
        input [4:0] rd, 
        input [5:0] opcode, 
        input [5:0] funcode
    );
        reg hazard;
        integer rs_status, rt_status, rd_status;
        begin
            hazard = `STALL_DISABLE;
            
            // 1. 检查RAW冒险（读后写）
            if (rs != 5'b0) begin
                rs_status = reg_status[rs];
                if (rs_status != 3'b0 && station_busy[rs_status-1]) begin
                    // 如果源寄存器被占用且保留站忙碌，需要等待
                    hazard = `STALL_ENABLE;
                end
            end
            
            if (rt != 5'b0) begin
                rt_status = reg_status[rt];
                if (rt_status != 3'b0 && station_busy[rt_status-1]) begin
                    hazard = `STALL_ENABLE;
                end
            end
            
            // 2. 检查结构冒险（保留站满）
            if (count_busy_stations() >= NUM_RESERVATION_STATIONS) begin
                hazard = `STALL_ENABLE;
            end
            
            // 3. 检查功能单元忙（乘除指令）
            if (is_mult_div_operation(opcode, funcode)) begin
                if (count_busy_function_units() >= NUM_FUNCTION_UNITS) begin
                    hazard = `STALL_ENABLE;
                end
            end
            
            // 4. 检查WAW冒险（写后写）- 对于Tomasulo算法通常不是问题
            // 因为保留站可以处理乱序完成
            
            check_hazards = hazard;
        end
    endfunction
    
    // 判断是否为乘除操作
    function automatic reg is_mult_div_operation(
        input [5:0] opcode,
        input [5:0] funcode
    );
        reg result;
        begin
            result = 1'b0;
            if (opcode == `OP_R_TYPE) begin
                case (funcode)
                    `FUNC_MULT, `FUNC_MULTU, `FUNC_DIV, `FUNC_DIVU: 
                        result = 1'b1;
                    default: 
                        result = 1'b0;
                endcase
            end
            is_mult_div_operation = result;
        end
    endfunction
    
    // 统计忙碌的保留站数量
    function automatic integer count_busy_stations();
        integer i, count;
        begin
            count = 0;
            for (i = 0; i < NUM_RESERVATION_STATIONS; i = i + 1) begin
                if (station_busy[i]) count = count + 1;
            end
            count_busy_stations = count;
        end
    endfunction
    
    // 统计忙碌的功能单元数量
    function automatic integer count_busy_function_units();
        integer i, count;
        begin
            count = 0;
            for (i = 0; i < NUM_FUNCTION_UNITS; i = i + 1) begin
                if (fu_busy[i] != `FU_IDLE) count = count + 1;
            end
            count_busy_function_units = count;
        end
    endfunction
    
    // 检查CDB是否有数据可用
    function automatic reg check_cdb_ready(
        input [4:0] reg_num,
        output reg [31:0] value
    );
        integer i;
        reg found;
        begin
            found = 1'b0;
            value = 32'b0;
            
            for (i = 0; i < NUM_CDB_BUSES; i = i + 1) begin
                if (cdb_valid[i] && cdb_reg[i] == reg_num) begin
                    value = cdb_value[i];
                    found = 1'b1;
                    break;
                end
            end
            
            check_cdb_ready = found;
        end
    endfunction
    
    // ============================================================
    // 控制信号生成主逻辑
    // ============================================================
    always @(*) begin
        // ------------------------------------------------
        // 1. 默认值设置
        // ------------------------------------------------
        sign = 1'b0;
        div = 1'b0;
        mfc0 = 1'b0;
        mtc0 = 1'b0;
        sys = 1'b0;
        eret = 1'b0;
        bre = 1'b0;
        teq = 1'b0;
        beq = 1'b0;
        bne = 1'b0;
        bgez = 1'b0;
        wcau = 1'b0;
        wsta = 1'b0;
        wepc = 1'b0;
        wotr = 1'b0;
        w_hi = 1'b0;
        w_lo = 1'b0;
        w_rf = 1'b0;
        w_dm = 1'b0;
        asource = `OP_SRC_REG;
        bsource = `OP_SRC_REG;
        cuttersource = `CUTTER_SRC_NONE;
        hisource = `HILO_SRC_NONE;
        losource = `HILO_SRC_NONE;
        pcsource = `PC_SRC_SEQ;
        SC = `MEM_STORE_WORD;
        LC = `MEM_LOAD_WORD;
        stall = `STALL_DISABLE;
        isGoto = `GOTO_DISABLE;
        fwhi = `FWD_HILO_NONE;
        fwlo = `FWD_HILO_NONE;
        fwda = `FWD_SRC_NONE;
        fwdb = `FWD_SRC_NONE;
        aluc_reg = `DEFAULT_ALUC;
        rfsource_reg = `DEFAULT_RF_SRC;
        
        // ------------------------------------------------
        // 2. 指令类型判断
        // ------------------------------------------------
        isRType = (op == `OP_R_TYPE);
        isIType = (op != `OP_R_TYPE) && (op != `OP_J) && (op != `OP_JAL) && 
                  (op != `OP_BGEZ) && (op != `OP_COPROC0);
        isJType = (op == `OP_J) || (op == `OP_JAL);
        isBranchType = (op == `OP_BEQ) || (op == `OP_BNE) || (op == `OP_BGEZ);
        isLoad = (op == `OP_LW) || (op == `OP_LH) || (op == `OP_LB) ||
                 (op == `OP_LHU) || (op == `OP_LBU);
        isStore = (op == `OP_SW) || (op == `OP_SH) || (op == `OP_SB);
        isSpecialInstr = (op == `OP_R_TYPE) && 
                        ((func == `FUNC_SYSCALL) || (func == `FUNC_BREAK) || 
                         (func == `FUNC_TEQ) || (func == `FUNC_ERET));
        
        // 具体指令类型判断
        isMultDiv = isRType && ((func == `FUNC_MULT) || (func == `FUNC_MULTU) ||
                                (func == `FUNC_DIV) || (func == `FUNC_DIVU));
        isMFHI = isRType && (func == `FUNC_MFHI);
        isMFLO = isRType && (func == `FUNC_MFLO);
        isMTHI = isRType && (func == `FUNC_MTHI);
        isMTLO = isRType && (func == `FUNC_MTLO);
        isJR = isRType && (func == `FUNC_JR);
        isJALR = isRType && (func == `FUNC_JALR);
        isJAL = (op == `OP_JAL);
        isJump = isJType;
        isShift = isRType && ((func == `FUNC_SLL) || (func == `FUNC_SRL) || 
                              (func == `FUNC_SRA));
        isShiftV = isRType && ((func == `FUNC_SLLV) || (func == `FUNC_SRLV) || 
                               (func == `FUNC_SRAV));
        isALUOp = isRType || isIType;
        isMemOp = isLoad || isStore;
        
        // ------------------------------------------------
        // 3. 目标寄存器选择
        // ------------------------------------------------
        if (isRType) begin
            if (func == `FUNC_JR || func == `FUNC_MTHI || func == `FUNC_MTLO || 
                isMultDiv) begin
                rn = 5'b0;  // 这些指令不写通用寄存器
            end else if (func == `FUNC_JALR) begin
                rn = 5'd31;  // JALR写$ra寄存器
            end else begin
                rn = rdc;    // 标准R型指令写rd
            end
        end else if (isLoad) begin
            rn = rtc;        // 加载指令写rt
        end else if (isIType || op == `OP_JAL || op == `OP_CLZ) begin
            rn = rtc;        // I型指令、JAL、CLZ写rt
        end else if (op == `OP_COPROC0 && mf == `RS_MFC0) begin
            rn = rtc;        // mfc0写rt
        end else begin
            rn = 5'b0;       // 其他指令不写寄存器
        end
        
        // ------------------------------------------------
        // 4. ALU控制信号生成
        // ------------------------------------------------
        if (isRType) begin
            case (func)
                `FUNC_ADD:   aluc_reg = `ALUC_ADD;
                `FUNC_ADDU:  aluc_reg = `ALUC_ADDU;
                `FUNC_SUB:   aluc_reg = `ALUC_SUB;
                `FUNC_SUBU:  aluc_reg = `ALUC_SUBU;
                `FUNC_AND:   aluc_reg = `ALUC_AND;
                `FUNC_OR:    aluc_reg = `ALUC_OR;
                `FUNC_XOR:   aluc_reg = `ALUC_XOR;
                `FUNC_NOR:   aluc_reg = `ALUC_NOR;
                `FUNC_SLT:   aluc_reg = `ALUC_SLT;
                `FUNC_SLTU:  aluc_reg = `ALUC_SLTU;
                `FUNC_SLL:   aluc_reg = `ALUC_SLL;
                `FUNC_SRL:   aluc_reg = `ALUC_SRL;
                `FUNC_SRA:   aluc_reg = `ALUC_SRA;
                `FUNC_SLLV:  aluc_reg = `ALUC_SLL;
                `FUNC_SRLV:  aluc_reg = `ALUC_SRL;
                `FUNC_SRAV:  aluc_reg = `ALUC_SRA;
                `FUNC_CLZ:   aluc_reg = `ALUC_CLZ;
                default:     aluc_reg = `DEFAULT_ALUC;
            endcase
        end else begin
            case (op)
                `OP_ADDI:   aluc_reg = `ALUC_ADD;
                `OP_ADDIU:  aluc_reg = `ALUC_ADDU;
                `OP_SLTI:   aluc_reg = `ALUC_SLT;
                `OP_SLTIU:  aluc_reg = `ALUC_SLTU;
                `OP_ANDI:   aluc_reg = `ALUC_AND;
                `OP_ORI:    aluc_reg = `ALUC_OR;
                `OP_XORI:   aluc_reg = `ALUC_XOR;
                `OP_LUI:    aluc_reg = `ALUC_LUI;
                `OP_CLZ:    aluc_reg = `ALUC_CLZ;
                `OP_BEQ, `OP_BNE: aluc_reg = `ALUC_SUB;
                `OP_BGEZ:   aluc_reg = `ALUC_BGEZ;
                default:    aluc_reg = `DEFAULT_ALUC;
            endcase
        end
        
        // ------------------------------------------------
        // 5. 寄存器堆写入源选择
        // ------------------------------------------------
        if (isLoad) begin
            rfsource_reg = `RF_SRC_MEM;      // 来自内存
        end else if (op == `OP_JAL || isJALR) begin
            rfsource_reg = `RF_SRC_PC_PLUS4; // 来自PC+4
        end else if (isMFHI || isMFLO) begin
            rfsource_reg = `RF_SRC_HILO;     // 来自HI/LO
        end else if (mfc0) begin
            rfsource_reg = `RF_SRC_CP0;      // 来自CP0
        end else if (isALUOp) begin
            rfsource_reg = `RF_SRC_ALU;      // 来自ALU
        end else begin
            rfsource_reg = `DEFAULT_RF_SRC;
        end
        
        // ------------------------------------------------
        // 6. 异常原因编码
        // ------------------------------------------------
        ex_cause_reg = 3'b000;
        if (isRType) begin
            case (func)
                `FUNC_SYSCALL: ex_cause_reg = `CAUSE_SYSCALL;
                `FUNC_BREAK:   ex_cause_reg = `CAUSE_BREAK;
                `FUNC_TEQ:     ex_cause_reg = `CAUSE_TEQ;
                default:       ex_cause_reg = 3'b000;
            endcase
        end
        
        // ------------------------------------------------
        // 7. 符号扩展控制
        // ------------------------------------------------
        sign = (op == `OP_ADDI || op == `OP_SLTI || op == `OP_SLTIU || 
                op == `OP_LB || op == `OP_LH || op == `OP_LW);
        
        // ------------------------------------------------
        // 8. 除法操作标志
        // ------------------------------------------------
        div = isRType && (func == `FUNC_DIV || func == `FUNC_DIVU);
        
        // ------------------------------------------------
        // 9. CP0操作控制
        // ------------------------------------------------
        mfc0 = (op == `OP_COPROC0) && (mf == `RS_MFC0);
        mtc0 = (op == `OP_COPROC0) && (mf == `RS_MTC0);
        eret = (op == `OP_COPROC0) && (mf == `RS_ERET) && (func == `FUNC_ERET);
        
        // ------------------------------------------------
        // 10. 特殊指令控制
        // ------------------------------------------------
        sys = isRType && (func == `FUNC_SYSCALL);
        teq = isRType && (func == `FUNC_TEQ);
        bre = isRType && (func == `FUNC_BREAK);
        
        // ------------------------------------------------
        // 11. 分支指令控制
        // ------------------------------------------------
        beq = (op == `OP_BEQ);
        bne = (op == `OP_BNE);
        bgez = (op == `OP_BGEZ) && (rtc == `RT_BGEZ);
        
        // ------------------------------------------------
        // 12. 寄存器写入控制
        // ------------------------------------------------
        w_hi = isRType && (func == `FUNC_MULT || func == `FUNC_MULTU || 
                          func == `FUNC_DIV || func == `FUNC_DIVU || 
                          func == `FUNC_MTHI);
        w_lo = isRType && (func == `FUNC_MULT || func == `FUNC_MULTU || 
                          func == `FUNC_DIV || func == `FUNC_DIVU || 
                          func == `FUNC_MTLO);
        w_rf = (isRType && !isJR && !isSpecialInstr && !isMTHI && !isMTLO && !isMultDiv) ||
               isIType || isLoad || (op == `OP_JAL) || isJALR || mfc0 || (op == `OP_CLZ);
        w_dm = isStore;
        
        // CP0写控制
        wcau = (ex_cause_reg != 3'b000);  // 有异常时写CAUSE
        wsta = (sys || bre || teq || eret);  // 特殊指令写STATUS
        wepc = (sys || bre || teq);  // 异常时写EPC
        wotr = mtc0;  // mtc0写其他CP0寄存器
        
        // ------------------------------------------------
        // 13. 操作数源选择
        // ------------------------------------------------
        asource = isRType ? `OP_SRC_REG : `OP_SRC_IMM;  // R型:寄存器, I型:立即数
        bsource = (isRType && isShift && !isShiftV) ? `OP_SRC_IMM : `OP_SRC_REG;
        
        // ------------------------------------------------
        // 14. HI/LO寄存器源选择
        // ------------------------------------------------
        if (func == `FUNC_MULT || func == `FUNC_MULTU) begin
            hisource = `HILO_SRC_MULT;
            losource = `HILO_SRC_MULT;
        end else if (func == `FUNC_DIV || func == `FUNC_DIVU) begin
            hisource = `HILO_SRC_DIV;
            losource = `HILO_SRC_DIV;
        end else if (func == `FUNC_MTHI || func == `FUNC_MTLO) begin
            hisource = `HILO_SRC_MOVE;
            losource = `HILO_SRC_MOVE;
        end else begin
            hisource = `HILO_SRC_NONE;
            losource = `HILO_SRC_NONE;
        end
        
        // ------------------------------------------------
        // 15. 存储器访问控制
        // ------------------------------------------------
        case (op)
            `OP_SB: SC = `MEM_STORE_BYTE;
            `OP_SH: SC = `MEM_STORE_HALF;
            `OP_SW: SC = `MEM_STORE_WORD;
            default: SC = `MEM_STORE_WORD;
        endcase
        
        case (op)
            `OP_LW:  LC = `MEM_LOAD_WORD;
            `OP_LH:  LC = `MEM_LOAD_HALF_S;
            `OP_LB:  LC = `MEM_LOAD_BYTE;
            `OP_LHU: LC = `MEM_LOAD_HALF_U;
            `OP_LBU: LC = `MEM_LOAD_BYTE_U;
            default: LC = `MEM_LOAD_WORD;
        endcase
        
        // 数据切割控制
        if (isLoad) begin
            case (op)
                `OP_LH, `OP_LHU: cuttersource = `CUTTER_SRC_HALF;
                `OP_LB, `OP_LBU: cuttersource = `CUTTER_SRC_BYTE;
                default: cuttersource = `CUTTER_SRC_NONE;
            endcase
        end else begin
            cuttersource = `CUTTER_SRC_NONE;
        end
        
        // ------------------------------------------------
        // 16. Tomasulo算法: 冒险检测和保留站分配
        // ------------------------------------------------
        stall = check_hazards(rsc, rtc, rn, op, func);
        
        // 如果没有停顿，尝试分配保留站
        if (!stall) begin
            integer rs_id;
            reg [2:0] rs_type;
            
            // 确定保留站类型
            if (isMultDiv) begin
                rs_type = `RS_TYPE_MULDIV;
            end else if (isMemOp) begin
                rs_type = `RS_TYPE_MEM;
            end else if (isBranchType || isJump || isJR || isJALR) begin
                rs_type = `RS_TYPE_BRANCH;
            end else begin
                rs_type = `RS_TYPE_ALU;
            end
            
            // 分配保留站
            rs_id = allocate_reservation_station(rs_type);
            if (rs_id == -1) begin
                stall = `STALL_ENABLE;  // 没有可用保留站，停顿
            end else begin
                // 配置保留站
                station_opcode[rs_id] = aluc_reg;
                station_dest[rs_id] = rn;
                
                // 设置操作数状态
                if (rsc != 5'b0 && reg_status[rsc] != 3'b0) begin
                    station_qj[rs_id] = `RS_OP_WAIT;
                end else begin
                    station_qj[rs_id] = `RS_OP_READY;
                end
                
                if (rtc != 5'b0 && reg_status[rtc] != 3'b0) begin
                    station_qk[rs_id] = `RS_OP_WAIT;
                end else begin
                    station_qk[rs_id] = `RS_OP_READY;
                end
            end
        end
        
        // ------------------------------------------------
        // 17. 数据前递控制 (Tomasulo算法)
        // ------------------------------------------------
        fwda = `FWD_SRC_NONE;
        fwdb = `FWD_SRC_NONE;
        fwhi = `FWD_HILO_NONE;
        fwlo = `FWD_HILO_NONE;
        
        // 检查源寄存器Rs的数据相关
        if (rsc != 5'b0) begin
            if (reg_status[rsc] != 3'b0 && station_busy[reg_status[rsc]-1]) begin
                // 检查CDB是否有数据可用
                reg [31:0] cdb_val;
                if (check_cdb_ready(rsc, cdb_val)) begin
                    fwda = `FWD_SRC_EX_ALU;  // 从CDB获取数据
                end else begin
                    fwda = `FWD_SRC_NONE;    // 等待数据就绪
                end
            end
        end
        
        // 检查源寄存器Rt的数据相关
        if (rtc != 5'b0) begin
            if (reg_status[rtc] != 3'b0 && station_busy[reg_status[rtc]-1]) begin
                reg [31:0] cdb_val;
                if (check_cdb_ready(rtc, cdb_val)) begin
                    fwdb = `FWD_SRC_EX_ALU;  // 从CDB获取数据
                end else begin
                    fwdb = `FWD_SRC_NONE;    // 等待数据就绪
                end
            end
        end
        
        // HI/LO寄存器前递
        if (Ew_hi) fwhi = `FWD_HILO_EX;
        if (Ew_lo) fwlo = `FWD_HILO_EX;
        
        // 对于乘除指令，前递来自EX阶段的结果
        if (isMultDiv) begin
            fwda = `FWD_SRC_EX_MULT;
            fwdb = `FWD_SRC_EX_MULT;
        end
        
        // ------------------------------------------------
        // 18. 跳转和分支控制
        // ------------------------------------------------
        isGoto = isJump || isJR || isJALR || isBranchType || eret;
        
        case (1'b1)
            (isJump || isJALR): pcsource = `PC_SRC_JUMP;
            isBranchType:       pcsource = `PC_SRC_BRANCH;
            isJR:               pcsource = `PC_SRC_REG;
            eret:               pcsource = `PC_SRC_EXCEPTION;
            default:            pcsource = `PC_SRC_SEQ;
        endcase
    end
    
    // ============================================================
    // 寄存器状态更新逻辑
    // ============================================================
    always @(*) begin
        // 当CDB有效时，更新寄存器状态
        integer i;
        for (i = 0; i < NUM_CDB_BUSES; i = i + 1) begin
            if (cdb_valid[i]) begin
                if (reg_status[cdb_reg[i]] == cdb_rs_id[i] + 1) begin
                    reg_status[cdb_reg[i]] = 3'b0;  // 寄存器变为空闲
                end
            end
        end
        
        // 当指令发射到保留站时，更新目标寄存器状态
        if (w_rf && rn != 5'b0) begin
            // 查找分配的保留站
            integer station_id = -1;
            for (integer j = 0; j < NUM_RESERVATION_STATIONS; j = j + 1) begin
                if (station_dest[j] == rn && station_busy[j]) begin
                    station_id = j;
                    break;
                end
            end
            
            if (station_id != -1) begin
                reg_status[rn] = station_id + 1;  // 保留站编号+1（0表示空闲）
            end
        end
    end
    
    // ============================================================
    // 输出连接
    // ============================================================
    assign aluc = aluc_reg;
    assign rfsource = rfsource_reg;
    assign ex_cause = ex_cause_reg;
    
    // ============================================================
    // 初始化
    // ============================================================
    initial begin
        integer i;
        for (i = 0; i < NUM_RESERVATION_STATIONS; i = i + 1) begin
            station_busy[i] = 1'b0;
            station_type[i] = `RS_TYPE_IDLE;
            station_dest[i] = 5'b00000;
            station_opcode[i] = `DEFAULT_ALUC;
            station_qj[i] = `RS_OP_READY;
            station_qk[i] = `RS_OP_READY;
            station_vj[i] = 32'b0;
            station_vk[i] = 32'b0;
        end
        
        for (i = 0; i < 32; i = i + 1) begin
            reg_status[i] = 3'b000;
        end
        
        hi_status = 3'b000;
        lo_status = 3'b000;
        
        for (i = 0; i < NUM_FUNCTION_UNITS; i = i + 1) begin
            fu_busy[i] = `FU_IDLE;
            fu_dest[i] = 5'b00000;
            fu_rs_id[i] = 3'b000;
        end
        
        for (i = 0; i < NUM_CDB_BUSES; i = i + 1) begin
            cdb_valid[i] = 1'b0;
            cdb_reg[i] = 5'b00000;
            cdb_value[i] = 32'b0;
            cdb_rs_id[i] = 3'b000;
        end
    end
    
endmodule