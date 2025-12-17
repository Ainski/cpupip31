`timescale 1ns / 1ps
// 数据切割模块
// 功能：根据控制信号和地址对来自数据存储器的数据进行切割
`include "def.v"
module Cutter(
    input [31:0] data_in,         // 从数据存储器读取的原始数据
    input [1:0] addr_low,         // 地址的低两位，用于确定字节/半字选择
    input [1:0] cuttersource,     // 切割类型控制信号
                                // 2'b00: word (字) - 不切割直接输出 (`w_cut)
                                // 2'b01: halfword (半字) - 取相应的16位 (`h_cut)
                                // 2'b11: byte (字节) - 取相应的8位 (`b_cut)
    input sign,                   // 符号扩展标志（用于确定是否进行符号扩展）
    output reg [31:0] data_out    // 切割后的输出数据
);

    always @(*) begin
        case (cuttersource)
            `b_cut: begin  // 字节操作 (byte)
                if (sign) begin  // 符号扩展 (用于 lb 指令)
                    case (addr_low[1:0])
                        2'b00: data_out <= {{24{data_in[7]}}, data_in[7:0]};    // 取第0字节，符号扩展
                        2'b01: data_out <= {{24{data_in[15]}}, data_in[15:8]};  // 取第1字节，符号扩展
                        2'b10: data_out <= {{24{data_in[23]}}, data_in[23:16]}; // 取第2字节，符号扩展
                        2'b11: data_out <= {{24{data_in[31]}}, data_in[31:24]}; // 取第3字节，符号扩展
                    endcase
                end
                else begin  // 零扩展 (用于 lbu 指令)
                    case (addr_low[1:0])
                        2'b00: data_out <= {24'b0, data_in[7:0]};    // 取第0字节，零扩展
                        2'b01: data_out <= {24'b0, data_in[15:8]};   // 取第1字节，零扩展
                        2'b10: data_out <= {24'b0, data_in[23:16]};  // 取第2字节，零扩展
                        2'b11: data_out <= {24'b0, data_in[31:24]};  // 取第3字节，零扩展
                    endcase
                end
            end
            `h_cut: begin  // 半字操作 (halfword)
                if (sign) begin  // 符号扩展 (用于 lh 指令)
                    case (addr_low[1])
                        1'b0: data_out <= {{16{data_in[15]}}, data_in[15:0]};   // 取低半字，符号扩展
                        1'b1: data_out <= {{16{data_in[31]}}, data_in[31:16]};  // 取高半字，符号扩展
                    endcase
                end
                else begin  // 零扩展 (用于 lhu 指令)
                    case (addr_low[1])
                        1'b0: data_out <= {16'b0, data_in[15:0]};   // 取低半字，零扩展
                        1'b1: data_out <= {16'b0, data_in[31:16]};  // 取高半字，零扩展
                    endcase
                end
            end
            `w_cut: begin  // 字操作 (word)
                data_out <= data_in;  // 不切割，直接输出整个字
            end
            default: data_out <= data_in;  // 默认情况也输出原数据
        endcase
    end

endmodule