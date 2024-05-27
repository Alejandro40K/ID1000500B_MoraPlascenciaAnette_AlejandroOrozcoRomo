/******************************************************************
* Description
*
* TB for the op level of Convolution procesor
*
*
* Author:	Anette Mora Plascencia
* email :	TAE2024.28@cinvestav.mx
* Date  :	05/05/2024
******************************************************************/

`timescale 1ns / 1ns

module convolution_procesor_tb();

localparam DATA_WIDTH_MEMY_ADDR = 5;
localparam DATA_WIDTH_DATAY = 8;
localparam DATA_WIDTH_SIZEY = 5;
localparam DATA_WIDTH_DATAZ = 16;
localparam DATA_WIDTH_MEMZ_ADDR = 6;

logic clk  = 1'b0;
logic rstn;
logic start;

logic [DATA_WIDTH_DATAY-1:0] dataY;
logic [DATA_WIDTH_SIZEY-1:0] sizeY;
	  
wire [DATA_WIDTH_MEMY_ADDR-1:0] memY_addr;
wire [DATA_WIDTH_MEMZ_ADDR-1:0] memZ_addr;
wire [DATA_WIDTH_DATAZ-1:0] dataZ;
wire writeZ;
wire busy;
wire done;

wire [DATA_WIDTH_DATAZ-1:0] dataZ_read;

//integer mem_out_file;

/*CONVOLUTION PROCESOR INSTANCE*/
convolution_procesor #(
		.DATA_WIDTH_MEMY_ADDR 	(DATA_WIDTH_MEMY_ADDR),
		.DATA_WIDTH_DATAY 		(DATA_WIDTH_DATAY),
		.DATA_WIDTH_SIZEY		(DATA_WIDTH_SIZEY),
		.DATA_WIDTH_DATAZ 		(DATA_WIDTH_DATAZ),
		.DATA_WIDTH_MEMZ_ADDR	(DATA_WIDTH_MEMZ_ADDR)
)
DUT
(
		/**** Ctrl inputs ****/
		.clk 		(clk),
		.rstn		(rstn),
		.dataY		(dataY),
		.sizeY		(sizeY),
		.start		(start),
		.memY_addr 	(memY_addr),
		.memZ_addr	(memZ_addr),
		.dataZ		(dataZ),
		.writeZ		(writeZ),
		.busy		(busy),
		.done		(done)
);

/*MEMORY Y INSTANCE*/
simple_dual_port_ram_single_clk_sv #(
	.DATA_WIDTH (DATA_WIDTH_DATAY),
	.ADDR_WIDTH (DATA_WIDTH_MEMY_ADDR),
	.TXT_FILE ("C:/intelFPGA_lite/22.1std/TAE-SYSTEM/convolution_procesor/MemY.txt")
)
RAM_Y
(
		.clk			(clk),	
		.write_en_i		(1'd0),
		.write_addr_i	(5'd0),				
		.read_addr_i	(memY_addr),
		.write_data_i	(8'd0),
		.read_data_o	(dataY)
	   
);

/*MEMORY Z INSTANCE*/
simple_dual_port_ram_single_clk_sv #(
	.DATA_WIDTH (DATA_WIDTH_DATAZ),
	.ADDR_WIDTH (DATA_WIDTH_MEMZ_ADDR),
	.TXT_FILE ("C:/intelFPGA_lite/22.1std/TAE-SYSTEM/convolution_procesor/MemZ.txt")
)
RAM_Z
(
		.clk			(clk),	
		.write_en_i		(writeZ),
		.write_addr_i	(memZ_addr),				
		.read_addr_i	(6'd0),
		.write_data_i	(dataZ),
		.read_data_o	(dataZ_read)
);

//clock source
always #5 clk = ~clk;

initial begin
	sizeY = 5'd5;
	rstn = 1'b0;
	start = 1'b0;
	#10ns;
	rstn = 1'b1;
	#10ns;
	start = 1'b1;
end

endmodule