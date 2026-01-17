// `default_nettype none

module draw_trace(
    input logic reset, clock,
    input logic [9:0] row, col,
    input logic [9:0] new_x1, new_y1, new_x2, new_y2,
    input logic en_cond,
    output logic [7:0] red, green, blue);

    logic [18:0] addra, addrb;
    logic ena;

    logic trace; //bool to see if trace is there

    always_comb begin
        addra = {9'd0,new_x1} * 19'd799 + {9'd0,new_y1};
        addrb = {9'd0,row} * 19'd799 + {9'd0,col};
    end

    grid_mem mem(.clka(clock), .addra(addra), .dina(1'b1), .wea(1'b1), .ena(en_cond),
                 .clkb(clock), .addrb(addrb), .doutb(trace));
    
    always_comb begin
        if (trace) begin
            red = 8'hFF;
            green = 8'hFF;
            blue = 8'hFF;
        end
        else begin
            red = 8'h00;
            green = 8'h00;
            blue = 8'h00;                                                                                            ;
        end
    end

endmodule: draw_trace