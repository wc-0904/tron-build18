`default_nettype none

module draw_object
    (input logic clock, reset, center,
     input logic [9:0] row, col,
     input logic [3:0] p1_info, p2_info,
     output logic [7:0] red, green, blue);

    //logic for register to keep track of traces
    logic [599:0][599:0] p1_trace, p2_trace;
    logic en_trace;
    logic [9:0] new_x1, new_x2, new_y1, new_y2;
    logic [9:0] start_x1, start_x2, start_y1, start_y2;

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            p1_trace <= 'b0;
            p2_trace <= 'b0;
        end
        if (en_trace) begin //TODO: fix updates to trace based on the new values
            p1_trace <= p1_trace;
            p2_trace <= p2_trace;
        end
    end

    assign start_x1 = 10'd6;
    assign start_y1 = 10'd594;
    assign start_x2 = 10'd594;
    assign start_y2 = 10'd6;

    player_update p1(.en, .clock, .reset, .default,
                    .start_x1, .start_x2, .start_y1, .start_y2,
                    .);


endmodule: draw_object