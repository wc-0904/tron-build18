`default_nettype none

module draw_object
    (input logic clock, reset, default,
     input logic [9:0] row, col,
     input logic [3:0] p1_info, p2_info,
     output logic [7:0] red, green, blue);
    
    // only update when at bottom right edge of display
    logic en_cond;
    assign en_cond = (row == 10'd599) && (col == 10'd799);

    logic default; // signal to set back to default

    //logic for register to keep track of traces
    logic [149:0][199:0] p1_trace, p2_trace, new_p1_trace, new_p2_trace;
    logic [9:0] new_x1, new_x2, new_y1, new_y2;
    logic [9:0] start_x1, start_x2, start_y1, start_y2;

    assign start_x1 = 10'd6;
    assign start_y1 = 10'd594;
    assign start_x2 = 10'd594;
    assign start_y2 = 10'd6;

    // update and draw p1
    player_update p1(.en_cond, .clock, .reset, .default,
                    .start_x(start_x1), .start_y(start_y1), .p_info(p1_info),
                    .new_x(new_x1), .new_y(new_y1));

    OffsetCheck #(10) oc1(.val(row), .low(new_x1), 
                        .delta(10'd4), .is_between(p1_height));
    
    OffsetCheck #(10) oc2(.val(col), .low(new_y1), 
                        .delta(10'd4), .is_between(p1_width));

    // update and draw p2
    player_update p2(.en_cond, .clock, .reset, .default,
                    .start_x(start_x2), .start_y(start_y2), .p_info(p2_info),
                    .new_x(new_x2), .new_y(new_y2));
    
    //update the traces
    update_trace u1(.p1_trace, .p2_trace, 
                    .new_x1, .new_y1,
                    .new_x2, .new_y2,
                    .valid,
                    .new_p1_trace,
                    .new_p2_trace);

    //register to store the values
    always_ff @(posedge clock, posedge rest) begin
        if (reset) begin
            start_x1 <= 'b0;
            start_y1 <= 'b0;
            start_x2 <= 'b0;
            start_y2 <= 'b0;
            p1_trace <= 'b0;
            p2_trace <= 'b0;
        end
        if (en_cond & valid) begin
            start_x1 <= new_x1;
            start_y1 <= new_y1;
            start_x2 <= new_x2;
            start_y2 <= new_y2;
            p1_trace <= new_p1_trace;
            p2_trace <= new_p2_trace;
        end

    end
    
    // check for collision
    
    OffsetCheck #(10) oc3(.val(row), .low(new_x2), 
                        .delta(10'd4), .is_between(p2_height));
    
    OffsetCheck #(10) oc4(.val(col), .low(new_y2), 
                        .delta(10'd4), .is_between(p2_width));
    

endmodule: draw_object