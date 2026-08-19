`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jessica Hou
// 
// Create Date: 08/18/2026 12:02:15 PM
// Module Name: seg7_driver
// Project Name: 16-Bit Hex Readout on a Multiplexed 7-Segment Display
// Tool Versions: Vivado
// Description: Reads 16 switches on an FPGA board and shows their value in hex on a 4-digit display.

// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seg7_driver(
    // defining clock connection
    input wire clk,

    // defining input switch wire
    input wire [15:0] sw,
    
    // defining variable to dictate led segments 
    output reg [6:0] seg,
    
    // defining variable to indicate which 1-4 led digit is currently displayed
    output wire [3:0] an
    );
    // define counter that syncs with clock
    reg [17:0] counter = 0;                 // shorten bit length to quicken flash rate
    
    // sequential logic to increment counter every	2.6 ms
    always @(posedge clk) counter <= counter + 1;
    
    // cycles through 2'b00, 2'b01, 2'b10, and 2'b11 every 655µs (per digit)
    wire [1:0]  sel = counter[17:16];    // shorten bit length to quicken flash rate
    
    // comb logic to assign FPGA output to clock counter
    assign an = (sel == 2'b00) ? 4'b1110:
                (sel == 2'b01) ? 4'b1101:
                (sel == 2'b10) ? 4'b1011:
                (sel == 2'b11) ? 4'b0111: 4'b1111;
          
    // choosing digit position based on mux       
    wire [3:0] sw_mux = (sel == 2'b00) ? sw[3:0]:
                (sel == 2'b01) ? sw[7:4]:
                (sel == 2'b10) ? sw[11:8]:
                (sel == 2'b11) ? sw[15:12]: 4'b1111;
    
    // assign output segment
    always @(*) begin
        case (sw_mux)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7:
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // b
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // d
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111;     
        endcase
    end
endmodule
