// ==========================================================

// ============================================================
//  risc32p_pipeline_control.sv
//  Pipeline control: hazards, stalls, flushes, interrupts
// ============================================================

module risc32p_pipeline_control (
    input  logic                clk,
    input  logic                reset,
    input  logic                int_signal,

    input  risc32p_if_id_t       if_id,
    input  risc32p_id_ex_t       id_ex,
    input  risc32p_ex_mem_t      ex_mem,
    input  risc32p_mem_wb_t      mem_wb,

    output logic                pc_write_en,
    output logic                if_id_write_en,
    output logic                id_ex_write_en,
    output logic                ex_mem_write_en,
    output logic                mem_wb_write_en,

    output logic                flush_if,
    output logic                flush_id,
    output logic                flush_ex
);

    // ========================================================
    // Internal hazard flags
    // ========================================================
    logic load_use_hazard;
    logic memory_use_hazard;
    logic interrupt_stall;
    logic swap_stall;

    // ========================================================
    // LOAD-USE hazard detection
    // ========================================================
    always_comb begin
        load_use_hazard = 1'b0;

        if (id_ex.ctrl.mem_read) begin
            if ((id_ex.rt == if_id.rs) || (id_ex.rt == if_id.rt)) begin
                load_use_hazard = 1'b1;
            end
        end
    end

    // ========================================================
    // Memory structural hazard
    // ========================================================
    always_comb begin
        memory_use_hazard = ex_mem.ctrl.mem_read | ex_mem.ctrl.mem_write;
    end

    // ========================================================
    // Interrupt stall
    // ========================================================
    always_comb begin
        interrupt_stall = ex_mem.ctrl.is_int;
    end

    // ========================================================
    // Swap stall (writeback-dependent)
    // ========================================================
    always_comb begin
        swap_stall = mem_wb.ctrl.is_swap;
    end

    // ========================================================
    // PIPELINE WRITE ENABLES
    // ========================================================
    always_comb begin
        // Default: pipeline flows
        pc_write_en     = 1'b1;
        if_id_write_en = 1'b1;
        id_ex_write_en = 1'b1;
        ex_mem_write_en = 1'b1;
        mem_wb_write_en = 1'b1;

        // Load-use stall
        if (load_use_hazard) begin
            pc_write_en     = 1'b0;
            if_id_write_en = 1'b0;
        end

        // Memory structural stall
        if (memory_use_hazard) begin
            pc_write_en     = 1'b0;
            if_id_write_en = 1'b0;
        end

        // Interrupt stall
        if (interrupt_stall) begin
            pc_write_en     = 1'b0;
            if_id_write_en = 1'b0;
            id_ex_write_en = 1'b0;
            ex_mem_write_en = 1'b0;
        end

        // Swap stall
        if (swap_stall) begin
            pc_write_en     = 1'b0;
            if_id_write_en = 1'b0;
            id_ex_write_en = 1'b0;
            ex_mem_write_en = 1'b0;
            mem_wb_write_en = 1'b0;
        end

        // Reset override
        if (reset) begin
            pc_write_en      = 1'b1;
            if_id_write_en  = 1'b1;
            id_ex_write_en  = 1'b1;
            ex_mem_write_en = 1'b1;
            mem_wb_write_en = 1'b1;
        end
    end

    // ========================================================
    // FLUSH CONTROL
    // ========================================================
    always_comb begin
        flush_if = 1'b0;
        flush_id = 1'b0;
        flush_ex = 1'b0;

        // Branch / jump taken
        if (ex_mem.branch_taken) begin
            flush_if = 1'b1;
            flush_id = 1'b1;
        end

        // Load-use hazard
        if (load_use_hazard) begin
            flush_ex = 1'b1;
        end

        // Interrupt entry / return
        if (interrupt_stall) begin
            flush_if = 1'b1;
            flush_id = 1'b1;
            flush_ex = 1'b1;
        end

        // Reset flush
        if (reset) begin
            flush_if = 1'b1;
            flush_id = 1'b1;
            flush_ex = 1'b1;
        end
    end

endmodule


// ==========================================================
