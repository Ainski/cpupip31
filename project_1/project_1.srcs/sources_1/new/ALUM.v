`timescale 1ps / 1ps

module ALUM
(
    input [31:0] a,
    input [31:0] b,
    input [2:0] ALUMCTR,
    input reset,
    input clk,
    output reg [31:0]HI,
    output reg [31:0]LO
);
parameter MUL=3'b001;
parameter MULU=3'b010;
parameter DIV=3'b011;
parameter DIVU=3'b100;
parameter MTHI=3'b101;
parameter MTLO=3'b110;
wire [31:0]temp_a;
wire [31:0]temp_b;
wire [31:0]quotient_o;
wire [31:0]remainder_o;
wire [63:0]prod;
wire [63:0]real_prod;

wire sign_a;
wire sign_b;
wire qr_valid_o;

wire [32:0]temp_a_divu;
wire [32:0]temp_b_divu;
wire [32:0]quotient_o_divu;
wire [32:0]remainder_o_divu;

wire qr_valid_o_divu;
wire result_sign;
assign sign_a=a[31];
assign sign_b=b[31];
assign result_sign = (ALUMCTR==DIV)&&sign_a^sign_b;


assign temp_a=(ALUMCTR==MUL||ALUMCTR==DIV)&&a[31]?-a:a;
assign temp_b=(ALUMCTR==MUL||ALUMCTR==DIV)&&b[31]?-b:b;
assign real_prod=(ALUMCTR==MUL||ALUMCTR==DIV)&&(sign_a^sign_b)?-prod:prod;

assign temp_a_divu={1'b0,temp_a};
assign temp_b_divu={1'b0,temp_b};

DIV #(.XDW(33)) div_unit_divu
(
    .data_valid_i(1'b1),
    .dividend_i(temp_a_divu),
    .divisor_i(temp_b_divu),
    .qr_valid_o(qr_valid_o_divu),
    .quotient_o(quotient_o_divu),
    .remainder_o(remainder_o_divu)
);

DIV div_unit(
    .data_valid_i(1'b1),
    .dividend_i(a),
    .divisor_i(b),
    .qr_valid_o(qr_valid_o),
    .quotient_o(quotient_o),
    .remainder_o(remainder_o)
);
MULTU mul_unit(
    .a(temp_a),
    .b(temp_b),
    .prod(prod)
);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        HI = 0;
        LO = 0;
    end else begin
        case (ALUMCTR)
            MUL: begin
                HI = real_prod[63:32];
                LO = real_prod[31:0];
            end
            MULU: begin
                HI = real_prod[63:32];
                LO = real_prod[31:0];
            end
            DIV: begin
                HI = sign_a?-remainder_o_divu[31:0]:remainder_o_divu[31:0];
                LO = result_sign?-quotient_o_divu[31:0]:quotient_o_divu[31:0];
            end
            DIVU: begin
                HI = remainder_o_divu[31:0];
                LO = quotient_o_divu[31:0];
            end
            MTHI: begin
                HI=a;
            end
            MTLO: begin
                LO=a;
            end
            default: begin
                HI = HI;
                LO = LO;
            end
        endcase 
    end 
end

endmodule





module DIV
#(parameter XDW = 32)  //X_DATA_WIDTH
(
	input 			     data_valid_i,
	input 	   [XDW-1:0] dividend_i,
	input 	   [XDW-1:0] divisor_i,
	output  	     	 qr_valid_o,
	output     [XDW-1:0] quotient_o,
	output     [XDW-1:0] remainder_o
);
wire [XDW-1:0] numwire [XDW-1:0];
wire [XDW  :0] numtemp [XDW-1:0];
wire [XDW-1:0] subwire [XDW-1:0];
wire [XDW-1:0] ge;
genvar i;

assign numwire[XDW-1] = {{XDW-1{1'b0}},dividend_i[XDW-1]};
assign numtemp[XDW-1] = numwire[XDW-1] - divisor_i;
assign ge[XDW-1]  	  = ~numtemp[XDW-1][XDW];
assign subwire[XDW-1] = ge[XDW-1]?numtemp[XDW-1]:numtemp[XDW-1]+ divisor_i;

generate
	for (i=XDW-2;i>=0;i=i-1) begin:shift_and_calculate_result
		assign numwire[i] = {subwire[i+1][XDW-2:0],dividend_i[i]};
		assign numtemp[i] = numwire[i] - divisor_i;
		assign ge[i]  	  = ~numtemp[i][XDW];
		assign subwire[i] = ge[i]?numtemp[i]:numtemp[i]+ divisor_i;
	end
endgenerate

// always @ (posedge clk_i or posedge rst_i) begin
// 	if (rst_i) begin
// 		quotient_o  <= {XDW{1'b0}};
// 		remainder_o <= {XDW{1'b0}};
// 		qr_valid_o  <=      1'b0  ;
// 	end else if (data_valid_i&& |divisor_i) begin
// 		qr_valid_o  <= data_valid_i;
// 		quotient_o  <= ge;
// 		remainder_o <= subwire[0]; 
// 	end else
// 		qr_valid_o  <=      1'b0  ;
// end
assign qr_valid_o=(data_valid_i && |divisor_i) ? data_valid_i:0;
assign quotient_o=(data_valid_i && |divisor_i) ? ge :0;
assign remainder_o=(data_valid_i && |divisor_i)?subwire[0]: 0;
endmodule


module MULTU( 
    input [31:0] a,  // 被乘数
    input [31:0] b,  // 乘数
    output [63:0] prod  // 乘积输出
);
    // 生成乘数每一位对应的被乘数左移结果（纯组合逻辑）
    wire [63:0] stored0  = b[0]  ? {32'b0, a}            : 64'b0;
    wire [63:0] stored1  = b[1]  ? {31'b0, a, 1'b0}       : 64'b0;
    wire [63:0] stored2  = b[2]  ? {30'b0, a, 2'b0}       : 64'b0;
    wire [63:0] stored3  = b[3]  ? {29'b0, a, 3'b0}       : 64'b0;
    wire [63:0] stored4  = b[4]  ? {28'b0, a, 4'b0}       : 64'b0;
    wire [63:0] stored5  = b[5]  ? {27'b0, a, 5'b0}       : 64'b0;
    wire [63:0] stored6  = b[6]  ? {26'b0, a, 6'b0}       : 64'b0;
    wire [63:0] stored7  = b[7]  ? {25'b0, a, 7'b0}       : 64'b0;
    wire [63:0] stored8  = b[8]  ? {24'b0, a, 8'b0}       : 64'b0;
    wire [63:0] stored9  = b[9]  ? {23'b0, a, 9'b0}       : 64'b0;
    wire [63:0] stored10 = b[10] ? {22'b0, a, 10'b0}      : 64'b0;
    wire [63:0] stored11 = b[11] ? {21'b0, a, 11'b0}      : 64'b0;
    wire [63:0] stored12 = b[12] ? {20'b0, a, 12'b0}      : 64'b0;
    wire [63:0] stored13 = b[13] ? {19'b0, a, 13'b0}      : 64'b0;
    wire [63:0] stored14 = b[14] ? {18'b0, a, 14'b0}      : 64'b0;
    wire [63:0] stored15 = b[15] ? {17'b0, a, 15'b0}      : 64'b0;
    wire [63:0] stored16 = b[16] ? {16'b0, a, 16'b0}      : 64'b0;
    wire [63:0] stored17 = b[17] ? {15'b0, a, 17'b0}      : 64'b0;
    wire [63:0] stored18 = b[18] ? {14'b0, a, 18'b0}      : 64'b0;
    wire [63:0] stored19 = b[19] ? {13'b0, a, 19'b0}      : 64'b0;
    wire [63:0] stored20 = b[20] ? {12'b0, a, 20'b0}      : 64'b0;
    wire [63:0] stored21 = b[21] ? {11'b0, a, 21'b0}      : 64'b0;
    wire [63:0] stored22 = b[22] ? {10'b0, a, 22'b0}      : 64'b0;
    wire [63:0] stored23 = b[23] ? {9'b0, a, 23'b0}       : 64'b0;
    wire [63:0] stored24 = b[24] ? {8'b0, a, 24'b0}       : 64'b0;
    wire [63:0] stored25 = b[25] ? {7'b0, a, 25'b0}       : 64'b0;
    wire [63:0] stored26 = b[26] ? {6'b0, a, 26'b0}       : 64'b0;
    wire [63:0] stored27 = b[27] ? {5'b0, a, 27'b0}       : 64'b0;
    wire [63:0] stored28 = b[28] ? {4'b0, a, 28'b0}       : 64'b0;
    wire [63:0] stored29 = b[29] ? {3'b0, a, 29'b0}       : 64'b0;
    wire [63:0] stored30 = b[30] ? {2'b0, a, 30'b0}       : 64'b0;
    wire [63:0] stored31 = b[31] ? {1'b0, a, 31'b0}       : 64'b0;
    
    // 一级加法：32个输入两两相加（16个结果）
    wire [63:0] add0_1  = stored0  + stored1;
    wire [63:0] add2_3  = stored2  + stored3;
    wire [63:0] add4_5  = stored4  + stored5;
    wire [63:0] add6_7  = stored6  + stored7;
    wire [63:0] add8_9  = stored8  + stored9;
    wire [63:0] add10_11 = stored10 + stored11;
    wire [63:0] add12_13 = stored12 + stored13;
    wire [63:0] add14_15 = stored14 + stored15;
    wire [63:0] add16_17 = stored16 + stored17;
    wire [63:0] add18_19 = stored18 + stored19;
    wire [63:0] add20_21 = stored20 + stored21;
    wire [63:0] add22_23 = stored22 + stored23;
    wire [63:0] add24_25 = stored24 + stored25;
    wire [63:0] add26_27 = stored26 + stored27;
    wire [63:0] add28_29 = stored28 + stored29;
    wire [63:0] add30_31 = stored30 + stored31;
    
    // 二级加法：16个结果两两相加（8个结果）
    wire [63:0] add0t1_2t3 = add0_1  + add2_3;
    wire [63:0] add4t5_6t7 = add4_5  + add6_7;
    wire [63:0] add8t9_10t11 = add8_9  + add10_11;
    wire [63:0] add12t13_14t15 = add12_13 + add14_15;
    wire [63:0] add16t17_18t19 = add16_17 + add18_19;
    wire [63:0] add20t21_22t23 = add20_21 + add22_23;
    wire [63:0] add24t25_26t27 = add24_25 + add26_27;
    wire [63:0] add28t29_30t31 = add28_29 + add30_31;
    
    // 三级加法：8个结果两两相加（4个结果）
    wire [63:0] add0t3_4t7 = add0t1_2t3 + add4t5_6t7;
    wire [63:0] add8t11_12t15 = add8t9_10t11 + add12t13_14t15;
    wire [63:0] add16t19_20t23 = add16t17_18t19 + add20t21_22t23;
    wire [63:0] add24t27_28t31 = add24t25_26t27 + add28t29_30t31;
    
    // 四级加法：4个结果两两相加（2个结果）
    wire [63:0] add0t7_8t15 = add0t3_4t7 + add8t11_12t15;
    wire [63:0] add16t23_24t31 = add16t19_20t23 + add24t27_28t31;
    
    // 最终加法：2个结果相加（1个结果）
    assign prod = add0t7_8t15 + add16t23_24t31;

endmodule