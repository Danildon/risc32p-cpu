// ============================================================
//  risc32p_if_id_reg.sv
//  Simple IF / ID register (no immediate logic here)
// ============================================================

import risc32p_types::*;

module risc32p_if_id_reg (
    input  logic           clk,
    input  logic           write_en,
    input  logic           flush,
    input  logic [31:0]    pc_in,
    input  logic [31:0]    instr_in,
    output risc32p_if_id_t if_id_out
);

    always_ff @(posedge clk) begin
        if (flush) begin
            if_id_out <= '0;
        end
        else if (write_en) begin
            if_id_out.pc    <= pc_in;
            if_id_out.instr <= instr_in;
            if_id_out.rs    <= instr_in[26:24];
            if_id_out.rt    <= instr_in[23:21];
            if_id_out.imm   <= 32'd0;   // ID stage will override if needed
        end
    end

endmodule