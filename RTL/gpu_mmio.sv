module gpu_mmio 
(
    input logic clk,
    input logic reset,

    //CPU
    input logic [15:0] cpu_address,
    input logic [15:0] cpu_write_data,
    input logic cpu_write_enable,
    input logic cpu_read_enable,
    output logic [15:0] cpu_read_data,

    //GPU
    input logic gpu_busy,
    output logic command_start,
    output logic [15:0] command,
    output logic [7:0] x,
    output logic [6:0] y,
    output logic [7:0] width,
    output logic [6:0] height,
    output logic [15:0] color,
    output logic [15:0] tile_id,
    output logic [31:0] source_addr,
    output logic [15:0] draw_flags
  
);
