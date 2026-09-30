module control_unit
(

	input logic [3:0] opcode,
	input logic [3:0] funct4,
	
	output logic alu_select, //0 for read_value_1, 1 for immediate
	output logic [3:0] alu_op,
	output logic [2:0] branch_op,
	output logic [1:0] pc_select,
	output logic rng_request,
	output logic write_enable,
	output logic [2:0] wb_select,
	output logic data_mem_read_enable,
	output logic data_mem_write_enable,
	output logic pc_halt,
	output logic [1:0] sp_status,
	output logic data_mem_write_value,
	output logic data_mem_read_write_address

);


always_comb
begin

alu_select = 1'b0;
alu_op = 4'b0000;
branch_op = 3'b100;
pc_select = 2'b00; //0 branch instructions/default, 1 for rs, 2 for data_mem_read
rng_request = 1'b0;
write_enable = 1'b0;
wb_select = 3'b000; //0 for alu result, 1 immediate, 2 data mem read, 3 rs2, 4 for rng_value
data_mem_read_enable = 1'b0;
data_mem_write_enable = 1'b0;
pc_halt = 1'b0; //0 for no halt, 1 for halt
sp_status = 2'b00; //10 for dec, 11 for inc
data_mem_write_value = 1'b0; //0 to rs, 1 pc + 2
data_mem_read_write_address = 1'b0; //0 for alu_result, 1 for sp


	case (opcode)
	
	4'b0000,
	4'b0001,
	4'b0010,
	4'b0011,
	4'b0100,
	4'b0101,
	4'b0110:
	begin
		
		alu_op = {1'b0, opcode[2:0]};
		alu_select = 1'b0;
		wb_select = 3'b000;
		write_enable = 1'b1;

	end	
	4'b0111:
	begin

		alu_op = 4'b0000;
		alu_select = 1'b1;
		wb_select = 3'b000;
		write_enable = 1'b1;

	end	
	4'b1000:
	begin

		write_enable = 1'b1;
		wb_select = 3'b001;

	end
	4'b1001:
	begin
	
		wb_select = 3'b010;
		write_enable = 1'b1;
		data_mem_read_enable = 1'b1;
		alu_select = 1'b1;
		alu_op = 4'b0000;
		data_mem_read_write_address = 1'b0; 

	end
	4'b1010:
	begin
	
		data_mem_write_enable = 1'b1;
		alu_select = 1'b1;
		alu_op = 4'b0000;
		data_mem_write_value = 1'b0; 
		data_mem_read_write_address = 1'b0; 

	end
	4'b1011,
	4'b1100,
	4'b1101,
	4'b1110:
	begin
	
		pc_select = 2'b00;
		branch_op = {1'b0, opcode[1:0]};

	end
	4'b1111:
	begin

		case (funct4)
		
		4'b0000:
		begin

			pc_select = 2'b01;

		end
		4'b0001: //Call
		begin

			sp_status = 2'b10;
			pc_select = 2'b01;
			data_mem_write_value = 1'b1;
			data_mem_read_write_address = 1'b1;
			data_mem_write_enable = 1'b1;

		end
		4'b0010: //Ret
		begin

			pc_select = 2'b10;
			sp_status = 2'b11;
			data_mem_read_write_address = 1'b1;
			data_mem_read_enable = 1'b1;

		end
		4'b0011:
		begin

			pc_halt = 1'b1;

		end
		4'b0100:
		begin

			//NOP

		end
		4'b0101:
		begin

			alu_op = 4'b1001;
			alu_select = 1'b0;
			wb_select = 3'b000;
			write_enable = 1'b1;

		end
		4'b0110:
		begin

			alu_op = 4'b0111;
			alu_select = 1'b0;
			wb_select = 3'b000;
			write_enable = 1'b1;

		end
		4'b0111:
		begin

			alu_op = 4'b1000;
			alu_select = 1'b0;
			wb_select = 3'b000;
			write_enable = 1'b1;

		end
		4'b1000:
		begin

			wb_select = 3'b011;
			write_enable = 1'b1;

		end
		4'b1001: //Push
		begin

			sp_status = 2'b10;
			data_mem_write_value = 1'b0; 
			data_mem_read_write_address = 1'b1; 
			data_mem_write_enable = 1'b1;

		end
		4'b1010: //Pop
		begin

			sp_status = 2'b11;
			data_mem_read_write_address = 1'b1; 
			data_mem_read_enable = 1'b1;
			wb_select = 3'b010;
			write_enable = 1'b1;

		end
		4'b1011:
		begin

			write_enable = 1'b1;
			wb_select = 3'b100;
			rng_request = 1'b1;

		end
		4'b1100:
		begin

			alu_op = 4'b0101;
			alu_select = 1'b1;
			wb_select = 3'b000;
			write_enable = 1'b1;

		end
		4'b1101:
		begin

			alu_op = 4'b0110;
			alu_select = 1'b1;
			wb_select = 3'b000;
			write_enable = 1'b1;

		end
		4'b1110:
		begin

			pc_select = 2'b00;
			branch_op = 3'b101;


		end
		4'b1111:
		begin

			write_enable = 1'b1;
			wb_select = 3'b001;

		end
		endcase

	end

	endcase

end
endmodule