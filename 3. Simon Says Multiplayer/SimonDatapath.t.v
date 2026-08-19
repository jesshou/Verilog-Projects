//===============================================================================
// Testbench Module for Simon Datapath
//===============================================================================
`timescale 1ns/100ps

// Print an error message (MSG) if value ONE is not equal
// to value TWO.
`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
		end                                    \
	end #0

// Set the variable VAR to the value VALUE, printing a notification
// to the screen indicating the variable's update.
// The setting of the variable is preceeded and followed by
// a 1-timestep delay.
`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

// Cycle the clock up and then down, simulating
// a button press.
`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

module SimonDatapathTest;

	// Local Vars
	reg clk = 0;
	reg level = 0;
	reg [3:0] pattern = 4'b0000;
	// More vars here...
	reg i_rst = 0;
	reg i_inc = 0;
	reg j_rst = 0;
	reg j_inc = 0;
	reg level_ld = 0;
	reg mem_w_en = 0;
	reg pattern_leds_sel = 0;
	
	wire legal;
	wire match;
	wire j_lt;
	wire j_eq;
	wire [3:0] pattern_leds;
	
	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// Simon Control Module
	SimonDatapath dpath(
		.clk     (clk),
		.level   (level),
		.pattern (pattern),

		// More ports here...
		.i_rst (i_rst),
		.i_inc (i_inc),
		.j_rst (j_rst),
		.j_inc (j_inc),
		.level_ld (level_ld),
		.mem_w_en (mem_w_en),
		.pattern_leds_sel (pattern_leds_sel),
		
		.legal (legal),
		.match (match),
		.j_lt (j_lt),
		.j_eq (j_eq),
		
		.pattern_leds (pattern_leds)
	);

	// Main Test Logic
	initial begin
		// Your Test Logic Here
		// test 1 easy bode
		`SET (level, 0);
		`SET (pattern, 4'b1010);
		`ASSERT_EQ(legal, 0, "1010 ILLEGAL");
		`SET (pattern, 4'b0001);
		`ASSERT_EQ(legal, 1, "0001 legal");
		
		// test 2 hard mode
		`SET (level, 1);
		`SET (pattern, 4'b1010);
		`ASSERT_EQ(legal, 1, "1010 legal");
		// inc i_rst, j_rst, level_ld on
		i_rst = 1; `CLOCK i_rst = 0;
		j_rst = 1; `CLOCK j_rst = 0;
		mem_w_en = 1; `CLOCK mem_w_en = 0;
		$finish;
	end

endmodule
