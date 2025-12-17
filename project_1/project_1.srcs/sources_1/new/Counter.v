`timescale 1ns / 1ps

module Counter(
    input  [31:0] rs,
    output  [31:0] clz_out
);

wire [31:0] clz_terms;

// 生成32个条件项，每个项对应原始代码中的一个与项
generate
    genvar i;
    for (i = 0; i < 32; i = i + 1) begin : term_gen
        assign clz_terms[i] = &(~rs[31:i]); // 计算从最低位到第i位的所有位取反后的与结果
    end
endgenerate

// 累加所有条件项得到最终结果
assign clz_out =(clz_terms[0] + clz_terms[1] + clz_terms[2] + clz_terms[3] +
                 clz_terms[4] + clz_terms[5] + clz_terms[6] + clz_terms[7] +
                 clz_terms[8] + clz_terms[9] + clz_terms[10] + clz_terms[11] +
                 clz_terms[12] + clz_terms[13] + clz_terms[14] + clz_terms[15] +
                 clz_terms[16] + clz_terms[17] + clz_terms[18] + clz_terms[19] +
                 clz_terms[20] + clz_terms[21] + clz_terms[22] + clz_terms[23] +
                 clz_terms[24] + clz_terms[25] + clz_terms[26] + clz_terms[27] +
                 clz_terms[28] + clz_terms[29] + clz_terms[30] + clz_terms[31]);

endmodule