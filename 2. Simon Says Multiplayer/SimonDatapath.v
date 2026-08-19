//==============================================================================
// Datapath for Simon Project
//==============================================================================

module SimonDatapath(
	// External Inputs
	input        clk,           // Clock
	input        level,         // Switch for setting level
	input  [3:0] pattern,       // Switches for creating pattern

	// Datapath Control Signals
	// input     control1;
	input i_rst,
	input i_inc,
	input j_rst,
	input j_inc,
	input level_ld,
	input mem_w_en,
	input pattern_leds_sel,

	// Datapath Outputs to Control
	// output    signal1;
	output legal,
	output match,
	output j_lt,
	output j_eq,

	// External Outputs
	// output [3:0] pattern_leds   // LED outputs for pattern
	output [3:0] pattern_leds
);

	// Declare Local Vars Here
	reg [6:0] i; // number of patterns stored
	reg [5:0] j; // index of pattern
	reg level_stored;
	
	wire [6:0] last_val = i-7'd1; // storing last pattern
	wire [3:0] r_data;
	
	// check if legal in easy mode
	assign legal = level_stored | (pattern == 4'b0001) || (pattern == 4'b0010) || (pattern == 4'b0100) || (pattern == 4'b1000);
    assign match = (pattern == r_data);
    assign j_lt = ({1'b0, j} < last_val);
    assign j_eq = ({1'b0, j} == last_val);

	//----------------------------------------------------------------------
	// Internal Logic -- Manipulate Registers, ALU's, Memories Local to
	// the Datapath
	//----------------------------------------------------------------------

	always @(posedge clk) begin
		// Sequential Internal Logic Here
		if (i_rst)
		  i <= 7'd0;
		else if (i_inc)
		  i <= i + 7'd1;
		  
		if (j_rst)
		  j <= 6'd0;
		else if (j_inc)
		  j <= j + 6'd1;
	end

	// 64-entry 4-bit memory (from Memory.v) -- Fill in Ports!
	Memory mem(
		.clk     (clk),
		.rst     (1'b0),
		.r_addr  (j),
		.w_addr  (i[5:0]),
		.w_data  (pattern),
		.w_en    (mem_w_en),
		.r_data  (r_data)
	);

	//----------------------------------------------------------------------
	// Output Logic -- Set Datapath Outputs
	//----------------------------------------------------------------------

	always @( * ) begin
		// Output Logic Here
		if (level_ld)
		  level_stored <= level;
	end
	
	assign pattern_leds = pattern_leds_sel ? r_data : pattern;

endmodule
