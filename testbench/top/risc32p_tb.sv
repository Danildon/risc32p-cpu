`timescale 1ns/1ps

import risc32p_types::*;

module risc32p_tb;

    // ==========================================
    // Clock / Reset
    // ==========================================
    logic clk;
    logic reset;
    logic int_signal;
    //logic [31:0] imm;
    logic [31:0] out_port;

    initial clk = 0;
    always #5 clk = ~clk;

    // ==========================================
    // DUT
    // ==========================================
    risc32p_cpu_top dut (
        .clk(clk),
        .reset(reset),
        .int_signal(int_signal),
        //.imm(imm),
        .out_port(out_port)
    );

    // ==========================================
    // Expected Output Sequence
    // ==========================================
    int expected_outputs[$] = '{10, 30, 5, 3};
    int output_index = 0;

    logic [31:0] last_out;

    // ==========================================
    // Output Monitor + Scoreboard
    // ==========================================
    always @(posedge clk) begin
        if (out_port !== last_out) begin

            $display("OUT detected: %0d", out_port);

            if (output_index >= expected_outputs.size()) begin
                $error("Too many OUT values! Unexpected output: %0d", out_port);
                $fatal;
            end

            if (out_port !== expected_outputs[output_index]) begin
                $error("Mismatch at index %0d", output_index);
                $error("Expected: %0d  Got: %0d",
                       expected_outputs[output_index], out_port);
                $fatal;
            end

            output_index++;
            last_out = out_port;
        end
    end

    // ==========================================
    // Detect HLT Instruction
    // ==========================================
    always @(posedge clk) begin
        if (dut.risc32p_mem_wb.opcode == RISC32P_OP_HLT) begin
            if (output_index == expected_outputs.size()) begin
                $display("");
                $display("======================================");
                $display("   ALL TESTS PASSED SUCCESSFULLY");
                $display("======================================");
                $finish;
            end else begin
                $error("Program halted early!");
                $fatal;
            end
        end
    end

    // ==========================================
    // Reset Sequence
    // ==========================================
    initial begin
        reset = 1;
        int_signal = 0;
        //imm = 0;

        #20;
        reset = 0;
    end

    // ==========================================
    // Timeout Protection
    // ==========================================
    initial begin
        #200000;
        $error("Simulation timeout — CPU did not halt.");
        $fatal;
    end
    
    //DEBUG
    
    always @(posedge clk) begin
        if (!reset) begin
            $display("PC=%0d  IF_instr=%h  OUT=%0d",
                dut.risc32p_pc_current,
                dut.risc32p_instr_fetch,
                //dut.risc32p_if_id.opcode,
                //dut.risc32p_mem_wb.opcode,
                dut.out_port
            );
        end
    end

endmodule