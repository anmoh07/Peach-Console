module ram
(

	input logic [15:0] address,
	input logic clk,

	input logic write_enable,
	input logic [15:0] write_value,

	input logic read_enable,
	output logic [15:0] read_value

);

//Von neuman architecture

logic [15:0] memory [32767:0];


always_ff @(posedge clk)
begin


	if (write_enable)
		memory[address[15:1]] <= write_value;

	else if (read_enable)
		read_value <= memory[address[15:1]];

	
end
endmodule