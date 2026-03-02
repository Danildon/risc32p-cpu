// ============================================================
// risc32p_regfile.sv
// ============================================================

module risc32p_regfile (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_en,

    input  logic [2:0]  read_addr_a,
    input  logic [2:0]  read_addr_b,
    input  logic [2:0]  write_addr,

    input  logic [31:0] write_data,

    output logic [31:0] read_data_a,
    output logic [31:0] read_data_b
);

    // 8 registers, 32-bit each
    logic [31:0] registers [0:7];


    // --------------------------------------------------------
    // Asynchronous read (exact match to VHDL)
    // --------------------------------------------------------
    assign read_data_a = registers[read_addr_a];
    assign read_data_b = registers[read_addr_b];


    // --------------------------------------------------------
    // Falling-edge synchronous write (CRITICAL)
    // --------------------------------------------------------
    integer i;

    always_ff @(negedge clk or posedge reset) begin

        if (reset) begin
            for (i = 0; i < 8; i++)
                registers[i] <= 32'd0;
        end
        else if (write_en) begin
            registers[write_addr] <= write_data;

            $display("REGISTER WRITE: R%0d = %0d",
                     write_addr, write_data);
        end

    end

endmodule