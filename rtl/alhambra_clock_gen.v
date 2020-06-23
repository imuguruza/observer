`default_nettype none
module alhambra_clock_gen
  (input wire i_clk,
   output wire o_clk,
   output wire o_rst);

   wire [4:0]  clk;
   wire        locked;
   reg [9:0]   r;

   assign o_clk = clk[0];

   assign o_rst = r[9];

   always @(posedge o_clk)
     if (locked)
       r <= {r[8:0],1'b0};
     else
       r <= 10'b1111111111;
      /*
      $ icepll -i 12 -o 16
      F_PLLIN:    12.000 MHz (given)
      F_PLLOUT:   16.000 MHz (requested)
      F_PLLOUT:   15.938 MHz (achieved)
      FEEDBACK: SIMPLE
      F_PFD:   12.000 MHz
      F_VCO: 1020.000 MHz
      DIVR:  0 (4'b0000)
      DIVF: 84 (7'b1010100)
      DIVQ:  6 (3'b110)
      FILTER_RANGE: 1 (3'b001)
      */

      localparam  DIVR_val = 4'b0000;
      localparam  DIVF_val = 7'b1010100;
      localparam  DIVQ_val = 3'b110;
      localparam  FILTER_val = 3'b001;

      SB_PLL40_CORE #(
      		.FEEDBACK_PATH("SIMPLE"),
      		.DIVR(DIVR_val),
      		.DIVF(DIVF_val),
      		.DIVQ(DIVQ_val),
      		.FILTER_RANGE(FILTER_val)
      	) uut (
      		.LOCK(locked),
      		.RESETB(1'b1),
      		.BYPASS(1'b0),
      		.REFERENCECLK(i_clk),
      		.PLLOUTCORE(o_clk)
      		);
endmodule
