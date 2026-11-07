// 4-to-1 Multiplexer Testbench - SystemVerilog
// 9 test cases with automatic verification

`timescale 1ns/1ps

module mux_4to1_tb();
    import mux_pkg::*;

    // Test signals
    logic [3:0] data_in;
    logic [1:0] select;
    logic       data_out;

    // DUT instantiation
    mux_4to1 dut (
        .data_in(data_in),
        .select(select),
        .data_out(data_out)
    );

    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("mux_4to1_sim.vcd");
        $dumpvars(0, mux_4to1_tb);
    end

    // Test stimulus and verification
    initial begin
        $display("=== 4-to-1 Multiplexer Simulation (SystemVerilog) ===");
        $display("Time\tdata_in\tselect\tdata_out\tExpected\tStatus");
        $display("-------------------------------------------------------");

        // Test Case 1: Select input 0
        test_case(4'b1010, 2'b00, 1'b0, "Select input 0");

        // Test Case 2: Select input 1
        test_case(4'b1010, 2'b01, 1'b1, "Select input 1");

        // Test Case 3: Select input 2
        test_case(4'b1010, 2'b10, 1'b0, "Select input 2");

        // Test Case 4: Select input 3
        test_case(4'b1010, 2'b11, 1'b1, "Select input 3");

        // Test Case 5: Changed data, select 0
        test_case(4'b0101, 2'b00, 1'b1, "Changed data, select 0");

        // Test Case 6: Changed data, select 1
        test_case(4'b0101, 2'b01, 1'b0, "Changed data, select 1");

        // Test Case 7: All inputs high
        test_case(4'b1111, 2'b00, 1'b1, "All inputs high, select 0");

        // Test Case 8: All inputs low
        test_case(4'b0000, 2'b11, 1'b0, "All inputs low, select 3");

        // Test Case 9: Rotating select pattern
        data_in = 4'b1100;
        for (int i = 0; i < 4; i++) begin
            select = i[1:0];
            #10;
            check_output(data_in[select], $sformatf("Rotating pattern, select %0d", i));
        end

        $display("-------------------------------------------------------");
        $display("=== Simulation Complete ===");
        #10 $finish;
    end

    // Task: Apply test case and verify
    task test_case(
        input logic [3:0] in,
        input logic [1:0] sel,
        input logic       expected,
        input string      description
    );
        data_in = in;
        select = sel;
        #10;
        check_output(expected, description);
    endtask

    // Task: Check output and display result
    task check_output(
        input logic expected,
        input string description
    );
        string status;
        if (data_out === expected) begin
            status = "✓ PASS";
        end else begin
            status = "✗ FAIL";
        end
        $display("%3d ns\t%b\t%b\t%b\t%b\t\t%s - %s",
                 $time, data_in, select, data_out, expected, status, description);
    endtask

endmodule
