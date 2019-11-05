/*
 mem = 00
 gpio = 01
 timer = 10
 FIFO = 11
 */
module emitter_mux
  (
   input wire 	      i_clk,
   input wire 	      i_rst,
   input wire [31:0]  i_wb_dbus_adr,
   input wire [31:0]  i_wb_dbus_dat,
   input wire [3:0]   i_wb_dbus_sel,
   input wire 	      i_wb_dbus_we,
   input wire 	      i_wb_dbus_cyc,
   output wire [31:0] o_wb_dbus_rdt,
   output wire 	      o_wb_dbus_ack,
   //RW
   output wire [31:0] o_wb_dmem_adr,
   output wire [31:0] o_wb_dmem_dat,
   output wire [3:0]  o_wb_dmem_sel,
   output wire 	      o_wb_dmem_we,
   output wire 	      o_wb_dmem_cyc,
   input wire [31:0]  i_wb_dmem_rdt,
   //W
   output wire 	      o_wb_gpio_dat,
   output wire 	      o_wb_gpio_cyc,
   //RW
   output wire [31:0] o_wb_timer_dat,
   output wire 	      o_wb_timer_we,
   output wire 	      o_wb_timer_cyc,
   input wire [31:0]  i_wb_timer_rdt,
   //R
   output wire [0:0]  o_wb_fifo_sel,
   output wire 	      o_wb_fifo_stb,
   input wire [9:0]   i_wb_fifo_rdt,
   input wire 	      i_wb_fifo_ack);

   parameter sim = 0;

   reg 		      ack;

   wire [1:0] 	  s = i_wb_dbus_adr[31:30];

   assign o_wb_dbus_rdt = !s[1] ? i_wb_dmem_rdt :
			  s[0]  ? {22'd0, i_wb_fifo_rdt} :
			  i_wb_timer_rdt;
   assign o_wb_dbus_ack = (s == 2'b11) ? i_wb_fifo_ack : ack;

   always @(posedge i_clk) begin
      ack <= 1'b0;
      if (i_wb_dbus_cyc & (s != 2'b11) & !ack)
	ack <= 1'b1;
      if (i_rst)
	ack <= 1'b0;
   end

   assign o_wb_dmem_adr = i_wb_dbus_adr;
   assign o_wb_dmem_dat = i_wb_dbus_dat;
   assign o_wb_dmem_sel = i_wb_dbus_sel;
   assign o_wb_dmem_we  = i_wb_dbus_we;
   assign o_wb_dmem_cyc = i_wb_dbus_cyc & (s == 2'b00);

   assign o_wb_gpio_dat = i_wb_dbus_dat[0];
   assign o_wb_gpio_cyc = i_wb_dbus_cyc & (s == 2'b01);

   assign o_wb_timer_dat = i_wb_dbus_dat;
   assign o_wb_timer_we  = i_wb_dbus_we;
   assign o_wb_timer_cyc = i_wb_dbus_cyc & (s == 2'b10);

   assign o_wb_fifo_sel = i_wb_dbus_sel[0];
   assign o_wb_fifo_stb = i_wb_dbus_cyc & (s == 2'b11);

   generate
      if (sim) begin
	 wire halt_en = (i_wb_dbus_adr[31:28] == 4'h9) & i_wb_dbus_cyc & o_wb_dbus_ack;

	 always @(posedge i_clk)
	   if(halt_en) begin
	      $display("Finito");
	      $finish;
	   end
      end
   endgenerate
endmodule
