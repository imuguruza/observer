module collector_i2c
  (input wire 	     i_clk,
   input wire 	      i_rst,
   //---- I2C -----
   output wire 	      sda,
   inout wire 	      scl,
   //--------------
   input wire [4:0]   i_wb_adr,
   input wire [31:0]  i_wb_dat,
   input wire 	      i_wb_we,
   input wire 	      i_wb_stb,
   output wire [31:0] o_wb_rdt,
   output wire 	      o_wb_ack);

   wire [7:0] 	     rdt;
   wire scl_padoen_oe;
   wire sda_padoen_oe;
   wire scl_pad_o;
   wire sda_pad_o;
   wire scl_pad_i;
   wire sda_pad_i;

   assign o_wb_rdt = {24'd0, rdt};

   //Taken from
   //https://opencores.org/websvn/filedetails?repname=i2c&path=%2Fi2c%2Ftrunk%2Fdoc%2Fi2c_specs.pdf
   assign scl = scl_padoen_oe ? 1’bz : scl_pad_o;
   assign sda = sda_padoen_oe ? 1’bz: sda_pad_o;
   assign scl_pad_i = scl;
   assign sda_pad_i = sda;

   i2c_master_top #(.ARST_LVL (0)) i2c_top (

 		// wishbone interface
 		.wb_clk_i(i_clk),
 		.wb_rst_i(1'b0),
 		.arst_i(i_rst),
 		.wb_adr_i(i_wb_adr[4:2]),
 		.wb_dat_i(i_wb_dat[7:0]),
 		.wb_dat_o(rdt),
 		.wb_we_i(i_wb_we),
 		.wb_stb_i(i_wb_stb),
 		.wb_cyc_i(i_wb_stb),
 		.wb_ack_o(o_wb_ack),
 		.wb_inta_o(),

 		// i2c signals
 		.scl_pad_i(scl),
 		.scl_pad_o(scl0_o),
 		.scl_padoen_o(scl0_oen),
 		.sda_pad_i(sda),
 		.sda_pad_o(sda0_o),
 		.sda_padoen_o(sda0_oen)
 	);

endmodule
