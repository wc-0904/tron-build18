// `default_nettype none

module draw_border(
    input logic reset,
    input logic [9:0] row, col,
    output logic [7:0] red, green, blue);

    //logic for range checks
    logic left_v, right_v, top_h, bottom_h;

    //Left vertical
    RangeCheck #(10) rc0(.val(col), .low(10'd0),
                         .high(10'd104), .is_between(left_v));

    //Right vertical
    RangeCheck #(10) rc1(.val(col), .low(10'd696),
                         .high(10'd799), .is_between(right_v));

    //Top horizontal
    RangeCheck #(10) rc2(.val(row), .low(10'd0),
                         .high(10'd4), .is_between(top_h));

    //Bottom horizontal
    RangeCheck #(10) rc3(.val(row), .low(10'd596),
                         .high(10'd599), .is_between(bottom_h));

    always_comb begin
        if (left_v | right_v | top_h | bottom_h) begin
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

endmodule: draw_border