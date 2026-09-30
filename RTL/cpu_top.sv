module cpu_top
(

	input logic clk,
	input logic reset,

	input logic [15:0] ram_data,
	output logic [15:0] ram_address,
	output logic [15:0] ram_write_value,
	output logic dm_write_en,
	output logic dm_read_en

);

//decoder
logic [3:0] opcode;
logic [3:0] rs1;
logic [3:0] rs2;
logic [3:0] rd;
logic [3:0] funct4;
logic [15:0] immediate;

logic [15:0] instruction;
logic [15:0] decoder_instruction;
logic [15:0] read_value_1;
logic [15:0] read_value_2;

//ALU
logic [15:0] alu_value_2;
logic alu_select; //0 for read_value_1, 1 for immediate
logic [3:0] alu_op;
logic [15:0] alu_result;

//branch
logic [2:0] branch_op;
logic [15:0] branch_pc_out;
logic [15:0] next_pc;
logic [1:0] pc_select; //0 branch instructions/default, 1 for rs, 2 for data_mem_read
logic pc_halt;
logic pc_update;
logic [15:0] current_pc;

//rng
logic rng_request;
logic rng_en;
logic [15:0] rng_value;

//wb
logic write_enable;
logic writes_allowed;
logic [15:0] write_value;
logic [2:0] wb_select; //0 for alu result, 1 immediate, 2 data mem read, 3 rs2, 4 for rng_value
logic [1:0] sp_status_cntr;
logic [1:0] sp_status;

//dm
logic data_mem_read_write_address; //0 for alu_result, 1 for sp
logic dm_write;
logic data_mem_write_value; //0 to rs, 1 pc + 2
logic dm_read;

typedef enum logic [1:0]
{

	FETCH, //fetching instruction from memory
   	MEM_OR_EXECUTE, //using data mem
   	WRITEBACK_PC_UPDATE, //fetching instruction from memory
	HALT

} cpu_state_t;

cpu_state_t cpu_state;

	pc pc_inst
	(	

		.clk(clk),
		.reset(reset),	
		.next_pc(next_pc), 
		.halt(pc_halt),
		.pc_update(pc_update),
		
		.current_pc(current_pc)

	);

	decoder decoder_inst
	(

		.instruction(decoder_instruction),
	
		.opcode(opcode),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.funct4(funct4),
		.immediate(immediate)

	);

	control_unit control_unit_inst
	(

		.opcode(opcode),
		.funct4(funct4),
	
		.alu_select(alu_select), //0 for read_value_1, 1 for immediate
		.alu_op(alu_op),
		.branch_op(branch_op),
		.pc_select(pc_select),
		.rng_request(rng_request),
		.write_enable(write_enable),
		.wb_select(wb_select),
		.data_mem_read_enable(dm_read),
		.data_mem_write_enable(dm_write),
		.pc_halt(pc_halt),
		.sp_status(sp_status_cntr),
		.data_mem_write_value(data_mem_write_value),
		.data_mem_read_write_address(data_mem_read_write_address)


	);

	regfile regfile_inst
	(

		.reset(reset),
		.clk(clk),
	
		.rs1(rs1),
		.rs2(rs2),
		.read_value_1(read_value_1),
		.read_value_2(read_value_2),

		.write_value(write_value),
		.write_index(rd),
		.write_enable(writes_allowed),

		.sp_status(sp_status)

	);


always_comb
begin

alu_value_2 = (alu_select) ?  immediate :  read_value_2 ;

if (wb_select == 3'b001)
	write_value = immediate;
else if (wb_select == 3'b010)
	write_value = ram_data;
else if (wb_select == 3'b011)
	write_value = read_value_2;
else if (wb_select == 3'b100)
	write_value = rng_value;
else
	write_value = alu_result;

if (pc_select == 2'b01)
	next_pc = read_value_2;
else if (pc_select == 2'b10)
	next_pc = ram_data;
else
	next_pc = branch_pc_out;

if (cpu_state == MEM_OR_EXECUTE)
begin

	if (data_mem_read_write_address)
	begin
		if (sp_status_cntr == 2'b10) 
			ram_address = read_value_1 - 16'd2;
		else                        
			ram_address = read_value_1;
	end
	else
		ram_address = alu_result;
end
else
	ram_address = current_pc;

if (cpu_state == FETCH)
begin

	dm_read_en = 1'b1;
	dm_write_en = 1'b0;
	sp_status = 2'b00;
	rng_en = 1'b0;;

end
else if (cpu_state == MEM_OR_EXECUTE)
begin

	dm_write_en = dm_write;
	sp_status = 2'b00;
	dm_read_en = dm_read;
	rng_en = 1'b0;

end
else if (cpu_state == WRITEBACK_PC_UPDATE)
begin

	dm_read_en = 1'b0;
	dm_write_en = 1'b0;
	sp_status = sp_status_cntr;
	rng_en = rng_request;

end
else
begin

	dm_read_en = 1'b0;
	dm_write_en = 1'b0;
	sp_status = 2'b00;
	rng_en = 1'b0;;

end


if (data_mem_write_value)
	ram_write_value = branch_pc_out;
else
	ram_write_value = read_value_2;


if (cpu_state == MEM_OR_EXECUTE)
	decoder_instruction = ram_data;
else
        decoder_instruction = instruction;

end

assign writes_allowed = (write_enable) && (cpu_state == WRITEBACK_PC_UPDATE);
assign pc_update = (cpu_state == WRITEBACK_PC_UPDATE);

always_ff @(posedge clk)
begin


	if (reset)
	begin

		cpu_state <= FETCH;

	end
	else if (pc_halt || (cpu_state == HALT))
	begin

		cpu_state <= HALT;

	end
	else if (cpu_state == FETCH)
	begin
		cpu_state <= MEM_OR_EXECUTE;
	end
	else if (cpu_state == MEM_OR_EXECUTE)
	begin
		instruction <= ram_data;
		cpu_state <= WRITEBACK_PC_UPDATE;
	end
	else if (cpu_state == WRITEBACK_PC_UPDATE)
	begin
		cpu_state <= FETCH;
	end

end

	alu alu_inst
	(

		.value_1(read_value_1),
		.value_2(alu_value_2),
		.alu_op(alu_op),

		.result(alu_result)

	);
	
	branch_unit branch_unit_inst
	(


		.rs1(read_value_1),
		.rs2(read_value_2),
		.offset(immediate),
		.pc(current_pc),
		.branch_op(branch_op), 

		.next_pc(branch_pc_out)

	);

	RNG RNG_inst
	(

		.reset(reset),
		.clk(clk),
		.rng_request(rng_en),

		.rng_value(rng_value)

	);	
	


endmodule
