module console_top
(

	input logic clk,
	input logic reset


);


logic [15:0] address; //from cpu_top to ram
logic [15:0] ram_write_value; //from ram to cpu_top
logic [15:0] ram_read_value; //from ram to cpu_top
logic ram_write_en;
logic ram_read_en;

	cpu_top cpu_top_inst
	(

		.clk(clk),
		.reset(reset),

		.ram_data(ram_read_value),
		.ram_address(address),
		.ram_write_value(ram_write_value),
		.dm_write_en(ram_write_en),
		.dm_read_en(ram_read_en)


	);


	ram ram_inst
	(
	
		.address(address),
		.clk(clk),
		
		.write_enable(ram_write_en),
		.write_value(ram_write_value),

		.read_enable(ram_read_en),
		.read_value(ram_read_value)


	);

	//Address checker

	//GPU

	//Controller




endmodule