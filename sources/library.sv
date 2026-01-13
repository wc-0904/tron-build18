// `default_nettype none


module Comparator
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]A, B,
     output logic AeqB);

    assign AeqB = (A == B);
endmodule: Comparator

module MagComp
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]A, B,
     output logic AltB, AeqB, AgtB);

    assign AltB = (A < B);
    assign AeqB = (A == B);
    assign AgtB = (A > B);

endmodule: MagComp

module Adder
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]A, B,
    input logic cin,
    output logic cout,
    output logic [WIDTH-1:0]sum);
    logic [WIDTH:0]temp_sum;

    assign temp_sum = {1'b0, A} + {1'b0, B} + cin;
    assign cout = temp_sum[WIDTH];
    assign sum = temp_sum[WIDTH-1:0];

endmodule: Adder

module Subtracter
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]A, B,
    input logic bin,
    output logic bout,
    output logic [WIDTH-1:0]diff);
    logic [WIDTH:0]temp_diff;

    assign temp_diff = {1'b0, A} - {1'b0, B} - bin;
    assign bout = ~temp_diff[WIDTH];
    assign diff = temp_diff[WIDTH-1:0];

endmodule: Subtracter

module Multiplexer
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]I,
    input logic [$clog2(WIDTH)-1:0]S,
    output logic Y);
     
    assign Y = I[S];

endmodule: Multiplexer

module Mux2to1
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]I0, 
     input logic[WIDTH-1:0]I1, 
     input logic S,
     output logic [WIDTH-1:0]Y);
    always_comb begin
        case(S)
        1'b0: Y = I0;
        1'b1: Y = I1;
        endcase
    end
endmodule : Mux2to1



module Decoder
    #(parameter WIDTH = 16)
    (input logic [$clog2(WIDTH)-1:0]I,
    input logic en,
    output logic [WIDTH-1:0]D);
    
    always_comb begin
        if (en) begin
            D = 1 << I;
        end
        else begin
            D = '0;
        end
    end

endmodule: Decoder

module DFlipFlop
    (input  logic D, clock, reset_L, preset_L,
     output logic Q);


    always_ff @(posedge clock) begin
        if (reset_L == 1'b0)
            Q <= 1'b0;
        else if (preset_L == 1'b0)
            Q <= 1'b1;
        else
            Q <= D;
    end
endmodule: DFlipFlop

module Register
    #(parameter WIDTH = 16)
    (input logic en, clear, clock,
    input logic [WIDTH-1:0]D,
    output logic [WIDTH-1:0]Q);

    always_ff @(posedge clock) begin
        if (en) Q <= D;
        else if (clear) Q <= '0;
    end
endmodule: Register

module Counter
    #(parameter WIDTH = 16)
    (input logic en, clear, load, up, clock,
    input logic [WIDTH-1:0]D,
    output logic [WIDTH-1:0]Q);

    always_ff @(posedge clock) begin
        if (clear) Q <= 0;
        else if (load) Q <= D;
        else if (en)
            if (up)
                Q <= Q + 1;
            else if (~up)
                Q <= Q - 1;
    end
endmodule: Counter

module ShiftRegisterSIPO
    #(parameter WIDTH = 16)
    (input logic en, left, serial, clock,
     output logic [WIDTH-1:0]Q);

     always_ff @(posedge clock) begin
        if (en) begin
            if (left) Q <= {Q[WIDTH-2:0], serial};
            else Q <= {serial, Q[WIDTH-1:1]};
        end
     end
endmodule: ShiftRegisterSIPO

module ShiftRegisterPIPO
    #(parameter WIDTH = 16)
    (input logic en, left, load, clock,
    input logic [WIDTH-1:0]D,
    output logic [WIDTH-1:0]Q);

    always_ff @(posedge clock) begin
        if (en) begin
            if (left) Q <= {Q[WIDTH-2:0], 1'b0};
            else Q <= {1'b0, Q[WIDTH-1:1]};
        end
    end
endmodule: ShiftRegisterPIPO

module BarrelShiftRegister
    #(parameter WIDTH = 16)
    (input logic en, load, clock,
    input logic [1:0]by,
    input logic [WIDTH-1:0]D,
    output logic [WIDTH-1:0]Q);

    always_ff @(posedge clock) begin
        if (load) Q <= D;
        else if (en) begin
            Q <= Q << by;
        end
    end
endmodule: BarrelShiftRegister

module Synchronizer
    (input logic async, clock,
    output logic sync);
    logic temp;

    always_ff @(posedge clock) begin
        temp <= async;
        sync <= temp;
    end

endmodule: Synchronizer

module BusDriver
    #(parameter WIDTH = 16)
    (input logic en,
    input logic [WIDTH-1:0]data,
    output logic [WIDTH-1:0]buff,
    inout tri [WIDTH-1:0]bus);

    assign buff = data;

    assign bus = (en) ? data : 'z;
endmodule: BusDriver

module Memory
    #(parameter DW = 16,
                WIDTH = 256,
                AW = $clog2(WIDTH))
    (input logic re, we, clock,
    input logic [AW-1:0] addr,
    inout tri [DW-1:0] data);

    logic [DW-1:0] M[WIDTH];
    logic [DW-1:0] rData;
    assign data = (re) ? rData: 'z;

    always_ff @(posedge clock)
        if (we)
            M[addr] <= data;
    always_comb
        rData = M[addr];
endmodule: Memory


    

    


        






