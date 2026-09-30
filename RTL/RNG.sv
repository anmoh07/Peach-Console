module RNG
(

	input logic reset,
	input logic clk,
	input logic rng_request,

	output logic [15:0] rng_value

);

always_ff @(posedge clk)
begin

	if (reset)
	begin
		rng_value <= 16'hACE1;
	end
	else if (rng_request)
	begin
		if (rng_value == 16'h0000)
		begin
			rng_value <= 16'hACE1;
		end
		else
		begin
		
			rng_value <= ((rng_value >> 1) | ((((rng_value >> 0) ^ (rng_value >> 2) ^ (rng_value >> 3) ^ (rng_value >> 5)) & 1) << 15));

		end
	end
end
endmodule