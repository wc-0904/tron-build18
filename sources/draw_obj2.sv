module draw_object (
    input  logic clock, reset, dflt,
    input  logic [9:0] row, col,
    input  logic [3:0] p1_info, p2_info,
    output logic [7:0] red, green, blue
);

    logic [9:0] x1, y1, x2, y2;
    logic [9:0] next_x1, next_y1, next_x2, next_y2;
    logic [23:0] p1_vram_dout, p2_vram_dout;
    
    // Grid Math: Scale 800x600 VGA to 75x75 Grid
    logic [6:0] vga_grid_x, vga_grid_y;
    assign vga_grid_x = (col >= 100 && col < 700) ? (col - 10'd100) >> 3 : 7'd0;
    assign vga_grid_y = (row < 600) ? row >> 3 : 7'd0;

    // Trigger for movement and memory writing
    // en_cond is high at the very end of a screen refresh [cite: 23]
    logic en_cond;
    assign en_cond = (row == 599 && col == 799);

    // BRAM 1: Player 1's Blue Traces
    grid_mem p1_vram (
        .clk(clock),
        .x_a((x1 - 10'd100) >> 3), .y_a(y1 >> 3), 
        .din_a(24'h0000FF), .we_a(en_cond), 
        .x_b(vga_grid_x), .y_b(vga_grid_y), .dout_b(p1_vram_dout)
    );

    // BRAM 2: Player 2's Red Traces
    grid_mem p2_vram (
        .clk(clock),
        .x_a((x2 - 10'd100) >> 3), .y_a(y2 >> 3), 
        .din_a(24'hFF0000), .we_a(en_cond), 
        .x_b(vga_grid_x), .y_b(vga_grid_y), .dout_b(p2_vram_dout)
    );

    // Movement Logic [cite: 28, 31, 51]
    player_update p1_logic(.dflt, .border_offset(10'd100), .player(1'b0), .start_x(x1),
                         .start_y(y1), .p_info(p1_info), .new_x(next_x1), .new_y(next_y1));
    player_update p2_logic(.dflt, .border_offset(10'd100), .player(1'b1), .start_x(x2),
                         .start_y(y2), .p_info(p2_info), .new_x(next_x2), .new_y(next_y2));

    always_ff @(posedge clock) begin
        if (reset) begin
            x1 <= 10'd116; y1 <= 10'd575; // Initial positions [cite: 45, 46]
            x2 <= 10'd675; y2 <= 10'd16;
        end else if (en_cond) begin
            x1 <= next_x1; y1 <= next_y1;
            x2 <= next_x2; y2 <= next_y2;
        end
    end

    // COMBINING THE TRACES FOR THE SCREEN
    // If Port B of BRAM1 says "Blue" OR Port B of BRAM2 says "Red", show that color.
    assign {red, green, blue} = p1_vram_dout | p2_vram_dout;

endmodule

module player_update
  (input logic dflt, player, 
  input logic [9:0] start_x, start_y, border_offset,
  input logic [3:0] p_info,
  output logic [9:0] new_x, new_y);

  logic [9:0] start_x1;
  logic [9:0] start_y1;
  logic [9:0] start_x2;
  logic [9:0] start_y2;

  assign start_x1 = 10'd16 + border_offset; // 'd0?
  assign start_y1 = 10'd575;
  assign start_x2 = 10'd775 - border_offset;
  assign start_y2 = 10'd16;
//   enum logic [2:0] {UP = 3'b000, DOWN = 3'b001, LEFT = 3'b010, RIGHT = 3'b011, STOP = 3'b100} ;

  always_comb begin
    if (dflt)
        if (player)
            {new_x, new_y} = {start_x2, start_y2};
        else
            {new_x, new_y} = {start_x1, start_y1};
    else begin
        case (p_info)
            4'b0001: {new_x, new_y} = {start_x, start_y - 10'd2};
            4'b0010: {new_x, new_y} = {start_x, start_y + 10'd2};
            4'b0100: {new_x, new_y} = {start_x - 10'd2, start_y};
            4'b1000: {new_x, new_y} = {start_x + 10'd2, start_y};
            // 4'b1001: {new_x, new_y} = {start_x, start_y};
            default: {new_x, new_y} = {start_x, start_y};
        endcase
    end
  end

endmodule: player_update