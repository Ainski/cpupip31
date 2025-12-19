// 4-to-1 Multiplexer
module MUX4_1 (
    input [31:0] d0,d1,d2,d3,  // 32-bit inputs
    input [1:0] sel,         // 2-bit selector
    output reg [31:0] y      // 32-bit output
);

always @(*) begin
    case(sel) 
        2'b00: y = d0;
        2'b01: y = d1;
        2'b10: y = d2;
        2'b11: y = d3;
    endcase
end

endmodule
