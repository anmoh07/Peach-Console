module tb
(
);

logic clk;
logic reset;
always #5 clk = ~clk;


initial
begin

	clk = 1'b0;
	reset = 1'b1;
	
	repeat (1) @(posedge clk);
	reset = 1'b0;	
	
	
	repeat (10) @(posedge clk);
	
	
	$stop;

end
	
	cpu_top dut
	(
	
		.clk(clk),
		.reset(reset)	

	);


endmodule