// 2-to-1 Multiplexer
module MUX2_1 (
    input [31:0] d0, d1,  // 32-bit inputs
    input sel,         // selector
    output reg [31:0] y  // 32-bit output
);

always @(*) begin
    case(sel)
        1'b0: y = d0;
        1'b1: y = d1;
    endcase
end

endmodule