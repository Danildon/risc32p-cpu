// ============================================================
//  risc32p_types.sv
//  Common type definitions for RISC32P CPU
// ============================================================

package risc32p_types;

  localparam int RISC32P_DATA_WIDTH = 32;
  localparam int RISC32P_ADDR_WIDTH = 18;
  localparam int RISC32P_REG_BITS   = 3;

  typedef enum logic [4:0] {
    RISC32P_OP_ADD   = 5'b00000,
    RISC32P_OP_SUB   = 5'b00001,
    RISC32P_OP_AND   = 5'b00010,
    RISC32P_OP_SWAP  = 5'b00011,
    RISC32P_OP_NOT   = 5'b00100,
    RISC32P_OP_MOV   = 5'b00101,
    RISC32P_OP_INC   = 5'b00110,
    RISC32P_OP_IADD  = 5'b00111,
    RISC32P_OP_LDD   = 5'b01000,
    RISC32P_OP_STD   = 5'b01001,
    RISC32P_OP_LDM   = 5'b01010,
    RISC32P_OP_PUSH  = 5'b01011,
    RISC32P_OP_POP   = 5'b01100,
    RISC32P_OP_OUT   = 5'b01101,
    RISC32P_OP_IN    = 5'b01110,
    RISC32P_OP_JZ    = 5'b01111,
    RISC32P_OP_JN    = 5'b10000,
    RISC32P_OP_JC    = 5'b10001,
    RISC32P_OP_JMP   = 5'b10010,
    RISC32P_OP_CALL  = 5'b10011,
    RISC32P_OP_RTI   = 5'b10100,
    RISC32P_OP_INT2  = 5'b10101,
    RISC32P_OP_INT3  = 5'b10110,
    RISC32P_OP_INT1  = 5'b10111,
    RISC32P_OP_HLT   = 5'b11000,
    RISC32P_OP_SETC  = 5'b11001,
    RISC32P_OP_RET   = 5'b11010,
    RISC32P_OP_NOP   = 5'b11011
  } risc32p_opcode_t;

  typedef enum logic [3:0] {
    RISC32P_ALU_PASS_A = 4'b0000,
    RISC32P_ALU_PASS_B = 4'b0001,
    RISC32P_ALU_ADD    = 4'b0010,
    RISC32P_ALU_SUB    = 4'b0011,
    RISC32P_ALU_AND    = 4'b0100,
    RISC32P_ALU_NOT    = 4'b0101,
    RISC32P_ALU_INC    = 4'b0110,
    RISC32P_ALU_DEC    = 4'b0111,
    RISC32P_ALU_SETC   = 4'b1000
  } risc32p_alu_op_t;

  typedef enum logic [1:0] {
    RISC32P_BR_Z   = 2'b00,
    RISC32P_BR_N   = 2'b01,
    RISC32P_BR_C   = 2'b10,
    RISC32P_BR_ANY = 2'b11
  } risc32p_branch_t;

  typedef enum logic [1:0] {
    RISC32P_ADDR_PC  = 2'b00,
    RISC32P_ADDR_SP  = 2'b01,
    RISC32P_ADDR_ALU = 2'b10,
    RISC32P_ADDR_INT = 2'b11
  } risc32p_addr_src_t;

  typedef enum logic [1:0] {
    RISC32P_WB_ALU = 2'b00,
    RISC32P_WB_IN  = 2'b01,
    RISC32P_WB_MEM = 2'b10
  } risc32p_wb_src_t;

  typedef struct packed {
    logic              reg_write;
    logic              mem_read;
    logic              mem_write;
    logic              sp_write;
    logic              sp_dir;
    logic              is_swap;
    logic              write_out;
    logic              is_int;
    logic              is_ret;
    logic              is_rti;
    logic              call_or_int;
    risc32p_addr_src_t addr_src;
    risc32p_wb_src_t   wb_src;
    risc32p_branch_t   branch_type;
    logic              jump;
    logic              needs_imm;
    logic [1:0]        alu_src;
  } risc32p_ctrl_t;

  typedef risc32p_ctrl_t risc32p_ctrl_ex_t;
  typedef risc32p_ctrl_t risc32p_ctrl_mem_t;
  typedef risc32p_ctrl_t risc32p_ctrl_wb_t;

  typedef struct packed {
    logic z;
    logic n;
    logic c;
  } risc32p_flags_t;

  // IF/ID pipeline register
  typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
    logic [31:0] imm;
    logic [2:0]  rs;
    logic [2:0]  rt;
  } risc32p_if_id_t;

  // ID/EX pipeline register
  typedef struct packed {
    logic [31:0]         pc;
    logic [31:0]         pc_next;
    logic [31:0]         rs_val;
    logic [31:0]         rt_val;
    logic [31:0]         imm;
    logic [2:0]          rs;
    logic [2:0]          rt;
    logic [2:0]          rd;
    risc32p_opcode_t     opcode;
    risc32p_ctrl_t       ctrl;
    risc32p_flags_t      flags;
  } risc32p_id_ex_t;

  // EX/MEM pipeline register
  typedef struct packed {
    logic [31:0]         pc;
    logic [31:0]         pc_next;
    logic [31:0]         pc_chosen;
    logic [31:0]         alu_result;
    logic [31:0]         rt_val;
    logic [31:0]         imm;
    logic [31:0]         old_sp;
    logic [2:0]          rs;
    logic [2:0]          rd;
    logic [1:0]          int_index;
    logic [2:0]          flags;
    logic                branch_taken;
    risc32p_ctrl_ex_t    ctrl;
    risc32p_opcode_t     opcode;
  } risc32p_ex_mem_t;

  // MEM/WB pipeline register
  typedef struct packed {
    logic [31:0]         alu_result;
    logic [31:0]         mem_data;
    logic [31:0]         rt_val;
    logic [2:0]          rs;
    logic [2:0]          rd;
    risc32p_ctrl_wb_t    ctrl;
    risc32p_opcode_t     opcode;
  } risc32p_mem_wb_t;

endpackage
