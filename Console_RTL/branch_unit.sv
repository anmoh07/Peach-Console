module branch_unit
(

	input logic [15:0] rs1,
	input logic [15:0] rs2,
	input logic [15:0] sign_extend_off4,
	input logic [1:0] branch_op,

	output logic [15:0] pc_inc


);


typedef enum logic [1:0]
{

	BNE,
	BLT,
	BGE,
	BEQ

} op_t;


always_comb
begin

	op_t op;
	op = op_t'(branch_op);

	case (op)

		BNE: pc_inc = ((rs1 != rs2) ? sign_extend_off4 : 16'h0000) + 16'h0002;
		BLT: pc_inc = (($signed(rs1) < $signed(rs2)) ? sign_extend_off4 : 16'h0000) + 16'h0002;
		BGE: pc_inc = (($signed(rs1) >= $signed(rs2)) ? sign_extend_off4 : 16'h0000) + 16'h0002;
		BEQ: pc_inc = ((rs1 == rs2) ? sign_extend_off4 : 16'h0000) + 16'h0002;
		default: pc_inc = 16'h0002;

	endcase

end


endmodule