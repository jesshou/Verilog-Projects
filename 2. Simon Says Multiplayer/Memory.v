//==============================================================================
// 64-entry 4-bit memory
//==============================================================================

module Memory
#(
	parameter N_ELEMENTS = 64,
	parameter ADDR_WIDTH = 6,
	parameter DATA_WIDTH = 4
)(
	// Inputs
	input                   clk,    // Clock
	input                   rst,    // Reset (All entries -> 0)
	input  [ADDR_WIDTH-1:0] r_addr, // Read Addresss
	input  [ADDR_WIDTH-1:0] w_addr, // Write Address
	input  [DATA_WIDTH-1:0] w_data, // Write Data
	input                   w_en,   // Write Enable

	// Outputs
	output [DATA_WIDTH-1:0] r_data  // Read Data
);

	// Memory Unit
	reg [DATA_WIDTH-1:0] mem[N_ELEMENTS:0];

	// Continuous Read
	assign r_data = mem[r_addr];

	// Synchronous Reset + Write
	genvar i;
	generate
		for (i = 0; i < N_ELEMENTS; i = i + 1) begin : wport
			always @(posedge clk) begin
				if (rst) begin
					mem[i] <= 0;
				end
				else if (w_en && w_addr == i) begin
					mem[i] <= w_data;
				end
			end
		end
	endgenerate

endmodule
