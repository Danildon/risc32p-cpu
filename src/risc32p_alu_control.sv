// ==========================================================

// ============================================================
//  risc32p_alu_control.sv
//  ALU control decoder for RISC32P CPU
// ============================================================

module risc32p_alu_control (
    input  logic [4:0]  risc32p_opcode,
    output logic [3:0]  risc32p_alu_sel,
    output logic        risc32p_modify_flags
);

    // ========================================================
    // Default values (NOP / MOV A)
    // ========================================================
    always_comb begin
        risc32p_alu_sel       = 4'b0000;
        risc32p_modify_flags = 1'b0;

        case (risc32p_opcode)

            // ===============================
            // Arithmetic & Logic
            // ===============================
            5'b00000: begin // ADD
                risc32p_alu_sel       = 4'b0010;
                risc32p_modify_flags = 1'b1;
            end

            5'b00001: begin // SUB
                risc32p_alu_sel       = 4'b0011;
                risc32p_modify_flags = 1'b1;
            end

            5'b00010: begin // AND
                risc32p_alu_sel       = 4'b0100;
                risc32p_modify_flags = 1'b1;
            end

            5'b00011: begin // SWAP
                risc32p_alu_sel       = 4'b0000;
                risc32p_modify_flags = 1'b0;
            end

            5'b00100: begin // NOT
                risc32p_alu_sel       = 4'b0101;
                risc32p_modify_flags = 1'b1;
            end

            5'b00101: begin // MOV
                risc32p_alu_sel       = 4'b0000;
                risc32p_modify_flags = 1'b0;
            end

            5'b00110: begin // INC
                risc32p_alu_sel       = 4'b0110;
                risc32p_modify_flags = 1'b1;
            end

            5'b00111: begin // IADD
                risc32p_alu_sel       = 4'b0010;
                risc32p_modify_flags = 1'b1;
            end

            // ===============================
            // Memory Addressing
            // ===============================
            5'b01000: begin // LDD
                risc32p_alu_sel       = 4'b0010;
                risc32p_modify_flags = 1'b0;
            end

            5'b01001: begin // STD
                risc32p_alu_sel       = 4'b0010;
                risc32p_modify_flags = 1'b0;
            end

            5'b01010: begin // LDM
                risc32p_alu_sel       = 4'b0001;
                risc32p_modify_flags = 1'b0;
            end

            // ===============================
            // Stack Operations
            // ===============================
            5'b01011: begin // PUSH
                risc32p_alu_sel       = 4'b0111;
                risc32p_modify_flags = 1'b0;
            end

            5'b01100: begin // POP
                risc32p_alu_sel       = 4'b0110;
                risc32p_modify_flags = 1'b0;
            end

            // ===============================
            // I/O
            // ===============================
            5'b01101: begin // OUT
                risc32p_alu_sel       = 4'b0000;
                risc32p_modify_flags = 1'b0;
            end

            5'b01110: begin // IN
                risc32p_alu_sel       = 4'b0001;
                risc32p_modify_flags = 1'b0;
            end

            // ===============================
            // Branching
            // ===============================
            5'b01111, // JZ
            5'b10000, // JN
            5'b10001, // JC
            5'b10010: begin // JMP
                risc32p_alu_sel       = 4'b0000;
                risc32p_modify_flags = 1'b0;
            end

            // ===============================
            // Subroutines & Interrupts
            // ===============================
            5'b10011, // CALL
            5'b10100, // RTI
            5'b10101, // INT2
            5'b10110, // INT3
            5'b10111: begin // INT1
                risc32p_alu_sel       = 4'b0111;
                risc32p_modify_flags = 1'b0;
            end

            // ===============================
            // Special / Flags
            // ===============================
            5'b11000: begin // HLT
                risc32p_alu_sel       = 4'b0000;
                risc32p_modify_flags = 1'b0;
            end

            5'b11001: begin // SETC
                risc32p_alu_sel       = 4'b1000;
                risc32p_modify_flags = 1'b1;
            end

            5'b11010, // RET
            5'b11011: begin // NOP
                risc32p_alu_sel       = 4'b0000;
                risc32p_modify_flags = 1'b0;
            end

            default: begin
                risc32p_alu_sel       = 4'b0000;
                risc32p_modify_flags = 1'b0;
            end

        endcase
    end

endmodule


// ==========================================================
