//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCDatapath(
    // External Inputs
    input  wire        clk,            // Clock
    input  wire        rst,            // Reset

    // DEBUG Signals (DO NOT MODIFY)
    input  wire [15:0] mem_debug_addr,
    input  wire [2:0]  rf_debug_addr,
    output wire [15:0] mem_debug_data,
    output wire [15:0] rf_debug_data,
    output wire [15:0] pc_debug_data,

    //======================================================================
    // Control signals from Control Unit
    //======================================================================

    // Memory controls
    input  wire [1:0]  mem_r_addr_sel, // `MEM_R_ADDR_SEL_*`
    input  wire        mem_w_addr_sel, // `MEM_W_ADDR_SEL_*`
    input  wire        mem_write_en,   // memory write enable

    // Register file controls
    input  wire        rf_r_addr_0_sel, // `RF_R_ADDR_0_SEL_*`
    input  wire        rf_r_addr_1_sel, // `RF_R_ADDR_1_SEL_*`
    input  wire        rf_w_addr_sel,   // `RF_W_ADDR_SEL_*`
    input  wire [1:0]  rf_w_data_sel,   // `RF_W_DATA_SEL_*`
    input  wire        rf_we,           // regfile write enable

    // Status (NZP) register controls
    input  wire        status_src_sel,  // `STATUS_SRC_SEL_*`
    input  wire        status_we,       // NZP write enable

    // Instruction Register control
    input  wire        ir_ld,           // IR load enable

    // Program Counter controls
    input  wire [1:0]  pc_src_sel,      // `PC_SRC_SEL_*`
    input  wire        pc_ld,           // PC load enable

    // ALU controls
    input  wire [1:0]  alu_src_0_sel,   // `ALU_SRC_0_SEL_*`
    input  wire [2:0]  alu_src_1_sel,   // `ALU_SRC_1_SEL_*`
    input  wire [1:0]  alu_fn,          // `ALU_FN_*`

    // Indirect-address register (for LDI / STI)
    input  wire        ind_addr_ld,     // load indirect address register

    //======================================================================
    // Outputs back to Control Unit
    //======================================================================

    output wire [15:0] ir_out,          // current instruction
    output wire        n_flag,          // condition codes
    output wire        z_flag,
    output wire        p_flag
);

    //==========================================================================
    // Architectural registers
    //==========================================================================

    reg [15:0] pc;              // program counter
    reg [15:0] ir;              // instruction register

    // Condition codes
    reg n_reg, z_reg, p_reg;

    // Indirect-address register used by LDI / STI
    reg [15:0] ind_addr;

    // Assign PC debug net
    assign pc_debug_data = pc;

    // Export IR and NZP to controller
    assign ir_out = ir;
    assign n_flag = n_reg;
    assign z_flag = z_reg;
    assign p_flag = p_reg;

    //==========================================================================
    // Sign-extended immediates / offsets (LC-3 style)
    //==========================================================================

    wire [15:0] imm5       = {{11{ir[4]}},  ir[4:0]};    // bits [4:0]
    wire [15:0] offset6    = {{10{ir[5]}},  ir[5:0]};    // bits [5:0]
    wire [15:0] pcoffset9  = {{7{ir[8]}},   ir[8:0]};    // bits [8:0]
    wire [15:0] pcoffset11 = {{5{ir[10]}},  ir[10:0]};   // bits [10:0]

    //==========================================================================
    // Register File
    //==========================================================================

    wire [2:0] rf_r_addr_0 =
        (rf_r_addr_0_sel == `RF_R_ADDR_0_SEL_8_6)  ? ir[8:6]  : ir[11:9];

    wire [2:0] rf_r_addr_1 =
        (rf_r_addr_1_sel == `RF_R_ADDR_1_SEL_2_0)  ? ir[2:0]  : ir[8:6];

    wire [2:0] rf_w_addr   =
        (rf_w_addr_sel   == `RF_W_ADDR_SEL_11_9)   ? ir[11:9] : 3'b111; // R7

    wire [15:0] rf_r_data_0;
    wire [15:0] rf_r_data_1;
    wire [15:0] rf_w_data;

    // 8-entry 16-bit register file
    RegisterFile rfile(
        .clk      (clk),
        .rst      (rst),
        .r_addr_0 (rf_r_addr_0),
        .r_addr_1 (rf_r_addr_1),
        .r_addr_2 (rf_debug_addr),
        .w_addr   (rf_w_addr),
        .w_data   (rf_w_data),
        .w_en     (rf_we),
        .r_data_0 (rf_r_data_0),
        .r_data_1 (rf_r_data_1),
        .r_data_2 (rf_debug_data)
    );

    //==========================================================================
    // ALU
    //==========================================================================

    // ALU input 0
    wire [15:0] alu_in0 =
        (alu_src_0_sel == `ALU_SRC_0_SEL_REG_0) ? rf_r_data_0 :
        (alu_src_0_sel == `ALU_SRC_0_SEL_REG_1) ? rf_r_data_1 :
                                                  pc; // `ALU_SRC_0_SEL_PC`

    // ALU input 1
    wire [15:0] alu_in1 =
        (alu_src_1_sel == `ALU_SRC_1_SEL_REG_1)  ? rf_r_data_1 :
        (alu_src_1_sel == `ALU_SRC_1_SEL_SXT_5)  ? imm5       :
        (alu_src_1_sel == `ALU_SRC_1_SEL_SXT_6)  ? offset6    :
        (alu_src_1_sel == `ALU_SRC_1_SEL_SXT_9)  ? pcoffset9  :
                                                   pcoffset11; // SXT_11

    // ALU function
    wire [15:0] alu_result =
        (alu_fn == `ALU_FN_ADD) ? (alu_in0 + alu_in1) :
        (alu_fn == `ALU_FN_AND) ? (alu_in0 & alu_in1) :
                                  ~alu_in0; // `ALU_FN_NOT`

    //==========================================================================
    // Memory
    //==========================================================================

    wire [15:0] mem_r_addr =
        (mem_r_addr_sel == `MEM_R_ADDR_SEL_PC)  ? pc         :
        (mem_r_addr_sel == `MEM_R_ADDR_SEL_ALU) ? alu_result :
                                                  ind_addr;  // `MEM_R_ADDR_SEL_IND`

    wire [15:0] mem_w_addr =
        (mem_w_addr_sel == `MEM_W_ADDR_SEL_ALU) ? alu_result :
                                                  ind_addr;  // `MEM_W_ADDR_SEL_IND`

    wire [15:0] mem_w_data = rf_r_data_0;  // stores write SR
    wire [15:0] mem_r_data;

    // 128-entry 16-bit memory (two read ports, one write port)
    Memory mem(
        .clk      (clk),
        .rst      (rst),
        .r_addr_0 (mem_r_addr),
        .r_addr_1 (mem_debug_addr),
        .w_addr   (mem_w_addr),
        .w_data   (mem_w_data),
        .w_en     (mem_write_en),
        .r_data_0 (mem_r_data),
        .r_data_1 (mem_debug_data)
    );

    //==========================================================================
    // RF write-data MUX
    //==========================================================================

    assign rf_w_data =
        (rf_w_data_sel == `RF_W_DATA_SEL_ALU) ? alu_result :
        (rf_w_data_sel == `RF_W_DATA_SEL_PC)  ? pc         :
                                                mem_r_data; // MEM

    //==========================================================================
    // Program Counter update
    //==========================================================================

    wire [15:0] pc_plus1 = pc + 16'd1;

    wire [15:0] pc_next =
        (pc_src_sel == `PC_SRC_SEL_REG) ? rf_r_data_0 :
        (pc_src_sel == `PC_SRC_SEL_INC) ? pc_plus1    :
                                          alu_result; // `PC_SRC_SEL_ALU`

    //==========================================================================
    // Status (NZP) update
    //==========================================================================

    wire [15:0] status_val =
        (status_src_sel == `STATUS_SRC_SEL_ALU) ? alu_result : mem_r_data;

    //==========================================================================
    // Sequential logic: PC, IR, NZP, indirect address
    //==========================================================================

    always @(posedge clk) begin
        if (rst) begin
            pc       <= 16'd0;
            ir       <= 16'd0;
            ind_addr <= 16'd0;

            n_reg    <= 1'b0;
            z_reg    <= 1'b0;
            p_reg    <= 1'b0;
        end
        else begin
            // PC
            if (pc_ld) begin
                pc <= pc_next;
            end

            // IR
            if (ir_ld) begin
                ir <= mem_r_data;
            end

            // indirect address register
            if (ind_addr_ld) begin
                ind_addr <= mem_r_data;
            end

            // NZP
            if (status_we) begin
                if (status_val == 16'd0) begin
                    n_reg <= 1'b0;
                    z_reg <= 1'b1;
                    p_reg <= 1'b0;
                end
                else if (status_val[15]) begin
                    n_reg <= 1'b1;
                    z_reg <= 1'b0;
                    p_reg <= 1'b0;
                end
                else begin
                    n_reg <= 1'b0;
                    z_reg <= 1'b0;
                    p_reg <= 1'b1;
                end
            end
        end
    end

endmodule

