// `default_nettype none

// Checks whether our given value is between our high and low input (inclusive)
module RangeCheck
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]val, high, low,
    output logic is_between);

    assign is_between = (val <= high) & (val >= low);
endmodule: RangeCheck

// Checks whether our given value is between low and delta + low (inclusive)
module OffsetCheck
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]val, delta, low,
    output logic is_between);

    logic [WIDTH-1:0] high;

    assign high = low + delta;

    RangeCheck #(.WIDTH(WIDTH)) u_RangeCheck (
        .val(val),
        .low(low),
        .high(high),
        .is_between(is_between)
    );

endmodule: OffsetCheck
