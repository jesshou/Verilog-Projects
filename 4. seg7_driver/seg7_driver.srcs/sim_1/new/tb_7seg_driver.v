//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jessica Hou
// 
// Create Date: 08/19/2026 11:04:57 AM
// Design Name: Test Bench
// Module Name: tb_7seg_driver

// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_7seg_driver;
    // creating clock (10ns period)
    reg clk = 0;
    always #5 clk = ~clk;
    
    // creating DUT connections
    reg [15:0] sw;
    wire [6:0] seg;
    wire [3:0] an;
    
    // creating DUT
    seg7_driver DUT(clk, sw, seg, an);
    
    // error count
    integer errors = 0;
    integer checks = 0;
    integer i;
    
    // expected test values 1-16
    reg [6:0] expected [0:15];
    initial begin
        expected[0]  = 7'b1111110;  expected[1]  = 7'b0110000;
        expected[2]  = 7'b1101101;  expected[3]  = 7'b1111001;
        expected[4]  = 7'b0110011;  expected[5]  = 7'b1011011;
        expected[6]  = 7'b1011111;  expected[7]  = 7'b1110000;
        expected[8]  = 7'b1111111;  expected[9]  = 7'b1110011;
        expected[10] = 7'b1110111;  expected[11] = 7'b0011111;
        expected[12] = 7'b1001110;  expected[13] = 7'b0111101;
        expected[14] = 7'b1001111;  expected[15] = 7'b1000111;
    end

    // helper function to check seg
    task assert_seg;
        input [3:0] digits;         // store 16 digits
        input [6:0] actual;
        input [6:0] expected;
        begin
            checks = checks + 1;    // storing checks
            // begin error logic
            if (actual !== expected) begin
                errors = errors + 1;
                $display("FAILURE $0t | digit $h actual=$b expected=$b", $time, digits, actual, expected);
            end
            else begin
                 $display("PASS t=%0t | digit=%h  seg=%b", $time, digits, actual);
            end
        end
    endtask
    
    // helper function to check an
    task assert_an;
        input [6:0] actual;
        input [6:0] expected;
        begin
            checks = checks + 1;    // storing checks
            // begin error logic
            if (actual !== expected) begin
                errors = errors + 1;
                $display("FAILURE $0t | an=$b expected=$b", $time, actual, expected);
            end
            else begin
                 $display("PASS t=%0t | an=%b", $time, actual);
            end
        end
    endtask
    initial begin
        sw = 16'h0000;
        @(posedge clk);

        // test 1 cycling through all 16 hex digits in the 0th digit
        for (i = 0; i < 16; i = i + 1) begin
            sw = {12'h000, i[3:0]};
            @(posedge clk); #1;
            assert_seg(i[3:0], seg, expected[i[3:0]]);
        end

        // test 2 upper digits must affect digit
        sw = 16'hFFF5; @(posedge clk); #1;
        assert_seg(4'h5, seg, expected[5]);

        // test 3 more tests
        sw = 16'h000A; @(posedge clk); #1;
        assert_seg(4'hA, seg, expected[10]);

        // test 5 anode should be enabling digit 0
        assert_an(an, 4'b1110);

        $display("\n%0d checks, %0d failures", checks, errors);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("TESTS FAILED");
        $finish;
    end
    
 endmodule