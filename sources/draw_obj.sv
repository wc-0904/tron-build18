// `default_nettype none
// typedef enum logic [2:0]
//   {UP = 3'b000, DOWN = 3'b001, LEFT = 3'b010, RIGHT = 3'b011, STOP = 3'b100}
//   player_dir_t;

module draw_object
    (input logic clock, reset, dflt,
     input logic [9:0] row, col,
     input logic [2:0] p1_info, p2_info,
     output logic [7:0] red, green, blue);
    
    // only update when at bottom right edge of display
    logic en_cond, valid, p2_height, p2_width, p1_height, p1_width;
    assign en_cond = (row == 10'd599) && (col == 10'd799);

    logic player1, player2; // signal to set back to default

    //logic for register to keep track of traces
    logic [149:0][199:0] p1_trace, p2_trace, new_p1_trace, new_p2_trace;
    logic [9:0] new_x1, new_x2, new_y1, new_y2;
    logic [9:0] start_x1, start_x2, start_y1, start_y2;

    assign player1 = 0;
    assign player1 = 1;

    // update p1
    player_update p1(.dflt, .player(player1),
                    .start_x(start_x1), .start_y(start_y1), .p_info(p1_info),
                    .new_x(new_x1), .new_y(new_y1));

    OffsetCheck #(10) oc1(.val(row), .low(new_x1), 
                        .delta(10'd4), .is_between(p1_height));
    
    OffsetCheck #(10) oc2(.val(col), .low(new_y1), 
                        .delta(10'd4), .is_between(p1_width));

    // update p2
    player_update p2(.dflt, .player(player2),
                    .start_x(start_x2), .start_y(start_y2), .p_info(p2_info),
                    .new_x(new_x2), .new_y(new_y2));
    
    //update the traces
    update_trace u1(.p1_trace, .p2_trace, 
                    .new_x1, .new_y1,
                    .new_x2, .new_y2,
                    .valid,
                    .new_p1_trace,
                    .new_p2_trace);

    //draw p1 and p2
    always_comb begin
        red = 8'h00;
        green = 8'h00;
        blue = 8'h00;
        
        if (p1_trace[row][col] == 1) begin
            red = 8'hFF;
        end
        if (p2_trace[row][col] == 1) begin
            blue = 8'hFF;
        end
    end

    //register to store the values
    always_ff @(posedge clock) begin
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

module player_update
  (input logic dflt, player, 
  input logic [9:0] start_x, start_y,
  input logic [2:0] p_info,
  output logic [9:0] new_x, new_y);

  logic [9:0] start_x1;
  logic [9:0] start_y1;
  logic [9:0] start_x2;
  logic [9:0] start_y2;

  assign start_x1 = 10'd6;
  assign start_y1 = 10'd594;
  assign start_x2 = 10'd594;
  assign start_y2 = 10'd6;
//   enum logic [2:0] {UP = 3'b000, DOWN = 3'b001, LEFT = 3'b010, RIGHT = 3'b011, STOP = 3'b100} ;

  always_comb begin
    if (dflt)
        if (player)
            {new_x, new_y} = {start_x2, start_y2};
        else
            {new_x, new_y} = {start_x1, start_y1};
    else begin
        case (p_info)
            3'b000: {new_x, new_y} = {start_x, start_y + 10'd2};
            3'b001: {new_x, new_y} = {start_x, start_y - 10'd2};
            3'b010: {new_x, new_y} = {start_x - 10'd2, start_y};
            3'b011: {new_x, new_y} = {start_x + 10'd2, start_y};
            3'b100: {new_x, new_y} = {start_x, start_y};
            default: {new_x, new_y} = {start_x, start_y};
        endcase
    end
  end

endmodule: player_update