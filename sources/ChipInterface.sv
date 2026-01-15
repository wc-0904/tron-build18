// Connects the logic of our game to our chip so that the game can be displayed
// Allows us to control whether the players are moving up, down, left, right

module chipInterface (
    input  logic        CLOCK_100,
    input  logic [ 3:0] BTN, 
    input  logic [15:0] SW,
    output logic [ 3:0] D2_AN, D1_AN,
    output logic [ 7:0] D2_SEG, D1_SEG,
    output logic        hdmi_clk_n, hdmi_clk_p,
    output logic [ 2:0] hdmi_tx_p, hdmi_tx_n
);

  logic clk_40MHz, clk_200MHz;
  logic locked, reset;


  //clock wizard configured with a 1x and 5x clock
  clk_wiz_0 clk_wiz (.clk_out1(clk_40MHz), .clk_out2(clk_200MHz), 
                    .reset, .locked(locked), .clk_in1(CLOCK_100));
  
  
  // Your code
  // Put your vga module here
  logic [9:0] row, col;
  logic [7:0] red, green, blue;
  logic [2:0] p1_info, p2_info;
  logic HS, VS, blank, BTN_reset, dflt;
  logic SW_lup, SW_lmove, SW_rup, SW_rmove;
  

  vga VGA(.clock_40MHz(clk_40MHz), .reset, .HS, .VS, .blank, .row, .col);
  
  Synchronizer syn1(.async(SW[15]), .clock(clk_40MHz), .sync(SW_lup));
  Synchronizer syn2(.async(SW[14]), .clock(clk_40MHz), .sync(SW_lmove));
  Synchronizer syn3(.async(SW[0]), .clock(clk_40MHz), .sync(SW_rup));
  Synchronizer syn4(.async(SW[1]), .clock(clk_40MHz), .sync(SW_rmove));
  Synchronizer syn5(.async(BTN[0]), .clock(clk_40MHz), .sync(BTN_reset));
  // Synchronizer syn6(.async(BTN[3]), .clock(clk_40MHz), .sync(serve));
  
  assign p1_info = 3'b000;
  assign p2_info = 3'b001;

//   Register #(4) r1(.en(en_trace), .clear(reset), .clock(clock), 
//                      .D(p1_info), .Q(p1_info_sync));

                     
//   draw_paddle dp(.reset(BTN_reset), .clock(clk_40MHz), .red(red_p),
//                 .green(green_p), .blue(blue_p), .*);
//   draw_ball db(.pad_y(new_pad_y), .reset(BTN_reset), .clock(clk_40MHz),
//               .red(red_b), .green(green_b), .blue(blue_b), .*);
//   gameFSM fsm(.clock(clk_40MHz), .reset(BTN_reset), .*);

  logic [7:0] red_o, green_o, blue_o, red_b, green_b, blue_b;

  draw_object dob(.clock(clk_40MHz), .red(red_o), .green(green_o), .blue(blue_o), .*);

  draw_border db(.red(red_b), .green(green_b), .blue(blue_b), .*);

//   EightSevenSegmentDisplays ssd(.CLOCK_100(clock_40MHz),
//                                 .reset,
//                                 .dec_points('0),
//                                 .blank(8'b1110_1110),
//                                 .HEX7('0),
//                                 .HEX6('0),
//                                 .HEX5('0),
//                                 .HEX4(left_score),
//                                 .HEX3('0),
//                                 .HEX2('0),
//                                 .HEX1('0),
//                                 .HEX0(right_score),
//                                 .*);

//   // display the flash state
//   Counter #(7) ct1(.en(count_up & flash_en), .load(0), .D(7'd0), .up(1),
//                   .clock(clk_40MHz), .clear(count_done), .Q(count_out));
//   MagComp #(7) mg1(.A(count_out), .B(end_val), 
//                   .AeqB(AeqB_d), .AgtB(AgtB_d));
//   assign count_done = AgtB_d | AeqB_d;  
//   // left score counter
//   Counter #(4) ct2(.en(score_l), .load(0), .D(4'd0), .up(1), 
//                   .clock(clk_40MHz), .clear(BTN_reset), .Q(left_score));
//   Counter #(4) ct3(.en(score_r), .load(0), .D(4'd0), .up(1), 
//                   .clock(clk_40MHz), .clear(BTN_reset), .Q(right_score));  
//   // if either left or right wins
//   Comparator #(4) cmp_r(.A(right_score), .B(4'd9), .AeqB(right_win));
//   Comparator #(4) cmp_l(.A(left_score), .B(4'd9), .AeqB(left_win));
//   assign game_over = left_win | right_win;  
  assign red = red_b | red_o;
  assign green = green_b | green_o;
  assign blue = blue_b | blue_o;

// Connect signals to the VGA to HDMI converter
// Make sure you connect your blank signal to the vde input
// Make sure you connect your VS signal to the vsync input
// Make sure you connect your HS signal to the hsync input
// Your red/green/blue signals go to the red/green/blue inputs


    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_40MHz),
        .pix_clkx5(clk_200MHz),
        .pix_clk_locked(locked),
  
        //Reset is active HIGH
        .rst(reset),

        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),

        .hsync(HS),
        .vsync(VS),
        .vde(~blank),

        //Differential outputs
        .TMDS_CLK_P(hdmi_clk_p),          
        .TMDS_CLK_N(hdmi_clk_n),          
        .TMDS_DATA_P(hdmi_tx_p),         
        .TMDS_DATA_N(hdmi_tx_n)          
    );
endmodule : chipInterface
