// IMEM_ip - Instruction Memory IP Module
// Drop-in replacement for Xilinx Block RAM IP or similar memory IP
// Designed to conform to interface used in PipeIF.v module

`timescale 1ns / 1ps

`include "def.v"

module IMEM(
    input [10:0] a,       // Address input (pc[11:2] -> 10-bit address)
    output [31:0] spo    // Instruction output
);
    // imem imem_ip(
    //     .a(address[12:2]),
    //     .spo(instrT)
    // );

    // Internal memory implementation (same as original IMEM)
    reg [31:0] IMEMreg [0:2047];
    assign spo = IMEMreg[a];  // Address directly maps to memory location

    initial begin
        // Original initialization paths commented for reference:
        //$readmemh("E:/Homeworks/cpupip8/testdata/1_addi.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/2_addiu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/9_addu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/11_beq.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/12_bne.hex.txt", IMEMreg);

        // Current active test data
        $readmemh("E:/Homeworks/cpupip8/testdata/16.26_lwsw.hex.txt", IMEMreg);

        //$readmemh("E:/Homeworks/cpupip8/testdata/16.26_lwsw2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/20_sll.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/22_sltu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/25_subu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/101_swlwbnebeq.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/102_regconflict.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/103_regconflict_detected_2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip8/testdata/104_pizza_tower_test.hex.txt", IMEMreg);
    end

endmodule