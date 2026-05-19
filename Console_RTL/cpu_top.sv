module cpu_top
(

	input logic clk,
	input logic reset

);

//ID stage signals and decoder
logic [15:0] address_index;
logic [15:0] instruction_IF;
logic [15:0] instruction_ID;
logic [3:0] opcode;
logic [3:0] field_a;
logic [3:0] field_b;
logic [3:0] field_c;

//Control unit/IF signals
logic [1:0] srcA_sel; //0 for unused, 1 for field A, 2 for field B, 3 for field C. Read 1
logic [1:0] srcB_sel; //0 for unused, 1 for field A, 2 for field B, 3 for field C. Read 2

logic [3:0] read_1;
logic [3:0] read_2;

logic [15:0] read_value_1;
logic [15:0] read_value_2;

logic [15:0] first_value; 
logic [15:0] second_value; 
logic [15:0] third_value;

logic [1:0] immediate;
logic [3:0] rd;
logic reg_write_enable;

logic alu_used;
logic [2:0] alu_op;

logic branch_used;
logic [1:0] branch_op;

logic mem_write_enable;
logic mem_read_enable;
logic pc_used;

//EX STAGE

logic [3:0] rd_EX;
logic [15:0] value_a_EX;
logic [15:0] value_b_EX;
logic [15:0] value_c_EX;
logic alu_used_EX;
logic [2:0] alu_op_EX;
logic reg_write_enable_EX;
logic branch_used_EX;
logic [1:0] branch_op_EX;
logic mem_write_enable_EX;
logic mem_read_enable_EX;
logic pc_used_EX;
logic [1:0] immediate_EX;

	
logic [15:0] alu_second_value;
logic [15:0] alu_result;
logic [15:0] pc_inc;
logic [15:0] pc_inc_calc;

//MEM signals
logic [3:0] rd_MEM;
logic mem_write_enable_MEM;
logic mem_read_enable_MEM;
logic reg_write_enable_MEM;
logic [15:0] store_data_MEM;
logic [15:0] result_MEM;

//WB signals
logic [15:0] result_WB;
logic reg_write_enable_WB;
logic [3:0] rd_WB;



	pc pc_inst
	(

		.reset(reset),
		.clk(clk),
		.pc_inc(pc_inc),
		.index(address_index)	

	);

	ROM ROM_inst //sequential reads to mimic actual ram
	(
		.clk(clk),
		.address(address_index),
		.instruction(instruction_IF)

	);

	IF_ID_register IF_ID_register_inst
	(
		
		.clk(clk),
		.reset(reset),
		.instruction_IF(instruction_IF),
		.instruction_ID(instruction_ID)

	);

	decoder decoder_inst
	(

		.instruction_ID(instruction_ID),
		.opcode(opcode),
		.field_a(field_a),
		.field_b(field_b),
		.field_c(field_c)

	);

	control_unit control_unit_inst
	(
	
		.opcode(opcode),
		.funct4(field_b),
	
		.srcA_sel(srcA_sel),
		.srcB_sel(srcB_sel),
		
		.immediate(immediate),
		.reg_write_enable(reg_write_enable),
		.alu_used(alu_used),
		.alu_op(alu_op),

		.branch_used(branch_used),
		.branch_op(branch_op),

		.mem_write_enable(mem_write_enable),
		.mem_read_enable(mem_read_enable),
		.pc_used(pc_used)

		//temporarily until special added
	);

	register_file register_file_inst
	(
		
		//ID stuff
		.clk(clk),
		.reset(reset),
		.read_1(read_1),
		.read_2(read_2),

		//WB stuff
		.write_index(rd_WB),
		.write_value(result_WB),
		.write_enable(reg_write_enable_WB),
		.read_value_1(read_value_1),
		.read_value_2(read_value_2)

	);




//Control unit and ID/EX MUXes
//assigns src a, b, or c to field a, b or c or nothing. 

//srcA and srcB are reads
//Immediate signal determines how values are interpreted

always_comb 
begin

rd = field_a; //Always the case, reg_write enable will determine if it's acting as rd or not
first_value = 16'h0000;
second_value = 16'h0000;
third_value = 16'h0000;

	//Determining reads, might be unused anyways
	case (srcA_sel)
        	2'b01:   read_1 = field_a;
        	2'b10:   read_1 = field_b;
        	2'b11:   read_1 = field_c;
        	default: read_1 = 4'b0000;
	endcase

	case (srcB_sel)
        	2'b01:   read_2 = field_a;
        	2'b10:   read_2 = field_b;
        	2'b11:   read_2 = field_c;
		default: read_2 = 4'b0000;
	endcase
	
	//Assigning values to first, second and third value
	case (immediate)
	
		2'b00:
		begin

			first_value = read_1;
			second_value = read_2;

		end
		2'b01:
		begin

			first_value = read_1;
			second_value = read_2;
			third_value = {{12{field_c[3]}}, field_c};

		end
		2'b10:
		begin

			first_value = {{8{1'b0}}, field_b, field_c};

		end
		2'b11:
		begin

			first_value = {{8{field_a[3]}}, field_a, field_c};

		end
		default
		begin
			
			first_value = 16'h0000;
			second_value = 16'h0000;
			third_value = 16'h0000;			

		end

	endcase

end

	ID_EX_register ID_EX_register_inst
	(

		.clk(clk),
		.reset(reset),
		.rd_ID(rd),
		.value_a_ID(first_value),
		.value_b_ID(second_value),
		.value_c_ID(third_value),
		.alu_used_ID(alu_used),
		.alu_op_ID(alu_op),
		.reg_write_enable_ID(reg_write_enable),
		.branch_used_ID(branch_used),
		.branch_op_ID(branch_op),
		.mem_write_enable_ID(mem_write_enable),
		.mem_read_enable_ID(mem_read_enable),
		.pc_used_ID(pc_used),
		.immediate_ID(immediate),

	
		.rd_EX(rd_EX),
		.value_a_EX(value_a_EX),
		.value_b_EX(value_b_EX),
		.value_c_EX(value_c_EX),
		.alu_used_EX(alu_used_EX),
		.alu_op_EX(alu_op_EX),
		.reg_write_enable_EX(reg_write_enable_EX),
		.branch_used_EX(branch_used_EX),
		.branch_op_EX(branch_op_EX),
		.mem_write_enable_EX(mem_write_enable_EX),
		.mem_read_enable_EX(mem_read_enable_EX),
		.pc_used_EX(pc_used_EX),
		.immediate_EX(immediate_EX)


	);


always_comb
begin
//immediate alu
if (immediate_EX == 2'b01)
	alu_second_value = value_c_EX;
else
	alu_second_value = value_b_EX;

end
	ALU ALU_inst
	(

		.alu_op(alu_op_EX),	
		.value_1(value_a_EX),
		.value_2(alu_second_value),

		.result(alu_result)

	);


	branch_unit branch_unit_inst
	(

		.rs1(value_a_EX),
		.rs2(value_b_EX),
		.sign_extend_off4(value_c_EX),
		.branch_op(branch_op_EX),

		.pc_inc(pc_inc_calc)

	);




assign pc_inc = (branch_used_EX) ? pc_inc_calc : 16'h0002;


	EX_MEM_register EX_MEM_register_inst
	(

		.clk(clk),
		.reset(reset),
		.rd_EX(rd_EX),
		.reg_write_enable_EX(reg_write_enable_EX),
		.result_EX(alu_result),
		.mem_write_enable_EX(mem_write_enable_EX),
		.mem_read_enable_EX(mem_read_enable_EX),
		.store_data_EX(value_b_EX),

		.rd_MEM(rd_MEM),
		.reg_write_enable_MEM(reg_write_enable_MEM),
		.result_MEM(result_MEM),
		.mem_write_enable_MEM(mem_write_enable_MEM),
		.mem_read_enable_MEM(mem_read_enable_MEM),
		.store_data_MEM(store_data_MEM)

	);





	data_mem data_mem_inst
	(
	
		.clk(clk),
		.write_enable(mem_write_enable_MEM),
		.read_enable(mem_read_enable_MEM),
		.write_value(store_data_MEM),
		.index(result_MEM),
		.reg_write_enable_MEM(reg_write_enable_MEM),
		.rd_MEM(rd_MEM),

		.result_value(result_WB),
		.reg_write_enable_WB(reg_write_enable_WB),
		.rd_WB(rd_WB)

	);



endmodule