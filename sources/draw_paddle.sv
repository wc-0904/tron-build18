// `default_nettype none


/** This module is in charge of determining where our padlle is at all times
    throughout our game. It changes the x and y coordinates of the paddle all. 
@input   row      The current row pixel of our vga
@input   col      The current col pixel of our vga
@input   pad_info       Vector containing paddle movement [left_move,
                         r_move, l_up, r_up]
@input   clock       clock_40Mhz
@input   reset       BTN[0] reset
@input   up_p        Update enable of our paddles
@input   center      Control signal for setting paddles to vertical center
@input   draw_p      Control signal if we want our paddles to show on screen
@output   red, green, blue    rgb values of our screen pixel
@output  new_pad_y      Currect y positions of our paddles

**/
module draw_paddle 
    (input logic [9:0]row, col,
    input logic [3:0]pad_info,
    input logic clock, reset,
    input logic up_p, center, draw_p,
    output logic [7:0]red, green, blue,
    output logic [19:0] new_pad_y);
    logic en_cond, color_cond, pos_cond;
    logic [3:0]pad_info_sync;
    logic [19:0]starting_y;
    logic [19:0]new_y;
    logic left_h, right_h, left_v, right_v;
    logic [23:0] rgb_out;
    logic in_left, in_right;
    logic [23:0]left_color, right_color;
    logic [23:0] inter_color;

    assign en_cond = (row == 10'd599) && (col == 10'd799);

    assign left_color = 24'hFFFF00; // Yellow
    assign right_color = 24'h00FFFF; // Cyan

    assign {starting_y[19:10], starting_y[9:0]} = {10'd275, 10'd275};

   // Syncing pad_info to clock
    Register #(4) r1(.en(en_cond), .clear(reset), .clock(clock), 
                     .D(pad_info), .Q(pad_info_sync));

   // Initializing module that updates paddle positions
    assign pos_cond = (up_p | center) & en_cond;
    pad_pos_update pu1(.pad_info(pad_info_sync), 
                       .en(pos_cond), 
                       .clock(clock), .reset, .starting_y, 
                       .new_y(new_pad_y), .center);
    
    // Left Paddle Check
    RangeCheck #(10) rc1(.val(col), .low(10'd40), 
                         .high(10'd43), .is_between(left_h));
    
    // Within y range of our left paddle
    OffsetCheck #(10) oc1(.val(row), .low(new_pad_y[19:10]), 
                         .delta(10'd48), .is_between(left_v));

    // Right Paddle Check
    RangeCheck #(10) rc2(.val(col), .low(10'd757), 
                         .high(10'd760), .is_between(right_h));

   // Within y range of our right paddle
    OffsetCheck #(10) oc2(.val(row), .low(new_pad_y[9:0]), 
                        .delta(10'd48), .is_between(right_v));

    // color assignment
    assign in_left = left_h & left_v;
    assign in_right = right_h & right_v;
    assign color_cond = (in_left | in_right) & draw_p;
    Mux2to1 #(24) m1(.I0(right_color), .I1(left_color), 
                     .S(in_left), .Y(inter_color));
    Mux2to1 #(24) m2(.I0(24'd0), .I1(inter_color), 
                  .S(color_cond), .Y(rgb_out));

    // assign the rgb values
    assign red = rgb_out[23:16];
    assign green = rgb_out[15:8];
    assign blue = rgb_out[7:0];

endmodule: draw_paddle


/** This module is the submodule which directly calculates and outputs the 
    new y coordinates of our paddles. Moves our paddles up or 5 pixels if
    they are moving and keeps them the same if otherwise.

@input starting_y    The initial dynamic y position of each of our paddles
@input pad_info      Vector containing paddle movement [left_move,
                         r_move, l_up, r_up]
@input en            Combination of en_condition and center an update 
                     paddle logic 
@input clock         clock_40Mhz
@input reset         BTN[0] reset
@input center        Control signal for setting paddles to vertical center
@output new_y        Updated y position of our paddles after moving
**/
module pad_pos_update
    (input logic [19:0]starting_y,
    input logic [3:0]pad_info, 
    input logic en, clock, reset, center,
    output logic [19:0]new_y);
    logic [9:0]l_old_y, r_old_y;
    logic [9:0]l_int_1, l_int_2, l_int_3, l_int_4, l_int_5, 
               r_int_1, r_int_2, r_int_3, r_int_4, r_int_5;
    logic l_up, r_up, l_move, r_move;
    logic [9:0]l_sub_val, r_sub_val, l_add_val, r_add_val;
    logic l_sub_sel, r_sub_sel, l_add_sel, r_add_sel;

    assign {l_old_y, r_old_y} = new_y;
    assign {l_move, r_move, l_up, r_up} = pad_info;

    // check left paddle edges (top and bottom)
    Comparator #(10) cmp1(.A(l_old_y), .B(10'd0), .AeqB(l_sub_sel));
    Mux2to1 #(10) mx1(.I0(10'd5), .I1(10'd0), .S(l_sub_sel), .Y(l_sub_val));

    MagComp #(10) cmp2(.A(l_old_y), .B(10'd550), .AgtB(l_add_sel));
    Mux2to1 #(10) mx2(.I0(10'd5), .I1(10'd0), .S(l_add_sel), .Y(l_add_val));

    // add and subtract with the correct values
    Adder #(10) a1(.cin('0), .A(l_old_y), .B(l_add_val), .sum(l_int_1));
    Subtracter #(10) s1(.bin('0), .A(l_old_y), .B(l_sub_val), .diff(l_int_2));

    Mux2to1 #(10) m1(.I0(l_int_2), .I1(l_int_1), .S(~l_up), .Y(l_int_3));
    Mux2to1 #(10) m2(.I0(l_old_y), .I1(l_int_3), .S(l_move), .Y(l_int_4));


    // Mux to center the balls
    Mux2to1 #(10) x1(.I0(l_int_4), .I1(starting_y[19:10]), 
                     .S(center), .Y(l_int_5));

    Register #(10) r1(.en(en), .clear(reset), .clock(clock), .D(l_int_5), 
                      .Q(new_y[19:10]));


    // check right paddle edges (top and bottom)
    Comparator #(10) cmp3(.A(r_old_y), .B(10'd0), .AeqB(r_sub_sel));
    Mux2to1 #(10) mx3(.I0(10'd5), .I1(10'd0), .S(r_sub_sel), .Y(r_sub_val));

    MagComp #(10) cmp4(.A(r_old_y), .B(10'd550), .AgtB(r_add_sel));
    Mux2to1 #(10) mx4(.I0(10'd5), .I1(10'd0), .S(r_add_sel), .Y(r_add_val));

    // add and subtract with correct values
    Adder #(10) a2(.cin('0), .A(r_old_y), .B(r_add_val), .sum(r_int_1));
    Subtracter #(10) s2(.bin('0), .A(r_old_y), .B(r_sub_val), .diff(r_int_2));

    Mux2to1 #(10) m3(.I0(r_int_2), .I1(r_int_1), .S(~r_up), .Y(r_int_3));
    Mux2to1 #(10) m4(.I0(r_old_y), .I1(r_int_3), .S(r_move), .Y(r_int_4));

    // Mux to center the paddles
    Mux2to1 #(10) x2(.I0(r_int_4), .I1(starting_y[9:0]), .S(center), 
                     .Y(r_int_5));

    Register #(10) r2(.en(en), .clear(reset), .clock(clock), .D(r_int_5), 
                      .Q(new_y[9:0]));
    
endmodule: pad_pos_update