// ============================================================
//  risc32p_unified_memory.sv
//  Unified instruction + data memory (Von Neumann)
// ============================================================

module risc32p_unified_memory #(
    parameter ADDR_WIDTH = 18,
    parameter DATA_WIDTH = 32
)(
    input  logic                     clk,
    input  logic [ADDR_WIDTH-1:0]    addr,
    input  logic                     wr_en,
    input  logic [DATA_WIDTH-1:0]    wdata,
    output logic [DATA_WIDTH-1:0]    rdata
);

    logic [DATA_WIDTH-1:0] mem_array [0:(1<<ADDR_WIDTH)-1];

    initial begin
        //$readmemh("../../../../../testbench/stimuli/mem/program.mem", mem_array);
        $readmemb("../../../../../testbench/stimuli/mem/program.mem", mem_array);
    end

    always_ff @(posedge clk) begin
        if (wr_en)
            mem_array[addr] <= wdata;
    end

    always_comb begin
        rdata = mem_array[addr];
    end

endmodule


// ==========================================================
