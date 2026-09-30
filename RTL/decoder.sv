module decoder
(

	input logic [15:0] instruction,
	
	output logic [3:0] opcode,
	output logic [3:0] rs1,
	output logic [3:0] rs2,
	output logic [3:0] rd,
	output logic [3:0] funct4,
	output logic [15:0] immediate

);

assign opcode = instruction[15:12];
assign rd = instruction[11:8];
assign funct4 = instruction[7:4];

always_comb
begin

rs1 = instruction[7:4];
rs2 = instruction[3:0];

	immediate = 16'h0000;
	case (opcode)

	4'b0111: immediate = {{12{rs2[3]}}, rs2};
	4'b1000: immediate = {{8{1'b0}}, instruction[7:0]};
	4'b1001: immediate = {{12{rs2[3]}}, rs2};
	4'b1010,
	4'b1011,
	4'b1100,
	4'b1101,
	4'b1110: immediate = {{12{rd[3]}}, rd};

	4'b1111:
	begin

		case (funct4)
			
			4'b0001,
			4'b0010,
			4'b1010: rs1 = 4'b1111;

			4'b1001: 

			begin
				
				rs2 = rd;
				rs1 = 4'b1111;

			end

			4'b0101,
			4'b0110,
			4'b0111: rs1 = rd;

			4'b1100,
			4'b1101: 
			begin

				rs1 = rd;
				immediate = {{12{1'b0}}, rs2};

			end
			4'b1110: immediate = {{8{rd[3]}}, rd, rs2};
			4'b1111: immediate = {funct4, rs2, {8{1'b0}}};

		endcase


		

	end

	endcase


end


endmodule