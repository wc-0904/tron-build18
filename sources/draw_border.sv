// `default_nettype none

module draw_trace(
    input logic reset, clock,
    input logic [9:0] row, col,
    input logic [9:0] new_x1, new_y1, new_x2, new_y2,
    input logic en_cond,
    output logic [7:0] red, green, blue);

    logic [18:0] addra1, addra2, addrb;
    logic ena;
    logic dina;

    logic trace1, trace2; //bool to see if trace is there

    always_comb begin
        if (reset) begin
            dina = 1'b0;
            addra1 = {9'd0,row} * 19'd799 + {9'd0,col};
            addra2 = {9'd0,row} * 19'd799 + {9'd0,col};
        end
        else begin 
            dina = 1'b1;
            addra1 = {9'd0, new_y1} * 19'd799 + {9'd0, new_x1};
            addra2 = {9'd0, new_y2} * 19'd799 + {9'd0, new_x2};
        end
    
        addrb = {9'd0,row} * 19'd799 + {9'd0,col};
    end

    grid_mem mem1(.clka(clock), .addra(addra1), .dina(dina), .wea(1'b1), .ena(en_cond || reset),
                 .clkb(clock), .addrb(addrb), .doutb(trace1));
    
    grid_mem mem2(.clka(clock), .addra(addra2), .dina(dina), .wea(1'b1), .ena(en_cond || reset),
                 .clkb(clock), .addrb(addrb), .doutb(trace2));
    
    always_comb begin
        red = 8'h00;
        green = 8'h00;
        blue = 8'h00; 
        if (trace1) begin
            blue = 8'hFF;
        end
        else if (trace2) begin
            red = 8'hFF;
        end
    end

endmodule: draw_trace