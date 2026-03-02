// ============================================================
// risc32p_mem_stage.sv
// ============================================================

import risc32p_types::*;

module risc32p_mem_stage (

    input  logic            clk,
    input  logic            reset,

    input  risc32p_ex_mem_t ex_mem_in,

    output logic [17:0]     mem_addr,
    output logic [31:0]     mem_wdata,
    input  logic [31:0]     mem_rdata,
    output logic            mem_wr_en,

    output risc32p_mem_wb_t mem_wb_out
);

    assign mem_addr  = ex_mem_in.alu_result[17:0];
    assign mem_wdata = ex_mem_in.rt_val;
    assign mem_wr_en = ex_mem_in.ctrl.mem_write;


    always_ff @(posedge clk or posedge reset) begin

        if(reset)
            mem_wb_out <= '0;

        else begin

            mem_wb_out.alu_result <= ex_mem_in.alu_result;
            mem_wb_out.mem_data   <= mem_rdata;

            mem_wb_out.rt_val     <= ex_mem_in.rt_val;

            mem_wb_out.rd         <= ex_mem_in.rd;
            mem_wb_out.rs         <= ex_mem_in.rs;

            mem_wb_out.ctrl       <= ex_mem_in.ctrl;
            mem_wb_out.opcode     <= ex_mem_in.opcode;

        end
    end

endmodule