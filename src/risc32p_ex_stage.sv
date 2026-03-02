// ==========================================================

// ============================================================
//  risc32p_ex_stage.sv
//  Execute stage for RISC32P CPU
//  Performs ALU ops, branch evaluation, and prepares EX/MEM
// ============================================================

import risc32p_types::*;

module risc32p_ex_stage (
    input  logic          clk,
    input  risc32p_id_ex_t id_ex_in,
    output risc32p_ex_mem_t ex_mem_out
);

    // ========================================================
    // Internal signals
    // ========================================================
    logic [3:0]  risc32p_alu_sel;
    logic        risc32p_modify_flags;

    logic [31:0] risc32p_alu_op_a;
    logic [31:0] risc32p_alu_op_b;
    logic [32:0] risc32p_alu_result;

    logic        risc32p_branch_taken;
    logic        risc32p_branch_flag;

    // ========================================================
    // ALU Control
    // ========================================================
    risc32p_alu_control u_alu_ctrl (
        .risc32p_opcode        (id_ex_in.opcode),
        .risc32p_alu_sel       (risc32p_alu_sel),
        .risc32p_modify_flags  (risc32p_modify_flags)
    );

    // ========================================================
    // ALU Operand Selection
    // ========================================================
    always_comb begin
        risc32p_alu_op_a = id_ex_in.rs_val;

        case (id_ex_in.ctrl.alu_src)
            2'b01: risc32p_alu_op_b = id_ex_in.imm;       // immediate
            //2'b10: risc32p_alu_op_b = id_ex_in.imm;   // IN instruction
            default: risc32p_alu_op_b = id_ex_in.rt_val;  // register
        endcase
    end

    // ========================================================
    // ALU
    // ========================================================
    risc32p_alu u_alu (
        .clk        (clk),
        .op_a       (risc32p_alu_op_a),
        .op_b       (risc32p_alu_op_b),
        .alu_sel    (risc32p_alu_sel),
        .alu_result (risc32p_alu_result)
    );

    // ========================================================
    // Branch Evaluation (perfect prediction model)
    // ========================================================
    always_comb begin
        case (id_ex_in.ctrl.branch_type)
            2'b00: risc32p_branch_flag = id_ex_in.flags.z; // JZ
            2'b01: risc32p_branch_flag = id_ex_in.flags.n; // JN
            2'b10: risc32p_branch_flag = id_ex_in.flags.c; // JC
            default: risc32p_branch_flag = 1'b1;           // JMP / CALL
        endcase
    end

    assign risc32p_branch_taken =
        id_ex_in.ctrl.jump & risc32p_branch_flag;

    // ========================================================
    // EX/MEM Register Output Assembly
    // ========================================================
    always_ff @(posedge clk) begin
        ex_mem_out.pc_next       <= id_ex_in.pc_next;
        ex_mem_out.alu_result    <= risc32p_alu_result[31:0];
        ex_mem_out.rt_val        <= id_ex_in.rt_val;
        ex_mem_out.rd            <= id_ex_in.rd;
        ex_mem_out.rs            <= id_ex_in.rs;
        ex_mem_out.flags         <= id_ex_in.flags;
        ex_mem_out.branch_taken  <= risc32p_branch_taken;

        ex_mem_out.ctrl          <= id_ex_in.ctrl;
        ex_mem_out.opcode        <= id_ex_in.opcode;
        ex_mem_out.imm       <= id_ex_in.imm;
    end

endmodule


// ==========================================================
