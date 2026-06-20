// Connects the logic of our game to our chip so that the game can be displayed
// Allows us to control whether the players are moving up, down, left, right

// `default_nettype none
module chipInterface (
    input  logic        CLOCK_100,
    input  logic [ 3:0] BTN, 
    input  logic [15:0] SW,
    input  logic        PD1, PD2, PD3, PD4, PD5, PD6, PD7, PD8,
    output logic [ 3:0] vga_r, vga_g, vga_b,
    output logic        vga_hs, vga_vs
);

  logic clk_40MHz;
  logic locked, reset;
  // assign reset = ~locked;
  clk_wiz_0 clk_wiz (.clk_out1(clk_40MHz),
                    .reset, .locked(locked), .clk_in1(CLOCK_100));


  // Misc logic variables
  logic [9:0] row, col;
  logic [7:0] red, green, blue;
  logic [3:0] p1_info, p2_info;
  logic HS, VS, blank, BTN_reset, dflt;
  logic en_update1, en_update2;
  logic [7:0] red_o, green_o, blue_o;
  logic [7:0] red_t, green_t, blue_t;
  logic en_cond;
  logic [9:0] new_x1, new_x2, new_y1, new_y2;
  logic collided;

  // P1 button logic variables
  logic btn_left, btn_right, btn_up, btn_down;
  logic [3:0] p1_buttons;

  // VGA output stage
  assign vga_r  = blank ? 4'h0 : red[7:4];
  assign vga_g  = blank ? 4'h0 : green[7:4];
  assign vga_b  = blank ? 4'h0 : blue[7:4];
  assign vga_hs = HS;
  assign vga_vs = VS;
  
  assign dflt = 1'b0;
    
  // Connect VGA module signals
  vga VGA(.clock_40MHz(clk_40MHz), .reset, .HS, .VS, .blank, .row, .col);



  always_comb begin
    // PMOD controls for P1, in case P1 should be controlled externally
    //case ({pd1_sync, pd3_sync, pd4_sync, pd2_sync})

    // Button Controls for P1, default
    case (p1_buttons)
        4'b0001: en_update1 = 1'b1; // left
        4'b0010: en_update1 = 1'b1; // right
        4'b0100: en_update1 = 1'b1; // up
        4'b1000: en_update1 = 1'b1; // down
        default: begin
            en_update1 = 1'b0;
        end
    endcase

    // PMOD controls for P2
    case ({pd5_sync, pd7_sync, pd8_sync, pd6_sync})
        4'b0001: en_update2 = 1'b1; // left
        4'b0010: en_update2 = 1'b1; // right
        4'b0100: en_update2 = 1'b1; // up
        4'b1000: en_update2 = 1'b1; // down
        default: begin
            en_update2 = 1'b0;
        end
    endcase
  end

  // Stop on Reset or Collision
  always_ff @(posedge clk_40MHz) begin
    if (BTN_reset || reset) begin
      p1_info <= 4'b0001;
      p2_info <= 4'b0010;
    end
    if (collided) begin
      p1_info <= 4'b0000;
      p2_info <= 4'b0000;
    end
    
    else if (en_update1) begin

      // PMOD for P1
      // p1_info <= {pd1_sync, pd3_sync, pd4_sync, pd2_sync};

      // Buttons for P1
      p1_info <= p1_buttons;

    end

    // PMOD for P2
    else if (en_update2) begin
      p2_info <= {pd5_sync, pd7_sync, pd8_sync, pd6_sync};
    end
  end


  draw_trace dt(.reset(BTN_reset), .clock(clk_40MHz), .row, .col, 
                .red(red_t), .green(green_t), .blue(blue_t), .en_cond, 
                .collided, .*);

  draw_object dob(.clock(clk_40MHz), .red(red_o), .green(green_o), .blue(blue_o),
                  .reset(BTN_reset), .en_cond, .*);

  assign red = red_t;
  assign green = green_t;
  assign blue = blue_t;

  logic pd1_sync, pd2_sync, pd3_sync, pd4_sync,
        pd5_sync, pd6_sync, pd7_sync, pd8_sync;


  // PMOD D I/O
  Synchronizer syn9(.async(PD1), .clock(clk_40MHz), .sync(pd1_sync));
  Synchronizer syn10(.async(PD2), .clock(clk_40MHz), .sync(pd2_sync));
  Synchronizer syn11(.async(PD3), .clock(clk_40MHz), .sync(pd3_sync));
  Synchronizer syn12(.async(PD4), .clock(clk_40MHz), .sync(pd4_sync));
  Synchronizer syn13(.async(PD5), .clock(clk_40MHz), .sync(pd5_sync));
  Synchronizer syn14(.async(PD6), .clock(clk_40MHz), .sync(pd6_sync));
  Synchronizer syn15(.async(PD7), .clock(clk_40MHz), .sync(pd7_sync));
  Synchronizer syn16(.async(PD8), .clock(clk_40MHz), .sync(pd8_sync));

  // Reset button
  Synchronizer syn17(.async(SW[0]), .clock(clk_40MHz), .sync(BTN_reset));
  
  // P1 Button Control Signals
  // Player 1 direction from onboard buttons (one-hot, same encoding as Pmod)
  // bit0=left, bit1=right, bit2=up, bit3=down

  Synchronizer synb0(.async(BTN[0]), .clock(clk_40MHz), .sync(btn_left));
  Synchronizer synb1(.async(BTN[1]), .clock(clk_40MHz), .sync(btn_right));
  Synchronizer synb2(.async(BTN[2]), .clock(clk_40MHz), .sync(btn_up));
  Synchronizer synb3(.async(BTN[3]), .clock(clk_40MHz), .sync(btn_down));
  assign p1_buttons = {btn_down, btn_up, btn_right, btn_left};

endmodule : chipInterface