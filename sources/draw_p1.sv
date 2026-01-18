module draw_object (
    input  logic clock, reset, dflt,
    input  logic [9:0] row, col,
    input  logic [3:0] p1_info,
    output logic [7:0] red, green, blue
);

    logic [9:0] x1, y1;
    logic [9:0] next_x1, next_y1;
    logic [23:0] p1_vram_dout;

    // Trigger for movement and memory writing
    // en_cond is high at the very end of a screen refresh [cite: 23]
    logic en_cond, draw_cond;
    assign en_cond = (row == 599 && col == 799);
    // assign draw_cond = (next_x1 <= col) & (col < next_x1)
    //                 & ((row < next_y1) & (row >= next_y1));

    // BRAM 1: Player 1's Blue Traces
    logic [18:0] addra, addrb;
    assign addra = ({9'd0, next_y1} * 19'd800) + {9'd0, next_x1};
    assign addrb = ({9'd0, row} * 19'd800) + {9'd0, col};
    grid_mem p1_vram (
        .clka(clock), .clkb(clock),
        .addra, .addrb, 
        .dina(24'h0000FF), .wea(en_cond), .doutb(p1_vram_dout)
    );

    // Movement Logic [cite: 28, 31, 51]
    player_update p1_logic(.dflt, .player(1'b0), .start_x(x1),
                         .start_y(y1), .p_info(p1_info), .new_x(next_x1), .new_y(next_y1));


    always_ff @(posedge clock) begin
        if (reset) begin
            x1 <= 10'd16; y1 <= 10'd775; // Initial positions [cite: 45, 46]
        end else if (en_cond) begin
            x1 <= next_x1; y1 <= next_y1;
        end
    end

    // COMBINING THE TRACES FOR THE SCREEN
    // If Port B of BRAM1 says "Blue" OR Port B of BRAM2 says "Red", show that color.
    assign {red, green, blue} = p1_vram_dout;

endmodule

module player_update
  (input logic dflt, player, 
  input logic [9:0] start_x, start_y,
  input logic [3:0] p_info,
  output logic [9:0] new_x, new_y);

  logic [9:0] start_x1;
  logic [9:0] start_y1;

  assign start_x1 = 10'd16; // 'd0?
  assign start_y1 = 10'd575;

//   enum logic [2:0] {UP = 3'b000, DOWN = 3'b001, LEFT = 3'b010, RIGHT = 3'b011, STOP = 3'b100} ;

  always_comb begin
    if (dflt)
        {new_x, new_y} = {start_x1, start_y1};
    else begin
        case (p_info)
            4'b0001: {new_x, new_y} = {start_x, start_y - 10'd1};
            4'b0010: {new_x, new_y} = {start_x, start_y + 10'd1};
            4'b0100: {new_x, new_y} = {start_x - 10'd1, start_y};
            4'b1000: {new_x, new_y} = {start_x + 10'd1, start_y};
            4'b1001: {new_x, new_y} = {start_x, start_y};
            default: {new_x, new_y} = {start_x, start_y};
        endcase
    end
  end

endmodule: player_update