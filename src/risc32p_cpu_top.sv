// ============================================================
//  risc32p_cpu_top.sv
//  Restored Pipeline Control + Proper Memory-Based Immediate
// ============================================================

import risc32p_types::*;

module risc32p_cpu_top (
    input  logic         clk,
    input  logic         reset,
    input  logic         int_signal,
    output logic [31:0]  out_port
);

    // ========================================================
    // Global pipeline control
    // ========================================================
    logic risc32p_pc_write_en;
    logic risc32p_if_id_write_en;
    logic risc32p_id_ex_write_en;
    logic risc32p_ex_mem_write_en;
    logic risc32p_mem_wb_write_en;

    logic risc32p_flush_if;
    logic risc32p_flush_id;
    logic risc32p_flush_ex;

    // ========================================================
    // Inter-stage pipeline registers
    // ========================================================
    risc32p_if_id_t   risc32p_if_id;
    risc32p_id_ex_t   risc32p_id_ex;
    risc32p_ex_mem_t  risc32p_ex_mem;
    risc32p_mem_wb_t  risc32p_mem_wb;

    // ========================================================
    // Fetch stage signals
    // ========================================================
    logic [31:0] risc32p_pc_current;
    logic [31:0] risc32p_pc_next;
    logic [31:0] risc32p_instr_fetch;

    logic [31:0] risc32p_pc_plus1;
    assign risc32p_pc_plus1 = risc32p_pc_current + 32'd1;
    assign risc32p_pc_next  = risc32p_pc_plus1;

    // ========================================================
    // Unified memory interface
    // ========================================================
    logic [17:0] risc32p_mem_addr;
    logic [17:0] risc32p_data_mem_addr;
    logic [31:0] risc32p_mem_wdata;
    logic [31:0] risc32p_mem_rdata;
    logic        risc32p_mem_wr_en;

    // ========================================================
    // FETCH STAGE
    // ========================================================
    risc32p_if_stage u_if_stage (
        .clk         (clk),
        .reset       (reset),
        .pc_write_en (risc32p_pc_write_en),
        .flush_if    (risc32p_flush_if),
        .pc_next     (risc32p_pc_next),
        .pc_current  (risc32p_pc_current),
        .instr_in    (risc32p_mem_rdata),
        .instr_out   (risc32p_instr_fetch)
    );

    // ========================================================
    // IF / ID REGISTER
    // ========================================================
    risc32p_if_id_reg u_if_id_reg (
        .clk        (clk),
        .write_en   (risc32p_if_id_write_en),
        .flush      (risc32p_flush_if),
        .pc_in      (risc32p_pc_current),
        .instr_in   (risc32p_instr_fetch),
        .if_id_out  (risc32p_if_id)
    );

    // ========================================================
    // DECODE STAGE
    // ========================================================
    risc32p_id_stage u_id_stage (
        .clk        (clk),
        .reset      (reset),
        .if_id_in   (risc32p_if_id),
        .mem_wb_in  (risc32p_mem_wb),
        .id_ex_out  (risc32p_id_ex)
    );

    // ========================================================
    // EXECUTE STAGE
    // ========================================================
    risc32p_ex_stage u_ex_stage (
        .clk        (clk),
        .id_ex_in   (risc32p_id_ex),
        .ex_mem_out (risc32p_ex_mem)
    );

    // ========================================================
    // MEMORY STAGE
    // ========================================================
    risc32p_mem_stage u_mem_stage (
        .clk        (clk),
        .reset      (reset),
        .ex_mem_in  (risc32p_ex_mem),
        .mem_addr   (risc32p_data_mem_addr),
        .mem_wdata  (risc32p_mem_wdata),
        .mem_rdata  (risc32p_mem_rdata),
        .mem_wr_en  (risc32p_mem_wr_en),
        .mem_wb_out (risc32p_mem_wb)
    );

    // Memory arbitration
    assign risc32p_mem_addr =
        (risc32p_mem_wr_en)
            ? risc32p_data_mem_addr
            : risc32p_pc_current[17:0];

    // ========================================================
    // WRITEBACK STAGE
    // ========================================================
    risc32p_wb_stage u_wb_stage (
        .clk        (clk),
        .mem_wb_in  (risc32p_mem_wb),
        .out_port   (out_port)
    );

    // ========================================================
    // MEMORY
    // ========================================================
    risc32p_unified_memory u_memory (
        .clk   (clk),
        .addr  (risc32p_mem_addr),
        .wr_en (risc32p_mem_wr_en),
        .wdata (risc32p_mem_wdata),
        .rdata (risc32p_mem_rdata)
    );

    // ========================================================
    // PIPELINE CONTROL
    // ========================================================
    risc32p_pipeline_control u_pipeline_ctrl (
        .clk             (clk),
        .reset           (reset),
        .int_signal      (int_signal),

        .if_id           (risc32p_if_id),
        .id_ex           (risc32p_id_ex),
        .ex_mem          (risc32p_ex_mem),
        .mem_wb          (risc32p_mem_wb),

        .pc_write_en     (risc32p_pc_write_en),
        .if_id_write_en  (risc32p_if_id_write_en),
        .id_ex_write_en  (risc32p_id_ex_write_en),
        .ex_mem_write_en (risc32p_ex_mem_write_en),
        .mem_wb_write_en (risc32p_mem_wb_write_en),

        .flush_if        (risc32p_flush_if),
        .flush_id        (risc32p_flush_id),
        .flush_ex        (risc32p_flush_ex)
    );

endmodule