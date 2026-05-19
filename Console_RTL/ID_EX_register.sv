module ID_EX_register
(

	input logic clk,
	input logic reset,
	//input logic stall,
	//input logic flush,

	input logic [3:0] rd_ID,
	input logic [15:0] value_a_ID,
	input logic [15:0] value_b_ID,
	input logic [15:0] value_c_ID,
	input logic alu_used_ID,
	input logic [2:0] alu_op_ID,
	input logic reg_write_enable_ID,
	input logic branch_used_ID,
	input logic [1:0] branch_op_ID,
	input logic mem_write_enable_ID,
	input logic mem_read_enable_ID,
	input logic pc_used_ID,
	input logic [1:0] immediate_ID,

	output logic [3:0] rd_EX,
	output logic [15:0] value_a_EX,
	output logic [15:0] value_b_EX,
	output logic [15:0] value_c_EX,
	output logic alu_used_EX,
	output logic [2:0] alu_op_EX,
	output logic reg_write_enable_EX,
	output logic branch_used_EX,
	output logic [1:0] branch_op_EX,
	output logic mem_write_enable_EX,
	output logic mem_read_enable_EX,
	output logic pc_used_EX,
	output logic [1:0] immediate_EX



);

always_ff @(posedge clk)
begin

	if (reset)
	begin

		rd_EX <= 4'b0000;
		value_a_EX <= 16'h0000;
		value_b_EX <= 16'h0000;
		value_c_EX <= 16'h0000;
		alu_used_EX <= 1'b0;
		alu_op_EX <= 3'b000;
		reg_write_enable_EX <= 1'b0;
		branch_used_EX <= 1'b0;
		branch_op_EX <= 2'b00;
		mem_write_enable_EX <= 1'b0;
		mem_read_enable_EX <= 1'b0;
		pc_used_EX <= 1'b0;
		immediate_EX <= 2'b00;


	end
	else
	begin

		rd_EX <= rd_ID;
		value_a_EX <= value_a_ID;
		value_b_EX <= value_b_ID;
		value_c_EX <= value_c_ID;
		alu_used_EX <= alu_used_ID;
		alu_op_EX <= alu_op_ID;
		reg_write_enable_EX <= reg_write_enable_ID;
		branch_used_EX <= branch_used_ID;
		branch_op_EX <= branch_op_ID;
		mem_write_enable_EX <= mem_write_enable_ID;
		mem_read_enable_EX <= mem_read_enable_ID;
		pc_used_EX <= pc_used_ID;
		immediate_EX <= immediate_ID;

	end

end



endmodule