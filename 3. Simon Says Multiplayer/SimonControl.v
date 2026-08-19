//==============================================================================
// Control Module for Simon Project
//==============================================================================

module SimonControl(
	// External Inputs
	input        clk,           // Clock
	input        rst,           // Reset

	// Datapath Inputs
	// input     localin1,
	input legal,
	input match,
	input j_lt,
	input j_eq,

	// Datapath Control Outputs
	// output    control1,
	output reg i_rst,
	output reg i_inc,
	output reg j_rst,
	output reg j_inc,
	output reg level_ld,
	output reg mem_w_en,
	output reg pattern_leds_sel,

	// External Outputs
	output reg [2:0] mode_leds
);

	// Declare Local Vars Here
	reg [1:0] state;
	reg [1:0] next_state;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// Declare State Names Here
	//localparam STATE_ONE = 2'd0;
	localparam STATE_ONE = 2'd0;
	localparam STATE_TWO = 2'd1;
	localparam STATE_THREE = 2'd2;
	localparam STATE_FOUR = 2'd3;

	// Output Combinational Logic
	always @( * ) begin
		// Set defaults
		// signal_one = 0; ...
		i_rst = 0; i_inc = 0; j_rst = 0; j_inc = 0;
		level_ld = 0; mem_w_en = 0; pattern_leds_sel = 0;
		
		if (rst) begin
		  i_rst = 1; j_rst = 1; level_ld = 1;
		end
		else case(state)
		  STATE_ONE: if (legal) begin
		      mem_w_en = 1; i_inc = 1; j_rst = 1;
		  end
		  STATE_TWO: begin
		      pattern_leds_sel = 1;
		      if (j_lt)   j_inc = 1;
		      else if (j_eq) j_rst = 1;
		  end
		  STATE_THREE: begin
		      if (match && j_lt)  j_inc = 1;
		      else if (!match)    j_rst = 1;
		  end
		  STATE_FOUR: begin
		      pattern_leds_sel = 1;
		      if (j_lt)   j_inc = 1;
		      else if (j_eq)  j_rst = 1;
		  end
	   endcase
		
		// Write your output logic here
		case (state)
		  STATE_ONE: mode_leds = LED_MODE_INPUT;
		  STATE_TWO: mode_leds = LED_MODE_PLAYBACK;
		  STATE_THREE: mode_leds = LED_MODE_REPEAT;
		  STATE_FOUR: mode_leds = LED_MODE_DONE;
		  default: mode_leds = LED_MODE_INPUT;
		endcase
		
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Write your Next State Logic Here
		// next_state = ???
		next_state = state;
		
		if (!rst) case (state)
	       STATE_ONE:  next_state = legal ? STATE_TWO : STATE_ONE;
	       STATE_TWO:  next_state = j_eq ? STATE_THREE : STATE_TWO;
	       STATE_THREE: begin
	           if (!match) next_state = STATE_FOUR;
	           else if (j_eq) next_state = STATE_ONE;
	           else next_state = STATE_THREE;
	       end
	       STATE_FOUR: next_state = STATE_FOUR;
	       default: next_state = STATE_ONE;
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Update state to reset state
			// state <= STATE_ONE;
			state <= STATE_ONE;
		end
		else begin
			// Update state to next state
			// state <= next_state;
			state <= next_state;
		end
	end

endmodule
