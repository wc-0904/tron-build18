module vga 
  #(parameter WIDTH = 11)
  (input logic clock_40MHz, reset,
  output logic HS, VS, blank,
  output logic [9:0] row, col);
  
  logic [WIDTH-1:0]hCount;
  logic v_disp, h_disp;
  logic v_end, h_end;
  logic [9:0]v_line;
  logic r_en;
  logic h_sync, v_sync;

  // hCount counter (counts individual clock cycles)
  assign hct_cond = reset | h_end;
  Counter #(WIDTH) cnt2(.en('1), .clear(hct_cond), .load('0), 
                        .up('1), .clock(clock_40MHz), .D('0), .Q(hCount));

  // v_line counter
  assign vline_cond = reset | (v_end & h_end);
  Counter #(10) cnt5(.en(h_end), .clear(vline_cond), .load('0), 
                        .up('1), .clock(clock_40MHz), .D('0), .Q(v_line));

  
  // check if hCount is within the horizontal Tdisp region  
  RangeCheck #(WIDTH) rc1(.val(hCount), .high(11'd1015), 
                          .low(11'd216), .is_between(h_disp));

  // horizontal sync signal                        
  RangeCheck #(WIDTH) rc2(.val(hCount), .high(11'd127), 
                          .low('0), .is_between(h_sync));

  // check if v_line is withing the vertical Tdisp region
  RangeCheck #(10) rc3(.val(v_line), .high(10'd626), 
                          .low(10'd27), .is_between(v_disp));

  // vertical sync signal
  RangeCheck #(10) rc4(.val(v_line), .high(10'd3), 
                          .low('0), .is_between(v_sync));

  // TODO: Remove this, lowkey never used
  RangeCheck #(10) rc5(.val(v_line), .high(10'd626), .low(10'd27), 
                       .is_between(r_en));

  // comparators to check if reached the end of an hCount of v_line cycle
  Comparator #(WIDTH) cmp1(.A(hCount), .B(11'd1055), .AeqB(h_end));
  Comparator #(10) cmp2(.A(v_line), .B(10'd627), .AeqB(v_end));

  // col and row are based on hCount and v_line respectively
  assign col = h_disp ? hCount - 11'd216 : '0;
  assign row = v_disp ? v_line - 11'd27 : '0;

  // the sync signals are active low 
  assign HS = ~h_sync;
  assign VS = ~v_sync;
  
  // blank anything not in the display region
  assign blank = ~(v_disp & h_disp);

endmodule: vga