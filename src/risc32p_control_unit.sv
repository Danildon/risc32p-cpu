// ==========================================================

// ============================================================
//  risc32p_control_unit.sv
//  Main instruction decode and control generation unit
// ============================================================

module risc32p_control_unit (
    input  logic        reset,
    input  logic [4:0]  opcode,

    // Memory / stack
    output logic        ctrl_mem_rd,
    output logic        ctrl_mem_wr,
    output logic        ctrl_sp_write,
    output logic        ctrl_sp_dir,
    output logic [1:0]  ctrl_addr_type,

    // Execute / flow control
    output logic        ctrl_jump,
    output logic [1:0]  ctrl_branch_type,
    output logic        ctrl_flag_restore,
    output logic [1:0]  ctrl_int_index,

    // ALU / datapath
    output logic [1:0]  ctrl_alu_src,
    output logic        ctrl_reg_dst,
    output logic        ctrl_needs_imm,

    // Writeback
    output logic [1:0]  ctrl_mem_to_reg,
    output logic        ctrl_reg_write,
    output logic        ctrl_write_out,

    // Special
    output logic        ctrl_is_swap,
    output logic        ctrl_is_int,
    output logic        ctrl_is_ret,
    output logic        ctrl_is_ret_or_int,
    output logic        ctrl_is_rti,
    output logic        ctrl_hlt_freeze
);

    // ========================================================
    // Opcode definitions (kept identical encoding)
    // ========================================================
    localparam logic [4:0]
        OP_ADD   = 5'b00000,
        OP_SUB   = 5'b00001,
        OP_AND   = 5'b00010,
        OP_SWAP  = 5'b00011,
        OP_NOT   = 5'b00100,
        OP_MOV   = 5'b00101,
        OP_INC   = 5'b00110,
        OP_IADD  = 5'b00111,
        OP_LDD   = 5'b01000,
        OP_STD   = 5'b01001,
        OP_LDM   = 5'b01010,
        OP_PUSH  = 5'b01011,
        OP_POP   = 5'b01100,
        OP_OUT   = 5'b01101,
        OP_IN    = 5'b01110,
        OP_JZ    = 5'b01111,
        OP_JN    = 5'b10000,
        OP_JC    = 5'b10001,
        OP_JMP   = 5'b10010,
        OP_CALL  = 5'b10011,
        OP_RTI   = 5'b10100,
        OP_INT1  = 5'b10101,
        OP_INT2  = 5'b10110,
        OP_INT3  = 5'b10111,
        OP_HLT   = 5'b11000,
        OP_SETC  = 5'b11001,
        OP_RET   = 5'b11010,
        OP_NOP   = 5'b11011;

    // ========================================================
    // Default assignments
    // ========================================================
    always_comb begin
        ctrl_mem_rd       = 1'b0;
        ctrl_mem_wr       = 1'b0;
        ctrl_sp_write     = 1'b0;
        ctrl_sp_dir       = 1'b1;
        ctrl_addr_type    = 2'b00;

        ctrl_jump         = 1'b0;
        ctrl_branch_type  = 2'b11;
        ctrl_flag_restore = 1'b0;
        ctrl_int_index    = 2'b00;

        ctrl_alu_src      = 2'b00;
        ctrl_reg_dst      = 1'b0;
        ctrl_needs_imm    = 1'b0;

        ctrl_mem_to_reg   = 2'b00;
        ctrl_reg_write    = 1'b0;
        ctrl_write_out    = 1'b0;

        ctrl_is_swap      = 1'b0;
        ctrl_is_int       = 1'b0;
        ctrl_is_ret       = 1'b0;
        ctrl_is_rti       = 1'b0;
        ctrl_hlt_freeze   = 1'b0;

        // ====================================================
        // Decode
        // ====================================================
        case (opcode)

            OP_ADD, OP_SUB, OP_AND, OP_IADD: begin
                ctrl_reg_write = 1'b1;
                ctrl_reg_dst   = 1'b1;
                ctrl_alu_src   = (opcode == OP_IADD) ? 2'b01 : 2'b00;
                ctrl_needs_imm = (opcode == OP_IADD);
            end

            OP_MOV, OP_NOT, OP_INC: begin
                ctrl_reg_write = 1'b1;
            end

            OP_SWAP: begin
                ctrl_reg_write = 1'b1;
                ctrl_is_swap   = 1'b1;
            end

            OP_LDD: begin
                ctrl_mem_rd     = 1'b1;
                ctrl_mem_to_reg = 2'b10;
                ctrl_reg_write  = 1'b1;
                ctrl_alu_src    = 2'b01;
                ctrl_needs_imm  = 1'b1;
                ctrl_addr_type  = 2'b10;
            end

            OP_STD: begin
                ctrl_mem_wr    = 1'b1;
                ctrl_alu_src   = 2'b01;
                ctrl_needs_imm = 1'b1;
                ctrl_addr_type = 2'b10;
            end

            OP_LDM: begin
                ctrl_reg_write = 1'b1;
                ctrl_alu_src   = 2'b01;
                ctrl_needs_imm = 1'b1;
            end

            OP_PUSH, OP_POP: begin
                ctrl_sp_write  = 1'b1;
                ctrl_addr_type = 2'b01;
                ctrl_mem_rd    = (opcode == OP_POP);
                ctrl_mem_wr    = (opcode == OP_PUSH);
                ctrl_reg_write = (opcode == OP_POP);
            end

            OP_OUT: begin
                ctrl_write_out = 1'b1;
            end

            OP_IN: begin
                ctrl_reg_write  = 1'b1;
                ctrl_mem_to_reg = 2'b01;
                ctrl_alu_src    = 2'b10;
            end

            OP_JZ, OP_JN, OP_JC, OP_JMP: begin
                ctrl_jump        = 1'b1;
                ctrl_needs_imm   = 1'b1;
                ctrl_branch_type = (opcode == OP_JZ) ? 2'b00 :
                                   (opcode == OP_JN) ? 2'b01 :
                                   (opcode == OP_JC) ? 2'b10 : 2'b11;
            end

            OP_CALL: begin
                ctrl_jump        = 1'b1;
                ctrl_mem_wr     = 1'b1;
                ctrl_sp_write   = 1'b1;
                ctrl_addr_type  = 2'b01;
            end

            OP_RET: begin
                ctrl_is_ret     = 1'b1;
                ctrl_sp_write  = 1'b1;
                ctrl_addr_type = 2'b01;
            end

            OP_RTI: begin
                ctrl_is_ret     = 1'b1;
                ctrl_is_rti     = 1'b1;
                ctrl_flag_restore = 1'b1;
                ctrl_sp_write  = 1'b1;
                ctrl_addr_type = 2'b01;
            end

            OP_INT1, OP_INT2, OP_INT3: begin
                ctrl_is_int     = 1'b1;
                ctrl_mem_wr    = 1'b1;
                ctrl_sp_write  = 1'b1;
                ctrl_addr_type = 2'b01;
                ctrl_int_index = (opcode == OP_INT1) ? 2'b01 :
                                 (opcode == OP_INT2) ? 2'b10 : 2'b11;
            end

            OP_HLT: begin
                ctrl_hlt_freeze = 1'b1;
            end

            default: begin
                // NOP
            end
        endcase
    end

    assign ctrl_is_ret_or_int = ctrl_is_ret | ctrl_is_int;

endmodule


// ==========================================================
