module ROM 
(

	input logic clk,
	input logic [15:0] address, 
	output logic [15:0] instruction 

); 

logic [15:0] memory [127:0]; 


//Reads 

always_ff @(posedge clk)
begin 

	instruction <= memory[address[7:1]];

end


endmodule