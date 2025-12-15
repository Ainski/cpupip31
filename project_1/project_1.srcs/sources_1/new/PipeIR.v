module PipeIR (
    input clk,rstn,
    input [31:0] pc4,instruction,
    input nostall,
    output [31:0] Dpc4,Dinstruction
);
Reg dpc4(clk,rstn,nostall,pc4,Dpc4);
Reg ir(clk,rstn,nostall,instruction);
    
endmodule