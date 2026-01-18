// `default_nettype none

module draw_trace(
    input logic reset, clock,
    input logic [9:0] row, col,
    input logic [9:0] new_x1, new_y1, new_x2, new_y2,
    input logic en_cond,
    output logic [7:0] red, green, blue,
    output logic collided);

    logic [16:0] addra1, addra2, addrb;
    logic ena;
    logic dina;

    logic trace1, trace2; //bool to see if trace is there
    logic collided, collision1, collision2;

    always_ff @(posedge clock) begin
        if (reset) collided <= 'b0;
        else if (collision1 || collision2) collided <= 'b1;
    end

    always_comb begin
        if (reset) begin
            dina = 1'b0;
            addra1 = {7'd0,(row >> 2)} * 17'd399 + {7'd0,(col >> 2)};
            addra2 = {7'd0,(row >> 2)} * 17'd399 + {7'd0,(col >> 2)};
        end
        else begin 
            dina = 1'b1;
            addra1 = {7'd0, (new_y1 >> 2)} * 17'd399 + {7'd0, (new_x1 >> 2)};
            addra2 = {7'd0, (new_y2 >> 2)} * 17'd399 + {7'd0, (new_x2 >> 2)};
        end
    
        addrb = {7'd0,(row >> 2)} * 17'd399 + {7'd0,(col >> 2)};
    end

    //Player 1
    grid_mem mem1a(.clka(clock), .addra(addra1), .dina(dina), .wea(1'b1), .ena(en_cond || reset),
                  .clkb(clock), .addrb(addrb), .doutb(trace1));

    //memory to determine if player2 collided with player1
    grid_mem mem1b(.clka(clock), .addra(addra1), .dina(dina), .wea(1'b1), .ena(en_cond || reset),
                  .clkb(clock), .addrb(addra2), .doutb(collision2));
    
    //Player 2
    grid_mem mem2a(.clka(clock), .addra(addra2), .dina(dina), .wea(1'b1), .ena(en_cond || reset),
                   .clkb(clock), .addrb(addrb), .doutb(trace2));

    //memory to determine if player1 collided with player2
    grid_mem mem2b(.clka(clock), .addra(addra2), .dina(dina), .wea(1'b1), .ena(en_cond || reset),
                   .clkb(clock), .addrb(addra1), .doutb(collision1));
    
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