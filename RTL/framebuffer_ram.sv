module framebuffer_ram
(

        input logic clk,
        input logic write_enable,
    	input logic [10:0] write_address,
    	input logic [255:0] write_pixels,
    	input logic [15:0] write_mask,

        input  logic [10:0]  read_address,
    	output logic [255:0] read_pixels


);


generate
    for (genvar i = 0; i <= 15; i++) begin : ram_banks
        
   
        logic [15:0] gpu_ram_bank [0:1295];

        always_ff @(posedge clk) 
        begin
            
            //write if enable and mask only
            if (write_enable && write_mask[i]) 
            begin

                gpu_ram_bank[write_address] <= write_pixels[16*i +: 16];

            end

            //if writing and reading the same thing (when writing allowed), return the new thing
            if (write_enable && (write_address == read_address) && write_mask[i]) 
            begin

                read_pixels[16*i +: 16] <= write_pixels[16*i +: 16]; 

            end 
            else 
            begin

                read_pixels[16*i +: 16] <= gpu_ram_bank[read_address]; //Otherwise, always read from the register

            end
            
        end
    end
endgenerate

endmodule
