`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/13 15:00:18
// Design Name: 
// Module Name: cp0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CP0(
    input clk,
    input rst,
    input mfc0,
    input mtc0,
    input [31:0] npc,
    input [4:0] rdc,
    input [31:0] wdata,
    input exception,
    input eret,
    input [4:0] cause,
    input intr,
    output [31:0] Erdata,
    output [31:0] status,
    output reg timer_int,
    output [31:0] exc_addr
    );
    parameter  SYSCALL     =   5'b01000,
               BREAK      =   5'b01001,
               TEQ        =   5'b01101;
    reg [31:0] ereg[0:31];
    wire [31:0] epc;
    //assign cause=ereg[13];
    assign epc=ereg[14];
    // assign Erdata = exception && mtc0 ? ereg[rdc] : 32'bz;
    // assign status = exception && mfc0 ? ereg[12] : 32'bz;
    assign Erdata = exception && mfc0 ? ereg[rdc] : 32'bz;
    assign status = ereg[12];
    assign exc_addr = exception && eret ? epc : 32'bz;
    assign real_exc = ereg[12][0] && (!ereg[12][8]&&cause==SYSCALL||!ereg[12][9]&&cause==BREAK||!ereg[12][10]&&cause==TEQ&&intr);
    always @ (posedge clk or posedge rst) begin
        if( rst) begin
            ereg[0]=0;
            ereg[1]=0;
            ereg[2]=0;
            ereg[3]=0;
            ereg[4]=0;
            ereg[5]=0;
            ereg[6]=0;
            ereg[7]=0;
            ereg[8]=0;
            ereg[9]=0;
            ereg[10]=0;
            ereg[11]=0;
            ereg[12]=0;
            ereg[13]=0;
            ereg[14]=0;
            ereg[15]=0;
            ereg[16]=0;
            ereg[17]=0;
            ereg[18]=0;
            ereg[19]=0;
            ereg[20]=0;
            ereg[21]=0;
            ereg[22]=0;
            ereg[23]=0;
            ereg[24]=0;
            ereg[25]=0;
            ereg[26]=0;
            ereg[27]=0;
            ereg[28]=0;
            ereg[29]=0;
            ereg[30]=0;
            ereg[31]=0;
        end else begin
            if( mtc0) begin
                ereg[rdc] = wdata;
            end
            else if(real_exc) begin
                ereg[13] = {25'b0,cause,2'b0};
                ereg[12] = ereg[12]<<5;
                ereg[14] = npc;
            end
            else if (eret) begin
                ereg[12] = ereg[12]>>5;
            end 
        end
    end
endmodule
