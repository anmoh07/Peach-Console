module register_file
(

	input logic clk,
	input logic reset,
	input logic [3:0] read_1,
	input logic [3:0] read_2,
	input logic [3:0] write_index,
	input logic [15:0] write_value,
	input logic write_enable, //if 1, writes are meaningful, if 0, writes aren't

	output logic [15:0] read_value_1,
	output logic [15:0] read_value_2
	//output logic [15:0] written_value //returning what was just written

);

//R0 hardwired to 0
//R15 is the stack pointer


logic [15:0] registers [15:0];
 

//Reads
always_comb
begin

	if (read_1 == 4'h0)
	begin
		read_value_1 = 16'h0000;
	end
	else
	begin
		read_value_1 = registers[read_1];
	end
	if (read_2 == 4'h0)
	begin
		read_value_2 = 16'h0000;
	end
	else
	begin
		read_value_2 = registers[read_2];
	end

end

//Write
always_ff @(posedge clk)
begin

	if (reset)
	begin
	
		for (int i = 0; i < 16; i++)
		begin
			registers[i] <= 16'h0000;
		end


	end
	else if (write_enable && (write_index != 4'h0))
	begin
	
		registers[write_index] <= write_value;

	end
	else
	begin

	end
end

endmodule

