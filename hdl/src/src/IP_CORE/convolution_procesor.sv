/******************************************************************
* Description
*
* Top level for Convolution procesor
*
* Parameters: DATA_WIDTH_MEMY_ADDR  -> Width of memY_addr
			  DATA_WIDTH_DATAY -> Width of data Y
			  DATA_WIDTH_SIZEY -> Width of size of data Y
			  DATA_WIDTH_DATAZ -> Width of data Z
			  DATA_WIDTH_MEMZ_ADDR -> Width of memZ_addr 
*
* Author:	Anette Mora Plascencia
* email :	TAE2024.28@cinvestav.mx
* Date  :	03/05/2024
******************************************************************/

module convolution_procesor #(
		parameter DATA_WIDTH_MEMY_ADDR 	= 5,
		parameter DATA_WIDTH_DATAY 		= 8,
		parameter DATA_WIDTH_SIZEY 		= 5,
		parameter DATA_WIDTH_DATAZ 		= 16,
		parameter DATA_WIDTH_MEMZ_ADDR 	= 6
)(
		/**** Ctrl inputs ****/
		input  logic		clk,
		input  logic     	rstn,
		/* Convolution procesor inputs */
		input  logic      [DATA_WIDTH_DATAY-1:0] dataY,
		input  logic 	   [DATA_WIDTH_SIZEY-1:0] sizeY,
		input  logic 	   start,
		/* Convolution procesor outputs */
		output logic 	   [DATA_WIDTH_MEMY_ADDR-1:0] memY_addr,
		output logic 	   [DATA_WIDTH_MEMZ_ADDR-1:0] memZ_addr,
		output logic 	   [DATA_WIDTH_DATAZ-1:0] dataZ,
		output logic 	   writeZ,
		output logic 	   busy,
		output logic 	   done
);

/*Parameter internos*/
parameter SIZEH_INT = 10;
parameter DATA_WIDTH_SIZEH = 5;
parameter DATA_WIDTH_DATAH = 8;
parameter DATA_WIDTH_MEMH_ADDR = 5;


/* wires FSM*/
wire comp1_i_wire;
wire comp2_i_wire;
wire comp3_i_wire;
wire ctrl1_o_wire;
wire ctrl2_o_wire;
wire ctrl3_o_wire;
wire ctrl_addr_o_wire; 
wire ctrl4_o_wire;
wire ctrl5_o_wire;
wire ctrl_j_o_wire;
wire ctrl6_o_wire;
wire ctrl7_o_wire;
wire ctrl8_o_wire;

/* wires STATE 2*/
wire [DATA_WIDTH_SIZEY-1:0] sizeY_temp_wire;

/* wires STATE 3*/
wire [DATA_WIDTH_SIZEH-1:0] sizeH_int_wire;
assign sizeH_int_wire = SIZEH_INT;
wire [5:0] adder_S3_wire;
wire [5:0] sub_S3_wire;
wire [5:0] tam_conv_wire;

/* wires STATE 7*/
wire [DATA_WIDTH_MEMZ_ADDR-1:0] sub_S7_wire;
wire [DATA_WIDTH_MEMZ_ADDR-1:0] memH_addr_wire;

/*wires STATE 8*/
wire [DATA_WIDTH_DATAH-1:0] dataH_wire;
wire [DATA_WIDTH_DATAY-1:0] dataY_temp_wire;

/*wires STATE 9*/
wire [DATA_WIDTH_DATAZ-1:0] mult_S9_wire;
wire [DATA_WIDTH_DATAZ-1:0] dataZ_temp_wire;
wire [DATA_WIDTH_DATAZ-1:0] adder_S9_wire;


/* wires STATE 10*/
wire [DATA_WIDTH_MEMY_ADDR-1:0] j_wire;
wire [DATA_WIDTH_MEMY_ADDR-1:0] adder_S10_wire;

/* wires STATE 12*/
wire [DATA_WIDTH_MEMZ_ADDR-1:0] i_wire;
wire [DATA_WIDTH_MEMZ_ADDR-1:0] adder_s12_wire;

/* wires STATE 15*/
wire [DATA_WIDTH_DATAZ-1:0] mult_S15_wire;

/*wires COMPARATORES*/
wire comp3_wire1;
wire comp3_wire2;


/** Instantiation FSM **/
convolution_procesor_sv_fsm_reg fsm (
   .clk 			(clk),
   .rstn 			(rstn),
   .start_i 		(start),
   .comp1_i 		(comp1_i_wire),
   .comp2_i 		(comp2_i_wire),
   .comp3_i 		(comp3_i_wire),
   .ctrl1_o 		(ctrl1_o_wire),
   .ctrl2_o 		(ctrl2_o_wire),
   .ctrl3_o 		(ctrl3_o_wire),
   .ctrl_addr_o 	(ctrl_addr_o_wire),
   .ctrl4_o 		(ctrl4_o_wire),
   .ctrl5_o 		(ctrl5_o_wire),
   .ctrl_j_o 		(ctrl_j_o_wire),
   .ctrl6_o 		(ctrl6_o_wire),
   .ctrl7_o 		(ctrl7_o_wire),
   .ctrl_busy_o 	(busy),
   .ctrl_done_o 	(done),
   .ctrl_writeZ_o (writeZ),
   .ctrl8_o			(ctrl8_o_wire)
);

/* STATE 2 */
convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_SIZEY)
) 
register_S2
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl1_o_wire),
	.data_i	(sizeY),
	.data_o	(sizeY_temp_wire)
);

/* STATE 3 */
convolution_procesor_realAdder
#(
   .DATA_WIDTH_A (DATA_WIDTH_SIZEH),
   .DATA_WIDTH_B (DATA_WIDTH_SIZEY),
   .DATA_WIDTH_O (6)
)
adder_S3
(
   .re_A	(sizeH_int_wire),
	.re_B	(sizeY_temp_wire),
   .re_out	(adder_S3_wire)
);

convolution_procesor_sub2
#(
   .DATA_WIDTH_A (DATA_WIDTH_MEMZ_ADDR),
   .DATA_WIDTH_B (1),
   .DATA_WIDTH_O (DATA_WIDTH_MEMZ_ADDR)
)
subtractor_S3
(
    .re_A	(adder_S3_wire),
	 .re_B	(1'b1),
    .re_out	(sub_S3_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_MEMZ_ADDR)
) 
register_S3
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl2_o_wire),
	.data_i	(sub_S3_wire),
	.data_o	(tam_conv_wire)
);

/*STATE 7*/
convolution_procesor_sub2
#(
   .DATA_WIDTH_A (DATA_WIDTH_MEMZ_ADDR),
   .DATA_WIDTH_B (DATA_WIDTH_MEMY_ADDR),
   .DATA_WIDTH_O (DATA_WIDTH_MEMZ_ADDR)
)
subtractor_S7
(
    .re_A	(i_wire),
	 .re_B	(j_wire),
    .re_out	(sub_S7_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_MEMZ_ADDR)
) 
register_H_S7
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl_addr_o_wire),
	.data_i	(sub_S7_wire),
	.data_o	(memH_addr_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_MEMY_ADDR)
) 
register_Y_S7
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl_addr_o_wire),
	.data_i	(j_wire),
	.data_o	(memY_addr)
);

/*STATE 8*/
convolution_procesor_simpleROM #(
	.DATA_WIDTH (DATA_WIDTH_DATAH),
	.ADDR_WIDTH (DATA_WIDTH_MEMH_ADDR),
	.TXT_FILE ("/home/anette/intelFPGA_lite/22.1std/quartus/HDL/txt/MemH.txt")
)
mem_rom
(
	.clk			(clk),		
	.read_addr_i	(memH_addr_wire[4:0]),
	.read_data_o	(dataH_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_DATAY)
) 
register_S8
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl4_o_wire),
	.data_i	(dataY),
	.data_o	(dataY_temp_wire)
);

/*STATE 9*/
convolution_procesor_mult2
#(
   .DATA_WIDTH_A (DATA_WIDTH_DATAY),
   .DATA_WIDTH_B (DATA_WIDTH_DATAH),
   .DATA_WIDTH_O (DATA_WIDTH_DATAZ)
)
multiplier_S9
(
   .re_A	(dataY_temp_wire),
	.re_B	(dataH_wire),
   .re_out	(mult_S9_wire)
);

convolution_procesor_realAdder
#(
   .DATA_WIDTH_A (DATA_WIDTH_DATAZ),
   .DATA_WIDTH_B (DATA_WIDTH_DATAZ),
   .DATA_WIDTH_O (DATA_WIDTH_DATAZ)
)
adder_S9
(
   .re_A	(mult_S15_wire),
	.re_B	(dataZ_temp_wire),
   .re_out	(adder_S9_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_DATAZ) 
) 
register_S9
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(ctrl3_o_wire),   
	.enh	(ctrl5_o_wire),
	.data_i	(adder_S9_wire),
	.data_o	(dataZ_temp_wire)
);

/*STATE 10*/
convolution_procesor_sum2
#(
   .DATA_WIDTH_A (1),
   .DATA_WIDTH_B (DATA_WIDTH_MEMY_ADDR),
   .DATA_WIDTH_O (DATA_WIDTH_MEMY_ADDR)
)
adder_S10
(
   .re_A	(1'b1),
	.re_B	(j_wire),
   .re_out	(adder_S10_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_MEMY_ADDR)
) 
register_S10
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(ctrl3_o_wire),   
	.enh	(ctrl_j_o_wire),
	.data_i	(adder_S10_wire),
	.data_o	(j_wire)
);

/*STATE 11*/
convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_MEMZ_ADDR)
) 
register_S11
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl6_o_wire),
	.data_i	(i_wire),
	.data_o	(memZ_addr)
);

/*STATE 12*/
convolution_procesor_sum2
#(
   .DATA_WIDTH_A (1),
   .DATA_WIDTH_B (DATA_WIDTH_MEMZ_ADDR),
   .DATA_WIDTH_O (DATA_WIDTH_MEMZ_ADDR)
)
adder_S12
(
   .re_A	(1'b1),
	.re_B	(i_wire),
   .re_out	(adder_s12_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_MEMZ_ADDR)
) 
register_S12_i
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(ctrl2_o_wire),   
	.enh	(ctrl7_o_wire),
	.data_i	(adder_s12_wire),
	.data_o	(i_wire)
);

convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_DATAZ)
) 
register_S12_dataZ
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl6_o_wire),
	.data_i	(dataZ_temp_wire),
	.data_o	(dataZ)
);

/*STATE 15*/
convolution_procesor_register
#(
	.DATA_WIDTH(DATA_WIDTH_DATAZ)
) 
register_S15
(
	.clk	(clk),
	.rstn	(rstn),
   .clrh	(1'b0),   
	.enh	(ctrl8_o_wire),
	.data_i	(mult_S9_wire),
	.data_o	(mult_S15_wire)
);

/* MODULOS DE COMPARACION*/
convolution_procesor_comparatorLessThan
#(
   .DATA_WIDTH_A (DATA_WIDTH_MEMZ_ADDR),
   .DATA_WIDTH_B (DATA_WIDTH_MEMZ_ADDR)
)
comparator_1
(
	.A_i			 (i_wire),
	.B_i			 (tam_conv_wire), 
	.A_less_than_B_o (comp1_i_wire)
);

convolution_procesor_comparatorLessThan
#(
   .DATA_WIDTH_A (DATA_WIDTH_MEMY_ADDR),
   .DATA_WIDTH_B (DATA_WIDTH_SIZEY)
)
comparator_2
(
	.A_i			 (j_wire),
	.B_i			 (sizeY_temp_wire), 
	.A_less_than_B_o (comp2_i_wire)
);

convolution_procesor_comparatorLessThan
#(
   .DATA_WIDTH_A (DATA_WIDTH_MEMZ_ADDR),
   .DATA_WIDTH_B (DATA_WIDTH_SIZEH)
)
comparator_3_lessthan
(
	.A_i			 (sub_S7_wire),
	.B_i			 (sizeH_int_wire), 
	.A_less_than_B_o (comp3_wire1)
);

convolution_procesor_comparatorGreaterIqualThan
#(
   .DATA_WIDTH_A (DATA_WIDTH_MEMZ_ADDR),
   .DATA_WIDTH_B (1)
)
comparator_3_greateriqual
(
	.A_i 				(sub_S7_wire),
	.B_i 				(1'b0), 
	.A_greater_than_B_o (comp3_wire2)
);

convolution_procesor_gateAND
#(
   .DATA_WIDTH (1)
)
comparator_3_and
(
   .re_A 	(comp3_wire1),
	.re_B 	(comp3_wire2),
   .re_out	(comp3_i_wire)
);

endmodule