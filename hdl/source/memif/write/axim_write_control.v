`default_nettype none

  module axim_write_control
    (
     input wire          clk,
     input wire          reset,

     input wire          start_triger,
     /*** axi interface ***/
     //Address Chanel
     input wire          axi_awready_in,
     output wire         axi_awvalid_out,
     output wire [7: 0]  axi_awlen_out,
     output wire [24: 0] axi_awaddr_out, //word address
     //Data Chanel
     input wire          axi_wready_in,
     output wire         axi_wvalid_out,
     output wire [15: 0] axi_wdata_out,
     output wire         axi_wlast_out,
     //Response Chanel
     output wire         axi_bready_out, //always Hi
     output wire         axi_bvaid_in,
     input wire [1: 0]   axi_bresp_in

    
     );

   localparam BURST_SIZE = 8'd32;
   //localparam BURST_SIZE = 8'd1;
   
   reg                   start_meta;
   reg                   start_1d;
   reg                   start_2d;
   

   always @(posedge clk) begin
      start_meta <= start_triger;
      start_1d <= start_meta;
      start_2d <= start_1d;
   end

   wire det_posedge_start;
   assign det_posedge_start = start_1d & ~start_2d;



   reg [15: 0] wdata;
   
   
   reg         axi_awvalid_reg;
   reg [7: 0]  axi_awlen_reg;

   reg         axi_wvalid_reg;
   reg         axi_wlast_reg;
   
   
   reg [7: 0]  burst_cnt_internal;


   //Top State Machine of Write Chanel
   reg         wseq_state;

   localparam WR_IDLE = 1'd0;
   localparam WR_WAIT = 1'd1;
   
   reg         start_flg_aw;
   reg         start_flg_w;
   
   
   always @(posedge clk) begin

      if (reset) begin
         wseq_state <= WR_IDLE;
      end
      else begin

         case (wseq_state)

           WR_IDLE : begin
              if (det_posedge_start) begin
                 start_flg_aw <= 1'b1;
                 start_flg_w <= 1'b1;

                 wseq_state <= WR_WAIT;
              end
              else begin
                 start_flg_aw <= 1'b0;
                 start_flg_w <= 1'b0;
              end
           end

           WR_WAIT : begin

              start_flg_aw <= 1'b0;
              start_flg_w <= 1'b0;

              if (axi_bvaid_in) begin
                 if (axi_bresp_in == 2'd0) begin
                    wseq_state <= WR_IDLE;               
                 end
              end
           end

           default : wseq_state <= WR_IDLE;
           
         endcase
         
      end
      
   end

   
   
   //State Machine of Address Chanel

   reg [1: 0]  state_aw;
   
   localparam IDLE_AW = 2'd0;
   localparam SET_AW = 2'd1;
   
   always @(posedge clk) begin

      if (reset) begin
         state_aw <= IDLE_AW;
         axi_awvalid_reg <= 1'b0;
      end
      else begin

         case (state_aw)

           IDLE_AW : begin
              
              if (start_flg_aw) begin
                 state_aw <= SET_AW;
                 axi_awvalid_reg <= 1'b1;
              end
           end

           SET_AW : begin
              
              if (axi_awready_in == 1'b1) begin
                 axi_awvalid_reg <= 1'b0;                
                 state_aw <= IDLE_AW;
              end
           end
           
           default : state_aw <= IDLE_AW;
           
         endcase // case (state_aw)
      end // else: !if(reset)
   end
   

   //State Machine of Data Chanel

   reg [1: 0] state_w;

   localparam IDLE_W = 2'd0;
   //localparam SET_W = 3'd1;
   localparam EXE_W = 2'd1;
   
   always @(posedge clk) begin

      if (reset) begin
         state_w <= IDLE_W;
         axi_wvalid_reg <= 1'b0;
      end
      else begin

         case (state_w)

           IDLE_W : begin

              burst_cnt_internal <= BURST_SIZE - 1'b1;
              axi_awlen_reg <= BURST_SIZE -1'b1;
              axi_wlast_reg <= 1'b0;
              axi_wvalid_reg <= 1'b0;


              if (start_flg_w) begin
                 state_w <= EXE_W;
                 axi_wvalid_reg <= 1'b1;
                 wdata <= 16'd100;
              end
              
           end // case: IDEL_W

           
           EXE_W : begin

              if (axi_wready_in == 1'b1) begin
                 if (burst_cnt_internal != 7'd0) begin
                    burst_cnt_internal <= burst_cnt_internal -1'd1;

                    wdata <= wdata + 1'b1;

                    if (burst_cnt_internal == 7'd1) begin
                       axi_wlast_reg <= 1'b1;
                    end
                 end
                 else begin
                    state_w <= IDLE_W;
                    axi_wvalid_reg <= 1'b0;
                    axi_wlast_reg <= 1'b0;
                 end
              end // if (axi_wready_in == 1'b1)
           end // case: EXE_W

           default : state_w <= IDLE_W;
           
         endcase // case (state_w)
      end // else: !if(reset)
   end // always @ (posedge clk)
   
   

   

   //output assign
   assign axi_awvalid_out = axi_awvalid_reg;
   assign axi_awlen_out = axi_awlen_reg;

   assign axi_wvalid_out = axi_wvalid_reg;

   assign axi_wdata_out = wdata;
   assign axi_wlast_out = axi_wlast_reg;
   
   assign axi_awaddr_out = 25'd0;

   assign axi_bready_out = 1'b1;
   
   
endmodule


`default_nettype wire
