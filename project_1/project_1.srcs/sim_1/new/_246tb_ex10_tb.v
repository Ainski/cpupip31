`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/11/19 11:22:11
// Design Name:
// Module Name: top_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module _246tb_ex10_tb(

    );

    reg clk,rstn;
    reg [31:0] count;
    reg [31:0]pc_end_count;
    reg userbreak;
    wire [31:0] instr;
    PipelineCPU cpu_inst(
        .clk(clk),
        .rstn(rstn),
        .userbreak(userbreak)
    );

    assign instr = _246tb_ex10_tb.cpu_inst.instruction;
    

    integer file_output;

    initial
    begin
        file_output = $fopen("_246tb_ex10_result.txt");
		// Initialize Inputs
		clk = 0;
		rstn = 0;
		count=0;
        pc_end_count=0;
        userbreak=0;


		// Wait 100 ns for global reset to finish
		#10;
        rstn = 1;
		// Add stimulus here

		//#100;
		//$fclose(file_output);
        #1000
        userbreak=1;
        #1000
        userbreak=0;
	end
	always begin
        #5;
        if(instr==32'hffffffff)begin
            pc_end_count=pc_end_count+1;
        end
        if(pc_end_count==20) begin
            $fdisplay(file_output, "regfile0: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[0]);
            $fdisplay(file_output, "regfile1: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[1]);
            $fdisplay(file_output, "regfile2: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[2]);
            $fdisplay(file_output, "regfile3: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[3]);
            $fdisplay(file_output, "regfile4: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[4]);
            $fdisplay(file_output, "regfile5: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[5]);
            $fdisplay(file_output, "regfile6: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[6]);
            $fdisplay(file_output, "regfile7: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[7]);
            $fdisplay(file_output, "regfile8: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[8]);
            $fdisplay(file_output, "regfile9: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[9]);
            $fdisplay(file_output, "regfile10: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[10]);
            $fdisplay(file_output, "regfile11: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[11]);
            $fdisplay(file_output, "regfile12: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[12]);
            $fdisplay(file_output, "regfile13: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[13]);
            $fdisplay(file_output, "regfile14: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[14]);
            $fdisplay(file_output, "regfile15: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[15]);
            $fdisplay(file_output, "regfile16: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[16]);
            $fdisplay(file_output, "regfile17: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[17]);
            $fdisplay(file_output, "regfile18: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[18]);
            $fdisplay(file_output, "regfile19: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[19]);
            $fdisplay(file_output, "regfile20: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[20]);
            $fdisplay(file_output, "regfile21: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[21]);
            $fdisplay(file_output, "regfile22: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[22]);
            $fdisplay(file_output, "regfile23: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[23]);
            $fdisplay(file_output, "regfile24: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[24]);
            $fdisplay(file_output, "regfile25: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[25]);
            $fdisplay(file_output, "regfile26: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[26]);
            $fdisplay(file_output, "regfile27: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[27]);
            $fdisplay(file_output, "regfile28: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[28]);
            $fdisplay(file_output, "regfile29: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[29]);
            $fdisplay(file_output, "regfile30: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[30]);
            $fdisplay(file_output, "regfile31: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[31]);
            $stop;
        end
        count=count+clk;

        clk= ~clk;
        // if(clk== 1'b1&&count!=0) begin
        //     $fdisplay(file_output, "pc: %h", PC);
        //     $fdisplay(file_output, "instr: %h", instr);
        //     $fdisplay(file_output, "regfile0: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[0]);
        //     $fdisplay(file_output, "regfile1: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[1]);
        //     $fdisplay(file_output, "regfile2: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[2]);
        //     $fdisplay(file_output, "regfile3: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[3]);
        //     $fdisplay(file_output, "regfile4: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[4]);
        //     $fdisplay(file_output, "regfile5: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[5]);
        //     $fdisplay(file_output, "regfile6: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[6]);
        //     $fdisplay(file_output, "regfile7: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[7]);
        //     $fdisplay(file_output, "regfile8: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[8]);
        //     $fdisplay(file_output, "regfile9: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[9]);
        //     $fdisplay(file_output, "regfile10: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[10]);
        //     $fdisplay(file_output, "regfile11: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[11]);
        //     $fdisplay(file_output, "regfile12: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[12]);
        //     $fdisplay(file_output, "regfile13: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[13]);
        //     $fdisplay(file_output, "regfile14: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[14]);
        //     $fdisplay(file_output, "regfile15: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[15]);
        //     $fdisplay(file_output, "regfile16: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[16]);
        //     $fdisplay(file_output, "regfile17: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[17]);
        //     $fdisplay(file_output, "regfile18: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[18]);
        //     $fdisplay(file_output, "regfile19: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[19]);
        //     $fdisplay(file_output, "regfile20: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[20]);
        //     $fdisplay(file_output, "regfile21: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[21]);
        //     $fdisplay(file_output, "regfile22: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[22]);
        //     $fdisplay(file_output, "regfile23: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[23]);
        //     $fdisplay(file_output, "regfile24: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[24]);
        //     $fdisplay(file_output, "regfile25: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[25]);
        //     $fdisplay(file_output, "regfile26: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[26]);
        //     $fdisplay(file_output, "regfile27: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[27]);
        //     $fdisplay(file_output, "regfile28: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[28]);
        //     $fdisplay(file_output, "regfile29: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[29]);
        //     $fdisplay(file_output, "regfile30: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[30]);
        //     $fdisplay(file_output, "regfile31: %h", _246tb_ex10_tb.cpu_inst.pipe_id.regfile.array_reg[31]);

        // end
	end

endmodule
