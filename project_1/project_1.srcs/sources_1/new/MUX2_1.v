// 2-to-1 Multiplexer
module MUX2_1 (
    input [31:0] A, B,  // 32-bit inputs
    input sel,         // selector
    output reg [31:0] Y  // 32-bit output
);

always @(*) begin
    case(sel)
        1'b0: Y = A;
        1'b1: Y = B;
    endcase
end

endmodule