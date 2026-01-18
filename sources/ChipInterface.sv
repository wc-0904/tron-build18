// Connects the logic of our game to our chip so that the game can be displayed
// Allows us to control whether the players are moving up, down, left, right

module chipInterface (
    input  logic        CLOCK_100,
    input  logic [ 3:0] BTN, 
    input  logic [15:0] SW,
    input  logic PD1, PD2, PD3, PD4, PD5, PD6, PD7, PD8,
    output logic [15:0] LD,
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
  logic [3:0] p1_info, p2_info;
  logic HS, VS, blank, BTN_reset, dflt;
  logic SW_lup, SW_lmove, SW_rup, SW_rmove;
  

  vga VGA(.clock_40MHz(clk_40MHz), .reset, .HS, .VS, .blank, .row, .col);
  
//   Synchronizer syn1(.async(SW[15]), .clock(clk_40MHz), .sync(SW_lup));
//   Synchronizer syn2(.async(SW[14]), .clock(clk_40MHz), .sync(SW_lmove));
//   Synchronizer syn3(.async(SW[0]), .clock(clk_40MHz), .sync(SW_rup));
//   Synchronizer syn4(.async(SW[1]), .clock(clk_40MHz), .sync(SW_rmove));
  // Synchronizer syn6(.async(BTN[3]), .clock(clk_40MHz), .sync(serve));
  
//   assign p1_info = 3'b000;
//   assign p2_info = 3'b001;

  logic [7:0] red_o, green_o, blue_o;
  logic [7:0] red_t, green_t, blue_t;
  logic en_cond;
  logic [9:0] new_x1, new_x2, new_y1, new_y2;
  logic collided;
  logic pd[3:0];

  always_comb begin
    case ({pd1_sync, pd3_sync, pd4_sync, pd2_sync})
        4'b0001: en_update1 = 1'b1; // left
        4'b0010: en_update1 = 1'b1; //right
        4'b0100: en_update1 = 1'b1; //up
        4'b1000: en_update1 = 1'b1; //down
        default: begin
            en_update1 = 1'b0;
        end
    endcase

    case ({pd5_sync, pd7_sync, pd8_sync, pd6_sync})
        4'b0001: en_update2 = 1'b1; // left
        4'b0010: en_update2 = 1'b1; //right
        4'b0100: en_update2 = 1'b1; //up
        4'b1000: en_update2 = 1'b1; //down
        default: begin
            en_update2 = 1'b0;
        end
    endcase
  end

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
      p1_info <= {pd1_sync, pd3_sync, pd4_sync, pd2_sync};
    end
    else if (en_update2) begin
      p2_info = {pd5_sync, pd7_sync, pd8_sync, pd6_sync};
    end
  end


  // Player 1 and 2 Movement Connections
  // always_comb begin
  //   if (collided) begin
  //       p1_info = 4'b0;
  //       p2_info = 4'b0;
  //   end
  //   // else begin
  //   //     // p1_info = {p1_bit3, p1_bit2, p1_bit1, p1_bit0};
  //   //     p1_info = {pd1_sync, pd3_sync, pd4_sync, pd2_sync};
  //   //     // p2_info = {p2_bit3, p2_bit2, p2_bit1, p2_bit0};
  //   //     p2_info = {pd5_sync, pd7_sync, pd8_sync, pd6_sync};
  //   // end
  // end

  draw_trace dt(.reset(BTN_reset), .clock(clk_40MHz), .row, .col, 
                .red(red_t), .green(green_t), .blue(blue_t), .en_cond, 
                .collided, .*);

  draw_object dob(.clock(clk_40MHz), .red(red_o), .green(green_o), .blue(blue_o),
                  .reset(BTN_reset), .en_cond, .*);

  assign red = red_t;
  assign green = green_t;
  assign blue = blue_t;

  logic p1_bit3, p1_bit2, p1_bit1, p1_bit0,
        p2_bit3, p2_bit2, p2_bit1, p2_bit0,
        pd1_sync, pd2_sync, pd3_sync, pd4_sync,
        pd5_sync, pd6_sync, pd7_sync, pd8_sync;

  // Switch inputs
  Synchronizer syn1(.async(SW[15]), .clock(clk_40MHz), .sync(p1_bit3));
  Synchronizer syn2(.async(SW[14]), .clock(clk_40MHz), .sync(p1_bit2));
  Synchronizer syn3(.async(SW[13]), .clock(clk_40MHz), .sync(p1_bit1));
  Synchronizer syn4(.async(SW[12]), .clock(clk_40MHz), .sync(p1_bit0));
  Synchronizer syn5(.async(SW[3]), .clock(clk_40MHz), .sync(p2_bit3));
  Synchronizer syn6(.async(SW[2]), .clock(clk_40MHz), .sync(p2_bit2));
  Synchronizer syn7(.async(SW[1]), .clock(clk_40MHz), .sync(p2_bit1));
  Synchronizer syn8(.async(SW[0]), .clock(clk_40MHz), .sync(p2_bit0));

  // PMOD D I/O
  Synchronizer syn9(.async(PD1), .clock(clk_40MHz), .sync(pd1_sync));
  Synchronizer syn10(.async(PD2), .clock(clk_40MHz), .sync(pd2_sync));
  Synchronizer syn11(.async(PD3), .clock(clk_40MHz), .sync(pd3_sync));
  Synchronizer syn12(.async(PD4), .clock(clk_40MHz), .sync(pd4_sync));
  Synchronizer syn13(.async(PD5), .clock(clk_40MHz), .sync(pd5_sync));
  Synchronizer syn14(.async(PD6), .clock(clk_40MHz), .sync(pd6_sync));
  Synchronizer syn15(.async(PD7), .clock(clk_40MHz), .sync(pd7_sync));
  Synchronizer syn16(.async(PD8), .clock(clk_40MHz), .sync(pd8_sync));
  // assign pd = {pd4_sync, pd3_sync, pd2_sync, pd1_sync};

  // I/O Test
  gpio_test gt(.led(LD[7:0]), .pd_port({pd4_sync, pd3_sync, pd2_sync, pd1_sync,
                                        pd8_sync, pd7_sync, pd6_sync, pd5_sync}));

  // Reset button
  Synchronizer syn17(.async(BTN[0]), .clock(clk_40MHz), .sync(BTN_reset));

  logic en_update1, en_update2;

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

    logic [6:0] h0, h1, h2, h3, h4, h5, h6, h7;
    logic [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    BCDtoSevenSegment b0(.bcd(p1_info[3:0]), .segment(h0)),
                    b1(.bcd({3'b0,en_update1}), .segment(h1)),
                    b2(.bcd(p2_info[3:0]), .segment(h2)),
                    b3(.bcd({3'b0, en_update2}), .segment(h3)),
                    b4(.bcd('b0), .segment(h4)),
                    b5(.bcd('b0), .segment(h5)),
                    b6(.bcd('b0), .segment(h6)),
                    b7(.bcd('b0), .segment(h7));
    
    SSegDisplayDriver ssd(.dpoints(8'b0), .reset(1'b0), .clk(CLOCK_100), .*);

    //inverts the bits because displays are active low
    assign HEX0 = ~h0;
    assign HEX1 = ~h1;
    assign HEX2 = ~h2;
    assign HEX3 = ~h3;
    assign HEX4 = ~h4;
    assign HEX5 = ~h5;
    assign HEX6 = ~h6;
    assign HEX7 = ~h7;

endmodule : chipInterface

//module for Seven Segment Display
module SevenSegmentDisplay
    (input logic [3:0] BCD7, BCD6, BCD5, BCD4,
                       BCD3, BCD2, BCD1, BCD0,
     input logic [7:0] blank,
     output logic [6:0] HEX7, HEX6, HEX5, HEX4,
                        HEX3, HEX2, HEX1, HEX0);

    logic [6:0] h0, h1, h2, h3, h4, h5, h6, h7;

    //find which of the segments will be on if the LED is on
    BCDtoSevenSegment b0(.bcd(BCD0), .segment(h0)),
                      b1(.bcd(BCD1), .segment(h1)),
                      b2(.bcd(BCD2), .segment(h2)),
                      b3(.bcd(BCD3), .segment(h3)),
                      b4(.bcd(BCD4), .segment(h4)),
                      b5(.bcd(BCD5), .segment(h5)),
                      b6(.bcd(BCD6), .segment(h6)),
                      b7(.bcd(BCD7), .segment(h7));

    //if statements to see if the display is on or off
    //included not statements because LEDs are wired backwards
    assign HEX0 = (~blank[0]) ? ~h0: 7'd127;
    assign HEX1 = (~blank[1]) ? ~h1: 7'd127;
    assign HEX2 = (~blank[2]) ? ~h2: 7'd127;
    assign HEX3 = (~blank[3]) ? ~h3: 7'd127;
    assign HEX4 = (~blank[4]) ? ~h4: 7'd127;
    assign HEX5 = (~blank[5]) ? ~h5: 7'd127;
    assign HEX6 = (~blank[6]) ? ~h6: 7'd127;
    assign HEX7 = (~blank[7]) ? ~h7: 7'd127;

endmodule: SevenSegmentDisplay

//module to take in a number and returns the LEDs that should be on
module BCDtoSevenSegment
    (input logic [3:0] bcd,
     output logic [6:0] segment);
    
    always_comb begin
        case (bcd) //putting the segments
            4'b0000: segment = 7'b0111111; //0
            4'b0001: segment = 7'b0000110; //1
            4'b0010: segment = 7'b1011011; //2
            4'b0011: segment = 7'b1001111; //3
            4'b0100: segment = 7'b1100110; //4
            4'b0101: segment = 7'b1101101; //5
            4'b0110: segment = 7'b1111101; //6
            4'b0111: segment = 7'b0000111; //7
            4'b1000: segment = 7'b1111111; //8
            4'b1001: segment = 7'b1101111; //9
            4'b1010: segment = 7'b1110111; //A
            4'b1011: segment = 7'b1111100; //B
            4'b1100: segment = 7'b0111001; //C
            4'b1101: segment = 7'b1011110; //D
            4'b1110: segment = 7'b1111001; //E
            4'b1111: segment = 7'b1110001; //F
        default: segment = 7'b0;
        endcase
    end

endmodule: BCDtoSevenSegment

// Required in every 18-240 file, but commented out to prevent synthesis issues
// `default_nettype none

/*
 * This module should be interfaced with a combinational 7-Segment Display
 * module in order to display 8 BCD values upon the Boolean board. It is
 * intended to abstract away the sequential logic required to use the
 * 7-Segment Displays present on the Boolean board for 18-240 students.
 *
 * Date:   1/27/25
 * Author: Rudy Sorensen (rsorense)
 */

module SSegDisplayDriver (
  input  logic            clk,
  input  logic            reset,
  input  logic [6:0] HEX0,
  input  logic [6:0] HEX1,
  input  logic [6:0] HEX2,
  input  logic [6:0] HEX3,
  input  logic [6:0] HEX4,
  input  logic [6:0] HEX5,
  input  logic [6:0] HEX6,
  input  logic [6:0] HEX7,
  input  logic [7:0] dpoints,
  output logic [3:0] D1_AN,
  output logic [3:0] D2_AN,
  output logic [7:0] D1_SEG,
  output logic [7:0] D2_SEG
  );

  logic cycle_cnt_clr;
  logic index_cnt_en;
  logic [1:0] anode_index;
  logic [3:0] anode_index_onecold;
  logic [16:0] cycle_cnt;

  /*
   * This counter reset value should be calculated by hand using the frequency
   * of your source clock to achieve the target frequency of 250Hz to 10KHz.
   *
   * The lower limit to the frequency comes from the fact that the human eye
   * de-saturates after around 20ms, while the upper limit is derived from the
   * need for the display to be on for at least 100us so that the value can
   * actually be perceived.
   *
   * Since the Boolean board has a 100MHz clock, we will count to 100,000. This
   * means that each segment will be lit for 1ms and flashed again 3ms later
   * because we are cycling through 4 values for each segment.
   */

  localparam CNT_LIMIT = 17'd100_000;

  assign cycle_cnt_clr = cycle_cnt == CNT_LIMIT;
  assign index_cnt_en = cycle_cnt_clr;

  SSDCounter #(17) cycle_cntr (
    .clk,
    .reset,
    .clr(cycle_cnt_clr),
    .cnt(cycle_cnt),
    .en(1'b1)
    );

  SSDCounter #(2) index_cntr (
    .clk,
    .reset,
    .clr(1'b0),
    .cnt(anode_index),
    .en(index_cnt_en)
    );

  OneColdDecoder #(4) anode_decode (
    .sel(anode_index),
    .out(anode_index_onecold)
    );

  /*
   *  AN3   AN1        AN3   AN1
   *  HX7   HX5        HX3   HX1
   *   | AN2 | AN0      | AN2 | AN0
   *   | HX6 | HX4      | HX2 | HX0
   * +-|--|--|--|--+  +-|--|--|--|--+
   * |             |  |             |
   * |  DISPLAY 1  |  |  DISPLAY 2  |
   * |             |  |             |
   * +-------------+  +-------------+
   *
   * The layout of the 7-Segment displays on the Boolean board is shown above to
   * aid understanding of the below block of code. Note that the HEX inputs are
   * not actually connected to the anodes. This visualization is just meant to
   * show the relationship between values from the HEX input and the anodes on
   * the 7-Segment displays.
   */

  always_comb begin
    D1_AN = anode_index_onecold;
    D2_AN = anode_index_onecold;

    case (anode_index)
      2'd0: begin
        D2_SEG = {~dpoints[0], HEX0};
        D1_SEG = {~dpoints[4], HEX4};
      end
      2'd1: begin
        D2_SEG = {~dpoints[1], HEX1};
        D1_SEG = {~dpoints[5], HEX5};
      end
      2'd2: begin
        D2_SEG = {~dpoints[2], HEX2};
        D1_SEG = {~dpoints[6], HEX6};
      end
      2'd3: begin
        D2_SEG = {~dpoints[3], HEX3};
        D1_SEG = {~dpoints[7], HEX7};
      end
    endcase

  end

endmodule : SSegDisplayDriver

module OneColdDecoder #(
  parameter NUM_OUTPUTS = 4
  ) (
  input  logic [$clog2(NUM_OUTPUTS)-1:0] sel,
  output logic [NUM_OUTPUTS-1:0] out
  );

  always_comb begin
    out = {NUM_OUTPUTS{1'b1}};
    out[sel] = 1'b0;
  end

endmodule : OneColdDecoder

module SSDCounter #(
  parameter WIDTH = 8
  ) (
  input  logic clk,
  input  logic reset,
  input  logic clr,
  input  logic en,
  output logic [WIDTH-1:0] cnt
  );

  always_ff @(posedge clk, posedge reset) begin
    if (reset)
      cnt <= '0;
    else if (clr)
      cnt <= '0;
    else if (en)
      cnt <= cnt + 1'b1;
  end

endmodule : SSDCounter