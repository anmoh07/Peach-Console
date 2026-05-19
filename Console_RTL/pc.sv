module pc
(

	input logic clk,
	input logic reset,
	input logic [15:0] pc_inc,

	output logic [15:0] index

);

//register

always_ff @(posedge clk)
begin	

	if (reset)
	begin

		index <= 16'h0000;

	end
	else
	begin

		index <= index + pc_inc;

	end

end
endmodule