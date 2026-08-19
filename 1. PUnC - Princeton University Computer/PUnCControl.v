//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
    // External Inputs
    input  wire        clk,
    input  wire        rst,

    // From datapath
    input  wire [15:0] ir,        // Instruction Register value
    input  wire        n_flag,    // Current NZP condition codes
    input  wire        z_flag,
    input  wire        p_flag,

    // Memory Controls
    output reg  [1:0]  mem_r_addr_sel,
    output reg         mem_w_addr_sel,
    output reg         mem_write_en,

    // Register File Controls
    output reg         rf_r_addr_0_sel,
    output reg         rf_r_addr_1_sel,
    output reg         rf_w_addr_sel,
    output reg  [1:0]  rf_w_data_sel,
    output reg         rf_we,

    // Status Registers Controls
    output reg         status_src_sel,
    output reg         status_we,

    // Instruction Register Controls
    output reg         ir_ld,

    // Program Counter Controls
    output reg  [1:0]  pc_src_sel,
    output reg         pc_ld,

    // ALU Controls
    output reg  [1:0]  alu_src_0_sel,
    output reg  [2:0]  alu_src_1_sel,
    output reg  [1:0]  alu_fn,

    // Indirect address register control
    output reg         ind_addr_ld
);

    //--------------------------------------------------------------------------
    // Decode helpers
    //--------------------------------------------------------------------------

    wire [3:0] opcode = ir[`OC];

    wire is_imm  = (ir[`IMM_BIT_NUM] == `IS_IMM);   // ADD/AND imm?
    wire is_jsr  = (ir[`JSR_BIT_NUM] == `IS_JSR);   // JSR vs JSRR
    wire is_ret  = (ir == `RET_MATCH);              // RET pattern

    // Branch enable
    wire br_taken =
        (ir[`BR_N] & n_flag) |
        (ir[`BR_Z] & z_flag) |
        (ir[`BR_P] & p_flag);

    //--------------------------------------------------------------------------
    // FSM States
    //--------------------------------------------------------------------------

    localparam [4:0]
        STATE_FETCH      = 5'd0,
        STATE_DECODE     = 5'd1,

        STATE_EXEC_ADD   = 5'd2,
        STATE_EXEC_AND   = 5'd3,
        STATE_EXEC_NOT   = 5'd4,

        STATE_EXEC_LD    = 5'd5,
        STATE_EXEC_LDR   = 5'd6,
        STATE_EXEC_LDI_0 = 5'd7,
        STATE_EXEC_LDI_1 = 5'd8,

        STATE_EXEC_ST    = 5'd9,
        STATE_EXEC_STR   = 5'd10,
        STATE_EXEC_STI_0 = 5'd11,
        STATE_EXEC_STI_1 = 5'd12,

        STATE_EXEC_BR    = 5'd13,
        STATE_EXEC_JMP   = 5'd14,
        STATE_EXEC_JSR   = 5'd15,
        STATE_EXEC_JSRR  = 5'd16,
        STATE_EXEC_LEA   = 5'd17,

        STATE_HALT       = 5'd31;

    reg [4:0] state, next_state;

    //============================================================================
    // Output Combinational Logic
    //============================================================================
    always @* begin
        //----------------------------------------------------------------------
        // Defaults (safe)
        //----------------------------------------------------------------------
        mem_r_addr_sel = `MEM_R_ADDR_SEL_PC;
        mem_w_addr_sel = `MEM_W_ADDR_SEL_ALU;
        mem_write_en   = 1'b0;

        rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_8_6;
        rf_r_addr_1_sel = `RF_R_ADDR_1_SEL_2_0;
        rf_w_addr_sel   = `RF_W_ADDR_SEL_11_9;
        rf_w_data_sel   = `RF_W_DATA_SEL_ALU;
        rf_we           = 1'b0;

        status_src_sel  = `STATUS_SRC_SEL_ALU;
        status_we       = 1'b0;

        ir_ld      = 1'b0;

        pc_src_sel = `PC_SRC_SEL_INC;
        pc_ld      = 1'b0;

        alu_src_0_sel = `ALU_SRC_0_SEL_REG_0;
        alu_src_1_sel = `ALU_SRC_1_SEL_REG_1;
        alu_fn        = `ALU_FN_ADD;

        ind_addr_ld   = 1'b0;

        //----------------------------------------------------------------------
        // State-specific control
        //----------------------------------------------------------------------
        case (state)

            //==============================================================
            // FETCH: IR <- Mem[PC]
            //==============================================================
            STATE_FETCH: begin
                mem_r_addr_sel = `MEM_R_ADDR_SEL_PC;
                ir_ld          = 1'b1;
                // PC increment is in DECODE.
            end

            //==============================================================
            // DECODE: PC <- PC + 1
            //==============================================================
            STATE_DECODE: begin
                pc_src_sel = `PC_SRC_SEL_INC;
                pc_ld      = 1'b1;
            end

            //==============================================================
            // Arithmetic / Logic
            //==============================================================
            STATE_EXEC_ADD: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_8_6; // SR1
                rf_r_addr_1_sel = `RF_R_ADDR_1_SEL_2_0; // SR2 (or don't-care in imm)

                alu_src_0_sel = `ALU_SRC_0_SEL_REG_0;
                alu_src_1_sel = is_imm ? `ALU_SRC_1_SEL_SXT_5 : `ALU_SRC_1_SEL_REG_1;
                alu_fn        = `ALU_FN_ADD;

                rf_w_addr_sel = `RF_W_ADDR_SEL_11_9; // DR
                rf_w_data_sel = `RF_W_DATA_SEL_ALU;
                rf_we         = 1'b1;

                status_src_sel = `STATUS_SRC_SEL_ALU;
                status_we      = 1'b1;
            end

            STATE_EXEC_AND: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_8_6; // SR1
                rf_r_addr_1_sel = `RF_R_ADDR_1_SEL_2_0; // SR2

                alu_src_0_sel = `ALU_SRC_0_SEL_REG_0;
                alu_src_1_sel = is_imm ? `ALU_SRC_1_SEL_SXT_5 : `ALU_SRC_1_SEL_REG_1;
                alu_fn        = `ALU_FN_AND;

                rf_w_addr_sel = `RF_W_ADDR_SEL_11_9; // DR
                rf_w_data_sel = `RF_W_DATA_SEL_ALU;
                rf_we         = 1'b1;

                status_src_sel = `STATUS_SRC_SEL_ALU;
                status_we      = 1'b1;
            end

            STATE_EXEC_NOT: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_8_6; // SR
                alu_src_0_sel   = `ALU_SRC_0_SEL_REG_0;
                alu_src_1_sel   = `ALU_SRC_1_SEL_REG_1; // unused
                alu_fn          = `ALU_FN_NOT;

                rf_w_addr_sel   = `RF_W_ADDR_SEL_11_9; // DR
                rf_w_data_sel   = `RF_W_DATA_SEL_ALU;
                rf_we           = 1'b1;

                status_src_sel  = `STATUS_SRC_SEL_ALU;
                status_we       = 1'b1;
            end

            //==============================================================
            // Loads
            //==============================================================
            // LD: DR <- Mem[PC + SEXT(PCoffset9)]
            STATE_EXEC_LD: begin
                alu_src_0_sel   = `ALU_SRC_0_SEL_PC;
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_9;
                alu_fn          = `ALU_FN_ADD;

                mem_r_addr_sel  = `MEM_R_ADDR_SEL_ALU;

                rf_w_addr_sel   = `RF_W_ADDR_SEL_11_9;
                rf_w_data_sel   = `RF_W_DATA_SEL_MEM;
                rf_we           = 1'b1;

                status_src_sel  = `STATUS_SRC_SEL_MEM;
                status_we       = 1'b1;
            end

            // LDR: DR <- Mem[BaseR + SEXT(offset6)]
            STATE_EXEC_LDR: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_8_6; // BaseR

                alu_src_0_sel   = `ALU_SRC_0_SEL_REG_0;
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_6;
                alu_fn          = `ALU_FN_ADD;

                mem_r_addr_sel  = `MEM_R_ADDR_SEL_ALU;

                rf_w_addr_sel   = `RF_W_ADDR_SEL_11_9;
                rf_w_data_sel   = `RF_W_DATA_SEL_MEM;
                rf_we           = 1'b1;

                status_src_sel  = `STATUS_SRC_SEL_MEM;
                status_we       = 1'b1;
            end

            // LDI step 0: TempAddr <- Mem[PC + SEXT(PCoffset9)]
            STATE_EXEC_LDI_0: begin
                alu_src_0_sel   = `ALU_SRC_0_SEL_PC;
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_9;
                alu_fn          = `ALU_FN_ADD;

                mem_r_addr_sel  = `MEM_R_ADDR_SEL_ALU;
                ind_addr_ld     = 1'b1;
            end

            // LDI step 1: DR <- Mem[TempAddr]
            STATE_EXEC_LDI_1: begin
                mem_r_addr_sel  = `MEM_R_ADDR_SEL_IND;

                rf_w_addr_sel   = `RF_W_ADDR_SEL_11_9;
                rf_w_data_sel   = `RF_W_DATA_SEL_MEM;
                rf_we           = 1'b1;

                status_src_sel  = `STATUS_SRC_SEL_MEM;
                status_we       = 1'b1;
            end

            //==============================================================
            // Stores
            //==============================================================
            // ST: Mem[PC + SEXT(PCoffset9)] <- SR
            STATE_EXEC_ST: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_11_9; // SR

                alu_src_0_sel   = `ALU_SRC_0_SEL_PC;
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_9;
                alu_fn          = `ALU_FN_ADD;

                mem_w_addr_sel  = `MEM_W_ADDR_SEL_ALU;
                mem_write_en    = 1'b1;
            end

            // STR: Mem[BaseR + SEXT(offset6)] <- SR
            STATE_EXEC_STR: begin
                // SR in [11:9] on read port 0
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_11_9;
                // BaseR in [8:6] on read port 1
                rf_r_addr_1_sel = `RF_R_ADDR_1_SEL_8_6;

                alu_src_0_sel   = `ALU_SRC_0_SEL_REG_1; // BaseR
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_6;
                alu_fn          = `ALU_FN_ADD;

                mem_w_addr_sel  = `MEM_W_ADDR_SEL_ALU;
                mem_write_en    = 1'b1;
            end

            // STI step 0: TempAddr <- Mem[PC + SEXT(PCoffset9)]
            STATE_EXEC_STI_0: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_11_9; // SR (we'll need it later)

                alu_src_0_sel   = `ALU_SRC_0_SEL_PC;
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_9;
                alu_fn          = `ALU_FN_ADD;

                mem_r_addr_sel  = `MEM_R_ADDR_SEL_ALU;
                ind_addr_ld     = 1'b1;
            end

            // STI step 1: Mem[TempAddr] <- SR
            STATE_EXEC_STI_1: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_11_9; // SR
                mem_w_addr_sel  = `MEM_W_ADDR_SEL_IND;
                mem_write_en    = 1'b1;
            end

            //==============================================================
            // Control Flow
            //==============================================================
            // BR
            STATE_EXEC_BR: begin
                if (br_taken) begin
                    alu_src_0_sel = `ALU_SRC_0_SEL_PC;
                    alu_src_1_sel = `ALU_SRC_1_SEL_SXT_9;
                    alu_fn        = `ALU_FN_ADD;

                    pc_src_sel    = `PC_SRC_SEL_ALU;
                    pc_ld         = 1'b1;
                end
            end

            // JMP / RET: PC <- BaseR
            STATE_EXEC_JMP: begin
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_8_6; // BaseR

                pc_src_sel = `PC_SRC_SEL_REG;
                pc_ld      = 1'b1;
            end

            // JSR: R7 <- PC+1; PC <- PC + SEXT(PCoffset11)
            STATE_EXEC_JSR: begin
                // Save return address
                rf_w_addr_sel   = `RF_W_ADDR_SEL_7_CN;
                rf_w_data_sel   = `RF_W_DATA_SEL_PC;
                rf_we           = 1'b1;

                // New PC
                alu_src_0_sel   = `ALU_SRC_0_SEL_PC;
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_11;
                alu_fn          = `ALU_FN_ADD;

                pc_src_sel      = `PC_SRC_SEL_ALU;
                pc_ld           = 1'b1;
            end

            // JSRR: R7 <- PC+1; PC <- BaseR
            STATE_EXEC_JSRR: begin
                // Save return address
                rf_w_addr_sel   = `RF_W_ADDR_SEL_7_CN;
                rf_w_data_sel   = `RF_W_DATA_SEL_PC;
                rf_we           = 1'b1;

                // BaseR is [8:6]
                rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_8_6;
                pc_src_sel      = `PC_SRC_SEL_REG;
                pc_ld           = 1'b1;
            end

            // LEA: DR <- PC + SEXT(PCoffset9)
            STATE_EXEC_LEA: begin
                alu_src_0_sel   = `ALU_SRC_0_SEL_PC;
                alu_src_1_sel   = `ALU_SRC_1_SEL_SXT_9;
                alu_fn          = `ALU_FN_ADD;

                rf_w_addr_sel   = `RF_W_ADDR_SEL_11_9;
                rf_w_data_sel   = `RF_W_DATA_SEL_ALU;
                rf_we           = 1'b1;

                status_src_sel  = `STATUS_SRC_SEL_ALU;
                status_we       = 1'b1;
            end

            //==============================================================
            // HALT (opcode 1111)
            //==============================================================
            STATE_HALT: begin
                // All enables remain 0. PC won't be updated, so PC freezes.
            end

            default: begin
                // keep defaults
            end
        endcase
    end

    //============================================================================
    // Next State Combinational Logic
    //============================================================================
    always @* begin
        next_state = state;

        case (state)
            STATE_FETCH:  next_state = STATE_DECODE;

            STATE_DECODE: begin
                if (is_ret)
                    next_state = STATE_EXEC_JMP; // RET treated as JMP R7
                else begin
                    case (opcode)
                        `OC_ADD: next_state = STATE_EXEC_ADD;
                        `OC_AND: next_state = STATE_EXEC_AND;
                        `OC_NOT: next_state = STATE_EXEC_NOT;

                        `OC_LD:  next_state = STATE_EXEC_LD;
                        `OC_LDR: next_state = STATE_EXEC_LDR;
                        `OC_LDI: next_state = STATE_EXEC_LDI_0;

                        `OC_ST:  next_state = STATE_EXEC_ST;
                        `OC_STR: next_state = STATE_EXEC_STR;
                        `OC_STI: next_state = STATE_EXEC_STI_0;

                        `OC_BR:  next_state = STATE_EXEC_BR;
                        `OC_JMP: next_state = STATE_EXEC_JMP;

                        `OC_JSR: next_state = is_jsr ? STATE_EXEC_JSR
                                                     : STATE_EXEC_JSRR;

                        `OC_LEA: next_state = STATE_EXEC_LEA;

                        `OC_HLT: next_state = STATE_HALT;

                        default: next_state = STATE_HALT; // illegal -> stop
                    endcase
                end
            end

            // Single-cycle exec -> back to FETCH
            STATE_EXEC_ADD,
            STATE_EXEC_AND,
            STATE_EXEC_NOT,
            STATE_EXEC_LD,
            STATE_EXEC_LDR,
            STATE_EXEC_ST,
            STATE_EXEC_STR,
            STATE_EXEC_BR,
            STATE_EXEC_JMP,
            STATE_EXEC_JSR,
            STATE_EXEC_JSRR,
            STATE_EXEC_LEA: begin
                next_state = STATE_FETCH;
            end

            // Multi-cycle
            STATE_EXEC_LDI_0: next_state = STATE_EXEC_LDI_1;
            STATE_EXEC_LDI_1: next_state = STATE_FETCH;

            STATE_EXEC_STI_0: next_state = STATE_EXEC_STI_1;
            STATE_EXEC_STI_1: next_state = STATE_FETCH;

            STATE_HALT: next_state = STATE_HALT;

            default:   next_state = STATE_FETCH;
        endcase
    end

    //============================================================================
    // State Update
    //============================================================================
    always @(posedge clk) begin
        if (rst) begin
            state <= STATE_FETCH;
        end else begin
            state <= next_state;
        end
    end

endmodule
