`timescale 1ns / 1ps
/*	
   ===================================================================
   Module Name  : Real adder
      
   Filename     : realAdder.v
   Type         : Verilog Module
   
   Description  : 
                  real adder with independent buses for real and imaginary parts.
                  Input    :  "DATA_WIDTH" length word in 2's complement representation.
                  Output   :  "DATA_WIDTH" length word in 2's complement representation.
                  
                  Designer must take care of overflow. 
                  We recommend to instantiate a "DATA WIDTH" length adder for "DATA WIDTH-1" length inputs.
                  
   -----------------------------------------------------------------------------
   Clocks      : -
   Reset       : -
   Parameters  :   
         NAME                         Comments                                            Default
         -------------------------------------------------------------------------------------------
         DATA_WIDTH              Number of data bits for inputs and outputs               22 
         -------------------------------------------------------------------------------------------
   Version     : 1.0
   Data        : 14 Nov 2018
   Revision    : -
   Reviser     : -		
   ------------------------------------------------------------------------------
      Modification Log "please register all the modifications in this area"
      (D/M/Y)  
      
   ----------------------
   // Instance template
   ----------------------
   realAdder
   #(
      .DATA_WIDTH_A    ()
		.DATA_WIDTH_B    ()
		.DATA_WIDTH_O    ()
   )
   "MODULE_NAME"
   (
       .re_A      (),
       .re_B      (),
       .re_out    ()
   );
*/


module convolution_procesor_realAdder
#(
   parameter DATA_WIDTH_A = 22,
   parameter DATA_WIDTH_B = 22,
   parameter DATA_WIDTH_O = 22
)(
    input signed  [DATA_WIDTH_A-1 : 0] re_A,
	 input signed [DATA_WIDTH_B-1 : 0] re_B,
    output [DATA_WIDTH_O-1 : 0] re_out
);

	
	wire signed [DATA_WIDTH_O-1: 0] temp_RE;
	
	assign temp_RE = re_A + re_B;
	
	assign re_out = temp_RE;
endmodule
