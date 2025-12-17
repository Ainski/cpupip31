// 8-to-1 Multiplexer
module MUX8_1 (
    input [31:0] A, B, C, D, E, F, G, H,  // 32-bit inputs
    input [2:0] sel,                     // 3-bit selector
    output reg [31:0] Y                  // 32-bit output
);

always @(*) begin
    case(sel)
        3'b000: Y = A;
        3'b001: Y = B;
        3'b010: Y = C;
        3'b011: Y = D;
        3'b100: Y = E;
        3'b101: Y = F;
        3'b110: Y = G;
        3'b111: Y = H;
    endcase
end

endmodule