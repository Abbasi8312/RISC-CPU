// Datapath module: Handles the data flow between registers, memory and the ALU
module datapath (
    output [3:0] instruction,  // Output instruction opcode
    output [14:0] memory_in,   // Output connections to memory
    input [7:0] memory_out,    // Input connections from memory
    input [23:0] reg_mem_ctrl, // Control signals for registers and memory
    input [2:0] bus_ctrl,      // Control signals for the bus
    input clk                  // Clock signal
);
    wire [7:0] bus_out;        // Output of the common bus
    wire [7:0] bus_in [0:7];   // Array of bus inputs

    // Extract instruction opcode from IR register (bus_in[5])
    assign instruction = bus_in[5][7:4];

    // Assign memory output to bus input
    assign bus_in[7] = memory_out;
    // Assign memory inputs: data (from bus), address (ar), mem_ctrl
    assign memory_in = {bus_out, bus_in[1][3:0], reg_mem_ctrl[23:21]};

    // Instantiate registers and connect them to the bus
    reg_4bit_lic ar (
        .data_out(bus_in[1]),
        .data_in(bus_out),
        .ctrl(reg_mem_ctrl[5:3]),
        .clk(clk)
    );
    reg_4bit_lic pc (
        .data_out(bus_in[2]),
        .data_in(bus_out),
        .ctrl(reg_mem_ctrl[8:6]),
        .clk(clk)
    );
    reg_8bit_lic dr (
        .data_out(bus_in[3]),
        .data_in(bus_out),
        .ctrl(reg_mem_ctrl[11:9]),
        .clk(clk)
    );

    wire [7:0] ac_in;
    reg_8bit_lic ac (
        .data_out(bus_in[4]),
        .data_in(ac_in),
        .ctrl(reg_mem_ctrl[14:12]),
        .clk(clk)
    );

    reg_8bit_l ir (
        .data_out(bus_in[5]),
        .data_in(bus_out),
        .ctrl(reg_mem_ctrl[17:15]),
        .clk(clk)
    );
    reg_8bit_lic tr (
        .data_out(bus_in[6]),
        .data_in(bus_out),
        .ctrl(reg_mem_ctrl[20:18]),
        .clk(clk)
    );

    // ALU instance
    arithmetic_logic_unit alu (
        .result(ac_in),
        .operand(bus_in[3]),
        .reg_value(bus_in[4]),
        .opcode(instruction[2:0])
    );

    // Common bus instance
    bus_8bit common_bus (
        .data_out(bus_out),
        .data_in({bus_in[7], bus_in[6], bus_in[5], bus_in[4], bus_in[3], bus_in[2], bus_in[1], bus_in[0]}),
        .ctrl(bus_ctrl)
    );

endmodule

// 4-bit register with load, increment, and clear
module reg_4bit_lic (
    output [3:0] data_out, // Output data
    input [3:0] data_in,   // Input data
    input [2:0] ctrl,      // Control signals: [load, increment, clear]
    input clk              // Clock signal
);
    reg [3:0] data;
    initial data = 0;

    always @(posedge clk) begin
        if (ctrl[0]) data <= data_in;  // Load data
        if (ctrl[1]) data <= data + 1; // Increment data
        if (ctrl[2]) data <= 0;        // Clear data
    end

    assign data_out = data;
endmodule

// 8-bit register with load, increment, and clear
module reg_8bit_lic (
    output [7:0] data_out, // Output data
    input [7:0] data_in,   // Input data
    input [2:0] ctrl,      // Control signals: [load, increment, clear]
    input clk              // Clock signal
);
    reg [7:0] data;
    initial data = 0;

    always @(posedge clk) begin
        if (ctrl[0]) data <= data_in;  // Load data
        if (ctrl[1]) data <= data + 1; // Increment data
        if (ctrl[2]) data <= 0;        // Clear data
    end

    assign data_out = data;
endmodule

// 8-bit register with load
module reg_8bit_l (
    output [7:0] data_out, // Output data
    input [7:0] data_in,   // Input data
    input [2:0] ctrl,      // Control signal: [load]
    input clk              // Clock signal
);
    reg [7:0] data;
    initial data = 0;

    always @(posedge clk) begin
        if (ctrl[0]) data <= data_in;  // Load data
    end

    assign data_out = data;
endmodule

// 8-bit wide bus with 8 channels of input data
module bus_8bit (
    output reg [7:0] data_out, // Output data
    input [63:0] data_in,      // Input data from 8 channels
    input [2:0] ctrl           // Control signals to select the input channel
);
    always @(*) begin
        case (ctrl)
            3'b000: data_out = data_in[7:0];      // Select channel 0
            3'b001: data_out = data_in[15:8];     // Select channel 1
            3'b010: data_out = data_in[23:16];    // Select channel 2
            3'b011: data_out = data_in[31:24];    // Select channel 3
            3'b100: data_out = data_in[39:32];    // Select channel 4
            3'b101: data_out = data_in[47:40];    // Select channel 5
            3'b110: data_out = data_in[55:48];    // Select channel 6
            3'b111: data_out = data_in[63:56];    // Select channel 7
            default: data_out = 8'b00000000;      // Default case
        endcase
    end
endmodule

// Arithmetic Logic Unit (ALU)
module arithmetic_logic_unit (
    output reg [7:0] result,   // Result of the ALU operation
    input [7:0] operand,       // Operand input
    input [7:0] reg_value,     // Register value input
    input [2:0] opcode         // Opcode to determine the operation
);
    always @(*) begin
        case (opcode)
            3'b000: result = operand + reg_value;        // Add
            3'b001: result = operand <<< 1;              // Arithmetic Shift Left
            3'b010: result = ~(operand ^ reg_value);     // XNOR
            3'b011: result = $signed(operand) >>> 1;     // Divide by 2
            3'b100: result = operand;                    // Load
            3'b101: result = reg_value;                  // Store
            3'b110: result = ~operand + 1;               // 2's Complement (Negate)
            default: result = 8'b00000000;               // Default case
        endcase
    end
endmodule
