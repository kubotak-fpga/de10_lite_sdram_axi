`default_nettype none

  module memif_top
    (
     input wire 	ref_clk, //100MHz
     input wire 	reset,
     input wire 	write_start_triger,
     input wire 	read_start_triger,
     //output wire 	local_init_done,

     //SDRAM Interface
     output wire [12:0] memory_mem_a,
     output wire [1:0] 	memory_mem_ba,

     output wire [0:0] 	memory_mem_cke,
     output wire [0:0] 	memory_mem_cs_n,

     output wire [0:0] 	memory_mem_ras_n,
     output wire [0:0] 	memory_mem_cas_n,
     output wire [0:0] 	memory_mem_we_n,

     inout wire [15:0] 	memory_mem_dq,
     output wire [1:0] 	memory_mem_dqm


     );



   //write addr chanel
   wire 		axi_awready_w0;
   wire 		axi_awvalid_w0;
   wire [7: 0] 		axi_awlen_w0;
   wire [24: 0] 	axi_awaddr_w0;

   //write data chanel
   wire 		axi_wvalid_w0;
   wire 		axi_wready_w0;
   wire 		axi_wlast_w0;
   wire [15: 0] 	axi_wdata_w0;

   //write response chanel
   wire 		axi_bresp_w0;
   wire 		axi_bvalid_w0;
   wire 		axi_bready_w0;
   
   wire 		aif_reset;
   

   axim_write_control u_axi_master_write_control
     (
      .clk(ref_clk),
      .reset(aif_reset),

      .start_triger(write_start_triger),
      //axi interface
      .axi_awready_in(axi_awready_w0),
      .axi_awvalid_out(axi_awvalid_w0),
      .axi_awlen_out(axi_awlen_w0),  //[7: 0]
      .axi_awaddr_out(axi_awaddr_w0),  //word address [24: 0]

      .axi_wready_in(axi_wready_w0),
      .axi_wvalid_out(axi_wvalid_w0),
      .axi_wdata_out(axi_wdata_w0), //[15: 0]
      .axi_wlast_out(axi_wlast_w0),

      .axi_bready_out(axi_bready_w0),  //always Hi
      .axi_bvaid_in(axi_bvalid_w0),
      .axi_bresp_in(axi_bresp_w0)



      );


   
   wire 		axi_arvalid_r0;
   wire 		axi_arready_r0;
   wire [7: 0] 		axi_arlen_r0;
   wire [24: 0] 	axi_araddr_r0;

   wire 		axi_rready_r0;  //set alway 1
   wire 		axi_rvalid_r0;
   wire [15: 0] 	axi_rdata_r0;

   wire 		axi_rresp_r0;
   wire 		axi_rlast_r0;
   

   axim_read_control u_axim_read_control
     (
      .clk(ref_clk),
      .reset(aif_reset),
      .start_triger(read_start_triger),
      
      //axi interface
      .axi_arready_in(axi_arready_r0),
      .axi_arvalid_out(axi_arvalid_r0),
      .axi_arlen_out(axi_arlen_r0), //[7: 0]
      .axi_araddr_out(axi_araddr_r0), //word address [24: 0]
      
      .axi_rready_out(axi_rready_r0), //always set 1
      .axi_rvalid_in(axi_rvalid_r0),
      .axi_rdata_in(axi_rdata_r0),
      .axi_rresp(axi_rresp_r0),  //No Use
      .axi_rlast(axi_rlast_r0)

      
      );

   

   //SDRAM
   sdram_qsys u_sdram_qsys
     (
      //Write Address
      .axi_simple_master_0_axm_m0_awaddr({axi_awaddr_w0, 1'b0}),  //  [25: 0] axi_simple_master_0_axm_m0.awaddr
      .axi_simple_master_0_axm_m0_awvalid(axi_awvalid_w0), // 
      .axi_simple_master_0_axm_m0_awready(axi_awready_w0), // 
      .axi_simple_master_0_axm_m0_awlen(axi_awlen_w0),   // [7: 0]

      .axi_simple_master_0_axm_m0_awprot(3'd0),  //[2: 0]
      .axi_simple_master_0_axm_m0_awsize(3'd1),  // [2: 0] , 2Byte
      .axi_simple_master_0_axm_m0_awburst(2'd1), // [1: 0] , address increment
      .axi_simple_master_0_axm_m0_awlock(1'b0),  
      .axi_simple_master_0_axm_m0_awcache(4'd3), // [3: 0], default3

      //Write Data
      .axi_simple_master_0_axm_m0_wdata(axi_wdata_w0),   //[15: 0] 
      .axi_simple_master_0_axm_m0_wlast(axi_wlast_w0),   //   
      .axi_simple_master_0_axm_m0_wvalid(axi_wvalid_w0),  //   
      .axi_simple_master_0_axm_m0_wready(axi_wready_w0),  //  

      //Write Response
      .axi_simple_master_0_axm_m0_bvalid(axi_bvalid_w0),  //    output
      .axi_simple_master_0_axm_m0_bready(axi_bready_w0),  // input
      .axi_simple_master_0_axm_m0_bresp(axi_bresp_w0),   // [1: 0] output

      //Read Adddress
      .axi_simple_master_0_axm_m0_arready(axi_arready_r0), //
      .axi_simple_master_0_axm_m0_arvalid(axi_arvalid_r0), //
      .axi_simple_master_0_axm_m0_araddr({axi_araddr_r0, 1'b0}),  //[25: 0]
      .axi_simple_master_0_axm_m0_arlen(axi_arlen_r0),   // [7: 0]

      
      .axi_simple_master_0_axm_m0_arprot(3'd0),  //[2: 0]
      .axi_simple_master_0_axm_m0_arcache(4'd3), // [3: 0]
      .axi_simple_master_0_axm_m0_arsize(3'd1),  // [2: 0]
      .axi_simple_master_0_axm_m0_arburst(2'd1), // [1: 0]
      .axi_simple_master_0_axm_m0_arlock(1'b0),  // 

      //Read Data
      .axi_simple_master_0_axm_m0_rdata(axi_rdata_r0),   //[15: 0]
      .axi_simple_master_0_axm_m0_rvalid(axi_rvalid_r0),  //
      .axi_simple_master_0_axm_m0_rready(axi_rready_r0),  //

      .axi_simple_master_0_axm_m0_rresp(axi_rresp_r0),   // [1: 0] 
      .axi_simple_master_0_axm_m0_rlast(axi_rlast_r0),   //

      .axi_simple_master_0_reset_reset(aif_reset), //outtput

      
      //SDR Interface
      .new_sdram_controller_0_wire_addr(memory_mem_a), // [12: 0] output
      .new_sdram_controller_0_wire_ba(memory_mem_ba), //  [1: 0] output
      .new_sdram_controller_0_wire_cas_n(memory_mem_cas_n), //  output
      .new_sdram_controller_0_wire_cke(memory_mem_cke), //    output       
      .new_sdram_controller_0_wire_cs_n(memory_mem_cs_n), //  output                  
      .new_sdram_controller_0_wire_dq(memory_mem_dq), //  [15: 0] inout
      .new_sdram_controller_0_wire_dqm(memory_mem_dqm), //  [1: 0] output
      .new_sdram_controller_0_wire_ras_n(memory_mem_ras_n), // output     
      .new_sdram_controller_0_wire_we_n(memory_mem_we_n), // output

      //clock
      .clk_clk(ref_clk), // input 		       
      .reset_reset_n(~reset)                   //input
      );

   




endmodule


`default_nettype wire

   
