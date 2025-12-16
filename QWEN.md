# CPU 流水线项目（类似MIPS）

## 项目概述
这是一个使用Verilog编写的5级流水线MIPS类似处理器实现。该项目结构为Xilinx Vivado项目（版本2016.2），位于`project_1`目录中。流水线遵循经典的IF（指令获取）、ID（指令译码）、EXE（执行）、MEM（内存访问）和WB（写回）阶段。

### 架构组件
CPU流水线由以下模块组成：
- **PipeIF.v**: 指令获取阶段 - 处理程序计数器（PC）更新和指令获取
- **PipeID.v**: 指令译码阶段 - 译码指令，管理寄存器文件访问和控制信号
- **PipeEXE.v**: 执行阶段 - 执行算术/逻辑运算，乘法，除法
- **PipeMEM.v**: 内存访问阶段 - 处理到数据内存的数据加载/存储操作
- **PipeWB.v**: 写回阶段 - 管理结果写回到寄存器
- **流水线寄存器**:
  - PcReg.v: PC寄存器
  - PipeDEreg.v: 译码/执行流水线寄存器
  - PipeEMreg.v: 执行/内存流水线寄存器
  - PipeMWreg.v: 内存/写回流水线寄存器
  - PipeIR.v: 指令寄存器
- **Reg.v**: 通用32位寄存器模块
- 支持多路复用器、ALU、乘法器、除法器等的模块（已引用但可能以IP格式存在）

### 主要特性
- 32位MIPS类似架构
- 5级流水线以提高吞吐量
- 支持整数算术、逻辑运算
- 加载/存储内存指令
- 乘法和除法单元
- 具有旁路机制的特殊寄存器文件（R0-R31）
- 用于管理流水线冒险和转发的控制单元
- 带有MARK_DEBUG属性的调试功能
- 支持CP0（协处理器0）进行系统控制
- 分支预测和跳转处理

## 构建和运行
由于这是Vivado项目：

### 先决条件
- Xilinx Vivado 2016.2或兼容版本
- Verilog综合和仿真工具

### 设置和编译
1. 打开Vivado
2. 打开项目：`project_1/project_1.xpr`
3. 源文件位于`project_1.srcs/sources_1/new/`
4. 运行综合：Tools → Synthesis → Run Synthesis
5. 运行实现：Tools → Implementation → Run Implementation
6. 生成比特流：Tools → Generate Bitstream

### 仿真
项目可能包括仿真功能：
1. 在仿真源文件中检查测试平台文件
2. 使用Vivado的仿真器验证功能
3. 在综合前运行行为仿真

## 开发约定
- 32位字对齐的内存寻址
- 小端字节序
- 模块命名约定：流水线阶段使用`Pipe<Stage>.v`
- 流水线寄存器模块命名为后缀`_reg`（例如`PipeDEreg.v`）
- 控制信号以前缀区分阶段（例如E表示执行阶段，M表示内存阶段）
- 调试信号标记`MARK_DEBUG="true"`属性以用于ILA集成
- 时钟(`clk`)和复位(`rstn`)信号在所有模块中是标准的
- 所有序列元素均采用同步低电平有效复位(`rstn`)

## 文件结构
```
E:\Homeworks\cpupip31\
├── QWEN.md                 # 此文档文件
└── project_1/              # 主要Vivado项目目录
    ├── project_1.xpr       # Vivado项目文件
    ├── vivado.log          # Vivado会话日志
    ├── vivado.jou          # Vivado日记文件
    ├── project_1.cache/    # Vivado缓存文件
    ├── project_1.hw/       # 硬件配置
    ├── project_1.ip_user_files/  # IP核心文件
    ├── project_1.sim/      # 仿真文件
    └── project_1.srcs/     # 源代码文件
        └── sources_1/
            └── new/        # Verilog源文件（IF、ID、EXE、MEM、WB阶段）
                ├── PipeIF.v
                ├── PipeID.v
                ├── PipeEXE.v
                ├── PipeMEM.v
                ├── PipeWB.v
                ├── PcReg.v
                ├── PipeDEreg.v
                ├── PipeEMreg.v
                ├── PipeMWreg.v
                ├── PipeIR.v
                └── Reg.v
```

## 流水线操作
1. **IF（指令获取）**: 使用程序计数器从IMEM获取指令
2. **ID（指令译码）**: 译码指令，读取寄存器文件，处理转发控制
3. **EXE（执行）**: 执行ALU操作，地址计算，算术运算
4. **MEM（内存访问）**: 从/向DMEM加载/存储数据
5. **WB（写回）**: 将结果写回寄存器文件

流水线包含处理数据冒险的转发机制和管理结构与控制冒险的控制逻辑。