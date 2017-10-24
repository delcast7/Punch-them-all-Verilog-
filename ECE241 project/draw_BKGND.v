module draw_BKGND (xPosition, yPosition, colourIn, xCounter, yCounter, resetn, load_x, load_y, clock, x, y,colourOut);
	input [7:0]xPosition;
	input [6:0]yPosition;
	input [2:0]colourIn;

	input resetn;
	input clock;
	
	output reg [7:0]x;
	output reg [6:0]y;
	output reg [2:0]colourOut;
	
	//assign colourOut =  colourIn;
	
	
	reg [7:0]xreg;
	reg [6:0]yreg;
	

	always@(*) begin

			x <= xPosition;
			y <= yPosition;
			colourOut =  colourIn;
   end
endmodule
