//==============================================================================
// Top-Level Module for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnC(
    // External Inputs
    input  wire        clk,            // Clock
    input  wire        rst,            // Reset

    // Debug Signals
    input  wire [15:0] mem_debug_addr,
    input  wire [2:0]  rf_debug_addr,
    output wire [15:0] mem_debug_data,
    output wire [15:0] rf_debug_data,
    output wire [15:0] pc_debug_data
);

    //======================================================================
    // Interconnect Wires: Datapath <-> Control Unit
    //======================================================================

    // From datapath to control
    wire [15:0] ir;
    wire        n_flag;
    wire        z_flag;
    wire        p_flag;

    // From control to datapath: memory
    wire [1:0]  mem_r_addr_sel;
    wire        mem_w_addr_sel;
    wire        mem_write_en;

    // Register file controls
    wire        rf_r_addr_0_sel;
    wire        rf_r_addr_1_sel;
    wire        rf_w_addr_sel;
    wire [1:0]  rf_w_data_sel;
    wire        rf_we;

    // NZP status
    wire        status_src_sel;
    wire        status_we;

    // IR
    wire        ir_ld;

    // PC
    wire [1:0]  pc_src_sel;
    wire        pc_ld;

    // ALU
    wire [1:0]  alu_src_0_sel;
    wire [2:0]  alu_src_1_sel;
    wire [1:0]  alu_fn;

    // Indirect register load
    wire        ind_addr_ld;

    //======================================================================
    // CONTROL UNIT
    //======================================================================

    PUnCControl ctrl(
        .clk             (clk),
        .rst             (rst),

        // From datapath
        .ir              (ir),
        .n_flag          (n_flag),
        .z_flag          (z_flag),
        .p_flag          (p_flag),

        // Memory controls
        .mem_r_addr_sel  (mem_r_addr_sel),
        .mem_w_addr_sel  (mem_w_addr_sel),
        .mem_write_en    (mem_write_en),

        // Register file controls
        .rf_r_addr_0_sel (rf_r_addr_0_sel),
        .rf_r_addr_1_sel (rf_r_addr_1_sel),
        .rf_w_addr_sel   (rf_w_addr_sel),
        .rf_w_data_sel   (rf_w_data_sel),
        .rf_we           (rf_we),

        // NZP
        .status_src_sel  (status_src_sel),
        .status_we       (status_we),

        // IR
        .ir_ld           (ir_ld),

        // PC
        .pc_src_sel      (pc_src_sel),
        .pc_ld           (pc_ld),

        // ALU
        .alu_src_0_sel   (alu_src_0_sel),
        .alu_src_1_sel   (alu_src_1_sel),
        .alu_fn          (alu_fn),

        // Indirect address
        .ind_addr_ld     (ind_addr_ld)
    );

    //======================================================================
    // DATAPATH
    //======================================================================

    PUnCDatapath dpath(
        .clk             (clk),
        .rst             (rst),

        // Debug signals
        .mem_debug_addr  (mem_debug_addr),
        .rf_debug_addr   (rf_debug_addr),
        .mem_debug_data  (mem_debug_data),
        .rf_debug_data   (rf_debug_data),
        .pc_debug_data   (pc_debug_data),

        // Memory interface
        .mem_r_addr_sel  (mem_r_addr_sel),
        .mem_w_addr_sel  (mem_w_addr_sel),
        .mem_write_en    (mem_write_en),

        // Register file interface
        .rf_r_addr_0_sel (rf_r_addr_0_sel),
        .rf_r_addr_1_sel (rf_r_addr_1_sel),
        .rf_w_addr_sel   (rf_w_addr_sel),
        .rf_w_data_sel   (rf_w_data_sel),
        .rf_we           (rf_we),

        // NZP
        .status_src_sel  (status_src_sel),
        .status_we       (status_we),

        // IR
        .ir_ld           (ir_ld),

        // PC
        .pc_src_sel      (pc_src_sel),
        .pc_ld           (pc_ld),

        // ALU
        .alu_src_0_sel   (alu_src_0_sel),
        .alu_src_1_sel   (alu_src_1_sel),
        .alu_fn          (alu_fn),

        // Indirect address
        .ind_addr_ld     (ind_addr_ld),

        // Datapath outputs
        .ir_out          (ir),
        .n_flag          (n_flag),
        .z_flag          (z_flag),
        .p_flag          (p_flag)
    );

endmodule
