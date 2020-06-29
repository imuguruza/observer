module collector_i2c
  (input wire 	     i_clk,
   input wire 	      i_rst,
   //---- I2C -----
   inout wire 	      io_sda,
   input wire 	      i_scl,
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

   //Problems with next assigments:
   // assign i_scl = scl_padoen_oe ? 1’bz : scl_pad_o;
   // assign io_sda = sda_padoen_oe ? 1’bz: sda_pad_o;
   //--------------------------------------------------//
   // assign scl_pad_i = i_scl;
   // assign sda_pad_i = io_sda;
   //Replace with:
   SB_IO #(
      .PIN_TYPE(6'b 1010_01),
      .PULLUP(1'b 1)
    ) io_pin_scl (
      .PACKAGE_PIN(i2c_temp_humidity_sen_scl),
      .OUTPUT_ENABLE(scl_padoen_oe),
      .D_OUT_0(scl_pad_o),
      .D_IN_0(scl_pad_i)
    );

    SB_IO #(
       .PIN_TYPE(6'b 1010_01),
       .PULLUP(1'b 1)
     ) io_pin_sda (
       .PACKAGE_PIN(i2c_temp_humidity_sen_sda),
       .OUTPUT_ENABLE(sda_padoen_oe),
       .D_OUT_0(sda_pad_o),
       .D_IN_0(sda_pad_i)
     );

   i2c_master_top #(.ARST_LVL (0)) i2c_top (

 		// wishbone interface
 		.wb_clk_i(i_clk),
 		.wb_rst_i(i_rst),
 		.arst_i(1'b1),
 		.wb_adr_i(i_wb_adr[4:2]),
 		.wb_dat_i(i_wb_dat[7:0]),
 		.wb_dat_o(rdt),
 		.wb_we_i(i_wb_we),
 		.wb_stb_i(i_wb_stb),
 		.wb_cyc_i(i_wb_stb),
 		.wb_ack_o(o_wb_ack),
 		.wb_inta_o(),

 		// i2c signals
 		.scl_pad_i(scl_pad_i),
 		.scl_pad_o(scl_pad_o),
 		.scl_padoen_o(sda_padoen_oe),
 		.sda_pad_i(sda_pad_i),
 		.sda_pad_o(sda_pad_o),
 		.sda_padoen_o(sda_padoen_oe)
 	);

endmodule
