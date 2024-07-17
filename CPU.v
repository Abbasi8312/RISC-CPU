// Central Processing Unit: Integrates the control unit and datapath to execute instructions
module central_processing_unit (
    input [7:0] memory_out,    // Memory output connections
    output [14:0] memory_in,   // Memory input connections
    input clk                  // Clock signal
);
    wire [23:0] reg_mem_ctrl;  // Control signals for registers and memory
    wire [2:0] bus_ctrl;       // Control signals for the bus
    wire [3:0] instruction;    // Current instruction opcode

    // Control Unit instance
    control_unit cu (
        .reg_mem_ctrl(reg_mem_ctrl),
        .bus_ctrl(bus_ctrl),
        .instruction(instruction),
        .clk(clk)
    );

    // Datapath instance
    datapath dp (
        .instruction(instruction),
        .memory_in(memory_in),
        .memory_out(memory_out),
        .reg_mem_ctrl(reg_mem_ctrl),
        .bus_ctrl(bus_ctrl),
        .clk(clk)
    );

endmodule
