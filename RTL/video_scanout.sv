
module video_scanout 
(

    input logic pixel_clk,

    input logic [7:0] x,
    input logic [6:0] y,

    input logic [255:0] framebuffer_pixels,
    output logic [10:0] framebuffer_address,
    output logic read_enable,
    
    output logic valid_pixel,
    output logic [15:0] pixel

);

logic [3:0] last_x_four_bits;
logic current_pixel_valid;

assign framebuffer_address = (y * 12) + (x >> 4); //then a one clk read happens from ram
assign pixel = framebuffer_pixels[ last_x_four_bits * 16 +: 16];

always_ff @(posedge clk)
begin

    last_x_four_bits <= x[3:0];
    valid_pixel <= current_pixel_valid;

end

always_comb
begin

    current_pixel_valid = 1'b1;
    read_enable = 1'b1;

    if ( (x > 8'b10111111 ) || (y > 8'b1101011 ) ) //rejecting pixels not within 192 x 108
    begin

        current_pixel_valid = 1'b0;
        read_enable = 1'b0;

    end

end

endmodule
