// ============================================================
// risc32p_id_stage.sv
// FINAL FIX - correct immediate pairing and register addressing
// ============================================================

import risc32p_types::*;

module risc32p_id_stage (

    input  logic             clk,
    input  logic             reset,

    input  risc32p_if_id_t   if_id_in,
    input  risc32p_mem_wb_t  mem_wb_in,

    output risc32p_id_ex_t   id_ex_out
);

    // =========================================================
    // Register addressing FIX
    // =========================================================

    logic waiting_for_imm;

    logic [31:0] saved_instr;
    risc32p_ctrl_t saved_ctrl;

    logic [2:0] rs_addr;
    logic [2:0] rt_addr;

    assign rs_addr =
        waiting_for_imm
            ? saved_instr[26:24]
            : if_id_in.instr[26:24];

    assign rt_addr =
        waiting_for_imm
            ? saved_instr[23:21]
            : if_id_in.instr[23:21];


    // =========================================================
    // Writeback data select
    // =========================================================

    logic [31:0] wb_data;

    assign wb_data =
        (mem_wb_in.ctrl.wb_src == RISC32P_WB_MEM)
            ? mem_wb_in.mem_data
            : mem_wb_in.alu_result;


    // =========================================================
    // Register file
    // =========================================================

    logic [31:0] rs_val;
    logic [31:0] rt_val;

    risc32p_regfile u_regfile (

        .clk(clk),
        .reset(reset),

        .write_en(mem_wb_in.ctrl.reg_write),
        .write_addr(mem_wb_in.rd),
        .write_data(wb_data),

        .read_addr_a(rs_addr),
        .read_addr_b(rt_addr),

        .read_data_a(rs_val),
        .read_data_b(rt_val)
    );


    // =========================================================
    // Control unit
    // =========================================================

    risc32p_ctrl_t ctrl_id;

    risc32p_control_unit u_control (

        .reset(reset),
        .opcode(if_id_in.instr[31:27]),

        .ctrl_mem_rd(ctrl_id.mem_read),
        .ctrl_mem_wr(ctrl_id.mem_write),
        .ctrl_sp_write(ctrl_id.sp_write),
        .ctrl_sp_dir(ctrl_id.sp_dir),
        .ctrl_addr_type(ctrl_id.addr_src),

        .ctrl_jump(ctrl_id.jump),
        .ctrl_branch_type(ctrl_id.branch_type),

        .ctrl_flag_restore(),
        .ctrl_int_index(),

        .ctrl_alu_src(ctrl_id.alu_src),
        .ctrl_reg_dst(),
        .ctrl_needs_imm(ctrl_id.needs_imm),

        .ctrl_mem_to_reg(ctrl_id.wb_src),
        .ctrl_reg_write(ctrl_id.reg_write),
        .ctrl_write_out(ctrl_id.write_out),

        .ctrl_is_swap(ctrl_id.is_swap),
        .ctrl_is_int(ctrl_id.is_int),
        .ctrl_is_ret(ctrl_id.is_ret),
        .ctrl_is_ret_or_int(),
        .ctrl_is_rti(ctrl_id.is_rti),

        .ctrl_hlt_freeze()
    );


    // =========================================================
    // Pipeline register logic
    // =========================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            waiting_for_imm <= 0;
            id_ex_out <= '0;

        end
        else begin

            //--------------------------------------------------
            // NORMAL instruction
            //--------------------------------------------------

            if (!waiting_for_imm) begin

                if (ctrl_id.needs_imm) begin

                    saved_instr     <= if_id_in.instr;
                    saved_ctrl      <= ctrl_id;

                    waiting_for_imm <= 1;

                end
                else begin

                    id_ex_out.pc       <= if_id_in.pc;
                    id_ex_out.pc_next  <= if_id_in.pc + 1;

                    id_ex_out.rs       <= if_id_in.instr[26:24];
                    id_ex_out.rt       <= if_id_in.instr[23:21];
                    id_ex_out.rd       <= if_id_in.instr[20:18];

                    id_ex_out.rs_val   <= rs_val;
                    id_ex_out.rt_val   <= rt_val;

                    id_ex_out.imm      <= 0;

                    id_ex_out.opcode   <= risc32p_opcode_t'(if_id_in.instr[31:27]);

                    id_ex_out.ctrl     <= ctrl_id;

                    id_ex_out.flags    <= '0;

                end

            end

            //--------------------------------------------------
            // IMMEDIATE word
            //--------------------------------------------------

            else begin

                id_ex_out.pc       <= if_id_in.pc - 1;
                id_ex_out.pc_next  <= if_id_in.pc;

                id_ex_out.rs       <= saved_instr[26:24];
                id_ex_out.rt       <= saved_instr[23:21];
                id_ex_out.rd       <= saved_instr[20:18];

                id_ex_out.rs_val   <= rs_val;
                id_ex_out.rt_val   <= rt_val;

                id_ex_out.imm      <= if_id_in.instr;

                id_ex_out.opcode   <= risc32p_opcode_t'(saved_instr[31:27]);

                id_ex_out.ctrl     <= saved_ctrl;

                id_ex_out.flags    <= '0;

                waiting_for_imm <= 0;

            end
        end
    end

endmodule