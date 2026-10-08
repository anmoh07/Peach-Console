module video_timing
(

    input logic pixel_clk,
    input logic reset,

    output logic [7:0] x,
    output logic [6:0] y,

    output logic hsync,
    output logic vsync,
    output logic active_video

);


logic [11:0] horizontal_counter = '0;
logic [10:0] vertical_counter = '0;
logic [3:0] x_counter = '0;
logic [3:0] y_counter = '0;


always_ff @(posedge pixel_clk)
begin

    if (reset)
    begin
        
        horizontal_counter <= 12'h000;
        vertical_counter <= 11'h000;
        x_counter <= 4'h0;
        y_counter <= 4'h0;
        x <= 8'h00;
        y <= 7'h00;
        hsync <= 1'b0;
        vsync <= 1'b0;
        active_video <= 1'b1;
    
    end
    else if (horizontal_counter >= 12'd1919)  
    begin  

        if ( (horizontal_counter >= 12'd2007) && (horizontal_counter <= 12'd2050) ) //if counter is in between these hortizontal numbers, flash hsync, hold x, update horizontal counter
        begin

            hsync <= 1'b1;
            x <= 8'd192;
            horizontal_counter <= horizontal_counter + 12'd1;
            active_video <= 1'b0;

        end
        else if (horizontal_counter == 12'd2199)
        begin

            if ( (vertical_counter >= 11'd1083) && (vertical_counter <= 11'd1087) )
            begin

                vsync <= 1'b1;    

            end
            else    
            begin  
      
                vsync <= 1'b0;

            end

            if (vertical_counter == 11'd1124)
            begin

                horizontal_counter <= 12'h000;
                vertical_counter <= 11'h000;
                x_counter <= 4'h0;
                y_counter <= 4'h0;
                x <= 8'h00;
                y <= 7'h00;
                hsync <= 1'b0;
                active_video <= 1'b1;

            end
            else
            begin

                hsync <= 1'b0;
                x <= 8'd0;
                horizontal_counter <= 12'd0;
                vertical_counter <= vertical_counter + 11'd1;
                x_counter <= 4'h0;


                if ((vertical_counter >= 11'd0) && (vertical_counter <= 11'd1078))
                begin 

                    active_video <= 1'b1;
                
                    if (y_counter == 4'd9)
                    begin

                        y <= y + 7'd1;
                        y_counter <= 4'd0;

                    end
                    else
                    begin

                        y_counter <= y_counter + 4'h1;

                    end
                end
                else if (vertical_counter == 11'd1079)
                begin

                    active_video <= 1'b0;
                    y <= 7'd108;

                end

            end

        end
        else
        begin

            hsync <= 1'b0;
            x <= 8'd192;
            horizontal_counter <= horizontal_counter + 12'd1;
            active_video <= 1'b0;

        end

  


    end
    else
    begin
        
        if (x_counter == 4'd9)
        begin

            x <= x + 8'd1;
            x_counter <= 4'd0;

        end
        else
        begin

            x_counter <= x_counter + 4'h1;

        end


        horizontal_counter <= horizontal_counter + 12'h001;
        
    end


end
endmodule
