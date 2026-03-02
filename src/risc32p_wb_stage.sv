// ============================================================
// risc32p_wb_stage.sv (FIXED, SAME PORT MAP)
// ============================================================
`include "risc32p_types.sv"

module risc32p_wb_stage (
    input  logic clk,
    input  risc32p_types::risc32p_mem_wb_t mem_wb_in,
    output logic [31:0] out_port
);

import risc32p_types::*;

always_ff @(posedge clk) begin
    if (mem_wb_in.ctrl.write_out) begin
        out_port <= mem_wb_in.rt_val;
        $display("OUT detected: %0d", mem_wb_in.rt_val);
    end
end

endmodule
