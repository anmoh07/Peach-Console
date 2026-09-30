module pc
(

	input logic clk,
	input logic reset,
	input logic [15:0] next_pc,
	input logic halt,
	input logic pc_update, //0 for no update, 1 for update

	output logic [15:0] current_pc

);


always_ff @(posedge clk)
begin

	if (reset)
	begin	
		current_pc <= 16'h0000;
	end
	else if (!halt && pc_update)
	begin
		current_pc <= next_pc;
	end
end
endmodule