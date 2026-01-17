// `default_nettype none

module grid_mem(
    input logic clk,
    input logic [6:0] x_a, y_a, // 0-74 range, for our 75x75 grid
    input logic [23:0] din_a,   // 24-bit color (rgb)
    input logic we_a,           // Write_enable
    input logic [6:0] x_b, y_b,
    output logic [23:0] dout_b   // Output the color at this cell
);

//   75 x 75 = 5625 cells
    (* ram_style = "block" *) logic [23:0] mem [0:5625];

    always_ff @(posedge clk) begin
        // Port A, write the trace color
        if (we_a)
            mem[(y_a * 7'd75) + x_a] <= din_a;
        
        // Port B, read for vga
        dout_b <= mem[(y_b * 7'd75) + x_b];
    end

endmodule: grid_mem

