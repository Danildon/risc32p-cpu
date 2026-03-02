// ============================================================
//  risc32p_if_stage.sv
//  Instruction Fetch stage with boot-vector support
// ============================================================

module risc32p_if_stage (
    input  logic         clk,
    input  logic         reset,

    input  logic         pc_write_en,
    input  logic         flush_if,

    input  logic [31:0]  pc_next,
    input  logic [31:0]  instr_in,

    output logic [31:0]  pc_current,
    output logic [31:0]  instr_out
);

    // --------------------------------------------------------
    // Boot state
    // --------------------------------------------------------
    logic boot_phase;

    logic [31:0] risc32p_pc_reg;

    // --------------------------------------------------------
    // PC register
    // --------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            risc32p_pc_reg <= 32'd0;
            boot_phase     <= 1'b1;
        end
        else begin
            if (boot_phase) begin
                // First fetched word becomes entry point
                risc32p_pc_reg <= instr_in;
                boot_phase     <= 1'b0;
            end
            else if (pc_write_en) begin
                risc32p_pc_reg <= pc_next;
            end
        end
    end

    assign pc_current = risc32p_pc_reg;

    // --------------------------------------------------------
    // Instruction output
    // --------------------------------------------------------
    always_comb begin
        if (flush_if)
            instr_out = 32'h00000000;
        else
            instr_out = instr_in;
    end

endmodule