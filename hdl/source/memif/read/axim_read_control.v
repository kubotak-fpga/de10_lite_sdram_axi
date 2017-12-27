`default_nettype none

  module axim_read_control
    (
     input wire 	 clk,
     input wire 	 reset,
     input wire 	 start_triger,
    
     //axi interface
     input wire 	 axi_arready_in,
     output wire 	 axi_arvalid_out,
     output wire [7: 0]  axi_arlen_out,
     output wire [24: 0] axi_araddr_out, //word address
    
     output wire 	 axi_rready_out, //always set 1
     input wire 	 axi_rvalid_in,
     input wire [15: 0]  axi_rdata_in,
     input wire 	 axi_rresp, //No Use
     input wire 	 axi_rlast


    
     );


   localparam BURST_SIZE = 8'd32;



   reg 			 start_meta;
   reg 			 start_1d;
   reg 			 start_2d;
   

   always @(posedge clk) begin
      start_meta <= start_triger;
      start_1d <= start_meta;
      start_2d <= start_1d;
   end

   wire det_posedge_start;
   assign det_posedge_start = start_1d & ~start_2d;

   localparam RD_READY = 3'd0;
   localparam RD_SET = 3'd1;
   localparam RD_EXE = 3'd2;
   localparam RD_BURST_COUNT = 3'd3;


   reg [2: 0] rseq_state;
   reg 	      axi_arvalid_reg;
   reg [7: 0] axi_arlen_reg;
   
   reg [7: 0] burst_cnt_internal;
   
   always @(posedge clk) begin

      if (reset) begin
	 rseq_state <= RD_READY;
	 
	 axi_arvalid_reg <= 1'b0;
	 burst_cnt_internal <= BURST_SIZE - 1'b1;
	 axi_arlen_reg <= BURST_SIZE - 1'b1;
	 
      end
      else begin

	 case (rseq_state)

	   RD_READY : begin

	      if (det_posedge_start) begin
		 rseq_state <= RD_SET;
	      end
	   end

	   RD_SET : begin

	      axi_arvalid_reg <= 1'b1;
	      rseq_state <= RD_EXE;
	   end

	   RD_EXE : begin

	      if (axi_arready_in == 1'b1) begin
		 axi_arvalid_reg <= 1'b0;
		 rseq_state <= RD_BURST_COUNT;
	      end
	   end

	   RD_BURST_COUNT : begin

	      if (axi_rvalid_in) begin

		 //for sim, no use
		 burst_cnt_internal <= burst_cnt_internal -1'b1;
		 
		 if (axi_rlast) begin
		    rseq_state <= RD_READY;
		 end
	      end
	   end

	 endcase
      end
   end // always @ (posedge clk)


   //output assign
   assign axi_arvalid_out = axi_arvalid_reg;
   assign axi_arlen_out = axi_arlen_reg;

   assign axi_araddr_out = 25'd0;

   assign axi_rready_out = 1'b1;
   

endmodule



`default_nettype wire
   
