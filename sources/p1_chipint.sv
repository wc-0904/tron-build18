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

  // Clock Wizard for HDMI/VGA timing
  clk_wiz_0 clk_wiz (
      .clk_out1(clk_40MHz), 
      .clk_out2(clk_200MHz), 
      .reset(reset), 
      .locked(locked), 
      .clk_in1(CLOCK_100)
  );
  
  // VGA Timing Signals
  logic [9:0] row, col;
  logic HS_raw, VS_raw, blank_raw, dflt;
  logic p1_bit3, p1_bit2, p1_bit1, p1_bit0;

  Synchronizer syn1(.async(SW[15]), .clock(clk_40MHz), .sync(p1_bit3));
  Synchronizer syn2(.async(SW[14]), .clock(clk_40MHz), .sync(p1_bit2));
  Synchronizer syn3(.async(SW[13]), .clock(clk_40MHz), .sync(p1_bit1));
  Synchronizer syn4(.async(SW[12]), .clock(clk_40MHz), .sync(p1_bit0));

  Synchronizer syn9(.async(BTN[0]), .clock(clk_40MHz), .sync(BTN_reset));
  
  vga VGA(
      .clock_40MHz(clk_40MHz), 
      .reset(reset), 
      .HS(HS_raw), 
      .VS(VS_raw), 
      .blank(blank_raw), 
      .row(row), 
      .col(col)
  );

  // --- THE CRITICAL BRAM DELAY ---
  // We must delay the timing signals by 1 clock cycle to match the BRAM's output delay.
  logic HS_del, VS_del, blank_del;
  
  always_ff @(posedge clk_40MHz) begin
      HS_del    <= HS_raw;
      VS_del    <= VS_raw;
      blank_del <= blank_raw;
  end

  // Game Logic and Rendering
  logic [7:0] red, green, blue;
  logic [3:0] p1_info;
  
  // Mapping buttons to direction info (similar to your original code)
  assign p1_info = {p1_bit3, p1_bit2, p1_bit1, p1_bit0};

  draw_object dob (
      .clock(clk_40MHz), 
      .reset(BTN_reset), 
      .dflt, // Default/Serve signal
      .row(row), 
      .col(col),
      .p1_info(p1_info), 
      .red(red), 
      .green(green), 
      .blue(blue)
  );

  // HDMI Transmitter
  hdmi_tx_0 vga_to_hdmi (
      .pix_clk(clk_40MHz),
      .pix_clkx5(clk_200MHz),
      .pix_clk_locked(locked),
      .rst(reset),
      .red(red), 
      .green(green), 
      .blue(blue),
      .hsync(HS_del),   // Use DELAYED HS
      .vsync(VS_del),   // Use DELAYED VS
      .vde(~blank_del), // Use DELAYED and Inverted Blank
      .TMDS_CLK_P(hdmi_clk_p), .TMDS_CLK_N(hdmi_clk_n),
      .TMDS_DATA_P(hdmi_tx_p), .TMDS_DATA_N(hdmi_tx_n)
  );

endmodule