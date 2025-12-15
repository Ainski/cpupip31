module PipeID(
    input clk,rstn,
    input [31:0] pc4,inst,
    input [31:0] Ealu,Malu,Mdm,Ehi,Elo,Epc0,Emuler_hi,Emuler_lo,Er,Eq,Ecounter,
    input [4:0] Ern,Mrn,
    input Ew_rf,Mw_rf,Ew_hi,Ew_lo,
    input [2:0]Erfsource,Mrfsource,
    input [1:0] Ehisource,Elosourse,
    input [31:0] Wdata_rf,Wdata_hi,Wdata_lo,
    input [4:0] Wrn,
    input Wena_rf,Wena_hi,Wena_lo,
    input EisGoto,
    output [31:0] cpc,rpc,bpc,jpc,Rsout,Rtout,imm,Dpc4,CP0out,Hiout,Loout,
    output [4:0] rn,
    output sign,div,
    output [3:0] aluc,
    output w_hi,w_lo,w_rf,w_dm,
    output asource,bsource,
    output [1:0] cuttersource,hisource,losource,
    output [2:0] rfsource,pcsource,
    output stall,isGoto,
    output [31:0] reg28 //???
);

( * MARK_DEBUG="true" * ) wire[5:0]op,func;
( * MARK_DEBUG="true" * ) wire [4:0] rsc,rtc,rdc,mf;
( * MARK_DEBUG="true" * ) wire [15:0] ext16;
( * MARK_DEBUG="true" * ) wire [1:0] fwda,fwdb;
( * MARK_DEBUG="true" * ) wire sign_ext;
( * MARK_DEBUG="true" * ) wire mfc0,mtc0,eret,teq,bre,sys,beq,bne,bgez;
( * MARK_DEBUG="true" * ) wire isBranch;
( * MARK_DEBUG="true" * ) wire [31:0] aout,bout,cp0, hi, lo;
( * MARK_DEBUG="true" * ) wire [1:0] fwhi,fwlo;
( * MARK_DEBUG="true" * ) wire [2:0] fwda,dwdb;
( * MARK_DEBUG="true" * ) wire [4:0] ex_cause;

assign func = inst[5:0] ;
assign op = inst [31:26];
assign mf = inst [25:21] ;
assign rsc = inst [25:21] ;
assign rtc = inst [20:16] ;
assign rdc = inst [15:11] ;
assign ext16 = inst [15:0] ;
assign jpc = {pc4[31:28],inst[25:0],2'b00};


wire[31:0] ext_18;
assign ext_18 = {14'b0,ext16,2'b00};
assign bpc = pc4+ext_18;

assign rpc=Rsout;
assign cpc=CP0out;
assign Dpc4=pc4;
assign imm=sign_ext? {{16{ext16[15]}}, ext16} : {16'b0,ext16};


Regfile regfile(clk,rstn,Wena_rf,rsc,rtc,Wrn,Wdata_rf,aout,bout,reg28);
MUX8_1 alu_aout(Ecounter,Ehi,Elo,Emuler_lo,Mdm,Malu,Ealu,aout,fwda,Rsout);
MUX8_1 alu_bout(Ecounter,Ehi,Elo,Emuler_lo,Mdm,Malu,Ealu,bout,fwdb,Rtout);

CP0 cp0reg(
    clk,rstn,
    mfc0,mtc0,eret,teq,bre,sys,
    wcau,wsta,wepc,woth,
    rsc,ex_cause,
    Rtout,
    CP0out
);

Reg hireg(clk,rstn,Wena_hi,Wdata_hi,hi);
MUX4_1 hiout(Er,Emuler_hi,Ehi,hi,fwhi,Hiout);
Reg loreg(clk,rstn,Wena_lo,Wdata_lo,lo);
MUX4_1 loout (Eq,Emuler_lo,Elo,lo,fwlo,Loout);

Compare_ID compare(Rsout,Rtout,beq,bne,bgez,teq,isBranch);

PipeControlUnit CU(
    rsc,rtc,rdc,func,op,mf,isBranch,
    EisGoto,
    Ern,Mrn,
    Ew_rf,Mw_rf, Er_hi, Ew_lo ,
    Erfsource, Mrfsource, Ehisource,Elosourse,
    fwhi,fwlo,fwda,fwdb,
    rn,sign,div,mfc0,mfc0,mtc0,sys,eret,bre,teq,beq,bne,bgez,aluc,
    wcau,wsta,wepc,wotr,w_hi,w_lo,w_rf,w_dm,
    ex_cause,
    asource,bsource,cuttersource,hisource,losource,rfsource,pcsource,
    stall,isGoto
);

        
endmodule
