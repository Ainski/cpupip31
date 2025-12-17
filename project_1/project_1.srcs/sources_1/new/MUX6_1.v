// 6-to-1 Multiplexer
module MUX6_1 (
    input [31:0] A, B, C, D, E, F,  // 32-bit inputs
    input [2:0] sel,               // 3-bit selector
    output reg [31:0] Y            // 32-bit output
);

always @(*) begin
    case(sel)
        3'b000: Y = A;
        3'b001: Y = B;
        3'b010: Y = C;
        3'b011: Y = D;
        3'b100: Y = E;
        3'b101: Y = F;
        default: Y = A; // For undefined cases
    endcase
end

endmodule