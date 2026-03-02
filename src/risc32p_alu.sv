// ==========================================================

// ============================================================
//  risc32p_alu.sv
//  Arithmetic Logic Unit for RISC32P CPU
//  Behavior-preserving port from original VHDL ALU
// ============================================================

module risc32p_alu (
    input  logic        clk,        // kept for compatibility (no state)
    input  logic [31:0] op_a,         // operand A
    input  logic [31:0] op_b,         // operand B
    input  logic [3:0]  alu_sel,      // ALU operation selector
    output logic [32:0] alu_result    // 33-bit result (carry included)
);

    logic [32:0] a_ext;
    logic [32:0] b_ext;

    // zero-extend operands
    assign a_ext = {1'b0, op_a};
    assign b_ext = {1'b0, op_b};

    always_comb begin
        alu_result = 33'b0;

        case (alu_sel)
            4'b0000: alu_result = a_ext;              // MOV A
            4'b0001: alu_result = b_ext;              // MOV B / Immediate
            4'b0010: alu_result = a_ext + b_ext;      // ADD
            4'b0011: alu_result = a_ext - b_ext;      // SUB
            4'b0100: alu_result = a_ext & b_ext;      // AND
            4'b0101: alu_result = ~b_ext;             // NOT
            4'b0110: alu_result = b_ext + 33'd1;      // INC
            4'b0111: alu_result = b_ext - 33'd1;      // DEC
            4'b1000: alu_result = 33'b0;              // SETC (handled in flags)
            default: alu_result = 33'b0;
        endcase
    end

endmodule


// ==========================================================
