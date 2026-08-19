`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: Jessica Hou
// 
// Create Date: 08/17/2026 02:28:08 PM
// Design Name: First Project
// Module Name: switch_test
// Project Name: Physical Switch
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado
// Description: program that lights up 1-16 LEDS if center button and corresponding switches are turned on
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module switch_test(
    // creating connection to the switches
    input wire [15:0] sw,
    
    // creating connection to central button
    input wire        btnC,
    
    // creating connection to output LED
    output wire [15:0] led
    );
    
    // writing combinational logic
    assign led = btnC ? sw : 16'b0;
endmodule
