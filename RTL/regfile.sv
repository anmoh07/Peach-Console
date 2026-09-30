module regfile
(

	input logic reset,
	input logic clk,

	input logic [3:0] rs1,
	input logic [3:0] rs2,
	output logic [15:0] read_value_1,
	output logic [15:0] read_value_2,

	input logic [15:0] write_value,
	input logic [3:0] write_index,
	input logic write_enable,

	input logic [1:0] sp_status

);

logic [15:0] regs [15:0];

//reads
always_comb
begin

	if (rs1 == 4'h0)
		read_value_1 = 16'h0000;
	else
		read_value_1 = regs[rs1];

	if (rs2 == 4'h0)
		read_value_2 = 16'h0000;
	else
		read_value_2 = regs[rs2];

end

//writes
always_ff @(posedge clk)
begin

	if (reset)
	begin
		for (int i = 1; i <= 15; i++)
		begin
			regs[i] <= 0;
		end
	end
	else if (write_enable && !(write_index == 4'h0))
		regs[write_index] <= write_value;
	
	if ((sp_status == 2'b11) && ~reset)
		regs[15] <= regs[15] + 16'b0010;
	else if ((sp_status == 2'b10) && ~reset)
		regs[15] <= regs[15] - 16'b0010;

end

endmodule