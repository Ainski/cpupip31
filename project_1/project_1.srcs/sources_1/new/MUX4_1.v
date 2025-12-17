// 4-to-1 Multiplexer
module MUX4_1 (
    input [31:0] A, B, C, D,  // 32-bit inputs
    input [1:0] sel,         // 2-bit selector
    output reg [31:0] Y      // 32-bit output
);

always @(*) begin
    case(sel)
        2'b00: Y = A;
        2'b01: Y = B;
        2'b10: Y = C;
        2'b11: Y = D;
    endcase
end

endmodule