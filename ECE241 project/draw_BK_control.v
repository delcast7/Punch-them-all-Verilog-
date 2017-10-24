module draw_BK_control(
	 input clk,
    input resetn,
	 //input go(~KEY[3]),
	 output reg [9:0] xCounter, yCounter
    );
	 
	
    reg [2:0] current_state, next_state;

	 localparam	 S_LOAD_X        	= 3'd0,
                S_LOAD_Y        	= 3'd1,
                DRAW_SQUARE      = 3'd2;

    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
				
					S_LOAD_X: 			next_state = S_LOAD_Y; 		// Loop in current state until go signal goes low
					S_LOAD_Y: 			next_state = DRAW_SQUARE; 	// Loop in current state until go signal goes low
					DRAW_SQUARE: 		next_state = S_LOAD_X;
					 	 
            default:    next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
	always @(*)
	begin: enable_signals
		// By default make all our signals 0
		ld_x <= 1'b0;
		ld_y <= 1'b0;
		plotOut <= 1'b0;
		
		case (current_state)
			
			DRAW_SQUARE: begin
				plotOut <= 1'b1;
				end
				
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 
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
	assign xCounter_clear = (xCounter == (C_HORZ_TOTAL_COUNT-1));

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
	assign yCounter_clear = (yCounter == (C_VERT_TOTAL_COUNT-1)); 
	
	/* Convert the xCounter/yCounter location from screen pixels (640x480) to our
	 * local dots (160x120). Here we effectively divide x/y coordinate by 4,*/

   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
				
		  else
            current_state <= next_state;
    end // state_FFS
endmodule
