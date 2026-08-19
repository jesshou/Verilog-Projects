//===============================================================================
// Testbench Module for Simon
//===============================================================================
`timescale 1ns/100ps

`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
			errors = errors + 1;               \
		end                                    \
	end #0

`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

`define SHOW_MODE(MODE) $display("\nEntering Mode: %s\n-----------------------------------", MODE)

module SimonTest;

	// Local Vars
	reg clk = 0;
	reg sysclk = 0;
	reg rst = 0;
	reg level = 0;
	reg [3:0] pattern = 4'd0;
	wire [2:0] mode_leds;
	wire [3:0] pattern_leds;

	// Error Counts
	reg [7:0] errors = 0;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;


	// Simon Module
	Simon simon(
		.pclk         (clk),
		.rst          (rst),
		.level        (level),
		.pattern      (pattern),

		.pattern_leds (pattern_leds),
		.mode_leds    (mode_leds)
	);

	// Main Test Logic
	initial begin
		// Reset the game
		`SHOW_MODE("Unknown");
		`SET(rst, 1);
		`CLOCK;

		//-----------------------------------------------
		// Input Mode
		// ----------------------------------------------
		`SHOW_MODE("Input");
		`SET(rst, 0);

		// Write your test cases here!

		$display("\nTESTS COMPLETED (%d FAILURES)", errors);
		$finish;
	end

endmodule
