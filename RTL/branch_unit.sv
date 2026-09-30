module branch_unit
(

	input logic [15:0] rs1,
	input logic [15:0] rs2,
	input logic [15:0] offset,
	input logic [15:0] pc,
	input logic [2:0] branch_op, //gonna do nothing for non branch and drive pc + 2

	output logic [15:0] next_pc

);


always_comb
begin

next_pc = pc + 16'd2;

	case (branch_op)

		3'b011:
		begin
		if (rs1 == rs2)
			next_pc = next_pc + (offset << 1);
		end
		3'b000:
		begin
		if (rs1 != rs2)
			next_pc = next_pc + (offset << 1);
		end
		3'b001:
		begin
		if ($signed(rs1) < $signed(rs2))
			next_pc = next_pc + (offset << 1);
		end
		3'b010:
		begin
		if ($signed(rs1) >= $signed(rs2))
			next_pc = next_pc + (offset << 1);
		end
		3'b101: //jmp_rel8
			next_pc = next_pc + (offset << 1);
		default: next_pc = pc + 16'd2;

	endcase

end
endmodule