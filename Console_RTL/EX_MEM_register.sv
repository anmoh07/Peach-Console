module EX_MEM_register
(
	
	input logic reset,
	input logic clk,
	//input logic flush,
	//input logic stall,

	input logic [15:0] result_EX,
	input logic [3:0] rd_EX,
	input logic reg_write_enable_EX,
	input logic mem_write_enable_EX,
	input logic mem_read_enable_EX,
	input logic [15:0] store_data_EX,

	output logic [15:0] result_MEM,
	output logic [3:0] rd_MEM,
	output logic reg_write_enable_MEM,
	output logic mem_write_enable_MEM,
	output logic mem_read_enable_MEM,
	output logic [15:0] store_data_MEM

);

always_ff @(posedge clk)
begin

	if (reset)
	begin

		result_MEM <= 16'h0000;
		rd_MEM <= 4'h0;
		reg_write_enable_MEM <= 1'b0;
		mem_write_enable_MEM <= 1'b0;
		mem_read_enable_MEM <= 1'b0;
		store_data_MEM <= 16'h0000;

	end
	else
	begin

		result_MEM <= result_EX;
		rd_MEM <= rd_EX;
		reg_write_enable_MEM <= reg_write_enable_EX;
		mem_write_enable_MEM <= mem_write_enable_EX;
		mem_read_enable_MEM <= mem_read_enable_EX;
		store_data_MEM <= store_data_EX;

	end

end

endmodule