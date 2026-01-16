// `default_nettype none

module update_trace (
    input logic [74:0][74:0] p1_trace, p2_trace,
    input logic [9:0] new_x1, new_y1,
    input logic [9:0] new_x2, new_y2,
    output logic valid,
    output logic [74:0][74:0] new_p1_trace, new_p2_trace);

    always_comb begin
        valid = 1'b0;
        new_p1_trace = p1_trace;
        new_p2_trace = p2_trace;

        if ((p1_trace[new_x1][new_y1] && p2_trace[new_x1][new_y1]) &&
            (p1_trace[new_x2][new_y2] && p2_trace[new_x2][new_y2])) begin
            valid = 1'b1;
            new_p1_trace[new_x1][new_y1] = 1'b1;
            new_p2_trace[new_x2][new_y2] = 1'b1;
        end

    end

endmodule: update_trace
