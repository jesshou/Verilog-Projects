`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jessica Hou
// 
// Create Date: 08/17/2026 04:59:10 PM
// Module Name: tb_switch_test
// Description: Writing a test bench before deploying on FPGA

// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// test bench does not include ports
module tb_switch_test;
    // creating inputs to the DUT
    reg [15:0] sw;
    reg btnC;
    
    // creating output from the DUT
    wire [15:0] led;
    
    // error counter
    integer error = 0;
    integer checks = 0;
    integer i;
    
    // instantiating DUT
    switch_test dut(sw, btnC, led);
    
    // helper function: comparing equivalency of two values 
    task assert_eq;
        input [15:0] actual;    // DUT's output
        input [15:0] expected;  // what DUT's output should be
        begin
            // start the check
            checks = checks + 1;
            
            // if input and output don't match
            if (actual !== expected) begin
                error = error + 1;
                $display("FAIL t=%0t ns | got %h, expected %h (btnC=%b led=%h)",
                $time, actual, expected, btnC, led);
            end
            else begin
                $display("PASS t=%0t ns | %h (btnC=%b led=%h)",
                $time, actual, btnC, led);
            end
        end
    endtask
    
    // starting logic
    initial begin
        // Button off - LEDs should stay dark
        btnC = 0;
        sw = 16'h0000; #1;  assert_eq(led,16'h0000); 
        sw = 16'hFFFF; #1;  assert_eq(led,16'h0000); 
        
        
        // Button on - LEDS turn on
        btnC = 1;
        sw = 16'h0000; #1;  assert_eq(led,16'h0000);
        sw = 16'hFFFF; #1;  assert_eq(led,16'hFFFF);
        sw = 16'h1234; #1;  assert_eq(led,16'h1234);
        $finish;
    end
endmodule
