module control_unit
(

	input logic [3:0] opcode,
	input logic [3:0] funct4, //not always meaningful, only if opcode == 4'b1111
	

	output logic [1:0] srcA_sel, //0 for unused, 1 for field A, 2 for field B, 3 for field C
	output logic [1:0] srcB_sel, //0 for unused, 1 for field A, 2 for field B, 3 for field C
	output logic [1:0] immediate, //0 for no, 1 for field C imm4 or off4, 2 for field C and field B for imm8, 3 for field A and field C for off8, 4 for field C and field B imm8 << 8

	output logic reg_write_enable, //0 for no, 1 for yes
	output logic alu_used,
	output logic [2:0] alu_op,

	output logic branch_used,
	output logic [1:0] branch_op,

	output logic mem_write_enable,
	output logic mem_read_enable,
	output logic pc_used
	//output logic sp_used unused for now
	
		

);

always_comb
begin

//Setting default signals
srcA_sel = 2'b00;
srcB_sel = 2'b00;
reg_write_enable = 1'b0;
immediate = 2'b00;
alu_op = 3'b000;
alu_used = 1'b0;
branch_used = 1'b0;
branch_op = 2'b00;
mem_write_enable = 1'b0;
pc_used = 1'b0;
mem_read_enable = 1'b0;


	casez (opcode)

		4'b0???:
		begin

			reg_write_enable = 1'b1;
			srcA_sel = 2'b10;
			srcB_sel = 2'b11;
			immediate = 2'b00;
			alu_op = opcode[2:0];
			alu_used = 1'b1;
			
			if (opcode == 4'b0111)
			begin
			
				immediate = 2'b01;
				alu_op = 3'b000;
				
			end

		end
		4'b1011,
		4'b1100,
		4'b1101,
		4'b1110:
		begin
			srcA_sel = 2'b01;
			srcB_sel = 2'b10;
			branch_used = 1'b1;
			branch_op = opcode[1:0]; //Simple trick, branch ops will just be defined around this
			immediate = 2'b01;
			pc_used = 1'b1;

		end
		4'b1000:
		begin
			reg_write_enable = 1'b1;
			immediate = 2'b10;
			
		end
		4'b1001:
		begin
			
			mem_read_enable = 1'b1;
			alu_used = 1'b1;
			alu_op = 3'b000;
			srcA_sel = 2'b10;
			reg_write_enable = 1'b1;
			immediate = 2'b01;
			
		end
		4'b1010:
		begin
			
			srcA_sel = 2'b10;//value added with immediate in the alu
			srcB_sel = 2'b01; //register whose value we will store in
			alu_used = 1'b1;
			alu_op = 3'b000;
			mem_write_enable = 1'b1;
			immediate = 2'b01;
			
		end
		4'b1111:
		begin
			
			case (funct4)
			
			4'b0000:
			begin

				

			end
			4'b0001:
			begin

				

			end
			4'b0010:
			begin

				

			end
			4'b0011:
			begin

					

			end
			4'b0100: 
			begin
			
				//NOP
				mem_read_enable = 1'b0;
				mem_write_enable = 1'b0;
				reg_write_enable = 1'b0;
				pc_used = 1'b0;

			end
			4'b0101:
			begin
	
				//MUL
				src_A

			end
			4'b0110:
			begin

				

			end
			4'b0111:
			begin

				

			end
			4'b1000:
			begin

					

			end
			4'b1001: 
			begin
			
		

			end
			4'b1010:
			begin

				

			end
			4'b1011:
			begin

				

			end
			4'b1100:
			begin

					

			end
			4'b1101:
			begin

					

			end
			4'b1110: 
			begin
			
		

			end
			4'b1111: 
			begin	
				reg_write_enable = 1'b1;
				immediate = 2'b10;
			end
			endcase

		end
		default:
		begin

				

		end		

	endcase

end


endmodule