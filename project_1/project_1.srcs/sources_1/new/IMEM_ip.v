`timescale 1ns / 1ps
// IMEM_ip - Instruction Memory IP Module
// Drop-in replacement for Xilinx Block RAM IP or similar memory IP
// Designed to conform to interface used in PipeIF.v module

`include "def.v"

module IMEM_ip(
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
        $readmemh("E:/Homeworks/cpupip31/testdata/1_addi.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/2_addiu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/3_andi.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/4_ori.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/5_sltiu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/6_lui.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/7_xori.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/8_slti.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/9_addu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/10_and.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/11_beq.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/12_bne.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/13_j.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/14_jal.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/15_jr.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/16.26_lwsw.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/16.26_lwsw2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/17_xor.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/18_nor.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/19_or.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/20_sll.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/21_sllv.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/22_sltu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/23_sra.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/24_srl.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/25_subu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/27_add.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/28_sub.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/29_slt.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/30_srlv.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/31_srav.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/32_clz.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/33_divu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/35_jalr.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/36.39_lbsb.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/36.39_lbsb2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/37_lbu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/37_lbu2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/38_lhu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/38_lhu2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/40.41_lhsh.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/40.41_lhsh2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/42.45_mfc0mtc0.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/43.46_mfhi.mthi.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/44.47_mflo.mtlo.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/48_mult.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/49_multu.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/52_bgez.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/54_div.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/55_cp0.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/101_swlwbnebeq.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/102_regconflict.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/103_regconflict_detected_2.hex.txt", IMEMreg);
        //$readmemh("E:/Homeworks/cpupip31/testdata/104_pizza_tower_test.hex.txt", IMEMreg);
    end

endmodule