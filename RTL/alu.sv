module alu
(

	input logic [15:0] value_1,
	input logic [15:0] value_2,
	input logic [3:0] alu_op,

	output logic [15:0] result

);

typedef enum logic [3:0]
{

	ADD, //ADDI too
	SUB,
	AND,
	OR,
	XOR,
	SHL, //SHLI too
	SHR, //SHRI too
	NOT,
	NEG,
	MUL


} op_t;

op_t op;



always_comb
begin

	op = op_t'(alu_op);
	result = 16'h0000;

	case (op)

		ADD: result = value_1 + value_2;
		SUB: result = value_1 - value_2;
		AND: result = value_1 & value_2;
		OR: result = value_1 | value_2;
		XOR: result = value_1 ^ value_2;
		SHL: result = value_1 << (value_2 & 4'hF);
		SHR: result = value_1 >> (value_2 & 4'hF);
		NOT: result = ~(value_1);
		NEG: result = -(value_1);
		MUL: result = value_1 * value_2;

	endcase

end

endmodule
