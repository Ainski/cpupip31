module PcReg(
    input clk,
    input rstn,
    input wena,
    input [31:0] data_in,
    output reg [31:0] data_out
);

always @(posedge clk or posedge rstn) begin
    if (!rstn)begin
        data_out<=32'h00400000;
    end else begin
        data_out<=data_in;
    end
end
endmodule