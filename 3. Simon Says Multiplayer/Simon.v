//==============================================================================
// Simon Module for Simon Project
//==============================================================================

module Simon(
	input        pclk,
	input        rst,
	input        level,
	input  [3:0] pattern,

	output [3:0] pattern_leds,
	output [2:0] mode_leds
);

	// Declare local connections here
	// wire localconn1; ...

	// Datapath Outputs to Control
	// output    signal1;
	wire legal, match, j_lt, j_eq;
	wire i_rst, i_inc, j_rst, j_inc, level_ld, mem_w_en, pattern_leds_sel;

	// Datapath -- Add port connections
	SimonDatapath dpath(
		.clk           (pclk),
		.level         (level),
		.pattern       (pattern),
        .i_rst          (i_rst),
        .i_inc          (i_inc),
	    .j_rst          (j_rst),
	    .j_inc         (j_inc),
	    .level_ld      (level_ld),
	    .mem_w_en      (mem_w_en),
	    .pattern_leds_sel (pattern_leds_sel),
	    
	    .legal         (legal),
	    .match         (match),
	    .j_lt          (j_lt),
	    .j_eq          (j_eq),

        .pattern_leds   (pattern_leds)
	);

	// Control -- Add port connections
	SimonControl ctrl(
		.clk           (pclk),
		.rst           (rst),

		// ...
		.legal         (legal),
		.match        (match),
		.j_lt         (j_lt),
		.j_eq         (j_eq),
    
        .i_rst          (i_rst),
        .i_inc          (i_inc),
        .j_rst          (j_rst),
        .j_inc          (j_inc),
        .level_ld       (level_ld),
        .mem_w_en       (mem_w_en),
        .pattern_leds_sel (pattern_leds_sel),
        .mode_leds      (mode_leds)
);
endmodule
