/**********************
* Description
*
* SystemVerilog FSM template with registered outputs
*
* Reset: Async active low
*
* Author: Anette Mora Plascencia
* email : TAE2024.28@cinvestav.mx
* Date  : 03/mayo/2024	
**********************/

module convolution_procesor_sv_fsm_reg (
   input  logic      clk,
   input  logic      rstn,
   input  logic      start_i,
   input  logic 	   comp1_i,
   input  logic 	   comp2_i,
   input  logic     	comp3_i,
   output logic 	   ctrl1_o,
   output logic 	   ctrl2_o,
   output logic 	   ctrl3_o,
   output logic 	   ctrl_addr_o,
   output logic 	   ctrl4_o,
   output logic 	   ctrl5_o,
   output logic 	   ctrl_j_o,
   output logic 	   ctrl6_o,
   output logic 	   ctrl7_o,
   output logic 	   ctrl_busy_o,
   output logic 	   ctrl_done_o,
   output logic 	   ctrl_writeZ_o,
   output logic		ctrl8_o
);

typedef enum logic [4:0] {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, XX='x} state_t; //For FSM states

 //typedef definitions
 state_t state;
 state_t next;

 //(1)State register
 always_ff@(posedge clk or negedge rstn)
     if(!rstn) state <= S1;                                            
     else      state <= next;

 //(2)Combinational next state logic
 always_comb begin
     next = XX;
     unique case(state)
			S1: if(start_i) 						next = S2;
					else  							next = S1;                        
			S2:           							next = S3;        
			S3:           							next = S4; 
			S4: if(comp1_i)						next = S5;
					else 								next = S16;
			S5: 										next = S6;
			S6: if(comp2_i && comp3_i) 		next = S7;
				else if (comp2_i && !comp3_i)	next = S12;
					else  							next = S13;
			S7: 										next = S8;
			S8:             						next = S9;
			S9:										next = S10;
			S10: 										next = S11;
			S11:										next = S12;
			S12:										next = S6;
			S13: 										next = S14;
			S14:										next = S15;
			S15:      								next = S4;
			S16: 										next = S17;
			S17: if(start_i)						next = S17;
					else								next = S1;
         default:        						next = XX;
     endcase
 end

 //(3)Registered output logic (Moore outputs)
 always_ff @(posedge clk or negedge rstn) begin
     if(!rstn) begin
		 ctrl1_o <= 1'b0;
		 ctrl2_o <= 1'b0;
		 ctrl3_o <= 1'b0;
		 ctrl_addr_o <= 1'b0;
		 ctrl4_o <= 1'b0;
		 ctrl5_o <= 1'b0;
		 ctrl_j_o <= 1'b0;
		 ctrl6_o <= 1'b0;
		 ctrl7_o <= 1'b0;
		 ctrl_busy_o <= 1'b0;
		 ctrl_done_o <= 1'b0;
		 ctrl_writeZ_o <= 1'b0;
		 ctrl8_o <= 1'b0;
     end
     else begin
		 ctrl1_o <= 1'b0;
		 ctrl2_o <= 1'b0;
		 ctrl3_o <= 1'b0;
		 ctrl_addr_o <= 1'b0;
		 ctrl4_o <= 1'b0;
		 ctrl5_o <= 1'b0;
		 ctrl_j_o <= 1'b0;
		 ctrl6_o <= 1'b0;
		 ctrl7_o <= 1'b0;
		 ctrl_busy_o <= 1'b1;
		 ctrl_done_o <= 1'b0;
		 ctrl_writeZ_o <= 1'b0;
		 ctrl8_o <= 1'b0;
             unique case(next)
					S1:  ctrl_busy_o <= 1'b0; 	
					S2:  ctrl1_o <= 1'b1; // ctrl_done_o/0 , ctrl_writeZ_o/0
					S3:  ctrl2_o <= 1'b1;
					S4: ; 
					S5:  ctrl3_o <= 1'b1;
					S6:  ctrl_busy_o <= 1'b1;	 	
               S7:  ctrl_addr_o <= 1'b1;
               S8:  ctrl_busy_o <= 1'b1;
					S9:  ctrl4_o <= 1'b1;
					S10: ctrl8_o <= 1'b1;
               S11: ctrl5_o <= 1'b1;
               S12: ctrl_j_o <= 1'b1;
               S13: ctrl6_o <= 1'b1;
					S14: ctrl_writeZ_o <= 1'b1;
               S15: ctrl7_o <= 1'b1; //ctrl_writeZ_o/0
					S16: begin 
							ctrl_busy_o <= 1'b0;
							ctrl_done_o <= 1'b1;
						  end
					S17: ctrl_busy_o <= 1'b0; //ctrl_done_o/0
             endcase
     end
 end
endmodule
