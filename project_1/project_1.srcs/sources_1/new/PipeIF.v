module PipeIF (
    input [31:0] pc,cpc,bpc,rpc,jpc,
    input [2:0] pcsource,
    output [31:0] npc,pc4,instruction
);
    assign pc4 = pc+32'h4;
    MUXt_1 next_pc(32'h4,cpc,rpc,bpc,jpc,pc4,pcsource,npc);
    IMEM_ip imem(pc[11:2],instruction);
endmodule