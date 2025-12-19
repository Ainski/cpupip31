// 8-to-1 Multiplexer
module MUX8_1 (
    input [31:0] d0,d1,d2,d3,d4,d5,d6,d7,  // 32-bit inputs
    input [2:0] sel,                     // 3-bit selector
    output reg [31:0] y                  // 32-bit output
);

always @(*) begin
    case(sel)
        3'b000: y = d0;
        3'b001: y = d1;
        3'b010: y = d2;
        3'b011: y = d3;
        3'b100: y = d4;
        3'b101: y = d5;
        3'b110: y = d6;
        3'b111: y = d7;
    endcase
end

endmodule