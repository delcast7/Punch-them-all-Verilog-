// Part 2

module projectECE241(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	// Declare your inputs and outputs here
	input [9:0]SW;
	input [3:0]KEY;
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	///////

	wire resetn;
	assign resetn = KEY[0];
	wire [7:0]xreg;
	wire [6:0]yreg;
	
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	reg [7:0] x;
	reg [6:0] y;
	wire writeEn;
	
	wire [2:0]q;


	// Define the number of colours as well as the initial background		
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(q),
			.x(x),
			.y(y),
			.plot(SW[0]),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "screen.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	reg [9:0] xCounter, yCounter;
	wire [14:0]  mem_address;
		
	
	parameter C_VERT_TOTAL_COUNT = 10'd525;
	parameter C_HORZ_TOTAL_COUNT = 10'd800;
		
	always @(posedge CLOCK_50 or negedge resetn)
	begin
		if (!resetn)
			xCounter <= 10'd0;
		else if (xCounter_clear)
			xCounter <= 10'd0;
		else
		begin
			xCounter <= xCounter + 1'b1;
		end
	end
	assign xCounter_clear = (xCounter == (10'd799));

	/* A counter to scan vertically, indicating the row currently being drawn. */
	always @(posedge CLOCK_50 or negedge resetn)
	begin
		if (!resetn)
			yCounter <= 10'd0;
		else if (xCounter_clear && yCounter_clear)
			yCounter <= 10'd0;
		else if (xCounter_clear)		//Increment when x counter resets
			yCounter <= yCounter + 1'b1;
	end
	assign yCounter_clear = (yCounter == (10'd524)); 
		/* Convert the xCounter/yCounter location from screen pixels (640x480) to our
	 * local dots (160x120). Here we effectively divide x/y coordinate by 4,*/
	 always@(*) begin

			x = xCounter[9:2];
			y = yCounter[8:2];
   end
	
	vga_address_translator M0(
	.x(x),
	.y(y),
	
	.mem_address(mem_address)
	);
	defparam M0.RESOLUTION = "160x120";

game game1 (
	.address(mem_address),
	.clock(CLOCK_50),
	.data(2'b0),
	.wren(0),
	.q(q));
	

endmodule

